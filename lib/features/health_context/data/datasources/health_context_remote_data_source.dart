// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/core/network/map_utils.dart';

/// Remote data source that fetches and writes health-context data to Lucent.
class HealthContextRemoteDataSource {
  HealthContextRemoteDataSource({
    required UserHealthContextApi api,
    required Dio dio,
  }) : _api = api,
       _dio = dio;

  final UserHealthContextApi _api;
  final Dio _dio;

  /// Calls GET /api/v1/user/health-context and returns the parsed DTO.
  Future<HealthContextDataDto> fetchHealthContext() async {
    final response = await _api
        .userHealthContextControllerGetUserHealthContextV1();
    return response.data!.data;
  }

  /// Calls PATCH /api/v1/user/health-context/profile and returns the parsed DTO.
  Future<HealthContextDataDto> updateProfile(HealthProfileUpdateInput input) {
    return _write(
      method: 'PATCH',
      path: '/api/v1/user/health-context/profile',
      payload: healthProfileUpdatePayload(input),
    );
  }

  /// Calls POST /api/v1/user/health-context/allergies and returns the parsed DTO.
  Future<HealthContextDataDto> createAllergy(HealthAllergyWriteInput input) {
    return _write(
      method: 'POST',
      path: '/api/v1/user/health-context/allergies',
      payload: healthAllergyCreatePayload(input),
    );
  }

  /// Calls PATCH /api/v1/user/health-context/allergies/:id and returns the parsed DTO.
  Future<HealthContextDataDto> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) {
    return _write(
      method: 'PATCH',
      path: '/api/v1/user/health-context/allergies/$id',
      payload: healthAllergyUpdatePayload(input),
    );
  }

  /// Calls DELETE /api/v1/user/health-context/allergies/:id and returns the parsed DTO.
  Future<HealthContextDataDto> deleteAllergy(String id) {
    return _write(
      method: 'DELETE',
      path: '/api/v1/user/health-context/allergies/$id',
    );
  }

  /// Calls POST /api/v1/user/health-context/conditions and returns the parsed DTO.
  Future<HealthContextDataDto> createCondition(
    HealthConditionWriteInput input,
  ) {
    return _write(
      method: 'POST',
      path: '/api/v1/user/health-context/conditions',
      payload: healthConditionCreatePayload(input),
    );
  }

  /// Calls PATCH /api/v1/user/health-context/conditions/:id and returns the parsed DTO.
  Future<HealthContextDataDto> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) {
    return _write(
      method: 'PATCH',
      path: '/api/v1/user/health-context/conditions/$id',
      payload: healthConditionUpdatePayload(input),
    );
  }

  /// Calls DELETE /api/v1/user/health-context/conditions/:id and returns the parsed DTO.
  Future<HealthContextDataDto> deleteCondition(String id) {
    return _write(
      method: 'DELETE',
      path: '/api/v1/user/health-context/conditions/$id',
    );
  }

  /// Calls POST /api/v1/user/health-context/current-medicines and returns the parsed DTO.
  Future<HealthContextDataDto> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) {
    return _write(
      method: 'POST',
      path: '/api/v1/user/health-context/current-medicines',
      payload: currentMedicineCreatePayload(input),
    );
  }

  /// Calls PATCH /api/v1/user/health-context/current-medicines/:id and returns the parsed DTO.
  Future<HealthContextDataDto> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) {
    return _write(
      method: 'PATCH',
      path: '/api/v1/user/health-context/current-medicines/$id',
      payload: currentMedicineUpdatePayload(input),
    );
  }

  /// Calls DELETE /api/v1/user/health-context/current-medicines/:id and returns the parsed DTO.
  Future<HealthContextDataDto> deleteCurrentMedicine(String id) {
    return _write(
      method: 'DELETE',
      path: '/api/v1/user/health-context/current-medicines/$id',
    );
  }

  Future<HealthContextDataDto> _write({
    required String method,
    required String path,
    Map<String, dynamic>? payload,
  }) async {
    final response = await _dio.request<Object>(
      path,
      data: payload,
      options: Options(method: method, contentType: Headers.jsonContentType),
    );

    final body = coerceToStringMap(response.data);
    if (body == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Lucent health-context response is empty.',
      );
    }

    return HealthContextResponseDto.fromJson(body).data;
  }
}

