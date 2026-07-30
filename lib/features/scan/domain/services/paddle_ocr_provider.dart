import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:paddle_ocr_native/paddle_ocr_native.dart';

/// Thin wrapper over [PaddleOcr] that converts results to domain types.
///
/// [PaddleOcr] is already a process-wide singleton with internal init/dispose
/// management and serialized calls. This wrapper adds:
/// - Lazy initialization on first [recognize] call
/// - Conversion from plugin types ([OcrResult] / [OcrPoint]) to domain
///   [OcrTextBlock], enabling unit testing of the extraction logic without
///   the native plugin.
class PaddleOcrEngine {
  PaddleOcrEngine();

  final _ocr = PaddleOcr();
  bool _initialized = false;

  /// Pre-initialise the ONNX Runtime sessions.
  ///
  /// Call this before entering the OCR scan flow to detect early whether
  /// the device supports the required native libraries (e.g. arm64-v8a ABI).
  /// Throws on init failure; the [_initialized] flag is reset so the next
  /// call can retry.
  Future<void> ensureInitialized() async {
    if (_initialized) return;
    try {
      await _ocr.init(
        config: const PaddleOcrConfig(),
        engine: const EngineConfig(numThreads: 4),
      );
      _initialized = true;
    } catch (e) {
      // Reset state so the engine can be retried on the next call.
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

/// Riverpod provider for the PaddleOCR engine.
///
/// The engine is a process-level singleton — [PaddleOcr] creates two ONNX
/// Runtime sessions that should be reused, not recreated per photo.
/// On dispose the native sessions are released.
final paddleOcrProvider = Provider<PaddleOcrEngine>((ref) {
  final engine = PaddleOcrEngine();
  ref.onDispose(() {
    unawaited(
      engine.dispose().catchError(
        (e) => appTalker.warning('PaddleOcrEngine dispose error: $e'),
      ),
    );
  });
  return engine;
});
