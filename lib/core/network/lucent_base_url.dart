import 'package:luminous/core/config/env_keys.dart';
import 'package:flutter/foundation.dart';
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
      // Debug fallback to local development server
      return 'http://127.0.0.1:3000';
    }
    return normalized;
  }
}
