import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class LucentBaseUrl {
  static const String defineKey = 'LUCENT_BASE_URL';
  static const String _fallback = 'http://127.0.0.1:3000';

  static String get value {
    try {
      final raw = dotenv.get(defineKey, fallback: _fallback);
      final normalized = raw.trim();
      return normalized.isEmpty ? _fallback : normalized;
    } catch (_) {
      return _fallback;
    }
  }
}
