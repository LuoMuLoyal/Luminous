import 'dart:convert';

import 'package:luminous/core/network/app_log.dart';

import 'local_model.dart';

/// Fetches the model manifest published with the release.
///
/// ## Why the manifest is fetched at runtime
///
/// The model list changes when a new GGUF is uploaded, and that is a release
/// operation, not an app release. Baking the list into the binary would mean a
/// new store build to point at a new file — and would make every digest a
/// hand-copied constant that rots silently when the upload is replaced.
///
/// ## Why the result is cached
///
/// The manifest is a few kilobytes and the model behind it is gigabytes, so the
/// fetch is not the expensive part — but it happens on a settings screen that the
/// user may open repeatedly, and each miss costs a round trip plus a consent
/// prompt that flashes. A cached copy with an explicit refresh keeps the screen
/// stable.
abstract interface class ModelManifestSource {
  /// Fetches the manifest. Throws on network or parse failure.
  Future<ModelManifest> fetch();
}

/// HTTP-backed [ModelManifestSource].
// ignore_for_file: prefer_initializing_formals
// 	his._get would make the parameter private-named, which Dart does not allow.
final class HttpModelManifestSource implements ModelManifestSource {
  HttpModelManifestSource({
    required this.url,
    required Future<String> Function(Uri url) get,
  }) : _get = get;

  final Uri url;
  final Future<String> Function(Uri url) _get;

  ModelManifest? _cached;

  @override
  Future<ModelManifest> fetch() async {
    final cached = _cached;
    if (cached != null) return cached;

    final raw = await _get(url);
    final manifest = ModelManifest.decode(raw);
    _cached = manifest;
    appLog.info(
      'model manifest loaded: v${manifest.version}, '
      '${manifest.models.length} model(s)',
    );
    return manifest;
  }
}

/// Serves a manifest embedded in the response, for tests and for an offline
/// first run where the release notes are already on disk.
final class StaticModelManifestSource implements ModelManifestSource {
  StaticModelManifestSource(this._json);

  final String _json;

  @override
  Future<ModelManifest> fetch() async => ModelManifest.decode(_json);
}

/// Where release assets live.
///
/// Kept as one place because the manifest URL and the asset URLs inside it must
/// agree: a manifest fetched from one host can legitimately point files at a CDN,
/// but a hand-edited override that disagrees is a debugging nightmare.
abstract final class ModelRelease {
  /// GitHub owner/repo publishing the models.
  static const repository = 'flespark/luminous-models';

  /// The tag whose manifest this build trusts.
  ///
  /// Pinned rather than floating: a floating tag would let a future upload change
  /// which weights the app runs without any client change, which is exactly the
  /// "remote code" property the digest check exists to prevent.
  static const tag = 'v1';

  /// The manifest asset name inside that tag.
  static const manifestAsset = 'manifest.json';

  static Uri get manifestUrl => Uri.parse(
    'https://github.com/$repository/releases/download/$tag/$manifestAsset',
  );
}

/// Decodes a manifest that was bundled with the app, if one was.
///
/// Returns null when the payload is empty, which is the shipping default: the
/// list is owned by the release, not the binary.
ModelManifest? decodeBundledManifest(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  try {
    return ModelManifest.decode(raw);
  } on Object catch (error) {
    // A bundled manifest that does not parse is worse than none: it would make
    // every entry look corrupt. Reporting and falling back to the network keeps
    // the screen usable.
    appLog.warning('bundled model manifest is unreadable: $error');
    return null;
  }
}

/// Encodes a manifest, used by tests and by the tooling that writes the release.
String encodeManifest(ModelManifest manifest) => jsonEncode({
  'version': manifest.version,
  'models': [
    for (final model in manifest.models)
      {
        'id': model.id,
        'name': model.name,
        'fileName': model.fileName,
        'downloadUrl': model.downloadUrl,
        'sha256': model.sha256,
        'sizeBytes': model.sizeBytes,
        'contextLength': model.contextLength,
      },
  ],
});
