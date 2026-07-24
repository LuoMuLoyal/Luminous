// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/apple_o_auth_callback_dto.dart';
import '../models/forgot_password_dto.dart';
import '../models/forgot_password_response_dto.dart';
import '../models/login_dto.dart';
import '../models/login_response_dto.dart';
import '../models/logout_dto.dart';
import '../models/o_auth_authorize_dto.dart';
import '../models/o_auth_authorize_response_dto.dart';
import '../models/o_auth_callback_dto.dart';
import '../models/o_auth_code_callback_dto.dart';
import '../models/qq_o_auth_authorize_dto.dart';
import '../models/qq_o_auth_callback_dto.dart';
import '../models/refresh_dto.dart';
import '../models/refresh_response_dto.dart';
import '../models/register_dto.dart';
import '../models/register_response_dto.dart';
import '../models/reset_password_dto.dart';
import '../models/send_verification_code_dto.dart';
import '../models/send_verification_code_response_dto.dart';
import '../models/success_response_dto.dart';
import '../models/verify_email_dto.dart';
import '../models/verify_email_response_dto.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  /// User registration.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/register')
  Future<RegisterResponseDto> localControllerRegisterV1({
    @Body() required RegisterDto body,
  });

  /// User login.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/login')
  Future<LoginResponseDto> localControllerLoginV1({
    @Body() required LoginDto body,
  });

  /// Send email verification code.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/send-verification-code')
  Future<SendVerificationCodeResponseDto>
  localControllerSendVerificationCodeV1({
    @Body() required SendVerificationCodeDto body,
  });

  /// Verify email.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/verify-email')
  Future<VerifyEmailResponseDto> localControllerVerifyEmailV1({
    @Body() required VerifyEmailDto body,
  });

  /// Forgot password.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/forgot-password')
  Future<ForgotPasswordResponseDto> localControllerForgotPasswordV1({
    @Body() required ForgotPasswordDto body,
  });

  /// Reset password.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/reset-password')
  Future<SuccessResponseDto> localControllerResetPasswordV1({
    @Body() required ResetPasswordDto body,
  });

  /// Create WeChat web OAuth authorize URL.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/oauth/wechat-web/authorize')
  Future<OAuthAuthorizeResponseDto>
  oAuthControllerCreateWechatWebAuthorizeUrlV1({
    @Body() OAuthAuthorizeDto? body,
  });

  /// WeChat web OAuth callback login.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/oauth/wechat-web/callback')
  Future<LoginResponseDto> oAuthControllerLoginWithWechatWebV1({
    @Body() required OAuthCallbackDto body,
  });

  /// WeChat web OAuth browser redirect.
  ///
  /// [code] - OAuth 授权码.
  ///
  /// [state] - 授权时生成的 state.
  @GET('/api/v1/auth/oauth/wechat-web/callback')
  Future<void> oAuthControllerRedirectWechatWebCallbackV1({
    @Query('code') required String code,
    @Query('state') required String state,
  });

  /// WeChat mobile OAuth callback login.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/oauth/wechat-mobile/callback')
  Future<LoginResponseDto> oAuthControllerLoginWithWechatMobileV1({
    @Body() required OAuthCodeCallbackDto body,
  });

  /// Apple Sign-In callback.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/oauth/apple/callback')
  Future<LoginResponseDto> oAuthControllerLoginWithAppleV1({
    @Body() required AppleOAuthCallbackDto body,
  });

  /// Create QQ OAuth authorize URL.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/oauth/qq/authorize')
  Future<OAuthAuthorizeResponseDto> oAuthControllerCreateQqAuthorizeUrlV1({
    @Body() QqOAuthAuthorizeDto? body,
  });

  /// QQ OAuth callback login.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/oauth/qq/callback')
  Future<LoginResponseDto> oAuthControllerLoginWithQqV1({
    @Body() required QqOAuthCallbackDto body,
  });

  /// User logout.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/logout')
  Future<SuccessResponseDto> sessionControllerLogoutV1({
    @Body() required LogoutDto body,
  });

  /// List active sessions for the current user
  @GET('/api/v1/auth/sessions')
  Future<void> sessionControllerListSessionsV1();

  /// Revoke a specific session
  @DELETE('/api/v1/auth/sessions/{sessionId}')
  Future<void> sessionControllerRevokeSessionV1({
    @Path('sessionId') required String sessionId,
  });

  /// Refresh token.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/refresh')
  Future<RefreshResponseDto> sessionControllerRefreshV1({
    @Body() required RefreshDto body,
  });
}
