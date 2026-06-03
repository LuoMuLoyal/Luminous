// ignore_for_file: prefer_initializing_formals

import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_api.dart';

/// Remote data source that fetches and writes health-context data to Lucent.
class HealthContextRemoteDataSource {
  HealthContextRemoteDataSource({required UserHealthContextApi api})
    : _api = api;

  final UserHealthContextApi _api;

  /// Calls GET /api/v1/me/health-context and returns the parsed DTO.
  Future<HealthContextDataDto> fetchHealthContext() async {
    final response = await _api.userHealthContextControllerGetMeHealthContextV1();
    return response.data!.data;
  }

  // ── Profile ──

  /// Calls PATCH /api/v1/me/health-context/profile and returns the parsed DTO.
  Future<HealthContextDataDto> updateProfile(
    UpdateHealthContextProfileDto dto,
  ) async {
    final response = await _api
        .userHealthContextControllerUpdateMeHealthContextProfileV1(
          updateHealthContextProfileDto: dto,
        );
    return response.data!.data;
  }

  // ── Allergies ──

  /// Calls POST /api/v1/me/health-context/allergies and returns the parsed DTO.
  Future<HealthContextDataDto> createAllergy(
    CreateHealthContextAllergyDto dto,
  ) async {
    final response = await _api.userHealthContextControllerCreateAllergyV1(
      createHealthContextAllergyDto: dto,
    );
    return response.data!.data;
  }

  /// Calls PATCH /api/v1/me/health-context/allergies/:id and returns the parsed DTO.
  Future<HealthContextDataDto> updateAllergy(
    String id,
    UpdateHealthContextAllergyDto dto,
  ) async {
    final response = await _api.userHealthContextControllerUpdateAllergyV1(
      id: id,
      updateHealthContextAllergyDto: dto,
    );
    return response.data!.data;
  }

  /// Calls DELETE /api/v1/me/health-context/allergies/:id and returns the parsed DTO.
  Future<HealthContextDataDto> deleteAllergy(String id) async {
    final response = await _api.userHealthContextControllerDeleteAllergyV1(
      id: id,
    );
    return response.data!.data;
  }

  // ── Conditions ──

  /// Calls POST /api/v1/me/health-context/conditions and returns the parsed DTO.
  Future<HealthContextDataDto> createCondition(
    CreateHealthContextConditionDto dto,
  ) async {
    final response = await _api.userHealthContextControllerCreateConditionV1(
      createHealthContextConditionDto: dto,
    );
    return response.data!.data;
  }

  /// Calls PATCH /api/v1/me/health-context/conditions/:id and returns the parsed DTO.
  Future<HealthContextDataDto> updateCondition(
    String id,
    UpdateHealthContextConditionDto dto,
  ) async {
    final response = await _api.userHealthContextControllerUpdateConditionV1(
      id: id,
      updateHealthContextConditionDto: dto,
    );
    return response.data!.data;
  }

  /// Calls DELETE /api/v1/me/health-context/conditions/:id and returns the parsed DTO.
  Future<HealthContextDataDto> deleteCondition(String id) async {
    final response = await _api.userHealthContextControllerDeleteConditionV1(
      id: id,
    );
    return response.data!.data;
  }

  // ── Current Medicines ──

  /// Calls POST /api/v1/me/health-context/current-medicines and returns the parsed DTO.
  Future<HealthContextDataDto> createCurrentMedicine(
    CreateCurrentMedicineDto dto,
  ) async {
    final response =
        await _api.userHealthContextControllerCreateCurrentMedicineV1(
          createCurrentMedicineDto: dto,
        );
    return response.data!.data;
  }

  /// Calls PATCH /api/v1/me/health-context/current-medicines/:id and returns the parsed DTO.
  Future<HealthContextDataDto> updateCurrentMedicine(
    String id,
    UpdateCurrentMedicineDto dto,
  ) async {
    final response =
        await _api.userHealthContextControllerUpdateCurrentMedicineV1(
          id: id,
          updateCurrentMedicineDto: dto,
        );
    return response.data!.data;
  }

  /// Calls DELETE /api/v1/me/health-context/current-medicines/:id and returns the parsed DTO.
  Future<HealthContextDataDto> deleteCurrentMedicine(String id) async {
    final response =
        await _api.userHealthContextControllerDeleteCurrentMedicineV1(
          id: id,
        );
    return response.data!.data;
  }
}
