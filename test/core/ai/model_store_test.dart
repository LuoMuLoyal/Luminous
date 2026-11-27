import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/ai/local_model.dart';
import 'package:luminous/core/ai/model_store.dart';

/// A model descriptor pointing at a file the test writes.
///
/// The digest is computed from the actual bytes below, so the test exercises the
/// real verification path rather than stubbing it.
const _model = LocalModel(
  id: 'test-model',
  name: 'Test Model',
  fileName: 'test-model.gguf',
  downloadUrl: 'https://example.invalid/test-model.gguf',
  // Placeholder; replaced per-test by `withDigest`.
  sha256: 'PLACEHOLDER',
  sizeBytes: 11,
  contextLength: 4096,
);

LocalModel _withDigest(LocalModel base, String digest) => LocalModel(
  id: base.id,
  name: base.name,
  fileName: base.fileName,
  downloadUrl: base.downloadUrl,
  sha256: digest,
  sizeBytes: base.sizeBytes,
  contextLength: base.contextLength,
);

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('llama_native_store_test');
  });

  tearDown(() async {
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  /// Builds a store whose "download" writes [bytes] and whose digest is computed
  /// over the file that lands on disk.
  LocalModelStore buildStore(
    List<int> bytes, {
    bool failDownload = false,
    Future<String> Function(File)? digestOf,
  }) {
    return LocalModelStore.forTesting(
      (
        String urlPath,
        String savePath, {
        void Function(int, int)? onReceiveProgress,
      }) async {
        if (failDownload) throw const SocketException('network down');
        final file = File(savePath);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes);
        onReceiveProgress?.call(bytes.length, bytes.length);
      },
      tempDir,
      digestOf: digestOf ?? _sha256Of,
    );
  }

  group('LocalModelStore', () {
    test('a missing model is not available', () {
      final store = buildStore(const []);

      expect(store.isAvailable(_model), isFalse);
    });

    test('a verified download becomes available', () async {
      const bytes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
      final digest = await _sha256OfBytes(bytes);
      final store = buildStore(bytes);
      final model = _withDigest(_model, digest);

      final progress = <double>[];
      await store.ensure(model, onProgress: progress.add);

      expect(store.isAvailable(model), isTrue);
      expect(progress.last, 1.0);
    });

    test(
      'a digest mismatch deletes the file and reports integrity failure',
      () async {
        // The whole point of the check: a substituted GGUF runs with the app's full
        // trust, so a mismatch must never leave a loadable file behind.
        const bytes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
        final store = buildStore(bytes);
        final model = _withDigest(_model, 'wrong-digest');

        await expectLater(
          store.ensure(model),
          throwsA(
            isA<LocalModelException>().having(
              (failure) => failure.reason,
              'reason',
              LocalModelFailure.integrityMismatch,
            ),
          ),
        );

        expect(File(store.pathOf(model)).existsSync(), isFalse);
        expect(store.isAvailable(model), isFalse);
      },
    );

    test('a failed download leaves no partial file behind', () async {
      // A length-based presence check would accept the truncated file on the next
      // launch and hand it to the loader, which fails deep inside llama.cpp.
      final store = buildStore(const [], failDownload: true);

      await expectLater(
        store.ensure(_model),
        throwsA(
          isA<LocalModelException>().having(
            (failure) => failure.reason,
            'reason',
            LocalModelFailure.downloadFailed,
          ),
        ),
      );

      expect(File(store.pathOf(_model)).existsSync(), isFalse);
    });

    test('an already present model is not downloaded again', () async {
      const bytes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
      final digest = await _sha256OfBytes(bytes);
      final model = _withDigest(_model, digest);

      var downloads = 0;
      final store = LocalModelStore.forTesting((
        String urlPath,
        String savePath, {
        void Function(int, int)? onReceiveProgress,
      }) async {
        downloads += 1;
        final file = File(savePath);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes);
      }, tempDir);

      await store.ensure(model);
      await store.ensure(model);

      expect(downloads, 1);
    });

    test('remove deletes the file so availability drops', () async {
      const bytes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
      final digest = await _sha256OfBytes(bytes);
      final model = _withDigest(_model, digest);
      final store = buildStore(bytes);

      await store.ensure(model);
      expect(store.isAvailable(model), isTrue);

      await store.remove(model);
      expect(store.isAvailable(model), isFalse);
    });
  });

  group('LocalModel', () {
    test('sizeLabel is human readable', () {
      const small = LocalModel(
        id: 'a',
        name: 'a',
        fileName: 'a',
        downloadUrl: 'u',
        sha256: 'd',
        sizeBytes: 30 * 1024 * 1024,
        contextLength: 2048,
      );
      expect(small.sizeLabel, '30 MB');

      const large = LocalModel(
        id: 'b',
        name: 'b',
        fileName: 'b',
        downloadUrl: 'u',
        sha256: 'd',
        sizeBytes: 2 * 1024 * 1024 * 1024,
        contextLength: 4096,
      );
      expect(large.sizeLabel, '2.0 GB');
    });
  });
}

Future<String> _sha256Of(File file) async {
  final digest = await sha256.bind(file.openRead()).first;
  return digest.toString();
}

Future<String> _sha256OfBytes(List<int> bytes) async {
  return sha256.convert(bytes).toString();
}
