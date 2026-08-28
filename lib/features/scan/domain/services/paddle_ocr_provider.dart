import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/domain/services/ocr_model_manager.dart';
import 'package:paddle_ocr_native/paddle_ocr_native.dart';

/// Thin wrapper over [PaddleOcr] that converts results to domain types.
///
/// [PaddleOcr] is already a process-wide singleton with internal init/dispose
/// management and serialized calls. This wrapper adds:
/// - Lazy initialization on first [recognize] call
/// - Model path resolution via [OcrModelManager]
/// - Conversion from plugin types ([OcrResult] / [OcrPoint]) to domain
///   [OcrTextBlock], enabling unit testing of the extraction logic without
///   the native plugin.
class PaddleOcrEngine {
  PaddleOcrEngine(this._modelManager);

  final OcrModelManager _modelManager;
  final _ocr = PaddleOcr();
  bool _initialized = false;

  /// Pre-initialise the ONNX Runtime sessions.
  ///
  /// Call this before entering the OCR scan flow to detect early whether
  /// the device supports the required native libraries (e.g. arm64-v8a ABI)
  /// and whether the model files are available locally.
  ///
  /// Throws if models are not downloaded or if native init fails.
  Future<void> ensureInitialized() async {
    if (_initialized) return;

    if (!_modelManager.isModelAvailable()) {
      throw const OcrModelsNotDownloadedException();
    }

    final paths = _modelManager.modelPaths;
    try {
      await _ocr.init(
        config: const PaddleOcrConfig(),
        engine: const EngineConfig(numThreads: 4),
        modelPaths: ModelPaths(
          detModelPath: paths.detPath,
          recModelPath: paths.recPath,
          recConfigPath: paths.configPath,
        ),
      );
      _initialized = true;
    } catch (e) {
      _initialized = false;
      rethrow;
    }
  }

  /// Recognise text in the image at [imagePath].
  ///
  /// Lazily initialises the ONNX Runtime sessions on first call.
  /// Subsequent calls reuse the sessions.
  Future<List<OcrTextBlock>> recognize(String imagePath) async {
    await ensureInitialized();

    final run = await _ocr.recognize(imagePath);

    return run.results
        .map(
          (r) => OcrTextBlock(
            text: r.text,
            confidence: r.confidence,
            boundingBox: r.boundingBox,
            points: r.points
                .map((p) => Offset(p.x.toDouble(), p.y.toDouble()))
                .toList(),
          ),
        )
        .toList();
  }

  Future<void> dispose() async {
    if (_initialized) {
      await _ocr.dispose();
      _initialized = false;
    }
  }
}

/// Thrown when OCR model files are not available locally and need to be
/// downloaded before the engine can be initialised.
class OcrModelsNotDownloadedException implements Exception {
  const OcrModelsNotDownloadedException();

  @override
  String toString() => 'OCR models not downloaded. Download required (~30MB).';
}

/// Riverpod provider for the PaddleOCR engine.
///
/// The engine is a process-level singleton — [PaddleOcr] creates two ONNX
/// Runtime sessions that should be reused, not recreated per photo.
/// On dispose the native sessions are released.
final paddleOcrProvider = FutureProvider<PaddleOcrEngine>((ref) async {
  final modelManager = await ref.watch(ocrModelManagerProvider.future);
  final engine = PaddleOcrEngine(modelManager);
  ref.onDispose(() {
    unawaited(
      engine.dispose().catchError(
        (e) => appTalker.warning('PaddleOcrEngine dispose error: $e'),
      ),
    );
  });
  return engine;
});
