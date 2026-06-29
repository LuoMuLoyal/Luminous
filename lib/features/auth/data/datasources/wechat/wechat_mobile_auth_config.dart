import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class WechatMobileAuthConfig {
  static const String appIdDefineKey = 'WECHAT_MOBILE_APP_ID';
  static const String iosUniversalLinkDefineKey = 'WECHAT_IOS_UNIVERSAL_LINK';

  static String get appId => _env(appIdDefineKey);
  static String get iosUniversalLink => _env(iosUniversalLinkDefineKey);

  static String _env(String key) {
    try {
      return dotenv.get(key, fallback: '');
    } catch (_) {
      return '';
    }
  }

  static bool get hasAppId => appId.trim().isNotEmpty;
}
