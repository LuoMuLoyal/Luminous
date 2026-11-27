/// Where an on-device model comes from.
///
/// ## Why HuggingFace and not our own release
///
/// The file is gigabytes. Hosting it ourselves would mean downloading it, checking
/// it, and re-uploading it — three times the cost of pointing the app at the
/// original, with a chance of corruption at each step.
///
/// The reason that is *safe* is that HuggingFace's tree API reports each file's
/// **git-lfs SHA-256** as `lfs.oid`, which is the digest of the exact bytes it
/// serves. That gives us the one thing a manifest needs — a hash the host itself
/// publishes — without us computing or copying anything.
final class ModelSource {
  const ModelSource({
    required this.repository,
    required this.fileName,
    required this.name,
    required this.contextLength,
    required this.minDeviceMemoryGb,
    this.note = '',
    this.revision = 'main',
  });

  /// HuggingFace repo id, e.g. `unsloth/gemma-4-E2B-it-GGUF`.
  final String repository;

  /// File inside that repo. Must already be a GGUF there.
  final String fileName;

  /// Display name; not derived from the file name because those are noisy.
  final String name;

  /// The context window the model was trained for.
  ///
  /// An upper bound: [LocalAssistant] caps what it allocates, because KV memory
  /// scales linearly with the window and a phone cannot hold a 32K cache.
  final int contextLength;

  /// Rough device RAM needed to load this model without being killed.
  ///
  /// The weights plus a KV cache for the allocated window plus the app itself.
  /// Exposed so the picker can filter rather than letting a user download 2.3 GB
  /// onto a device that will immediately run out of memory — the failure mode there
  /// is an OS kill, not a slow answer, and it happens *after* the download.
  final int minDeviceMemoryGb;

  /// One line about what this model is good at, shown beside it in the picker.
  final String note;

  /// Git revision. `main` follows the repo, which is acceptable because the digest
  /// is re-read on every resolve: a changed file is rejected, not silently used.
  final String revision;

  /// Direct download URL. `resolve` follows LFS to the bytes; `blob` serves HTML.
  Uri get downloadUrl => Uri.parse(
    'https://huggingface.co/$repository/resolve/$revision/$fileName',
  );

  /// The API endpoint listing this repo's tree, including per-file digests.
  Uri get treeUrl =>
      Uri.parse('https://huggingface.co/api/models/$repository/tree/$revision');

  /// Stable identifier: the repo and file uniquely name the bytes.
  String get id => '$repository/$fileName';

  @override
  String toString() => 'ModelSource($id)';
}

