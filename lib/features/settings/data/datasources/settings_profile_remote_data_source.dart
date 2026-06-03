import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart';

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
      '/api/v1/me/health-context/profile',
      data: payload,
      options: Options(contentType: Headers.jsonContentType),
    );

    final body = _coerceToMap(response.data);
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

  Map<String, dynamic>? _coerceToMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, entryValue) => MapEntry(key.toString(), entryValue),
      );
    }
    return null;
  }
}
