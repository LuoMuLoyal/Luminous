import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/api_paths.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/features/settings/domain/entities/notification_preferences.dart';
import 'package:luminous/features/settings/domain/repositories/notification_preferences.dart';

/// Lucent-backed implementation of [NotificationPreferencesRepository].
///
/// Single implementation of the interface, so it returns `TaskEither`
/// directly (today suggestion datasource precedent). Every expected
/// recoverable failure (network, server business failure) is a Left produced
/// via `LucentErrorMapper.fromObject`; a successful response is a Right.
/// An empty success response body is a `LucentFailure.network(emptyResponse)`
/// (auth `_requireBody` precedent).
class LucentNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  LucentNotificationPreferencesRepository({
    required this.api,
    required this.dio,
  });

  final NotificationPreferencesApi api;
  final Dio dio;

  @override
  TaskEither<LucentFailure, NotificationPreferences> getPreferences() {
    return TaskEither.tryCatch(() async {
      final response = await api.notificationPreferencesControllerGetV1();
      return _map(
        _requireData(response.data, operation: 'getNotificationPreferences'),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, NotificationPreferences> patchPreferences(
    NotificationPreferencesPatch patch,
  ) {
    return TaskEither.tryCatch(() async {
      final response = patch.clearSleepBedtime || patch.clearSleepWakeTime
          ? await dio.patch<Object>(
              LucentApiPaths.notificationPreferences,
              data: patch.toJson(),
            )
          : await api.notificationPreferencesControllerPatchV1(
              updateNotificationPreferencesDto:
                  UpdateNotificationPreferencesDto(
                    healthAlertsEnabled: patch.healthAlertsEnabled,
                    weeklyInsightEnabled: patch.weeklyInsightEnabled,
                    waterRemindersEnabled: patch.waterRemindersEnabled,
                    sleepReminderEnabled: patch.sleepReminderEnabled,
                    sleepBedtimeMinutes: patch.sleepBedtimeMinutes,
                    sleepWakeTimeMinutes: patch.sleepWakeTimeMinutes,
                  ),
            );

      if (response is Response<NotificationPreferencesResponseDto>) {
        return _map(
          _requireData(
            response.data,
            operation: 'patchNotificationPreferences',
          ),
        );
      }

      final raw = response.data;
      if (raw is! Map<String, dynamic>) {
        throw LucentFailure.network(
          message: 'Empty notification preferences response',
          networkErrorCode: NetworkErrorCode.emptyResponse,
        );
      }
      return _map(NotificationPreferencesResponseDto.fromJson(raw));
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  /// Extracts a non-null generated-client payload, throwing
  /// [LucentFailure.network] (emptyResponse) when the success body is absent
  /// (auth `_requireBody` / medicine `dose_log_remote` precedent).
  T _requireData<T>(T? data, {String? operation}) {
    if (data == null) {
      final context = operation != null ? ' ($operation)' : '';
      throw LucentFailure.network(
        message: 'Empty response body$context',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return data;
  }

  NotificationPreferences _map(NotificationPreferencesResponseDto data) {
    return NotificationPreferences(
      healthAlertsEnabled: data.healthAlertsEnabled,
      weeklyInsightEnabled: data.weeklyInsightEnabled,
      waterRemindersEnabled: data.waterRemindersEnabled,
      sleepReminderEnabled: data.sleepReminderEnabled,
      sleepBedtimeMinutes: data.sleepBedtimeMinutes?.toInt(),
      sleepWakeTimeMinutes: data.sleepWakeTimeMinutes?.toInt(),
      configured: data.configured,
      updatedAt: data.updatedAt,
    );
  }
}
