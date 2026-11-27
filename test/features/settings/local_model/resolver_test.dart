import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/settings/data/local_model/resolver.dart';
import 'package:luminous/features/settings/domain/local_model/catalog.dart';

/// Resolving a catalogue entry against the host's own metadata.
///
/// This is where the app learns a model's digest and size. If the parse is too
/// permissive, a malformed response becomes a 2 GB download that fails at the very
/// end with an integrity error — the most expensive possible way to report a
/// manifest bug.
void main() {
  const source = ModelSource(
    repository: 'unsloth/gemma-3-1b-it-GGUF',
    fileName: 'gemma-3-1b-it-Q4_K_M.gguf',
    name: 'Gemma 3 1B',
    contextLength: 32768,
    minDeviceMemoryGb: 4,
  );

  const digest =
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

  String tree(List<Map<String, Object?>> entries) => jsonEncode(entries);

  Map<String, Object?> entry({
    String path = 'gemma-3-1b-it-Q4_K_M.gguf',
    num? size = 800000000,
    String? oid = digest,
    bool withLfs = true,
    String type = 'file',
  }) => {
    'type': type,
    'path': path,
    'size': size,
    if (withLfs) 'lfs': {'oid': oid, 'size': size},
  };

  group('parseHuggingFaceTree', () {
    test('reads size and digest from the lfs metadata', () {
      final model = parseHuggingFaceTree(source, tree([entry()]));

      expect(model.sha256, digest);
      expect(model.sizeBytes, 800000000);
      expect(model.id, '${source.repository}/${source.fileName}');
      // The descriptor carries the catalogue's presentation fields through, because
      // the picker shows them without re-resolving.
      expect(model.name, 'Gemma 3 1B');
      expect(model.contextLength, 32768);
      expect(model.minDeviceMemoryGb, 4);
    });

    test('builds the download URL from the repo, revision and file name', () {
      final model = parseHuggingFaceTree(source, tree([entry()]));

      expect(
        model.downloadUrl,
        'https://huggingface.co/unsloth/gemma-3-1b-it-GGUF'
        '/resolve/main/gemma-3-1b-it-Q4_K_M.gguf',
      );
    });

    test('refuses a file with no published digest', () {
      // Without `lfs.oid` there is nothing to verify against, and downloading
      // unverifiable weights is exactly what this check exists to prevent.
      expect(
        () => parseHuggingFaceTree(source, tree([entry(withLfs: false)])),
        throwsA(
          isA<ModelManifestException>().having(
            (error) => error.message,
            'message',
            contains('lfs.oid'),
          ),
        ),
      );
    });

    test('refuses a digest that is not a SHA-256', () {
      expect(
        () => parseHuggingFaceTree(source, tree([entry(oid: 'abc123')])),
        throwsA(isA<ModelManifestException>()),
      );
    });

    test('refuses a non-positive size', () {
      expect(
        () => parseHuggingFaceTree(source, tree([entry(size: 0)])),
        throwsA(isA<ModelManifestException>()),
      );
    });

    test('reports a missing file by name', () {
      // A repo rename or a removed quantisation must read as "not there", not as a
      // generic parse failure.
      expect(
        () => parseHuggingFaceTree(source, tree([entry(path: 'other.gguf')])),
        throwsA(
          isA<ModelManifestException>().having(
            (error) => error.message,
            'message',
            contains('is not in'),
          ),
        ),
      );
    });

    test('rejects a directory entry with the expected name', () {
      expect(
        () => parseHuggingFaceTree(source, tree([entry(type: 'directory')])),
        throwsA(isA<ModelManifestException>()),
      );
    });

    test('rejects a response that is not JSON', () {
      expect(
        () => parseHuggingFaceTree(source, '<html>rate limited</html>'),
        throwsA(isA<ModelManifestException>()),
      );
    });

    test('rejects a response that is not a list', () {
      expect(
        () => parseHuggingFaceTree(source, '{"error":"not found"}'),
        throwsA(isA<ModelManifestException>()),
      );
    });

    test('picks the matching entry out of a multi-file listing', () {
      // Real repos ship many quantisations; resolving the wrong one downloads
      // gigabytes of a model the user did not choose.
      final model = parseHuggingFaceTree(
        source,
        tree([
          entry(path: 'gemma-3-1b-it-Q8_0.gguf', size: 1300000000),
          entry(),
          entry(path: 'mmproj-model-f16.gguf', size: 1000),
        ]),
      );

      expect(model.fileName, 'gemma-3-1b-it-Q4_K_M.gguf');
      expect(model.sizeBytes, 800000000);
    });
  });

  group('ModelSource', () {
    test('treeUrl targets the models API for the revision', () {
      expect(
        source.treeUrl.toString(),
        'https://huggingface.co/api/models/unsloth/gemma-3-1b-it-GGUF/tree/main',
      );
    });

    test('id names the bytes uniquely', () {
      expect(source.id, 'unsloth/gemma-3-1b-it-GGUF/gemma-3-1b-it-Q4_K_M.gguf');
    });
  });

  group('LocalModel', () {
    test('sizeLabel is human readable', () {
      final model = LocalModel.fromSource(
        source: source,
        sha256: digest,
        sizeBytes: 2 * 1024 * 1024 * 1024,
      );

      expect(model.sizeLabel, '2.0 GB');
    });
  });

  group('availableModels', () {
    test('every entry names a file, and ids are unique', () {
      // A duplicate id makes the persisted choice ambiguous; an empty file name
      // would resolve against a directory listing and always fail.
      final ids = <String>{};
      for (final model in availableModels) {
        expect(model.fileName, endsWith('.gguf'), reason: model.repository);
        expect(ids.add(model.id), isTrue, reason: 'duplicate id ${model.id}');
      }
    });

    test('entries are ordered by increasing device requirement', () {
      // The picker presents them in this order, so a smaller device's options come
      // first — the "will this fit my phone" question answers itself.
      for (var i = 1; i < availableModels.length; i++) {
        expect(
          availableModels[i].minDeviceMemoryGb,
          greaterThanOrEqualTo(availableModels[i - 1].minDeviceMemoryGb),
          reason: '${availableModels[i].name} is out of order',
        );
      }
    });

    test('the default fits a small device', () {
      // Defaulting to something a mid-range phone cannot load makes the feature look
      // broken for most users.
      final fallback = defaultModel;
      expect(fallback, isNotNull);
      expect(fallback!.minDeviceMemoryGb, lessThanOrEqualTo(4));
    });
  });
}
