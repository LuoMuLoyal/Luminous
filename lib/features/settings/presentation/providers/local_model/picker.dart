import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/app/composition/settings/local_model_assistant.dart';
import 'package:luminous/features/settings/domain/local_model/catalog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'picker.freezed.dart';
part 'picker.g.dart';

/// What the picker needs to render one row.
@freezed
abstract class ModelChoice with _$ModelChoice {
  const factory ModelChoice({
    required ModelSource source,

    /// The resolved descriptor, or null while it is being resolved or when
    /// resolution failed.
    LocalModel? model,

    /// Whether the bytes are on disk and verified.
    @Default(false) bool downloaded,

    /// Whether the device reports enough memory for this model.
    @Default(true) bool fitsDevice,

    /// Whether this is the model currently loaded.
    @Default(false) bool selected,
  }) = _ModelChoice;

  const ModelChoice._();

  /// Whether the row can be picked at all.
  ///
  /// A model whose digest could not be read is shown but not selectable: the
  /// download would fail verification, so offering it as a choice is a dead end.
  bool get isUsable => model != null;
}

/// The state of the model picker screen.
@freezed
abstract class ModelPickerState with _$ModelPickerState {
  const factory ModelPickerState({
    @Default([]) List<ModelChoice> choices,
    @Default(true) bool loading,

    /// Set when the whole listing could not be prepared. Per-row resolution
    /// failures live on [ModelChoice.model] instead.
    String? failure,

    /// The model currently being downloaded, if any.
    String? downloadingId,

    /// 0.0–1.0 for `downloadingId`.
    double? downloadProgress,

    /// The model currently being loaded into memory.
    String? loadingModelId,
  }) = _ModelPickerState;

  const ModelPickerState._();

  /// The row being downloaded or loaded, if any.
  ///
  /// A single flag for both phases: they are mutually exclusive by construction
  /// (the controller refuses a second operation while one runs), and the UI needs
  /// "is something happening to this row" more than it needs to distinguish them.
  bool isBusy(String id) => downloadingId == id || loadingModelId == id;
}

@riverpod
class ModelPickerController extends _$ModelPickerController {
  @override
  Future<ModelPickerState> build() async {
    final assistant = ref.watch(localAssistantProvider);
    final resolver = ref.watch(modelSourceResolverProvider);
    final probe = ref.watch(localModelMemoryProvider);
    final selected = ref.watch(selectedModelSourceProvider);

    final memoryGb = await probe.totalMemoryGb();
    final choices = <ModelChoice>[];

    // Resolved one at a time rather than in parallel: each is a small request, and
    // a burst of a dozen simultaneous requests to one host is a good way to be rate
    // limited.
    for (final source in availableModels) {
      LocalModel? resolved;
      try {
        resolved = await resolver.resolve(source);
      } on Object {
        // Shown as unavailable rather than hidden: the user should see the option
        // exists and is broken right now, not silently get a shorter list.
        resolved = null;
      }
      choices.add(
        ModelChoice(
          source: source,
          model: resolved,
          downloaded: resolved != null && assistant.isDownloaded(resolved),
          // Unknown memory means "assume it fits": hiding every model on a platform
          // whose probe failed would hide the feature.
          fitsDevice: memoryGb == null || source.minDeviceMemoryGb <= memoryGb,
          selected: selected?.id == source.id && assistant.isReady,
        ),
      );
    }

    return ModelPickerState(choices: choices, loading: false);
  }

  /// Downloads [source]'s bytes without loading them.
  ///
  /// Separate from [select] so a user can pre-fetch on Wi-Fi and switch instantly
  /// later: the download is the bandwidth cost, the load is the memory cost.
  Future<void> download(ModelSource source) async {
    final current = state.asData?.value;
    if (current == null || current.downloadingId != null) return;

    final assistant = ref.read(localAssistantProvider);
    final model = await ref.read(modelSourceResolverProvider).resolve(source);

    state = AsyncData(
      current.copyWith(downloadingId: source.id, downloadProgress: 0),
    );
    try {
      await assistant.download(
        model,
        onProgress: (progress) {
          final latest = state.asData?.value;
          if (latest == null || latest.downloadingId != source.id) return;
          state = AsyncData(latest.copyWith(downloadProgress: progress));
        },
      );
      _setDownloaded(source.id, downloaded: true);
    } finally {
      final latest = state.asData?.value;
      if (latest != null) {
        state = AsyncData(
          latest.copyWith(downloadingId: null, downloadProgress: null),
        );
      }
    }
  }

  /// Persists [source] as the chosen model and loads it.
  ///
  /// Loading is what costs memory, so it happens here — when the user asks for the
  /// assistant — not when they merely selected a row.
  Future<void> select(ModelSource source) async {
    final current = state.asData?.value;
    if (current == null || current.loadingModelId != null) return;

    final assistant = ref.read(localAssistantProvider);
    final model = await ref.read(modelSourceResolverProvider).resolve(source);

    state = AsyncData(current.copyWith(loadingModelId: source.id));
    try {
      // Persist before loading: if the load fails, the choice is still remembered so
      // the next attempt does not make the user pick again.
      await ref.read(localModelSelectionProvider.notifier).remember(source);
      await assistant.load(model);
      _setSelected(source.id);
    } finally {
      final latest = state.asData?.value;
      if (latest != null) {
        state = AsyncData(latest.copyWith(loadingModelId: null));
      }
    }
  }

  /// Deletes a downloaded model from disk.
  Future<void> remove(ModelSource source) async {
    final assistant = ref.read(localAssistantProvider);
    final model = await ref.read(modelSourceResolverProvider).resolve(source);
    // Unload first: deleting a file the engine has mapped is unsafe.
    if (assistant.loadedModel?.id == source.id) {
      await assistant.unload();
    }
    await assistant.discard(model);
    _setDownloaded(source.id, downloaded: false, selected: false);
  }

  void _setDownloaded(String id, {required bool downloaded, bool? selected}) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        choices: [
          for (final choice in current.choices)
            if (choice.source.id == id)
              choice.copyWith(
                downloaded: downloaded,
                selected: selected ?? choice.selected,
              )
            else if (selected == true)
              // Only one model is ever selected.
              choice.copyWith(selected: false)
            else
              choice,
        ],
      ),
    );
  }

  void _setSelected(String id) {
    _setDownloaded(id, downloaded: true, selected: true);
  }
}
