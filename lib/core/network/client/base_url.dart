import 'package:flutter/foundation.dart';
import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';

abstract final class LucentBaseUrl {
  static String get defineKey => EnvKey.lucentBaseUrl.wireName;

  static String get value {
    final raw = EnvReader.string(EnvKey.lucentBaseUrl);
    final normalized = raw.trim();
    if (normalized.isEmpty) {
      if (kReleaseMode) {
        throw StateError(
          'LUCENT_BASE_URL must be configured in release builds.',
        );
      }
      // Debug fallback to local development server.
      // On Android emulators, 127.0.0.1 refers to the emulator itself;
      // use 10.0.2.2 to reach the host machine's loopback interface.
      return defaultTargetPlatform == TargetPlatform.android
          ? 'http://10.0.2.2:3000'
          : 'http://127.0.0.1:3000';
    }
    return normalized;
  }
}
