// ignore_for_file: prefer_initializing_formals

import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_api.dart';

/// Remote data source that fetches health-context data from Lucent.
class HealthContextRemoteDataSource {
  HealthContextRemoteDataSource({required UserHealthContextApi api})
    : _api = api;

  final UserHealthContextApi _api;

  /// Calls GET /api/v1/me/health-context and returns the parsed DTO.
  Future<HealthContextDataDto> fetchHealthContext() async {
    final response = await _api.userHealthContextControllerGetMeHealthContextV1();
    return response.data!.data;
  }
}
