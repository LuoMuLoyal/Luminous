import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';

/// tests for AuthApi
void main() {
  final instance = LucentOpenapi().getAuthApi();

  group(AuthApi, () {
    // 创建微信网页登录授权地址
    //
    //Future<OAuthAuthorizeResponseDto> authControllerCreateWechatWebAuthorizeUrlV1({ OAuthAuthorizeDto oAuthAuthorizeDto }) async
    test('test authControllerCreateWechatWebAuthorizeUrlV1', () async {
      // TODO
    });

    // 忘记密码
    //
    //Future<ForgotPasswordResponseDto> authControllerForgotPasswordV1(ForgotPasswordDto forgotPasswordDto) async
    test('test authControllerForgotPasswordV1', () async {
      // TODO
    });

    // 用户登录
    //
    //Future<LoginResponseDto> authControllerLoginV1(LoginDto loginDto) async
    test('test authControllerLoginV1', () async {
      // TODO
    });

    // 微信移动端登录回调
    //
    //Future<LoginResponseDto> authControllerLoginWithWechatMobileV1(OAuthCodeCallbackDto oAuthCodeCallbackDto) async
    test('test authControllerLoginWithWechatMobileV1', () async {
      // TODO
    });

    // 微信网页登录回调登录
    //
    //Future<LoginResponseDto> authControllerLoginWithWechatWebV1(OAuthCallbackDto oAuthCallbackDto) async
    test('test authControllerLoginWithWechatWebV1', () async {
      // TODO
    });

    // 用户登出
    //
    //Future<SuccessResponseDto> authControllerLogoutV1(LogoutDto logoutDto) async
    test('test authControllerLogoutV1', () async {
      // TODO
    });

    // 微信网页登录浏览器回跳
    //
    //Future authControllerRedirectWechatWebCallbackV1(String code, String state) async
    test('test authControllerRedirectWechatWebCallbackV1', () async {
      // TODO
    });

    // 刷新令牌
    //
    //Future<RefreshResponseDto> authControllerRefreshV1(RefreshDto refreshDto) async
    test('test authControllerRefreshV1', () async {
      // TODO
    });

    // 用户注册
    //
    //Future<RegisterResponseDto> authControllerRegisterV1(RegisterDto registerDto) async
    test('test authControllerRegisterV1', () async {
      // TODO
    });

    // 重置密码
    //
    //Future<SuccessResponseDto> authControllerResetPasswordV1(ResetPasswordDto resetPasswordDto) async
    test('test authControllerResetPasswordV1', () async {
      // TODO
    });

    // 发送邮箱验证码
    //
    //Future<SendVerificationCodeResponseDto> authControllerSendVerificationCodeV1(SendVerificationCodeDto sendVerificationCodeDto) async
    test('test authControllerSendVerificationCodeV1', () async {
      // TODO
    });

    // 验证邮箱
    //
    //Future<VerifyEmailResponseDto> authControllerVerifyEmailV1(VerifyEmailDto verifyEmailDto) async
    test('test authControllerVerifyEmailV1', () async {
      // TODO
    });
  });
}
