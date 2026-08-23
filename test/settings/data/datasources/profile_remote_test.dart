import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/features/settings/data/datasources/profile_remote.dart';

// ── CaptureAdapter (reused from test/helpers) ──────────────────

class _CaptureAdapter implements HttpClientAdapter {
  _CaptureAdapter();

  int statusCode = 200;
  Object? responseData;

  RequestOptions? capturedRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedRequest = options;

    final body = responseData != null
        ? utf8.encode(
            responseData is String
                ? responseData as String
                : jsonEncode(responseData),
          )
        : utf8.encode('');

    return ResponseBody(
      body.isNotEmpty ? Stream.fromIterable([body]) : const Stream.empty(),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

// ── Helpers ────────────────────────────────────────────────────

String _healthContextResponseJson({
  String locale = 'zh-CN',
  String timezone = 'Asia/Shanghai',
  String unitSystem = 'metric',
}) {
  return jsonEncode({
    'summary': {
      'age': null,
      'onboardingCompleted': false,
      'activeAllergyCount': 0,
      'conditionCount': 0,
      'currentMedicineCount': 0,
      'missingCoreProfileFields': [],
    },
    'profile': {
      'birthDate': null,
      'sexAtBirth': 'unknown',
      'heightCm': null,
      'weightKg': null,
      'bloodType': null,
      'locale': locale,
      'timezone': timezone,
      'unitSystem': unitSystem,
      'onboardingCompletedAt': null,
      'emergencyContact': {'name': null, 'phone': null},
      'extras': null,
    },
    'allergies': [],
    'conditions': [],
    'currentMedicines': [],
  });
}

void main() {
  group('SettingsProfileRemoteDataSource', () {
    late _CaptureAdapter adapter;
    late Dio dio;
    late SettingsProfileRemoteDataSource dataSource;

    setUp(() {
      adapter = _CaptureAdapter();
      dio = Dio();
      dio.httpClientAdapter = adapter;
      dataSource = SettingsProfileRemoteDataSource(dio: dio);
    });

    // ── updatePreferences — payload construction ──────────────
    group('updatePreferences payload construction', () {
      test('sends only locale when only locale is provided', () async {
        adapter.responseData = _healthContextResponseJson();

        await dataSource.updatePreferences(locale: 'en-US');

        final body = adapter.capturedRequest!.data as Map<String, dynamic>;
        expect(body, hasLength(1));
        expect(body['locale'], 'en-US');
        expect(body.containsKey('timezone'), isFalse);
        expect(body.containsKey('unitSystem'), isFalse);
      });

      test('sends only timezone when only timezone is provided', () async {
        adapter.responseData = _healthContextResponseJson();

        await dataSource.updatePreferences(timezone: 'America/New_York');

        final body = adapter.capturedRequest!.data as Map<String, dynamic>;
        expect(body, hasLength(1));
        expect(body['timezone'], 'America/New_York');
      });

      test('sends only unitSystem when only unitSystem is provided', () async {
        adapter.responseData = _healthContextResponseJson();

        await dataSource.updatePreferences(unitSystem: 'imperial');

        final body = adapter.capturedRequest!.data as Map<String, dynamic>;
        expect(body, hasLength(1));
        expect(body['unitSystem'], 'imperial');
      });

      test('sends multiple fields when multiple are provided', () async {
        adapter.responseData = _healthContextResponseJson();

        await dataSource.updatePreferences(
          locale: 'en-US',
          timezone: 'UTC',
          unitSystem: 'imperial',
        );

        final body = adapter.capturedRequest!.data as Map<String, dynamic>;
        expect(body, hasLength(3));
        expect(body['locale'], 'en-US');
        expect(body['timezone'], 'UTC');
        expect(body['unitSystem'], 'imperial');
      });

      test('sends empty payload when all fields use sentinel', () async {
        adapter.responseData = _healthContextResponseJson();

        await dataSource.updatePreferences();

        final body = adapter.capturedRequest!.data as Map<String, dynamic>;
        expect(body, isEmpty);
      });

      test('uses PATCH method', () async {
        adapter.responseData = _healthContextResponseJson();

        await dataSource.updatePreferences(locale: 'zh-CN');

        expect(adapter.capturedRequest!.method, 'PATCH');
      });

      test('targets /api/v1/user/health-context/profile endpoint', () async {
        adapter.responseData = _healthContextResponseJson();

        await dataSource.updatePreferences(locale: 'zh-CN');

        expect(
          adapter.capturedRequest!.path,
          '/api/v1/user/health-context/profile',
        );
      });

      test('sets JSON content type', () async {
        adapter.responseData = _healthContextResponseJson();

        await dataSource.updatePreferences(locale: 'zh-CN');

        expect(adapter.capturedRequest!.contentType, Headers.jsonContentType);
      });
    });

    // ── updatePreferences — response parsing ─────────────────
    group('updatePreferences response parsing', () {
      test('returns parsed HealthContextResponseDto on success', () async {
        adapter.responseData = _healthContextResponseJson(
          locale: 'en-US',
          timezone: 'America/New_York',
          unitSystem: 'imperial',
        );

        final result = await dataSource.updatePreferences(locale: 'en-US');

        expect(result.profile.locale, 'en-US');
        expect(result.profile.timezone, 'America/New_York');
        expect(result.profile.unitSystem, UnitSystem.imperial);
      });

      test(
        'returns parsed HealthContextResponseDto with zh-CN defaults',
        () async {
          adapter.responseData = _healthContextResponseJson();

          final result = await dataSource.updatePreferences();

          expect(result.profile.locale, 'zh-CN');
          expect(result.profile.timezone, 'Asia/Shanghai');
          expect(result.profile.unitSystem, UnitSystem.metric);
        },
      );

      test('throws emptyResponse failure on an empty success body', () async {
        adapter.responseData = null;

        await expectLater(
          dataSource.updatePreferences(locale: 'en-US'),
          throwsA(
            isA<LucentFailure>().having(
              (failure) => failure.networkErrorCode,
              'networkErrorCode',
              NetworkErrorCode.emptyResponse,
            ),
          ),
        );
      });

      test(
        'keeps a protocol exception when the body shape is invalid',
        () async {
          adapter.responseData = {'unexpected': 'shape'};

          await expectLater(
            dataSource.updatePreferences(locale: 'en-US'),
            throwsA(isA<Object>()),
          );
        },
      );
    });

    // ── settingsProfileNoChange sentinel ──────────────────────
    group('settingsProfileNoChange sentinel', () {
      test('is a singleton Object', () {
        expect(settingsProfileNoChange, isA<Object>());
        expect(
          identical(settingsProfileNoChange, settingsProfileNoChange),
          isTrue,
        );
      });

      test('default parameter values match sentinel', () async {
        adapter.responseData = _healthContextResponseJson();

        // Calling without any args should use defaults = sentinel
        await dataSource.updatePreferences();

        final body = adapter.capturedRequest!.data as Map<String, dynamic>;
        expect(body, isEmpty);
      });

      test('explicitly passing sentinel omits field from payload', () async {
        adapter.responseData = _healthContextResponseJson();

        await dataSource.updatePreferences(
          locale: 'en-US',
          timezone: settingsProfileNoChange,
          unitSystem: settingsProfileNoChange,
        );

        final body = adapter.capturedRequest!.data as Map<String, dynamic>;
        expect(body, hasLength(1));
        expect(body['locale'], 'en-US');
      });
    });
  });
}
