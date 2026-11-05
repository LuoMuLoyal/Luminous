import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/client/base_url.dart';
import 'package:luminous/core/network/config/pref_keys.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:talker_flutter/talker_flutter.dart' as talker;

part 'developer_settings.freezed.dart';

/// Normalizes a user-entered API endpoint into a URL the client can dial.
///
/// Re-exported from this layer so the settings UI (presentation) does not have
/// to import `core/network` directly. Returns `null` when the input cannot be
/// turned into an http(s) URL — the endpoint sheet must reject it instead of
/// persisting a value that would break Dio.
String? normalizeApiUrl(String raw) => LucentBaseUrl.normalize(raw);

/// API endpoint presets available for developer switching.
///
/// Runtime surface in every build mode: the stored choice decides where the
/// app talks (see `lucentBaseUrlProvider`). A build-pinned `LUCENT_BASE_URL`
/// only seeds the default when no choice is stored, so a release package can
/// be repointed without a rebuild.
enum ApiEndpoint {
  local('local', 'http://127.0.0.1:3000'),
  // 没有预发布环境（三台机器是同一套生产拓扑，见工作区 DEPLOY-SYSTEM-INFO.md），
  // 该预设仍是占位值：选中只会指向手机/模拟器自身。
  staging('staging', 'http://127.0.0.1:3000'),
  // 已部署主站。地址**不入库**（仓库是公开的），由构建期 `LUCENT_PROD_BASE_URL`
  // 注入，见 DeveloperSettingsState.resolvedBaseUrl；`defaultUrl` 因此留空。
  production('production', ''),
  custom('custom', '');

  const ApiEndpoint(this.storageValue, this.defaultUrl);

  /// Value persisted in [SharedPreferences].
  final String storageValue;

  /// Default URL for this endpoint. Empty for [custom] (user must supply).
  final String defaultUrl;

  static ApiEndpoint fromStorage(String? value) {
    for (final endpoint in ApiEndpoint.values) {
      if (endpoint.storageValue == value) {
        return endpoint;
      }
    }
    return ApiEndpoint.local;
  }
}

@freezed
abstract class DeveloperSettingsState with _$DeveloperSettingsState {
  const factory DeveloperSettingsState({
    @Default(ApiEndpoint.local) ApiEndpoint apiEndpoint,
    @Default('') String customApiUrl,
    @Default(LogLevel.info) LogLevel logLevel,
  }) = _DeveloperSettingsState;

  const DeveloperSettingsState._();

  /// The resolved base URL based on the current [apiEndpoint] selection.
  ///
  /// Always returns a URL that Dio can parse: [LucentBaseUrl.normalize] repairs
  /// scheme-less input (`122.9.102.50:3000` → `http://122.9.102.50:3000`) and
  /// falls back to the compile-time default when the stored custom value is
  /// unusable, so a bad preference saved by an older build cannot put the HTTP
  /// client provider into an error state.
  ///
  /// For [ApiEndpoint.custom], returns the normalized [customApiUrl] if
  /// usable, otherwise falls back to the compile-time default.
  ///
  /// For [ApiEndpoint.production], returns the build-injected
  /// `LUCENT_PROD_BASE_URL`, falling back to the compile-time
  /// `LUCENT_BASE_URL` (which is the production host in any real build).
  ///
  /// For [ApiEndpoint.local], uses `10.0.2.2` on Android emulators (where
  /// `127.0.0.1` refers to the emulator itself) and `127.0.0.1` elsewhere.
  String get resolvedBaseUrl {
    if (apiEndpoint == ApiEndpoint.custom) {
      final custom = LucentBaseUrl.normalize(customApiUrl);
      if (custom != null) return custom;
      return LucentBaseUrl.value;
    }
    if (apiEndpoint == ApiEndpoint.production) {
      return LucentBaseUrl.productionConfigured ?? LucentBaseUrl.value;
    }
    if (apiEndpoint == ApiEndpoint.local) {
      return LucentBaseUrl.fallback;
    }
    return apiEndpoint.defaultUrl;
  }
}

class DeveloperSettingsController
    extends AsyncNotifier<DeveloperSettingsState> {
  static const _apiEndpointKey = PrefKeys.developerApiEndpoint;
  static const _customApiUrlKey = PrefKeys.developerCustomApiUrl;
  static const _logLevelKey = PrefKeys.developerLogLevel;

  talker.Talker get _talker => ref.read(talkerProvider);

  /// The endpoint to use while the developer has never made a choice.
  ///
  /// A build that pins `LUCENT_BASE_URL` (`--dart-define` /
  /// `--dart-define-from-file`) keeps that URL: the local preset is only
  /// correct on emulators/simulators/desktop, so defaulting an Android
  /// physical device to the emulator-only `10.0.2.2` alias silently breaks
  /// every request with a connection timeout.
  static ApiEndpoint get _defaultEndpoint =>
      LucentBaseUrl.configured == null ? ApiEndpoint.local : ApiEndpoint.custom;

  static String get _defaultCustomApiUrl => LucentBaseUrl.configured ?? '';

  static DeveloperSettingsState get _defaultState => DeveloperSettingsState(
    apiEndpoint: _defaultEndpoint,
    customApiUrl: _defaultCustomApiUrl,
  );

  @override
  Future<DeveloperSettingsState> build() async {
    final preferences = KvStore.instance;
    final storedEndpoint = preferences.getOrNull<String>(_apiEndpointKey);
    final endpoint = storedEndpoint == null
        ? _defaultEndpoint
        : ApiEndpoint.fromStorage(storedEndpoint);
    final customUrl =
        preferences.getOrNull<String>(_customApiUrlKey) ?? _defaultCustomApiUrl;
    final level = LogLevel.fromString(
      preferences.getOrNull<String>(_logLevelKey),
    );

    // Apply log level immediately.
    _applyLogLevel(level);

    return DeveloperSettingsState(
      apiEndpoint: endpoint,
      customApiUrl: customUrl,
      logLevel: level,
    );
  }

  Future<void> setApiEndpoint(ApiEndpoint endpoint) async {
    final current = state.asData?.value ?? const DeveloperSettingsState();
    final next = current.copyWith(apiEndpoint: endpoint);
    state = AsyncData(next);
    final preferences = KvStore.instance;
    await preferences.set(_apiEndpointKey, endpoint.storageValue);
  }

  Future<void> setCustomApiUrl(String url) async {
    final current = state.asData?.value ?? const DeveloperSettingsState();
    final next = current.copyWith(customApiUrl: url);
    state = AsyncData(next);
    final preferences = KvStore.instance;
    await preferences.set(_customApiUrlKey, url);
  }

  Future<void> setLogLevel(LogLevel level) async {
    final current = state.asData?.value ?? const DeveloperSettingsState();
    final next = current.copyWith(logLevel: level);
    state = AsyncData(next);
    _applyLogLevel(level);
    final preferences = KvStore.instance;
    await preferences.set(_logLevelKey, level.name);
  }

  Future<void> reset() async {
    state = AsyncData(_defaultState);
    _applyLogLevel(LogLevel.info);
    final preferences = KvStore.instance;
    await preferences.remove(_apiEndpointKey);
    await preferences.remove(_customApiUrlKey);
    await preferences.remove(_logLevelKey);
  }

  void _applyLogLevel(LogLevel level) {
    applyLogLevelToTalker(_talker, level);
  }
}

final developerSettingsControllerProvider =
    AsyncNotifierProvider<DeveloperSettingsController, DeveloperSettingsState>(
      DeveloperSettingsController.new,
    );
