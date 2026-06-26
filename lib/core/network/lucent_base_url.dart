import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class LucentBaseUrl {
  static const String defineKey = 'LUCENT_BASE_URL';

  static String get value {
    final raw = dotenv.get(defineKey, fallback: '');
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
