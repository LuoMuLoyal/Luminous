// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/account_email_response_dto.dart';
import '../models/account_response_dto.dart';
import '../models/change_email_dto.dart';
import '../models/change_password_dto.dart';
import '../models/delete_account_dto.dart';
import '../models/o_auth_authorize_dto.dart';
import '../models/o_auth_authorize_response_dto.dart';
import '../models/o_auth_callback_dto.dart';
import '../models/o_auth_code_callback_dto.dart';
import '../models/set_password_dto.dart';
import '../models/success_response_dto.dart';
import '../models/update_account_dto.dart';

part 'account_api.g.dart';

@RestApi()
abstract class AccountApi {
  factory AccountApi(Dio dio, {String? baseUrl}) = _AccountApi;

  /// Get authenticated account profile
  @GET('/api/v1/account')
  Future<AccountResponseDto> accountControllerGetAccountV1();

  /// Update authenticated account profile.
  ///
  /// [body] - Name not received - field will be skipped.
  @PATCH('/api/v1/account')
  Future<AccountResponseDto> accountControllerUpdateAccountV1({
    @Body() required UpdateAccountDto body,
  });

  /// Delete authenticated account.
  ///
  /// [body] - Name not received - field will be skipped.
  @DELETE('/api/v1/account')
  Future<SuccessResponseDto> accountControllerDeleteAccountV1({
    @Body() required DeleteAccountDto body,
  });

  /// Change authenticated account password.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/account/password')
  Future<SuccessResponseDto> accountControllerChangePasswordV1({
    @Body() required ChangePasswordDto body,
  });

  /// Set initial password for OAuth-only account using email verification.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/account/set-password')
  Future<SuccessResponseDto> accountControllerSetPasswordV1({
    @Body() required SetPasswordDto body,
  });

  /// Change authenticated account email.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/account/email')
  Future<AccountEmailResponseDto> accountControllerChangeEmailV1({
    @Body() required ChangeEmailDto body,
  });

  /// Unlink authenticated account OAuth identity
  @DELETE('/api/v1/account/identities/{identityId}')
  Future<AccountResponseDto> accountControllerUnlinkIdentityV1({
    @Path('identityId') required String identityId,
  });

  /// Create WeChat web OAuth authorize URL for linking.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/account/identities/wechat-web/authorize')
  Future<OAuthAuthorizeResponseDto>
  accountControllerCreateWechatWebIdentityLinkAuthorizeUrlV1({
    @Body() OAuthAuthorizeDto? body,
  });

  /// Link WeChat web identity to authenticated account.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/account/identities/wechat-web/callback')
  Future<AccountResponseDto> accountControllerLinkWechatWebIdentityV1({
    @Body() required OAuthCallbackDto body,
  });

  /// Link WeChat mobile identity to authenticated account.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/account/identities/wechat-mobile/callback')
  Future<AccountResponseDto> accountControllerLinkWechatMobileIdentityV1({
    @Body() required OAuthCodeCallbackDto body,
  });
}
