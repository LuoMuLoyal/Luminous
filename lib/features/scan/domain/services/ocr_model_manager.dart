import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:path_provider/path_provider.dart';

import 'ocr_model_hashes.dart';

/// Minimal downloader abstraction used by [OcrModelManager].
///
/// Keeps the manager testable without a real network: production uses
/// [Dio], tests inject a fake.
abstract interface class OcrModelDownloader {
  /// Downloads [urlPath] to [savePath], reporting progress when the total
  /// content length is known.
  Future<void> download(
    String urlPath,
    String savePath, {
    void Function(int received, int total)? onReceiveProgress,
  });
}

/// Dio-backed [OcrModelDownloader].
class DioOcrModelDownloader implements OcrModelDownloader {
  DioOcrModelDownloader([Dio? dio]) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<void> download(
    String urlPath,
    String savePath, {
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    await _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

/// Thrown when a downloaded OCR model file fails its SHA-256 integrity check.
///
/// This is a supply-chain guard: the ONNX models are executed by the native
/// OCR engine, so files that do not match the pinned digest must never be
/// loaded. The caller should surface a retryable error UI.
class OcrModelIntegrityException implements Exception {
  const OcrModelIntegrityException(this.fileName, this.expected, this.actual);

  final String fileName;
  final String expected;
  final String actual;

  @override
  String toString() =>
      'OCR model integrity check failed for $fileName: '
      'expected sha256 $expected, got $actual';
}

/// Strategy for verifying a downloaded model file's digest.
///
/// Extracted from [OcrModelManager] so tests can inject a fake verifier and
/// exercise both the accept and reject paths without 30 MB downloads.
typedef OcrModelVerifier = Future<String> Function(File file);

/// Default verifier: SHA-256 of the file contents.
Future<String> _sha256OfFile(File file) async {
  // Collect the final digest via the accumulator pattern: crypto 3.x
  // `startChunkedConversion` requires an output `Sink<Digest>`; we feed it
  // into an accumulator that captures the digest produced on close.
  final output = _DigestAccumulator();
  final chunked = sha256.startChunkedConversion(output);
  await for (final chunk in file.openRead()) {
    chunked.add(chunk);
  }
  chunked.close();
  return output.digest!.toString();
}

/// Accumulates the single [Digest] produced by a chunked hash conversion.
class _DigestAccumulator implements Sink<Digest> {
  Digest? digest;

  @override
  void add(Digest data) {
    digest = data;
  }

  @override
  void close() {}
}

/// Manages the on-demand download and storage of PaddleOCR ONNX model files.
///
/// The model files (~30MB total) are not bundled in the APK to reduce app
/// size. They are downloaded on first use and cached in the app's persistent
/// storage directory. Every downloaded file is verified against its pinned
/// SHA-256 digest ([ocr_model_hashes.dart]) before it is kept.
class OcrModelManager {
  OcrModelManager._(this._downloader, this._appDir, this._verifier);

  /// Creates an instance with an injected [verifier] for tests; production
  /// code should use [create] (real SHA-256 verification).
  @visibleForTesting
  factory OcrModelManager.forTesting(
    OcrModelDownloader downloader,
    Directory appDir, {
    OcrModelVerifier verifier = _sha256OfFile,
  }) {
    return OcrModelManager._(downloader, appDir, verifier);
  }

  final OcrModelDownloader _downloader;
  final Directory _appDir;
  final OcrModelVerifier _verifier;

  static const _modelDirName = 'paddle_ocr_models';

  // Model file names within the model directory.
  static const detModelFileName = 'det_inference.onnx';
  static const recModelFileName = 'rec_inference.onnx';
  static const recConfigFileName = 'rec_inference.yml';

  // GitHub download URLs for the ONNX model files.
  // Decision: the model files live in the `v0.1.1` git tag of the upstream
  // repo (raw.githubusercontent). The upstream `v0.1.1-models` GitHub *release*
  // does not exist (404), so the release download endpoint cannot be used.
  // The pinned SHA-256 digests in ocr_model_hashes.dart (matching
  // pkgs/paddle_ocr_native-0.1.1/doc/model-provenance.md) verify the exact
  // bytes, so a tampered or replaced upstream file fails closed.
  static const _modelBaseUrl =
      'https://raw.githubusercontent.com/flespark/paddle_ocr_native/v0.1.1/assets/models';

  /// Approximate total download size in MB, shown to the user before download.
  static const downloadSizeMB = 30;

  /// Checks whether all required model files exist locally.
  bool isModelAvailable() {
    final dir = modelDirectory;
    return File('${dir.path}/$detModelFileName').existsSync() &&
        File('${dir.path}/$recModelFileName').existsSync() &&
        File('${dir.path}/$recConfigFileName').existsSync();
  }

  /// Returns the directory where model files are stored.
  Directory get modelDirectory {
    final dir = Directory('${_appDir.path}/$_modelDirName');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  /// Downloads all model files if not already present.
  ///
  /// [onProgress] receives a 0.0–1.0 progress value.
  ///
  /// Throws on network or file system errors, and on
  /// [OcrModelIntegrityException] when a downloaded file does not match its
  /// pinned SHA-256 digest (the offending file is deleted so a stale copy can
  /// never be reused).
  Future<void> downloadModels({
    void Function(double progress)? onProgress,
  }) async {
    final dir = modelDirectory;

    final downloads = <String>[detModelFileName, recModelFileName];
    // +1 for the config copy step that follows the download loop
    // (当前为 det + rec 两个下载 + 1 次 config 拷贝;新增下载项时
    // totalSteps 随 downloads.length 自动增长,只有拷贝步数是常数)。
    final totalSteps = downloads.length + 1;

    var completed = 0;
    for (final fileName in downloads) {
      final targetPath = '${dir.path}/$fileName';
      final file = File(targetPath);

      if (file.existsSync() && file.lengthSync() > 0) {
        completed++;
        onProgress?.call(completed / totalSteps);
        continue;
      }

      final url = '$_modelBaseUrl/$fileName';
      appTalker.info('Downloading OCR model: $url → $targetPath');

      try {
        await _downloader.download(
          url,
          targetPath,
          onReceiveProgress: (received, total) {
            if (total > 0) {
              final fileProgress = received / total;
              final overallProgress = (completed + fileProgress) / totalSteps;
              onProgress?.call(overallProgress);
            }
          },
        );

        await _verifyOrDelete(file, fileName);
      } catch (e) {
        // A failed download may leave a partial file behind, and the
        // "already downloaded" check above only looks at length > 0 — so
        // without this cleanup the next run would treat the truncated file
        // as complete and hand it to the OCR engine.
        await _deleteQuietly(file, reason: 'incomplete download of $fileName');
        rethrow;
      }
      completed++;
      onProgress?.call(completed / totalSteps);
    }

    // Copy the rec config yml from plugin assets to the model directory.
    final configPath = '${dir.path}/$recConfigFileName';
    final configFile = File(configPath);
    try {
      if (!configFile.existsSync()) {
        const assetKey =
            'packages/paddle_ocr_native/assets/models/rec/inference.yml';
        final data = await rootBundle.load(assetKey);
        await configFile.writeAsBytes(data.buffer.asUint8List());
      }
      // Verify the config copy (whether freshly written or pre-existing) so a
      // tampered config never reaches the OCR engine.
      await _verifyOrDelete(
        configFile,
        recConfigFileName,
        expected: recConfigSha256,
      );
      // Signal 100% after the config copy (the final step) has succeeded.
      // If config already exists, the model set is still complete, so 1.0
      // is appropriate.
      onProgress?.call(1.0);
    } catch (e, st) {
      if (e is OcrModelIntegrityException) rethrow;
      // Progress stays at 2/3 on failure; the caller's catch block handles
      // the error UI. Re-throw so the caller can show the failure dialog.
      appTalker.error('OCR config copy failed', e, st);
      rethrow;
    }

    appTalker.info('OCR model download complete');
  }

  /// Verifies [file] against the expected digest for [fileName]; on mismatch
  /// the file is deleted and [OcrModelIntegrityException] is thrown.
  Future<void> _verifyOrDelete(
    File file,
    String fileName, {
    String? expected,
  }) async {
    final expectedDigest = expected ?? _expectedSha256(fileName);
    final actual = await _verifier(file);
    if (actual != expectedDigest) {
      appTalker.error(
        'OCR model integrity check failed for $fileName: '
        'expected $expectedDigest, got $actual — deleting file',
      );
      // Never keep a tampered/incomplete file for a later run to load.
      await _deleteQuietly(file, reason: 'integrity check failed');
      throw OcrModelIntegrityException(fileName, expectedDigest, actual);
    }
  }

  /// Deletes [file] if it exists, logging (rather than throwing) when the
  /// delete itself fails. Cleanup runs on an error path, so a delete failure
  /// must never mask the original error — but leaving a stale file behind is
  /// worth knowing about, since the next run may load it.
  Future<void> _deleteQuietly(File file, {required String reason}) async {
    if (!file.existsSync()) return;
    try {
      await file.delete();
      appTalker.warning('OCR model: deleted $file ($reason)');
    } catch (e) {
      appTalker.error('OCR model: failed to delete $file ($reason)', e);
    }
  }

  /// Deletes all cached model files.
  Future<void> deleteModels() async {
    final dir = modelDirectory;
    if (dir.existsSync()) {
      await dir.delete(recursive: true);
    }
  }

  /// Returns the absolute file paths for all three model files.
  ///
  /// Callers should verify [isModelAvailable] before using these paths.
  ({String detPath, String recPath, String configPath}) get modelPaths {
    final dir = modelDirectory;
    return (
      detPath: '${dir.path}/$detModelFileName',
      recPath: '${dir.path}/$recModelFileName',
      configPath: '${dir.path}/$recConfigFileName',
    );
  }

  static String _expectedSha256(String fileName) {
    return switch (fileName) {
      detModelFileName => detModelSha256,
      recModelFileName => recModelSha256,
      _ => throw ArgumentError('Unknown OCR model file: $fileName'),
    };
  }

  static Future<OcrModelManager> create() async {
    final appDir = await getApplicationSupportDirectory();
    return OcrModelManager._(DioOcrModelDownloader(), appDir, _sha256OfFile);
  }
}

/// Riverpod provider for [OcrModelManager].
final ocrModelManagerProvider = FutureProvider<OcrModelManager>((ref) async {
  return OcrModelManager.create();
});
