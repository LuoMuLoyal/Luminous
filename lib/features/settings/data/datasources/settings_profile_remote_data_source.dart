import 'package:lucent_openapi/lucent_openapi.dart';

class SettingsProfileRemoteDataSource {
  const SettingsProfileRemoteDataSource({required this.api});

  final UserHealthContextApi api;

  Future<HealthContextDataDto> updatePreferences({
    Object? locale,
    Object? timezone,
    UnitSystem? unitSystem,
  }) async {
    final response = await api
        .userHealthContextControllerUpdateMeHealthContextProfileV1(
          updateHealthContextProfileDto: UpdateHealthContextProfileDto(
            locale: locale,
            timezone: timezone,
            unitSystem: unitSystem,
          ),
        );

    return response.data!.data;
  }
}
