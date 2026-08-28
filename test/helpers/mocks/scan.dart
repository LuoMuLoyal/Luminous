import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:luminous/features/scan/domain/repositories/scan.dart';
import 'package:luminous/features/scan/domain/services/ocr_model_manager.dart';
import 'package:luminous/features/scan/domain/services/paddle_ocr_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:paddle_ocr_native/paddle_ocr_native.dart';
// PaddleOcrNativePlatform is not re-exported by paddle_ocr_native, so import
// the platform interface directly (tests only).
import 'package:paddle_ocr_native/src/paddle_ocr_platform.dart'
    show PaddleOcrNativePlatform;
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

/// Configurable [PermissionHandlerPlatform] fake for widget tests.
///
/// Extends the platform interface so the singleton token matches; install via
/// `PermissionHandlerPlatform.instance = fake` in tests.
class FakePermissionHandlerPlatform extends PermissionHandlerPlatform {
  FakePermissionHandlerPlatform({required this.status, this.requestResult});

  /// Status returned by [checkPermissionStatus] (i.e. `Permission.camera.status`).
  PermissionStatus status;

  /// Status returned by [requestPermissions]; defaults to [status].
  PermissionStatus? requestResult;

  int openAppSettingsCalls = 0;

  @override
  Future<PermissionStatus> checkPermissionStatus(Permission permission) async =>
      status;

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async => {
    for (final permission in permissions) permission: requestResult ?? status,
  };

  @override
  Future<bool> openAppSettings() async {
    openAppSettingsCalls++;
    return true;
  }
}

/// Configurable [MobileScannerPlatform] fake that never talks to the real
/// camera. Emit [BarcodeCapture] into [barcodes] to simulate detections.
class FakeMobileScannerPlatform extends MobileScannerPlatform {
  /// Push [BarcodeCapture] here to simulate a scan detection.
  final StreamController<BarcodeCapture?> barcodes =
      StreamController<BarcodeCapture?>.broadcast();

  final StreamController<TorchState> torchState =
      StreamController<TorchState>.broadcast();

  final StreamController<double> zoomScale =
      StreamController<double>.broadcast();

  int startCalls = 0;
  int stopCalls = 0;
  int disposeCalls = 0;
  int toggleTorchCalls = 0;

  @override
  Stream<BarcodeCapture?> get barcodesStream => barcodes.stream;

  @override
  Stream<TorchState> get torchStateStream => torchState.stream;

  @override
  Stream<double> get zoomScaleStateStream => zoomScale.stream;

  @override
  Future<MobileScannerViewAttributes> start(StartOptions startOptions) async {
    startCalls++;
    return const MobileScannerViewAttributes(
      cameraDirection: CameraFacing.back,
      currentTorchMode: TorchState.off,
      size: Size(640, 480),
      numberOfCameras: 1,
      initialDeviceOrientation: DeviceOrientation.portraitUp,
    );
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<void> toggleTorch() async {
    toggleTorchCalls++;
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
  }

  @override
  Future<Set<CameraLensType>> getSupportedLenses() async => {
    CameraLensType.any,
  };

  @override
  Widget buildCameraView() =>
      const ColoredBox(color: Color(0xFF000000), child: SizedBox.expand());

  /// Closes the backing stream controllers (call in test teardown).
  Future<void> close() async {
    await barcodes.close();
    await torchState.close();
    await zoomScale.close();
  }
}

/// Fake of the paddle OCR native platform, injected via
/// `PaddleOcrNativePlatform.instance` BEFORE the `PaddleOcr` singleton is
/// first touched (the singleton captures the platform at construction).
class FakePaddleOcrNativePlatform extends PaddleOcrNativePlatform {
  int initCalls = 0;
  int releaseCalls = 0;

  /// When set, [init] throws this value (simulating ABI/model-load failure).
  Object? initError;

  OcrRunResult recognizeResult = OcrRunResult.empty;
  String? lastRecognizedPath;

  @override
  Future<Map<String, dynamic>> init({
    required PaddleOcrConfig config,
    required EngineConfig engine,
    required ModelPaths modelPaths,
  }) async {
    initCalls++;
    if (initError != null) {
      throw initError!;
    }
    return const <String, dynamic>{};
  }

  @override
  Future<OcrRunResult> recognize(String imagePath) async {
    lastRecognizedPath = imagePath;
    return recognizeResult;
  }

  @override
  Future<void> release() async {
    releaseCalls++;
  }
}

/// Fake [ImagePickerPlatform] returning a fixed image for `pickImage`.
class FakeImagePickerPlatform extends ImagePickerPlatform {
  FakeImagePickerPlatform({this.imagePath});

  /// Path returned by [getImageFromSource]; `null` simulates a cancelled pick.
  String? imagePath;

  int pickCalls = 0;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    pickCalls++;
    final path = imagePath;
    return path == null ? null : XFile(path);
  }
}

class MockScanRepository extends Mock implements ScanRepository {}

/// Mock of [PaddleOcrEngine] that never touches the native plugin / singleton.
/// Use it to override [paddleOcrProvider] in widget tests.
class MockPaddleOcrEngine extends Mock implements PaddleOcrEngine {}

/// Fake [OcrModelManager] that reports models as always available without
/// touching the file system. Used in unit tests where [PaddleOcrEngine] needs
/// a model manager but the real download/storage path is irrelevant.
class FakeOcrModelManager implements OcrModelManager {
  const FakeOcrModelManager({this.modelsAvailable = true});

  /// When `true`, [isModelAvailable] returns `false` to simulate
  /// "models not downloaded" scenarios.
  final bool modelsAvailable;

  @override
  bool isModelAvailable() => modelsAvailable;

  @override
  ({String detPath, String recPath, String configPath}) get modelPaths =>
      const (
        detPath: '/fake/det.onnx',
        recPath: '/fake/rec.onnx',
        configPath: '/fake/rec.yml',
      );

  @override
  Directory get modelDirectory => Directory('/fake/paddle_ocr_models');

  @override
  Future<void> downloadModels({
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(1.0);
  }

  @override
  Future<void> deleteModels() async {}
}
