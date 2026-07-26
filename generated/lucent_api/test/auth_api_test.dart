import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for AuthApi
void main() {
  final instance = LucentApi().getAuthApi();

  group(AuthApi, () {
    // Forgot password
    //
    //Future<ForgotPasswordResponseDto> localControllerForgotPasswordV1(ForgotPasswordDto forgotPasswordDto) async
    test('test localControllerForgotPasswordV1', () async {
      // TODO
    });

    // User login
    //
    //Future<LoginResponseDto> localControllerLoginV1(LoginDto loginDto) async
    test('test localControllerLoginV1', () async {
      // TODO
    });

    // User registration
    //
    //Future<RegisterResponseDto> localControllerRegisterV1(RegisterDto registerDto) async
    test('test localControllerRegisterV1', () async {
      // TODO
    });

    // Reset password
    //
    //Future<SuccessResponseDto> localControllerResetPasswordV1(ResetPasswordDto resetPasswordDto) async
    test('test localControllerResetPasswordV1', () async {
      // TODO
    });

    // Send email verification code
    //
    //Future<SendVerificationCodeResponseDto> localControllerSendVerificationCodeV1(SendVerificationCodeDto sendVerificationCodeDto) async
    test('test localControllerSendVerificationCodeV1', () async {
      // TODO
    });

    // Verify email
    //
    //Future<VerifyEmailResponseDto> localControllerVerifyEmailV1(VerifyEmailDto verifyEmailDto) async
    test('test localControllerVerifyEmailV1', () async {
      // TODO
    });

    // Create QQ OAuth authorize URL
    //
    //Future<OAuthAuthorizeResponseDto> oAuthControllerCreateQqAuthorizeUrlV1({ QqOAuthAuthorizeDto qqOAuthAuthorizeDto }) async
    test('test oAuthControllerCreateQqAuthorizeUrlV1', () async {
      // TODO
    });

    // Create WeChat web OAuth authorize URL
    //
    //Future<OAuthAuthorizeResponseDto> oAuthControllerCreateWechatWebAuthorizeUrlV1({ OAuthAuthorizeDto oAuthAuthorizeDto }) async
    test('test oAuthControllerCreateWechatWebAuthorizeUrlV1', () async {
      // TODO
    });

    // Apple Sign-In callback
    //
    //Future<LoginResponseDto> oAuthControllerLoginWithAppleV1(AppleOAuthCallbackDto appleOAuthCallbackDto) async
    test('test oAuthControllerLoginWithAppleV1', () async {
      // TODO
    });

    // QQ OAuth callback login
    //
    //Future<LoginResponseDto> oAuthControllerLoginWithQqV1(QqOAuthCallbackDto qqOAuthCallbackDto) async
    test('test oAuthControllerLoginWithQqV1', () async {
      // TODO
    });

    // WeChat mobile OAuth callback login
    //
    //Future<LoginResponseDto> oAuthControllerLoginWithWechatMobileV1(OAuthCodeCallbackDto oAuthCodeCallbackDto) async
    test('test oAuthControllerLoginWithWechatMobileV1', () async {
      // TODO
    });

    // WeChat web OAuth callback login
    //
    //Future<LoginResponseDto> oAuthControllerLoginWithWechatWebV1(OAuthCallbackDto oAuthCallbackDto) async
    test('test oAuthControllerLoginWithWechatWebV1', () async {
      // TODO
    });

    // WeChat web OAuth browser redirect
    //
    //Future oAuthControllerRedirectWechatWebCallbackV1(String code, String state) async
    test('test oAuthControllerRedirectWechatWebCallbackV1', () async {
      // TODO
    });

    // List active sessions for the current user
    //
    //Future sessionControllerListSessionsV1() async
    test('test sessionControllerListSessionsV1', () async {
      // TODO
    });

    // User logout
    //
    //Future<SuccessResponseDto> sessionControllerLogoutV1(LogoutDto logoutDto) async
    test('test sessionControllerLogoutV1', () async {
      // TODO
    });

    // Refresh token
    //
    //Future<RefreshResponseDto> sessionControllerRefreshV1(RefreshDto refreshDto) async
    test('test sessionControllerRefreshV1', () async {
      // TODO
    });

    // Revoke a specific session
    //
    //Future sessionControllerRevokeSessionV1(String sessionId) async
    test('test sessionControllerRevokeSessionV1', () async {
      // TODO
    });
  });
}
