import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/map_utils.dart';

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
      '/api/v1/user/health-context/profile',
      data: payload,
      options: Options(contentType: Headers.jsonContentType),
    );

    final body = coerceToStringMap(response.data);
    if (body == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Lucent health-context profile response is empty.',
      );
    }

    return HealthContextResponseDto.fromJson(body).data;
  }
}
