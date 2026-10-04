import 'package:luminous/core/errors/client_error_code.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/auth/data/datasources/wechat/mobile_auth_client_base.dart';

class DefaultWechatMobileAuthClient extends WechatMobileAuthClient {
  const DefaultWechatMobileAuthClient();

  @override
  bool get isSupported => false;

  @override
  Future<String> authorize() {
    // 调用方（`WechatOAuthService.tryMobileAuth`）先看 isSupported，正常不会走到
    // 这里；真走到时必须抛出可本地化的失败，而不是英文 UnsupportedError。
    throw LucentFailure.client(
      clientErrorCode: ClientErrorCode.wechatMobileUnsupported,
      message: 'WeChat mobile SDK login is not supported.',
    );
  }
}
