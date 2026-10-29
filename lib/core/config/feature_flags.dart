import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/ai/runtime_config.dart';
import 'package:luminous/core/network/config/pref_keys.dart';
import 'package:luminous/core/storage/kv_store.dart';

part 'feature_flags.freezed.dart';

/// Experimental feature flags that can be toggled at runtime in debug mode.
///
/// Defaults are seeded from compile-time environment variables on first
/// launch. Subsequent reads come from [SharedPreferences], allowing
/// runtime overrides without recompilation.
@freezed
abstract class FeatureFlagsState with _$FeatureFlagsState {
  const factory FeatureFlagsState({
    @Default(false) bool onDeviceAiRuntime,
    @Default(AiRuntimeProviderKind.none)
    AiRuntimeProviderKind aiRuntimeProvider,
    @Default(false) bool genUiEnabled,
    @Default(true) bool assistantStreamMode,
    @Default(false) bool medicineBarcodeScan,
    @Default(false) bool reportExportPdf,
  }) = _FeatureFlagsState;

  const FeatureFlagsState._();

  /// Count of enabled flags (for summary display).
  int get enabledCount {
    var count = 0;
    if (onDeviceAiRuntime) count++;
    if (genUiEnabled) count++;
    if (assistantStreamMode) count++;
    if (medicineBarcodeScan) count++;
    if (reportExportPdf) count++;
    // aiRuntimeProvider is an enum, not a simple toggle; skip.
    return count;
  }

  /// Total number of toggleable flags (excludes the provider enum).
  static const int totalCount = 5;
}

class FeatureFlagsController extends AsyncNotifier<FeatureFlagsState> {
  static const _onDeviceAiRuntimeKey = PrefKeys.featureFlagsOnDeviceAiRuntime;
  static const _aiProviderKey = PrefKeys.featureFlagsAiRuntimeProvider;
  static const _genUiKey = PrefKeys.featureFlagsGenUiEnabled;
  static const _streamModeKey = PrefKeys.featureFlagsAssistantStreamMode;
  static const _barcodeScanKey = PrefKeys.featureFlagsMedicineBarcodeScan;
  static const _pdfExportKey = PrefKeys.featureFlagsReportExportPdf;

  @override
  Future<FeatureFlagsState> build() async {
    final preferences = KvStore.instance;

    // Seed from compile-time env on first launch.
    final envConfig = AiRuntimeConfig.fromEnvironment(
      AiRuntimeEnvironment.fromPlatform(),
    );

    final onDeviceAiRuntime = preferences.get<bool>(
      _onDeviceAiRuntimeKey,
      fallback: envConfig.enabled,
    );
    final aiRuntimeProvider = _providerFromStorage(
      preferences.getOrNull<String>(_aiProviderKey),
      envConfig.provider,
    );
    final genUiEnabled = preferences.get<bool>(
      _genUiKey,
      fallback: envConfig.genUiEnabled,
    );
    final streamMode = preferences.get<bool>(_streamModeKey, fallback: true);
    final barcodeScan = preferences.get<bool>(_barcodeScanKey, fallback: false);
    final pdfExport = preferences.get<bool>(_pdfExportKey, fallback: false);

    return FeatureFlagsState(
      onDeviceAiRuntime: onDeviceAiRuntime,
      aiRuntimeProvider: aiRuntimeProvider,
      genUiEnabled: genUiEnabled,
      assistantStreamMode: streamMode,
      medicineBarcodeScan: barcodeScan,
      reportExportPdf: pdfExport,
    );
  }

  Future<void> setOnDeviceAiRuntime(bool enabled) async {
    final current = state.asData?.value ?? const FeatureFlagsState();
    state = AsyncData(current.copyWith(onDeviceAiRuntime: enabled));
    final preferences = KvStore.instance;
    await preferences.set(_onDeviceAiRuntimeKey, enabled);
  }

  Future<void> setAiRuntimeProvider(AiRuntimeProviderKind provider) async {
    final current = state.asData?.value ?? const FeatureFlagsState();
    state = AsyncData(current.copyWith(aiRuntimeProvider: provider));
    final preferences = KvStore.instance;
    await preferences.set(_aiProviderKey, provider.name);
  }

  Future<void> setGenUiEnabled(bool enabled) async {
    final current = state.asData?.value ?? const FeatureFlagsState();
    state = AsyncData(current.copyWith(genUiEnabled: enabled));
    final preferences = KvStore.instance;
    await preferences.set(_genUiKey, enabled);
  }

  Future<void> setAssistantStreamMode(bool enabled) async {
    final current = state.asData?.value ?? const FeatureFlagsState();
    state = AsyncData(current.copyWith(assistantStreamMode: enabled));
    final preferences = KvStore.instance;
    await preferences.set(_streamModeKey, enabled);
  }

  Future<void> setMedicineBarcodeScan(bool enabled) async {
    final current = state.asData?.value ?? const FeatureFlagsState();
    state = AsyncData(current.copyWith(medicineBarcodeScan: enabled));
    final preferences = KvStore.instance;
    await preferences.set(_barcodeScanKey, enabled);
  }

  Future<void> setReportExportPdf(bool enabled) async {
    final current = state.asData?.value ?? const FeatureFlagsState();
    state = AsyncData(current.copyWith(reportExportPdf: enabled));
    final preferences = KvStore.instance;
    await preferences.set(_pdfExportKey, enabled);
  }

  Future<void> reset() async {
    state = const AsyncData(FeatureFlagsState());
    final preferences = KvStore.instance;
    await preferences.remove(_onDeviceAiRuntimeKey);
    await preferences.remove(_aiProviderKey);
    await preferences.remove(_genUiKey);
    await preferences.remove(_streamModeKey);
    await preferences.remove(_barcodeScanKey);
    await preferences.remove(_pdfExportKey);
  }

  static AiRuntimeProviderKind _providerFromStorage(
    String? stored,
    AiRuntimeProviderKind fallback,
  ) {
    if (stored == null) return fallback;
    for (final kind in AiRuntimeProviderKind.values) {
      if (kind.name == stored) return kind;
    }
    return fallback;
  }
}

final featureFlagsControllerProvider =
    AsyncNotifierProvider<FeatureFlagsController, FeatureFlagsState>(
      FeatureFlagsController.new,
    );
