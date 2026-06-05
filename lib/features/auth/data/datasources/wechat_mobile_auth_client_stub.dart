import 'package:luminous/features/auth/data/datasources/wechat_mobile_auth_client_base.dart';

class DefaultWechatMobileAuthClient extends WechatMobileAuthClient {
  const DefaultWechatMobileAuthClient();

  @override
  bool get isSupported => false;

  @override
  Future<String> authorize() {
    throw UnsupportedError('WeChat mobile SDK login is not supported.');
  }
}
