import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/settings/data/repositories/notification_preferences.dart';
import 'package:luminous/features/settings/domain/entities/notification_preferences.dart';

void main() {
  test('maps the generated GET response into the domain entity', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.httpClientAdapter = _JsonAdapter(
      responseData: {
        'healthAlertsEnabled': false,
        'weeklyInsightEnabled': true,
        'waterRemindersEnabled': true,
        'sleepReminderEnabled': true,
        'sleepBedtimeMinutes': 1380,
        'sleepWakeTimeMinutes': 420,
        'configured': true,
        'updatedAt': '2026-08-20T00:00:00.000Z',
      },
    );
    final repository = LucentNotificationPreferencesRepository(
      api: NotificationPreferencesApi(dio),
      dio: dio,
    );

    final result = await repository.getPreferences();

    expect(result.healthAlertsEnabled, isFalse);
    expect(result.weeklyInsightEnabled, isTrue);
    expect(result.sleepBedtimeMinutes, 1380);
    expect(result.configured, isTrue);
  });

  test(
    'uses raw PATCH JSON when a nullable sleep time must be cleared',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      final adapter = _JsonAdapter(
        responseData: const {
          'healthAlertsEnabled': true,
          'weeklyInsightEnabled': false,
          'waterRemindersEnabled': true,
          'sleepReminderEnabled': false,
          'sleepBedtimeMinutes': null,
          'sleepWakeTimeMinutes': null,
          'configured': true,
          'updatedAt': null,
        },
      );
      dio.httpClientAdapter = adapter;
      final repository = LucentNotificationPreferencesRepository(
        api: NotificationPreferencesApi(dio),
        dio: dio,
      );

      await repository.patchPreferences(
        const NotificationPreferencesPatch(clearSleepBedtime: true),
      );

      expect(
        adapter.capturedRequest?.path,
        '/api/v1/user/notification-preferences',
      );
      expect(adapter.capturedRequest?.data, {'sleepBedtimeMinutes': null});
    },
  );
}

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter({required this.responseData});

  final Map<String, dynamic> responseData;
  RequestOptions? capturedRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedRequest = options;
    return ResponseBody.fromString(
      jsonEncode(responseData),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