Map<String, dynamic> healthProfileUpdatePayload(
  HealthProfileUpdateInput input,
) {
  final payload = <String, dynamic>{};
  _putIfChanged(payload, 'locale', input.locale);
  _putIfChanged(payload, 'timezone', input.timezone);
  _putIfChanged(payload, 'unitSystem', input.unitSystem);
  _putIfChanged(payload, 'birthDate', input.birthDate);
  _putIfChanged(payload, 'sexAtBirth', input.sexAtBirth);
  _putIfChanged(payload, 'heightCm', input.heightCm);
  _putIfChanged(payload, 'bloodType', input.bloodType);
  _putIfChanged(payload, 'onboardingCompleted', input.onboardingCompleted);
  return payload;
}

Map<String, dynamic> healthAllergyCreatePayload(HealthAllergyWriteInput input) {
  return _compactCreatePayload(<String, dynamic>{
    'kind': input.kind.value,
    'label': input.label,
    'reaction': input.reaction,
    'severity': input.severity?.value,
    'note': input.note,
    'recordedAt': input.recordedAt,
  });
}

Map<String, dynamic> healthAllergyUpdatePayload(
  HealthAllergyUpdateInput input,
) {
  final payload = <String, dynamic>{};
  _putIfChanged(payload, 'kind', input.kind);
  _putIfChanged(payload, 'label', input.label);
  _putIfChanged(payload, 'reaction', input.reaction);
  _putIfChanged(payload, 'severity', input.severity);
  _putIfChanged(payload, 'note', input.note);
  _putIfChanged(payload, 'recordedAt', input.recordedAt);
  _putIfChanged(payload, 'isActive', input.isActive);
  return payload;
}

Map<String, dynamic> healthConditionCreatePayload(
  HealthConditionWriteInput input,
) {
  return _compactCreatePayload(<String, dynamic>{
    'label': input.label,
    'status': input.status?.value,
    'diagnosedAt': input.diagnosedAt,
    'note': input.note,
  });
}

Map<String, dynamic> healthConditionUpdatePayload(
  HealthConditionUpdateInput input,
) {
  final payload = <String, dynamic>{};
  _putIfChanged(payload, 'label', input.label);
  _putIfChanged(payload, 'status', input.status);
  _putIfChanged(payload, 'diagnosedAt', input.diagnosedAt);
  _putIfChanged(payload, 'note', input.note);
  return payload;
}

Map<String, dynamic> currentMedicineCreatePayload(
  CurrentMedicineWriteInput input,
) {
  return _compactCreatePayload(<String, dynamic>{
    'source': input.source.value,
    'sourceRefId': input.sourceRefId,
    'displayName': input.displayName,
    'strengthText': input.strengthText,
    'doseText': input.doseText,
    'route': input.route,
    'startedAt': input.startedAt,
    'endedAt': input.endedAt,
    'note': input.note,
  });
}

Map<String, dynamic> currentMedicineUpdatePayload(
  CurrentMedicineUpdateInput input,
) {
  final payload = <String, dynamic>{};
  _putIfChanged(payload, 'source', input.source);
  _putIfChanged(payload, 'sourceRefId', input.sourceRefId);
  _putIfChanged(payload, 'displayName', input.displayName);
  _putIfChanged(payload, 'strengthText', input.strengthText);
  _putIfChanged(payload, 'doseText', input.doseText);
  _putIfChanged(payload, 'route', input.route);
  _putIfChanged(payload, 'startedAt', input.startedAt);
  _putIfChanged(payload, 'endedAt', input.endedAt);
  _putIfChanged(payload, 'note', input.note);
  _putIfChanged(payload, 'isCurrent', input.isCurrent);
  return payload;
}

Map<String, dynamic> _compactCreatePayload(Map<String, dynamic> payload) {
  return Map<String, dynamic>.from(payload)
    ..removeWhere((_, value) => value == null);
}

void _putIfChanged(Map<String, dynamic> payload, String key, Object? value) {
  if (identical(value, healthContextNoChange)) {
    return;
  }
  payload[key] = _wireValue(value);
}

Object? _wireValue(Object? value) {
  if (value is HealthContextWireEnum) {
    return value.value;
  }
  return value;
}