/// The models this build offers.
///
/// ## Why a list rather than one model
///
/// Model choice is a trade the user is better placed to make than we are: a 0.75 GB
/// model runs on a four-year-old phone, and a 2.3 GB one answers noticeably better
/// on a flagship. Hard-coding one means either excluding devices or wasting their
/// capability. So the app offers the set and filters by [ModelSource
/// .minDeviceMemoryGb].
///
/// ## Why these entries
///
/// Every one is a Q4_K_M (or the model's own QAT q4_0) file that exists **today**
/// on HuggingFace — verified by querying each repo's tree for `size` and
/// `lfs.oid`, because a model that cannot be resolved is a download button that
/// always fails. Sizes below are the measured values, not estimates.
///
/// Ordered smallest first: that is the order the picker presents, and it makes the
/// "will this fit my phone" question answer itself.
const List<ModelSource> availableModels = [
  // ---- ~0.6–0.8 GB: 4 GB devices ------------------------------------------------
  ModelSource(
    repository: 'openbmb/MiniCPM-V-4.7-1B-gguf',
    fileName: 'MiniCPM-V-4_7-1B-Q4_K_M.gguf',
    name: 'MiniCPM-V 1B',
    contextLength: 8192,
    minDeviceMemoryGb: 4,
    note: '多模态：能读图',
  ),
  ModelSource(
    repository: 'ggml-org/gemma-3-1b-it-GGUF',
    fileName: 'gemma-3-1b-it-Q4_K_M.gguf',
    name: 'Gemma 3 1B',
    contextLength: 32768,
    minDeviceMemoryGb: 4,
    note: '体积最小，多语言稳',
  ),
  ModelSource(
    repository: 'bartowski/Llama-3.2-1B-Instruct-GGUF',
    fileName: 'Llama-3.2-1B-Instruct-Q4_K_M.gguf',
    name: 'Llama 3.2 1B',
    contextLength: 8192,
    minDeviceMemoryGb: 4,
    note: '工具调用格式成熟',
  ),

  // ---- ~1.4–1.9 GB: 6 GB devices ------------------------------------------------
  ModelSource(
    repository: 'openbmb/MiniCPM5-2B-GGUF',
    fileName: 'MiniCPM5-2B-Q4_K_M.gguf',
    name: 'MiniCPM5 2B',
    contextLength: 32768,
    minDeviceMemoryGb: 6,
    note: '中英均衡',
  ),
  ModelSource(
    repository: 'unsloth/Llama-3.2-3B-Instruct-GGUF',
    fileName: 'Llama-3.2-3B-Instruct-Q4_K_M.gguf',
    name: 'Llama 3.2 3B',
    contextLength: 8192,
    minDeviceMemoryGb: 6,
    note: '通用能力比 1B 明显强',
  ),
  ModelSource(
    repository: 'bartowski/HuggingFaceTB_SmolLM3-3B-GGUF',
    fileName: 'HuggingFaceTB_SmolLM3-3B-Q4_K_M.gguf',
    name: 'SmolLM3 3B',
    contextLength: 32768,
    minDeviceMemoryGb: 6,
    note: '长上下文，小体积',
  ),

  // ---- ~2.1–2.6 GB: 8 GB devices ------------------------------------------------
  ModelSource(
    repository: 'ibm-granite/granite-4.2-3b-GGUF',
    fileName: 'granite-4.2-3b-Q4_K_M.gguf',
    name: 'Granite 4.2 3B',
    contextLength: 32768,
    minDeviceMemoryGb: 8,
    note: 'IBM，企业语料',
  ),
  ModelSource(
    repository: 'unsloth/gemma-3-4b-it-GGUF',
    fileName: 'gemma-3-4b-it-Q4_K_M.gguf',
    name: 'Gemma 3 4B',
    contextLength: 32768,
    minDeviceMemoryGb: 8,
    note: '多语言最好',
  ),
  ModelSource(
    repository: 'unsloth/Phi-4-mini-instruct-GGUF',
    fileName: 'Phi-4-mini-instruct-Q4_K_M.gguf',
    name: 'Phi-4-mini',
    contextLength: 16384,
    minDeviceMemoryGb: 8,
    note: '推理与结构化输出强',
  ),
  ModelSource(
    repository: 'empero-ai/Qwen3.8-4B-Distill-GGUF',
    fileName: 'Qwen3.8-4B-Q4_K_M.gguf',
    name: 'Qwen3.8 4B',
    contextLength: 32768,
    minDeviceMemoryGb: 8,
    note: '中文最强',
  ),

  // ---- ~2.9 GB+: 12 GB devices ---------------------------------------------------
  ModelSource(
    repository: 'unsloth/gemma-4-E2B-it-GGUF',
    fileName: 'gemma-4-E2B-it-Q4_K_M.gguf',
    name: 'Gemma 4 E2B',
    contextLength: 32768,
    minDeviceMemoryGb: 12,
    note: '新一代，效果明显提升',
  ),
  ModelSource(
    repository: 'mistralai/Ministral-3-8B-Instruct-2512-GGUF',
    fileName: 'Ministral-3-8B-Instruct-2512-Q4_K_M.gguf',
    name: 'Ministral 3 8B',
    contextLength: 32768,
    // 4.8 GB of weights plus a KV cache needs 16 GB to be safe, not 12: the
    // measured size is why this sits below Gemma 4 E4B rather than beside it.
    minDeviceMemoryGb: 16,
    note: '8B 档，旗舰机',
  ),
  ModelSource(
    repository: 'unsloth/gemma-4-E4B-it-GGUF',
    fileName: 'gemma-4-E4B-it-Q4_K_M.gguf',
    name: 'Gemma 4 E4B',
    contextLength: 32768,
    minDeviceMemoryGb: 16,
    note: '端侧最强一档',
  ),
];

