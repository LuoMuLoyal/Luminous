/// A downloadable on-device model, pinned by digest.
///
/// ## Why the digest is the identity, not the filename
///
/// A GGUF is a few gigabytes served from a third party. A filename proves
/// nothing: the bytes behind it can change, and a swapped model would run with
/// the full trust of the app. Pinning SHA-256 and refusing anything else is what
/// makes "download a model" an operation the app can perform at all.
///
/// The descriptor also carries its own size so the UI can ask for consent before
/// spending a user's data allowance — a 2 GB download is not something to start
/// on a whim.
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

  /// Stable identifier used for storage and settings.
  final String id;

  /// Display name.
  final String name;

  /// File name on disk (not the identity — see the type doc).
  final String fileName;

  final String downloadUrl;

  /// Lowercase hex SHA-256 of the exact bytes served at [downloadUrl].
  final String sha256;

  /// Exact size, for the pre-download consent prompt and progress fallback when
  /// the server omits `Content-Length`.
  final int sizeBytes;

  /// The context window this model was trained for.
  ///
  /// Kept on the descriptor rather than read from the file so the settings
  /// screen can show a plausible memory estimate **before** downloading.
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

/// The models this build can offer.
///
/// Deliberately a short list with pinned digests: an on-device model is a
/// compatibility commitment (context window, chat template, quantisation), and a
/// free-form "paste a URL" flow would produce configurations the app cannot
/// support and cannot diagnose.
///
/// **This list is currently empty.** Entries require a digest computed from the
/// exact bytes the host will serve; inventing one would make every download fail
/// verification, and weakening the check to accommodate that would defeat its
/// purpose. See `docs/TODO.md` for the remaining work.
const List<LocalModel> availableLocalModels = [];
