import 'package:luminous/core/config/env_keys.dart';

/// Unified reader for compile-time environment variables supplied via
/// `--dart-define` or `--dart-define-from-file`.
///
/// For unit and widget tests, use [setTestValue] to inject values without
/// recompiling. Call [clearTestValues] (e.g. in `tearDown`) to keep tests
/// isolated.
abstract final class EnvReader {
  static final Map<EnvKey, String> _testOverrides = {};

  /// Returns the string value for [key].
  ///
  /// Resolution order:
  /// 1. Test override (if set).
  /// 2. Build-time `String.fromEnvironment(...)` for the known key.
  /// 3. [fallback], or an empty string if none is provided.
  static String string(EnvKey key, {String fallback = ''}) {
    final overridden = _testOverrides[key];
    if (overridden != null) return overridden.trim();

    final value = _readEnvironmentValue(key).trim();
    if (value.isEmpty) return fallback;
    return value;
  }

  /// Parses the value for [key] as a boolean.
  ///
  /// Recognizes `true`, `1`, and `yes` (case-insensitive) as true.
  /// Returns [fallback] when the value is empty.
  static bool boolValue(EnvKey key, {bool fallback = false}) {
    final value = string(key).toLowerCase();
    if (value.isEmpty) return fallback;
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Overrides the value of [key] for the current test isolate.
  static void setTestValue(EnvKey key, String value) =>
      _testOverrides[key] = value;

  /// Clears all test overrides.
  static void clearTestValues() => _testOverrides.clear();

  static String _readEnvironmentValue(EnvKey key) {
    switch (key) {
      case EnvKey.lucentBaseUrl:
        return const String.fromEnvironment('LUCENT_BASE_URL');
      case EnvKey.e2eLucentBaseUrl:
        return const String.fromEnvironment('E2E_LUCENT_BASE_URL');
      case EnvKey.wechatMobileAppId:
        return const String.fromEnvironment('WECHAT_MOBILE_APP_ID');
      case EnvKey.wechatIosUniversalLink:
        return const String.fromEnvironment('WECHAT_IOS_UNIVERSAL_LINK');
      case EnvKey.e2eTestEmail:
        return const String.fromEnvironment('E2E_TEST_EMAIL');
      case EnvKey.e2eTestPassword:
        return const String.fromEnvironment('E2E_TEST_PASSWORD');
      case EnvKey.e2eRecordDate:
        return const String.fromEnvironment('E2E_RECORD_DATE');
      case EnvKey.e2eTestNickname:
        return const String.fromEnvironment('E2E_TEST_NICKNAME');
      case EnvKey.luminousExperimentalAiRuntime:
        return const String.fromEnvironment('LUMINOUS_EXPERIMENTAL_AI_RUNTIME');
      case EnvKey.luminousAiRuntimeProvider:
        return const String.fromEnvironment('LUMINOUS_AI_RUNTIME_PROVIDER');
      case EnvKey.luminousEnableGenUi:
        return const String.fromEnvironment('LUMINOUS_ENABLE_GEN_UI');
      case EnvKey.sentryDsn:
        return const String.fromEnvironment('SENTRY_DSN');
    }
  }
}
