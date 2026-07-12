import 'package:luminous/core/config/env_keys.dart';
import 'package:luminous/core/config/env_reader.dart';

abstract final class WechatMobileAuthConfig {
  static String get appIdDefineKey => EnvKey.wechatMobileAppId.wireName;
  static String get iosUniversalLinkDefineKey =>
      EnvKey.wechatIosUniversalLink.wireName;

  static String get appId => EnvReader.string(EnvKey.wechatMobileAppId);
  static String get iosUniversalLink =>
      EnvReader.string(EnvKey.wechatIosUniversalLink);
  static bool get hasAppId => appId.trim().isNotEmpty;
}
