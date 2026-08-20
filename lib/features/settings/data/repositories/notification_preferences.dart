import 'package:dio/dio.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/api_paths.dart';
import 'package:luminous/core/network/envelope.dart';
import 'package:luminous/features/settings/domain/entities/notification_preferences.dart';
import 'package:luminous/features/settings/domain/repositories/notification_preferences.dart';

class LucentNotificationPreferencesRepository
    implements NotificationPreferencesRepository {
  LucentNotificationPreferencesRepository({
    required this.api,
    required this.dio,
  });

  final NotificationPreferencesApi api;
  final Dio dio;

  @override
  Future<NotificationPreferences> getPreferences() async {
    final response = await api.notificationPreferencesControllerGetV1();
    return _map(
      requireData(response.data, operation: 'getNotificationPreferences').data,
    );
  }

  @override
  Future<NotificationPreferences> patchPreferences(
    NotificationPreferencesPatch patch,
  ) async {
    final response = patch.clearSleepBedtime || patch.clearSleepWakeTime
        ? await dio.patch<Object>(
            LucentApiPaths.notificationPreferences,
            data: patch.toJson(),
          )
        : await api.notificationPreferencesControllerPatchV1(
            updateNotificationPreferencesDto: UpdateNotificationPreferencesDto(
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
        requireData(
          response.data,
          operation: 'patchNotificationPreferences',
        ).data,
      );
    }

    final raw = response.data;
    if (raw is! Map<String, dynamic>) {
      throw StateError('API 返回空的通知偏好响应');
    }
    final envelope = LucentEnvelope<NotificationPreferencesDataDto>.fromJson(
      raw,
      dataDecoder: (data) =>
          NotificationPreferencesDataDto.fromJson(data as Map<String, dynamic>),
    );
    return _map(envelope.unwrapOrThrow());
  }

  NotificationPreferences _map(NotificationPreferencesDataDto data) {
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
