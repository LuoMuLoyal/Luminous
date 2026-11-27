import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/ai/local_model.dart';
import 'package:luminous/core/ai/model_manifest_source.dart';

/// Manifest parsing.
///
/// The manifest is the one document that decides which weights the app runs and
/// what their digests are, so a parse that silently accepts a malformed entry
/// turns a manifest mistake into a download-time failure with a much less useful
/// message.
void main() {
  const validEntry = <String, Object?>{
    'id': 'qwen3-1.7b-q4',
    'name': 'Qwen3 1.7B',
    'fileName': 'qwen3-1.7b-q4_k_m.gguf',
    'downloadUrl': 'https://example.invalid/qwen3.gguf',
    'sha256':
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    'sizeBytes': 1200000000,
    'contextLength': 32768,
  };

  /// Wraps entries into a manifest payload, the way the release would publish it.
  String payload(List<Map<String, Object?>> entries) =>
      jsonEncode({'version': 1, 'models': entries});

  group('ModelManifest', () {
    test('parses a valid manifest', () {
      final manifest = ModelManifest.decode(payload([validEntry]));

      expect(manifest.version, 1);
      expect(manifest.models, hasLength(1));
      final model = manifest.models.single;
      expect(model.id, 'qwen3-1.7b-q4');
      expect(model.contextLength, 32768);
    });

    test('byId finds a model and returns null otherwise', () {
      final manifest = ModelManifest.decode(payload([validEntry]));

      expect(manifest.byId('qwen3-1.7b-q4')?.name, 'Qwen3 1.7B');
      expect(manifest.byId('missing'), isNull);
    });

    test('rejects a manifest without a version', () {
      expect(
        () => ModelManifest.decode(jsonEncode({'models': <Object?>[]})),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a truncated sha256', () {
      // A short hash compares unequal to every file and is reported as an
      // integrity failure, which sends the user to suspect their network instead
      // of the manifest.
      final broken = {...validEntry, 'sha256': 'abc123'};

      expect(
        () => ModelManifest.decode(payload([broken])),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an entry missing a download URL', () {
      final broken = Map<String, Object?>.from(validEntry)
        ..remove('downloadUrl');

      expect(
        () => ModelManifest.decode(payload([broken])),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a non-hex sha256', () {
      final broken = {...validEntry, 'sha256': 'z' * 64};

      expect(
        () => ModelManifest.decode(payload([broken])),
        throwsA(isA<FormatException>()),
      );
    });

    test('round-trips through encode', () {
      final manifest = ModelManifest.decode(payload([validEntry]));
      final again = ModelManifest.decode(encodeManifest(manifest));

      expect(again.models.single.sha256, manifest.models.single.sha256);
      expect(again.models.single.sizeBytes, manifest.models.single.sizeBytes);
    });
  });

  group('decodeBundledManifest', () {
    test('returns null for an empty payload', () {
      // Empty is the shipping default: the list is owned by the release.
      expect(decodeBundledManifest(null), isNull);
      expect(decodeBundledManifest('  '), isNull);
    });

    test('returns null rather than throwing on corrupt JSON', () {
      // A bundled manifest that does not parse is worse than none: it makes every
      // entry look corrupt and leaves the screen unusable.
      expect(decodeBundledManifest('{not json'), isNull);
    });
  });

  group('ModelRelease', () {
    test('pins the manifest to a release tag', () {
      // A floating tag would let a future upload change which weights the app
      // runs without any client change, which is what the digest check exists to
      // prevent.
      expect(ModelRelease.tag, 'v1');
      expect(
        ModelRelease.manifestUrl.toString(),
        contains('/releases/download/v1/manifest.json'),
      );
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
