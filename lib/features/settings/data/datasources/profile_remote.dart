import 'package:dio/dio.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/map_utils.dart';

/// Settings is a thin configuration surface: its data layer maps directly to
/// generated Lucent DTOs (e.g. [HealthContextDataDto]) and local platform
/// services. There is no dedicated domain layer because the business rules are
/// limited to form-level validation and preference persistence.

const Object settingsProfileNoChange = Object();

class SettingsProfileRemoteDataSource {
  const SettingsProfileRemoteDataSource({required this.dio});

  final Dio dio;

  Future<HealthContextDataDto> updatePreferences({
    Object? locale = settingsProfileNoChange,
    Object? timezone = settingsProfileNoChange,
    Object? unitSystem = settingsProfileNoChange,
  }) async {
    final payload = <String, dynamic>{};
    if (!identical(locale, settingsProfileNoChange)) {
      payload['locale'] = locale;
    }
    if (!identical(timezone, settingsProfileNoChange)) {
      payload['timezone'] = timezone;
    }
    if (!identical(unitSystem, settingsProfileNoChange)) {
      payload['unitSystem'] = unitSystem;
    }

    final response = await dio.patch<Object>(
      LucentApiPaths.healthContextProfile,
      data: payload,
      options: Options(contentType: Headers.jsonContentType),
    );

    final body = requireBody(
      response,
      message: 'Lucent health-context profile response is empty.',
    );

    return HealthContextResponseDto.fromJson(body).data;
  }
}
