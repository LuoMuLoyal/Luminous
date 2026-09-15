import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/scan/domain/services/ocr_model_hashes.dart';
import 'package:luminous/features/scan/domain/services/ocr_model_manager.dart';

/// Downloader stub that writes a fixed byte payload to the target path and
/// records the URLs it was asked to download.
class _FakeDownloader implements OcrModelDownloader {
  _FakeDownloader(this._payload);

  final List<int> _payload;
  final downloaded = <String>[];

  @override
  Future<void> download(
    String urlPath,
    String savePath, {
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    downloaded.add(urlPath);
    final file = File(savePath);
    await file.writeAsBytes(_payload);
    if (onReceiveProgress != null) {
      onReceiveProgress(_payload.length, _payload.length);
    }
  }
}

/// Downloader stub that writes part of the payload and then fails, standing in
/// for a connection dropped mid-download.
class _FailingDownloader implements OcrModelDownloader {
  final downloaded = <String>[];

  @override
  Future<void> download(
    String urlPath,
    String savePath, {
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    downloaded.add(urlPath);
    // Write a truncated file first: this is exactly what dio can leave behind.
    await File(savePath).writeAsBytes(List<int>.filled(512, 0x41));
    throw const SocketException('connection dropped');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OcrModelManager.downloadModels integrity guard', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('ocr-model-test');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    Directory modelDir() => Directory('${tempDir.path}/paddle_ocr_models');

    test(
      'deletes a corrupted det model and throws integrity exception',
      () async {
        final fakeDownloader = _FakeDownloader(List<int>.filled(1024, 0x41));
        final manager = OcrModelManager.forTesting(fakeDownloader, tempDir);

        await expectLater(
          manager.downloadModels(),
          throwsA(
            isA<OcrModelIntegrityException>().having(
              (e) => e.fileName,
              'fileName',
              'det_inference.onnx',
            ),
          ),
        );

        // The corrupted file must not survive for a later run to load.
        expect(
          File('${modelDir().path}/det_inference.onnx').existsSync(),
          isFalse,
        );
        // The download stopped at the first (det) file.
        expect(fakeDownloader.downloaded, hasLength(1));
      },
    );

    test('deletes the partial file when the download itself fails', () async {
      final fakeDownloader = _FailingDownloader();
      final manager = OcrModelManager.forTesting(fakeDownloader, tempDir);

      await expectLater(
        manager.downloadModels(),
        throwsA(isA<SocketException>()),
      );

      // 半截文件必须删掉:下一轮的"已下载"判定只看 length > 0,
      // 留着会让截断的文件被当成完整模型交给 OCR 引擎。
      expect(
        File('${modelDir().path}/det_inference.onnx').existsSync(),
        isFalse,
      );
      expect(fakeDownloader.downloaded, hasLength(1));
    });

    test('accepts a download whose digest matches the pinned hash', () async {
      // Inject a verifier that returns the pinned digest per file, simulating
      // byte-for-byte matches with the upstream models.
      final fakeDownloader = _FakeDownloader(List<int>.filled(1024, 0x41));
      final manager = OcrModelManager.forTesting(
        fakeDownloader,
        tempDir,
        verifier: (file) async => switch (file.path) {
          _ when file.path.endsWith('det_inference.onnx') => detModelSha256,
          _ when file.path.endsWith('rec_inference.onnx') => recModelSha256,
          _ => recConfigSha256,
        },
      );

      await manager.downloadModels();

      expect(
        File('${modelDir().path}/det_inference.onnx').existsSync(),
        isTrue,
      );
      expect(
        File('${modelDir().path}/rec_inference.onnx').existsSync(),
        isTrue,
      );
      expect(fakeDownloader.downloaded, hasLength(2));
    });

    test('rec config integrity check rejects a tampered config', () async {
      // Simulate the config-copy step producing bytes whose hash does not
      // match recConfigSha256. The downloads are pre-satisfied by existing
      // files (the loop skips them), then the config step verifies.
      final configDir = modelDir();
      configDir.createSync(recursive: true);
      final configFile = File('${configDir.path}/rec_inference.yml');
      await configFile.writeAsBytes(List<int>.filled(64, 0x21));

      // Pre-create det/rec files so the download loop skips them; verifier
      // returns the pinned hashes so the *downloads* pass, isolating the
      // config-step failure.
      final detFile = File('${configDir.path}/det_inference.onnx');
      final recFile = File('${configDir.path}/rec_inference.onnx');
      await detFile.writeAsBytes(List<int>.filled(128, 0x01));
      await recFile.writeAsBytes(List<int>.filled(128, 0x02));

      final fakeDownloader = _FakeDownloader(<int>[]);
      final manager = OcrModelManager.forTesting(
        fakeDownloader,
        tempDir,
        verifier: (_) async => detModelSha256,
      );

      await expectLater(
        manager.downloadModels(),
        throwsA(
          isA<OcrModelIntegrityException>().having(
            (e) => e.fileName,
            'fileName',
            'rec_inference.yml',
          ),
        ),
      );
      expect(configFile.existsSync(), isFalse);
    });
  });
}
