abstract class WechatMobileAuthClient {
  const WechatMobileAuthClient();

  bool get isSupported;

  Future<String> authorize();
}
