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

  /// 用户注册.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/register')
  Future<RegisterResponseDto> authControllerRegisterV1({
    @Body() required RegisterDto body,
  });

  /// 用户登录.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/login')
  Future<LoginResponseDto> authControllerLoginV1({
    @Body() required LoginDto body,
  });

  /// 创建微信网页登录授权地址.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/oauth/wechat-web/authorize')
  Future<OAuthAuthorizeResponseDto>
  authControllerCreateWechatWebAuthorizeUrlV1({
    @Body() OAuthAuthorizeDto? body,
  });

  /// 微信网页登录回调登录.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/oauth/wechat-web/callback')
  Future<LoginResponseDto> authControllerLoginWithWechatWebV1({
    @Body() required OAuthCallbackDto body,
  });

  /// 微信网页登录浏览器回跳.
  ///
  /// [code] - OAuth 授权码.
  ///
  /// [state] - 授权时生成的 state.
  @GET('/api/v1/auth/oauth/wechat-web/callback')
  Future<void> authControllerRedirectWechatWebCallbackV1({
    @Query('code') required String code,
    @Query('state') required String state,
  });

  /// 微信移动端登录回调.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/oauth/wechat-mobile/callback')
  Future<LoginResponseDto> authControllerLoginWithWechatMobileV1({
    @Body() required OAuthCodeCallbackDto body,
  });

  /// Apple 登录回调.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/oauth/apple/callback')
  Future<LoginResponseDto> authControllerLoginWithAppleV1({
    @Body() required AppleOAuthCallbackDto body,
  });

  /// 创建 QQ 登录授权地址.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/oauth/qq/authorize')
  Future<OAuthAuthorizeResponseDto> authControllerCreateQqAuthorizeUrlV1({
    @Body() QqOAuthAuthorizeDto? body,
  });

  /// QQ 登录回调.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/oauth/qq/callback')
  Future<LoginResponseDto> authControllerLoginWithQqV1({
    @Body() required QqOAuthCallbackDto body,
  });

  /// 用户登出.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/logout')
  Future<SuccessResponseDto> authControllerLogoutV1({
    @Body() required LogoutDto body,
  });

  /// 列出当前用户的活跃会话
  @GET('/api/v1/auth/sessions')
  Future<void> authControllerListSessionsV1();

  /// 撤销指定会话
  @DELETE('/api/v1/auth/sessions/{sessionId}')
  Future<void> authControllerRevokeSessionV1({
    @Path('sessionId') required String sessionId,
  });

  /// 刷新令牌.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/refresh')
  Future<RefreshResponseDto> authControllerRefreshV1({
    @Body() required RefreshDto body,
  });

  /// 发送邮箱验证码.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/send-verification-code')
  Future<SendVerificationCodeResponseDto> authControllerSendVerificationCodeV1({
    @Body() required SendVerificationCodeDto body,
  });

  /// 验证邮箱.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/verify-email')
  Future<VerifyEmailResponseDto> authControllerVerifyEmailV1({
    @Body() required VerifyEmailDto body,
  });

  /// 忘记密码.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/forgot-password')
  Future<ForgotPasswordResponseDto> authControllerForgotPasswordV1({
    @Body() required ForgotPasswordDto body,
  });

  /// 重置密码.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/auth/reset-password')
  Future<SuccessResponseDto> authControllerResetPasswordV1({
    @Body() required ResetPasswordDto body,
  });
}