/// The model this build selects when the user has not chosen.
///
/// Gemma 3 1B: it fits a 4 GB phone, which means it is the only choice that does
/// not exclude anyone. Better models are an opt-in, never a default — defaulting to
/// something a mid-range device cannot load makes the feature look broken.
ModelSource? get defaultModel => availableModels.length < 2
    ? (availableModels.isEmpty ? null : availableModels.first)
    : availableModels[1];

/// A model whose digest and size have been confirmed by the host.
///
/// Produced by [parseHuggingFaceTree] — never assembled by hand, because a
/// hand-copied digest that disagrees with the served bytes turns every download into
/// an integrity failure.
final class LocalModel {
  const LocalModel({
    required this.id,
    required this.name,
    required this.fileName,
    required this.downloadUrl,
    required this.sha256,
    required this.sizeBytes,
    required this.contextLength,
    required this.minDeviceMemoryGb,
    required this.note,
  });

  /// Ties a [ModelSource] to the digest the host reports for its file.
  ///
  /// Throws [ModelManifestException] when the digest is not a usable SHA-256 or the
  /// size is not positive: a descriptor without a trustworthy digest would reach
  /// the download step and fail there, where the message is far less useful.
  factory LocalModel.fromSource({
    required ModelSource source,
    required String sha256,
    required int sizeBytes,
  }) {
    final normalised = sha256.toLowerCase();
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(normalised)) {
      throw ModelManifestException(
        'digest for ${source.fileName} is not a SHA-256: "$sha256"',
      );
    }
    if (sizeBytes <= 0) {
      throw ModelManifestException(
        'size for ${source.fileName} is not positive: $sizeBytes',
      );
    }
    return LocalModel(
      id: source.id,
      name: source.name,
      fileName: source.fileName,
      downloadUrl: source.downloadUrl.toString(),
      sha256: normalised,
      sizeBytes: sizeBytes,
      contextLength: source.contextLength,
      minDeviceMemoryGb: source.minDeviceMemoryGb,
      note: source.note,
    );
  }

  /// Stable identifier used for storage and settings.
  final String id;

  /// Display name.
  final String name;

  /// File name on disk (not the identity — [sha256] is).
  final String fileName;

  final String downloadUrl;

  /// Lowercase hex SHA-256 of the exact bytes at [downloadUrl], as published by the
  /// host's LFS metadata.
  final String sha256;

  /// Exact size, for the pre-download consent prompt and for progress when the host
  /// omits `Content-Length`.
  final int sizeBytes;

  /// The context window the model was trained for.
  final int contextLength;

  /// Rough device RAM needed to load this without being killed.
  final int minDeviceMemoryGb;

  /// One line shown beside the model in the picker.
  final String note;

  /// Human-readable size for the consent prompt.
  String get sizeLabel {
    final gigabytes = sizeBytes / (1024 * 1024 * 1024);
    if (gigabytes >= 1) return '${gigabytes.toStringAsFixed(1)} GB';
    return '${(sizeBytes / (1024 * 1024)).round()} MB';
  }

  @override
  String toString() => 'LocalModel($id, $sizeLabel)';
}

/// Raised when a model's digest or size cannot be established.
final class ModelManifestException implements Exception {
  const ModelManifestException(this.message);

  final String message;

  @override
  String toString() => 'ModelManifestException: $message';
}
