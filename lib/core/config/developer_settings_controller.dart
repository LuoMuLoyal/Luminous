import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/base_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart' as talker;

part 'developer_settings_controller.freezed.dart';

/// API endpoint presets available for developer switching.
///
/// Only visible in debug builds. In release, [ApiEndpoint.production]
/// is always used regardless of the stored preference.
enum ApiEndpoint {
  local('local', 'http://127.0.0.1:3000'),
  staging('staging', 'https://staging-api.luminous.app'),
  production('production', 'https://api.luminous.app'),
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
  /// For [ApiEndpoint.custom], returns [customApiUrl] if non-empty,
  /// otherwise falls back to the compile-time default.
  String get resolvedBaseUrl {
    if (apiEndpoint == ApiEndpoint.custom) {
      final custom = customApiUrl.trim();
      if (custom.isNotEmpty) return custom;
      return LucentBaseUrl.value;
    }
    return apiEndpoint.defaultUrl;
  }
}

class DeveloperSettingsController
    extends AsyncNotifier<DeveloperSettingsState> {
  static const _apiEndpointKey = 'developer.apiEndpoint';
  static const _customApiUrlKey = 'developer.customApiUrl';
  static const _logLevelKey = 'developer.logLevel';

  talker.Talker get _talker => ref.read(talkerProvider);

  @override
  Future<DeveloperSettingsState> build() async {
    final preferences = await SharedPreferences.getInstance();
    final endpoint = ApiEndpoint.fromStorage(
      preferences.getString(_apiEndpointKey),
    );
    final customUrl = preferences.getString(_customApiUrlKey) ?? '';
    final level = LogLevel.fromString(preferences.getString(_logLevelKey));

    // Apply log level immediately.
    _applyLogLevel(level);

    // In release mode, force production endpoint.
    if (kReleaseMode) {
      return const DeveloperSettingsState(
        apiEndpoint: ApiEndpoint.production,
        logLevel: LogLevel.info,
      );
    }

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
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_apiEndpointKey, endpoint.storageValue);
  }

  Future<void> setCustomApiUrl(String url) async {
    final current = state.asData?.value ?? const DeveloperSettingsState();
    final next = current.copyWith(customApiUrl: url);
    state = AsyncData(next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_customApiUrlKey, url);
  }

  Future<void> setLogLevel(LogLevel level) async {
    final current = state.asData?.value ?? const DeveloperSettingsState();
    final next = current.copyWith(logLevel: level);
    state = AsyncData(next);
    _applyLogLevel(level);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_logLevelKey, level.name);
  }

  Future<void> reset() async {
    state = const AsyncData(DeveloperSettingsState());
    _applyLogLevel(LogLevel.info);
    final preferences = await SharedPreferences.getInstance();
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
