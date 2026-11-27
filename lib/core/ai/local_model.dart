import 'dart:convert';

/// A downloadable on-device model, as published by the release.
///
/// ## Why the descriptor comes from the release, not from a constant
///
/// A GGUF is gigabytes served from a third party, and the digest is the only
/// thing that makes "download and run these weights" safe. Computing that digest
/// by hand is not an option: it has to match the exact bytes the host will serve,
/// and a hand-copied value silently rots the moment the upload is replaced.
///
/// So the release publishes a manifest alongside the model files, and this class
/// is its parsed form. The app reads the manifest, downloads what it names, and
/// verifies against the digest that same manifest carries — one source of truth
/// for both URL and hash.
final class LocalModel {
  const LocalModel({
    required this.id,
    required this.name,
    required this.fileName,
    required this.downloadUrl,
    required this.sha256,
    required this.sizeBytes,
    required this.contextLength,
  });

  /// Parses one entry of the release manifest.
  ///
  /// Throws [FormatException] when a required field is missing or malformed:
  /// a partial descriptor would reach the download step and fail there, with a
  /// far less useful message.
  factory LocalModel.fromJson(Map<String, Object?> json) {
    String requireString(String key) {
      final value = json[key];
      if (value is! String || value.isEmpty) {
        throw FormatException('manifest entry is missing "$key"', json);
      }
      return value;
    }

    int requireInt(String key) {
      final value = json[key];
      if (value is! num) {
        throw FormatException('manifest entry is missing "$key"', json);
      }
      return value.toInt();
    }

    final sha256 = requireString('sha256').toLowerCase();
    // Rejecting a malformed digest here is the point of the check: a truncated
    // hash would compare unequal to every file and fail as an integrity error,
    // sending the user to look at their network instead of at the manifest.
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(sha256)) {
      throw FormatException('manifest entry has an invalid sha256', json);
    }

    return LocalModel(
      id: requireString('id'),
      name: requireString('name'),
      fileName: requireString('fileName'),
      downloadUrl: requireString('downloadUrl'),
      sha256: sha256,
      sizeBytes: requireInt('sizeBytes'),
      contextLength: requireInt('contextLength'),
    );
  }

  /// Stable identifier used for storage and settings.
  final String id;

  /// Display name.
  final String name;

  /// File name on disk (not the identity — [sha256] is).
  final String fileName;

  final String downloadUrl;

  /// Lowercase hex SHA-256 of the exact bytes at [downloadUrl].
  final String sha256;

  /// Exact size, for the pre-download consent prompt and for progress when the
  /// host omits `Content-Length`.
  final int sizeBytes;

  /// The context window the model was trained for; kept here so the settings
  /// screen can show a memory estimate **before** downloading.
  final int contextLength;

  /// Human-readable size for the consent prompt.
  String get sizeLabel {
    final gigabytes = sizeBytes / (1024 * 1024 * 1024);
    if (gigabytes >= 1) return '${gigabytes.toStringAsFixed(1)} GB';
    return '${(sizeBytes / (1024 * 1024)).round()} MB';
  }

  @override
  String toString() => 'LocalModel($id, $sizeLabel)';
}

/// The release manifest: every model this build can offer.
final class ModelManifest {
  const ModelManifest({required this.models, required this.version});

  /// Parses the manifest published in the release.
  ///
  /// Shape:
  /// ```json
  /// {
  ///   "version": 1,
  ///   "models": [
  ///     { "id": "...", "name": "...", "fileName": "...", "downloadUrl": "...",
  ///       "sha256": "...", "sizeBytes": 0, "contextLength": 4096 }
  ///   ]
  /// }
  /// ```
  factory ModelManifest.fromJson(Map<String, Object?> json) {
    final version = json['version'];
    if (version is! num) {
      throw const FormatException('manifest is missing "version"');
    }
    final rawModels = json['models'];
    if (rawModels is! List) {
      throw const FormatException('manifest is missing "models"');
    }
    return ModelManifest(
      version: version.toInt(),
      models: [
        for (final entry in rawModels)
          LocalModel.fromJson(Map<String, Object?>.from(entry as Map)),
      ],
    );
  }

  /// Decodes [raw] JSON into a manifest.
  factory ModelManifest.decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('manifest is not a JSON object');
    }
    return ModelManifest.fromJson(decoded);
  }

  /// Manifest schema version, so a future format change can be detected rather
  /// than misparsed.
  final int version;

  final List<LocalModel> models;

  /// The model with [id], or null.
  LocalModel? byId(String id) {
    for (final model in models) {
      if (model.id == id) return model;
    }
    return null;
  }
}
