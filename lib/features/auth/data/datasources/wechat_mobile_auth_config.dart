abstract final class WechatMobileAuthConfig {
  static const String appIdDefineKey = 'WECHAT_MOBILE_APP_ID';
  static const String iosUniversalLinkDefineKey = 'WECHAT_IOS_UNIVERSAL_LINK';

  static const String appId = String.fromEnvironment(appIdDefineKey);
  static const String iosUniversalLink = String.fromEnvironment(
    iosUniversalLinkDefineKey,
  );

  static bool get hasAppId => appId.trim().isNotEmpty;
}
