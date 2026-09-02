import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:path_provider/path_provider.dart';

/// Manages the on-demand download and storage of PaddleOCR ONNX model files.
///
/// The model files (~30MB total) are not bundled in the APK to reduce app
/// size. They are downloaded on first use and cached in the app's persistent
/// storage directory.
class OcrModelManager {
  OcrModelManager._(this._dio, this._appDir);

  final Dio _dio;
  final Directory _appDir;

  static const _modelDirName = 'paddle_ocr_models';

  // Model file names within the model directory.
  static const detModelFileName = 'det_inference.onnx';
  static const recModelFileName = 'rec_inference.onnx';
  static const recConfigFileName = 'rec_inference.yml';

  // GitHub release download URLs for the ONNX model files.
  // Decision: GitHub Releases is the permanent model distribution channel for
  // this plugin. The repo is public, the release tag is pinned, and the total
  // download size (~30MB) is small enough that GitHub's rate limits are not a
  // concern for first-scan traffic. No CDN migration is planned.
  static const _modelBaseUrl =
      'https://github.com/flespark/paddle_ocr_native/releases/download/v0.1.1-models';

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
  /// Throws on network or file system errors.
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

      await _dio.download(
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
      // Signal 100% after the config copy (the final step) has succeeded.
      // If config already exists, the model set is still complete, so 1.0
      // is appropriate.
      onProgress?.call(1.0);
    } catch (e, st) {
      // Progress stays at 2/3 on failure; the caller's catch block handles
      // the error UI. Re-throw so the caller can show the failure dialog.
      appTalker.error('OCR config copy failed', e, st);
      rethrow;
    }

    appTalker.info('OCR model download complete');
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

  static Future<OcrModelManager> create() async {
    final appDir = await getApplicationSupportDirectory();
    return OcrModelManager._(Dio(), appDir);
  }
}

/// Riverpod provider for [OcrModelManager].
final ocrModelManagerProvider = FutureProvider<OcrModelManager>((ref) async {
  return OcrModelManager.create();
});
