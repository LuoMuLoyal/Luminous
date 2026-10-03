import 'package:flutter/foundation.dart';
import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';

abstract final class LucentBaseUrl {
  static String get defineKey => EnvKey.lucentBaseUrl.wireName;

  /// The base URL explicitly pinned by the build, or `null` when no
  /// `LUCENT_BASE_URL` was supplied (`--dart-define` /
  /// `--dart-define-from-file`).
  ///
  /// [value] always returns a non-empty string in debug builds, so it cannot
  /// tell "the build pinned an endpoint" apart from "nobody configured
  /// anything, fall back to localhost". Callers that need that distinction
  /// (the developer-settings default) must use this getter.
  static String? get configured {
    final normalized = EnvReader.string(EnvKey.lucentBaseUrl).trim();
    return normalized.isEmpty ? null : normalized;
  }

  /// The `LUCENT_PROD_BASE_URL` pinned by the build, or `null` when unset.
  ///
  /// The deployed host address never lives in the repository (it would be
  /// published with the repo): it is injected at build time through `.env` /
  /// CI secrets and read back by the 「生产」developer preset. See
  /// `DeveloperSettingsState.resolvedBaseUrl`.
  static String? get productionConfigured {
    final normalized = EnvReader.string(EnvKey.lucentProdBaseUrl).trim();
    return normalized.isEmpty ? null : normalized;
  }

  static String get value {
    final pinned = configured;
    if (pinned != null) return pinned;

    if (kReleaseMode) {
      throw StateError('LUCENT_BASE_URL must be configured in release builds.');
    }
    // Debug fallback to local development server.
    // On Android emulators, 127.0.0.1 refers to the emulator itself;
    // use 10.0.2.2 to reach the host machine's loopback interface.
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:3000'
        : 'http://127.0.0.1:3000';
  }
}
