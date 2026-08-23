import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/features/settings/data/repositories/notification_preferences.dart';
import 'package:luminous/features/settings/domain/entities/notification_preferences.dart';

import '../helpers/task_either.dart';

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

    final result = await expectTaskRight(repository.getPreferences());

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

      await expectTaskRight(
        repository.patchPreferences(
          const NotificationPreferencesPatch(clearSleepBedtime: true),
        ),
      );

      expect(
        adapter.capturedRequest?.path,
        '/api/v1/user/notification-preferences',
      );
      expect(adapter.capturedRequest?.data, {'sleepBedtimeMinutes': null});
    },
  );

  test('empty GET success body maps to a network Left', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.httpClientAdapter = _JsonAdapter();
    final repository = LucentNotificationPreferencesRepository(
      api: NotificationPreferencesApi(dio),
      dio: dio,
    );

    final failure = await expectTaskLeft(repository.getPreferences());

    expect(failure.kind, LucentFailureKind.network);
    expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
  });

  test('empty raw PATCH success body maps to a network Left', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.httpClientAdapter = _JsonAdapter();
    final repository = LucentNotificationPreferencesRepository(
      api: NotificationPreferencesApi(dio),
      dio: dio,
    );

    final failure = await expectTaskLeft(
      repository.patchPreferences(
        const NotificationPreferencesPatch(clearSleepBedtime: true),
      ),
    );

    expect(failure.kind, LucentFailureKind.network);
    expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
  });

  test('404 Problem Details keeps code and status as a Left', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    dio.httpClientAdapter = _JsonAdapter(
      statusCode: 404,
      contentType: 'application/problem+json',
      responseData: {
        'type':
            'https://api.lumos.example/problems/'
            'NOTIFICATION_PREFERENCES_NOT_FOUND',
        'title': 'Not found',
        'detail': '通知偏好不存在',
        'code': 'NOTIFICATION_PREFERENCES_NOT_FOUND',
      },
    );
    final repository = LucentNotificationPreferencesRepository(
      api: NotificationPreferencesApi(dio),
      dio: dio,
    );

    final failure = await expectTaskLeft(repository.getPreferences());

    expect(failure.code, 'NOTIFICATION_PREFERENCES_NOT_FOUND');
    expect(failure.statusCode, 404);
    expect(failure.kind, LucentFailureKind.business);
  });
}

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter({
    this.responseData,
    this.statusCode = 200,
    this.contentType = 'application/json',
  });

  final Map<String, dynamic>? responseData;
  final int statusCode;
  final String contentType;
  RequestOptions? capturedRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedRequest = options;
    return ResponseBody.fromString(
      // A null body is an empty success response (dio leaves data null).
      responseData == null ? '' : jsonEncode(responseData),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [contentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
