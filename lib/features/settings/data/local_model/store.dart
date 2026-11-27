import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:luminous/core/network/app_log.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/local_model/catalog.dart';

/// Why a model could not be made available.
enum LocalModelFailure {
  /// The download failed: no network, or the host refused.
  downloadFailed,

  /// The bytes served did not match the pinned digest. The file is deleted, so a
  /// later run cannot load a tampered or truncated model.
  integrityMismatch,

  /// The file system refused to store the model — usually out of space.
  storageFailed,
}

/// A failure with a stable [reason] and a diagnostic [message].
final class LocalModelException implements Exception {
  const LocalModelException(this.reason, this.message, [this.cause]);

  final LocalModelFailure reason;
  final String message;
  final Object? cause;

  @override
  String toString() => 'LocalModelException(${reason.name}): $message';
}

/// Stores on-device models on disk, verifying them on the way in.
///
/// ## Why verification is not optional
///
/// The model file is executed as trusted weights: a substituted GGUF can change
/// what the assistant says. The digest check is the only thing standing between
/// "download" and "run arbitrary third-party weights", so a mismatch deletes the
/// file rather than warning and continuing.
///
/// ## Why partial downloads are deleted
///
/// A presence check based on file length would accept a truncated download on the
/// next launch and hand it to the loader, which fails deep inside llama.cpp with
/// an opaque message. Deleting on any failure keeps "the file exists" equivalent
/// to "the file is complete and verified".
class ModelStore {
  ModelStore._(this._downloader, this._appDir, this._digestOf);

  @visibleForTesting
  factory ModelStore.forTesting(
    Future<void> Function(
      String urlPath,
      String savePath, {
      void Function(int received, int total)? onReceiveProgress,
    })
    downloader,
    Directory appDir, {
    Future<String> Function(File file) digestOf = _sha256OfFile,
  }) {
    return ModelStore._(downloader, appDir, digestOf);
  }

  final Future<void> Function(
    String urlPath,
    String savePath, {
    void Function(int received, int total)? onReceiveProgress,
  })
  _downloader;

  final Directory _appDir;
  final Future<String> Function(File file) _digestOf;

  static const _directoryName = 'local_models';

  static Future<ModelStore> create() async {
    final appDir = await getApplicationSupportDirectory();
    final dio = Dio();
    return ModelStore._(
      (urlPath, savePath, {onReceiveProgress}) =>
          dio.download(urlPath, savePath, onReceiveProgress: onReceiveProgress),
      appDir,
      _sha256OfFile,
    );
  }

  /// Where models live.
  Directory get directory {
    final dir = Directory('${_appDir.path}/$_directoryName');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// The path a model occupies once available.
  String pathOf(LocalModel model) => '${directory.path}/${model.fileName}';

  /// Whether [model] is present **and** was verified when it was written.
  ///
  /// No re-hash here: hashing gigabytes on every launch would stall startup, so
  /// the guarantee rests on the digest check at write time plus deleting on any
  /// failure.
  bool isAvailable(LocalModel model) {
    final file = File(pathOf(model));
    return file.existsSync() && file.lengthSync() == model.sizeBytes;
  }

  /// Downloads and verifies [model], reporting 0.0–1.0 progress.
  ///
  /// Skips the download when the file is already present and the right size.
  /// Throws [LocalModelException] on any failure, having deleted whatever partial
  /// file was written.
  Future<void> ensure(
    LocalModel model, {
    void Function(double progress)? onProgress,
  }) async {
    if (isAvailable(model)) {
      onProgress?.call(1);
      return;
    }

    final target = File(pathOf(model));
    try {
      await _downloader(
        model.downloadUrl,
        target.path,
        onReceiveProgress: (received, total) {
          // Fall back to the pinned size when the host omits Content-Length:
          // a progress bar that never moves is indistinguishable from a hang.
          final denominator = total > 0 ? total : model.sizeBytes;
          if (denominator > 0) {
            onProgress?.call((received / denominator).clamp(0.0, 1.0));
          }
        },
      );
    } on Object catch (error) {
      await _deleteQuietly(target);
      throw LocalModelException(
        LocalModelFailure.downloadFailed,
        'could not download ${model.name}',
        error,
      );
    }

    final actual = await _digestOf(target);
    if (actual != model.sha256) {
      await _deleteQuietly(target);
      appLog.error(
        'local model integrity check failed for ${model.id}: '
        'expected ${model.sha256}, got $actual',
      );
      throw LocalModelException(
        LocalModelFailure.integrityMismatch,
        '${model.name} failed verification',
      );
    }

    onProgress?.call(1);
  }

  /// Deletes [model] from disk.
  Future<void> remove(LocalModel model) => _deleteQuietly(File(pathOf(model)));

  Future<void> _deleteQuietly(File file) async {
    if (!file.existsSync()) return;
    try {
      await file.delete();
    } on Object catch (error) {
      // Cleanup runs on an error path; a failed delete must not mask the original
      // failure, but leaving a stale file is worth a log because the next run may
      // load it.
      appLog.warning('local model: failed to delete ${file.path}: $error');
    }
  }
}

/// SHA-256 of [file], streamed so a multi-gigabyte model does not sit in memory.
Future<String> _sha256OfFile(File file) async {
  final digest = await sha256.bind(file.openRead()).first;
  return digest.toString();
}
