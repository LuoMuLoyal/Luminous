// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/create_current_medicine_dto.dart';
import '../models/create_health_context_allergy_dto.dart';
import '../models/create_health_context_condition_dto.dart';
import '../models/health_context_response_dto.dart';
import '../models/update_current_medicine_dto.dart';
import '../models/update_health_context_allergy_dto.dart';
import '../models/update_health_context_condition_dto.dart';
import '../models/update_health_context_profile_dto.dart';

part 'user_health_context_api.g.dart';

@RestApi()
abstract class UserHealthContextApi {
  factory UserHealthContextApi(Dio dio, {String? baseUrl}) =
      _UserHealthContextApi;

  /// Get the current user health context aggregate
  @GET('/api/v1/user/health-context')
  Future<HealthContextResponseDto>
  userHealthContextControllerGetUserHealthContextV1();

  /// Update the current user health-context profile.
  ///
  /// [body] - Name not received - field will be skipped.
  @PATCH('/api/v1/user/health-context/profile')
  Future<HealthContextResponseDto>
  userHealthContextControllerUpdateUserHealthContextProfileV1({
    @Body() required UpdateHealthContextProfileDto body,
  });

  /// Create an allergy record.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/health-context/allergies')
  Future<HealthContextResponseDto> userHealthContextControllerCreateAllergyV1({
    @Body() required CreateHealthContextAllergyDto body,
  });

  /// Update an allergy record.
  ///
  /// [id] - Allergy id.
  ///
  /// [body] - Name not received - field will be skipped.
  @PATCH('/api/v1/user/health-context/allergies/{id}')
  Future<HealthContextResponseDto> userHealthContextControllerUpdateAllergyV1({
    @Path('id') required String id,
    @Body() required UpdateHealthContextAllergyDto body,
  });

  /// Deactivate an allergy record (soft delete).
  ///
  /// [id] - Allergy id.
  @DELETE('/api/v1/user/health-context/allergies/{id}')
  Future<HealthContextResponseDto> userHealthContextControllerDeleteAllergyV1({
    @Path('id') required String id,
  });

  /// Create a condition record.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/health-context/conditions')
  Future<HealthContextResponseDto>
  userHealthContextControllerCreateConditionV1({
    @Body() required CreateHealthContextConditionDto body,
  });

  /// Update a condition record.
  ///
  /// [id] - Condition id.
  ///
  /// [body] - Name not received - field will be skipped.
  @PATCH('/api/v1/user/health-context/conditions/{id}')
  Future<HealthContextResponseDto>
  userHealthContextControllerUpdateConditionV1({
    @Path('id') required String id,
    @Body() required UpdateHealthContextConditionDto body,
  });

  /// Resolve a condition record (soft delete).
  ///
  /// [id] - Condition id.
  @DELETE('/api/v1/user/health-context/conditions/{id}')
  Future<HealthContextResponseDto>
  userHealthContextControllerDeleteConditionV1({
    @Path('id') required String id,
  });

  /// Add a current medicine record.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/health-context/current-medicines')
  Future<HealthContextResponseDto>
  userHealthContextControllerCreateCurrentMedicineV1({
    @Body() required CreateCurrentMedicineDto body,
  });

  /// Update a current medicine record.
  ///
  /// [id] - Current medicine id.
  ///
  /// [body] - Name not received - field will be skipped.
  @PATCH('/api/v1/user/health-context/current-medicines/{id}')
  Future<HealthContextResponseDto>
  userHealthContextControllerUpdateCurrentMedicineV1({
    @Path('id') required String id,
    @Body() required UpdateCurrentMedicineDto body,
  });

  /// Deactivate a current medicine record (soft delete).
  ///
  /// [id] - Current medicine id.
  @DELETE('/api/v1/user/health-context/current-medicines/{id}')
  Future<HealthContextResponseDto>
  userHealthContextControllerDeleteCurrentMedicineV1({
    @Path('id') required String id,
  });
}
