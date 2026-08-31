import 'package:dio/dio.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/map_utils.dart';

/// Settings is a thin configuration surface: its data layer maps directly to
/// generated Lucent DTOs (e.g. [HealthContextResponseDto]) and local platform
/// services. There is no dedicated domain layer because the business rules are
/// limited to form-level validation and preference persistence.

const Object settingsProfileNoChange = Object();

/// Remote data source for the health-context profile preferences.
///
/// Transport-only: keeps a `Future` boundary and propagates [DioException]
/// (HTTP errors) and [LucentFailure] (empty success body, per the auth
/// `_requireBody` precedent). A body that does not match the generated-client
/// structure stays a thrown protocol exception, logged via [appTalker] for
/// diagnosability, and surfaces at the consuming boundary as
/// `LucentFailureKind.unknown` (cause preserved).
class SettingsProfileRemoteDataSource {
  const SettingsProfileRemoteDataSource({required this.dio});

  final Dio dio;

  Future<HealthContextResponseDto> updatePreferences({
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

    final body = coerceToStringMap(response.data);
    if (body == null) {
      // Empty success body: transport-level failure (auth `_requireBody`
      // precedent), not a protocol invariant.
      throw LucentFailure.network(
        message: 'Lucent health-context profile response is empty.',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }

    try {
      return HealthContextResponseDto.fromJson(body);
    } catch (error) {
      // Protocol violation: the success body does not match the generated
      // client structure. Logged for diagnosability and kept as a thrown
      // protocol exception (mapped to Left(unknown) at the consuming
      // boundary).
      appTalker.error(
        'SettingsProfileRemoteDataSource.updatePreferences: response body '
        'does not match HealthContextResponseDto: $error',
      );
      rethrow;
    }
  }
}
