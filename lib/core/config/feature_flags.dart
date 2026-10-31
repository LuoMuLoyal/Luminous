import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/experiments/runtime/config.dart';
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
    @Default(false) bool onDeviceRuntime,
    @Default(RuntimeProviderKind.none) RuntimeProviderKind runtimeProvider,
    @Default(false) bool genUiEnabled,
    @Default(true) bool assistantStreamMode,
    @Default(false) bool medicineBarcodeScan,
    @Default(false) bool reportExportPdf,
  }) = _FeatureFlagsState;

  const FeatureFlagsState._();

  /// Count of enabled flags (for summary display).
  int get enabledCount {
    var count = 0;
    if (onDeviceRuntime) count++;
    if (genUiEnabled) count++;
    if (assistantStreamMode) count++;
    if (medicineBarcodeScan) count++;
    if (reportExportPdf) count++;
    // runtimeProvider is an enum, not a simple toggle; skip.
    return count;
  }

  /// Total number of toggleable flags (excludes the provider enum).
  static const int totalCount = 5;
}

class FeatureFlagsController extends AsyncNotifier<FeatureFlagsState> {
  static const _onDeviceRuntimeKey = PrefKeys.featureFlagsOnDeviceRuntime;
  static const _aiProviderKey = PrefKeys.featureFlagsRuntimeProvider;
  static const _genUiKey = PrefKeys.featureFlagsGenUiEnabled;
  static const _streamModeKey = PrefKeys.featureFlagsAssistantStreamMode;
  static const _barcodeScanKey = PrefKeys.featureFlagsMedicineBarcodeScan;
  static const _pdfExportKey = PrefKeys.featureFlagsReportExportPdf;

  @override
  Future<FeatureFlagsState> build() async {
    final preferences = KvStore.instance;

    // Seed from compile-time env on first launch.
    final envConfig = RuntimeConfig.fromEnvironment(
      RuntimeEnvironment.fromPlatform(),
    );

    final onDeviceRuntime = preferences.get<bool>(
      _onDeviceRuntimeKey,
      fallback: envConfig.enabled,
    );
    final runtimeProvider = _providerFromStorage(
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
      onDeviceRuntime: onDeviceRuntime,
      runtimeProvider: runtimeProvider,
      genUiEnabled: genUiEnabled,
      assistantStreamMode: streamMode,
      medicineBarcodeScan: barcodeScan,
      reportExportPdf: pdfExport,
    );
  }

  Future<void> setOnDeviceRuntime(bool enabled) async {
    final current = state.asData?.value ?? const FeatureFlagsState();
    state = AsyncData(current.copyWith(onDeviceRuntime: enabled));
    final preferences = KvStore.instance;
    await preferences.set(_onDeviceRuntimeKey, enabled);
  }

  Future<void> setRuntimeProvider(RuntimeProviderKind provider) async {
    final current = state.asData?.value ?? const FeatureFlagsState();
    state = AsyncData(current.copyWith(runtimeProvider: provider));
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
    await preferences.remove(_onDeviceRuntimeKey);
    await preferences.remove(_aiProviderKey);
    await preferences.remove(_genUiKey);
    await preferences.remove(_streamModeKey);
    await preferences.remove(_barcodeScanKey);
    await preferences.remove(_pdfExportKey);
  }

  static RuntimeProviderKind _providerFromStorage(
    String? stored,
    RuntimeProviderKind fallback,
  ) {
    if (stored == null) return fallback;
    for (final kind in RuntimeProviderKind.values) {
      if (kind.name == stored) return kind;
    }
    return fallback;
  }
}

final featureFlagsControllerProvider =
    AsyncNotifierProvider<FeatureFlagsController, FeatureFlagsState>(
      FeatureFlagsController.new,
    );

/// `genUiEnabled` 的同步读法，供**装配层**判断「要不要注册生成式组件」。
///
/// 为什么不直接用 `featureFlagsControllerProvider`：
/// - 它是 `AsyncValue`，首帧（flag 还没从 `KvStore` 读出来）是 `loading`。
///   装配点若把 loading 当成 false 去注册，会让「已开启」的用户在冷启动首帧
///   看到组件缺失；若当成 true 又会让默认关闭的用户短暂拿到组件。
///   这里在加载中沿用 [FeatureFlagsState] 的默认值（genUi 默认关闭），
///   与「默认关闭」的语义一致。
/// - 装配点是同步 build，不能 await。
///
/// 加载完成后它随 controller 一起更新，所以用户改开关会**立即**引发 registry
/// 重建（前提是读取方用 `watch`，见 `app/composition/components/registry.dart`）。
final genUiEnabledProvider = Provider<bool>((ref) {
  final flags = ref.watch(featureFlagsControllerProvider).asData?.value;
  return flags?.genUiEnabled ?? const FeatureFlagsState().genUiEnabled;
}, name: 'genUiEnabled');
