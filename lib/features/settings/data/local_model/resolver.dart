// Named parameters cannot be private in Dart: `this._get` is not an option, so
// the public parameter name stays.
// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:luminous/core/network/app_log.dart';

import '../../domain/local_model/catalog.dart';

/// Turns a [ModelSource] into a [LocalModel] by asking the host what it serves.
///
/// ## Why the digest is fetched rather than shipped
///
/// HuggingFace's tree API reports each file's git-lfs SHA-256 as `lfs.oid`. That is
/// a hash **the host publishes about the exact bytes it will serve**, which is
/// strictly better than a constant in our source: a constant drifts from the upload
/// and nothing notices until a user hits an integrity failure.
///
/// The cost is one small JSON request before a download that transfers gigabytes.
///
/// ## Why a missing file is surfaced early
///
/// A repo can be renamed, a quantisation removed, or a revision deleted. Learning
/// that from the tree API costs a few kilobytes; learning it from a failed 2 GB
/// download costs the user their data allowance.
abstract interface class ModelSourceResolver {
  /// Resolves [source] to a downloadable, digest-bearing model.
  Future<LocalModel> resolve(ModelSource source);
}

/// HTTP-backed [ModelSourceResolver] over the HuggingFace API.
final class HuggingFaceModelResolver implements ModelSourceResolver {
  HuggingFaceModelResolver({required Future<String> Function(Uri url) get})
    : _get = get;

  final Future<String> Function(Uri url) _get;

  /// Resolved models, keyed by [ModelSource.id].
  ///
  /// Cached because the picker rebuilds on every progress tick during a download,
  /// and re-resolving would add a network round trip to each rebuild.
  final Map<String, LocalModel> _cache = {};

  @override
  Future<LocalModel> resolve(ModelSource source) async {
    final cached = _cache[source.id];
    if (cached != null) return cached;

    final raw = await _get(source.treeUrl);
    final model = parseHuggingFaceTree(source, raw);
    _cache[source.id] = model;
    appLog.info(
      'resolved ${source.id}: ${model.sizeLabel}, '
      'sha256=${model.sha256.substring(0, 12)}…',
    );
    return model;
  }
}

/// Reads [source]'s entry out of a HuggingFace tree response.
///
/// Separated from the HTTP call so the parsing — where a malformed or unexpected
/// response becomes a confusing failure — is testable without a network.
///
/// Throws [ModelManifestException] when the file is absent, carries no LFS metadata
/// (meaning the digest is not published), or reports a digest that is not a
/// SHA-256.
LocalModel parseHuggingFaceTree(ModelSource source, String raw) {
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException catch (error) {
    throw ModelManifestException(
      'HuggingFace tree response for ${source.repository} was not JSON: '
      '${error.message}',
    );
  }

  if (decoded is! List) {
    throw ModelManifestException(
      'HuggingFace tree response for ${source.repository} was not a list',
    );
  }

  for (final entry in decoded) {
    if (entry is! Map) continue;
    if (entry['path'] != source.fileName) continue;
    if (entry['type'] != null && entry['type'] != 'file') {
      throw ModelManifestException(
        '${source.fileName} is a ${entry['type']}, not a file',
      );
    }

    final size = entry['size'];
    if (size is! num || size <= 0) {
      throw ModelManifestException(
        '${source.fileName} has no usable size in the tree response',
      );
    }

    // `lfs` is present only for files stored via LFS. Its absence means no digest
    // is published, and proceeding without one would defeat the check entirely.
    final lfs = entry['lfs'];
    final oid = lfs is Map ? lfs['oid'] : null;
    if (oid is! String) {
      throw ModelManifestException(
        '${source.fileName} has no lfs.oid, so no digest is published; '
        'refusing to download a file we cannot verify',
      );
    }

    return LocalModel.fromSource(
      source: source,
      sha256: oid,
      sizeBytes: size.toInt(),
    );
  }

  throw ModelManifestException(
    '${source.fileName} is not in ${source.repository}@${source.revision}',
  );
}
