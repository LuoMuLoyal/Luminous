// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/change_security_pin_dto.dart';
import '../models/disable_security_pin_dto.dart';
import '../models/enable_security_pin_dto.dart';
import '../models/security_pin_elevation_response_dto.dart';
import '../models/update_user_settings_dto.dart';
import '../models/user_settings_response_dto.dart';
import '../models/verify_security_pin_dto.dart';

part 'user_settings_api.g.dart';

@RestApi()
abstract class UserSettingsApi {
  factory UserSettingsApi(Dio dio, {String? baseUrl}) = _UserSettingsApi;

  /// Get authenticated user settings
  @GET('/api/v1/user/settings')
  Future<UserSettingsResponseDto> userSettingsControllerGetSettingsV1();

  /// Update authenticated user settings.
  ///
  /// [body] - Name not received - field will be skipped.
  @PATCH('/api/v1/user/settings')
  Future<UserSettingsResponseDto> userSettingsControllerUpdateSettingsV1({
    @Body() required UpdateUserSettingsDto body,
  });

  /// Enable Security PIN.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/settings/security-pin')
  Future<UserSettingsResponseDto> userSettingsControllerEnableSecurityPinV1({
    @Body() required EnableSecurityPinDto body,
  });

  /// Verify Security PIN and receive elevation token.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/settings/security-pin/verify')
  Future<SecurityPinElevationResponseDto>
  userSettingsControllerVerifySecurityPinV1({
    @Body() required VerifySecurityPinDto body,
  });

  /// Change Security PIN.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/settings/security-pin/change')
  Future<UserSettingsResponseDto> userSettingsControllerChangeSecurityPinV1({
    @Body() required ChangeSecurityPinDto body,
  });

  /// Disable Security PIN.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/settings/security-pin/disable')
  Future<UserSettingsResponseDto> userSettingsControllerDisableSecurityPinV1({
    @Body() required DisableSecurityPinDto body,
  });
}
