import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/today/data/datasources/suggestion_remote.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';

import '../helpers/task_either.dart';

/// Adapter that returns a JSON response with configurable body.
class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter({
    this.responseBody,
    this.statusCode = 200,
    this.contentType = 'application/json',
    this.error,
  });

  Map<String, dynamic>? responseBody;
  int statusCode;
  String contentType;

  /// When set, [fetch] throws this object instead of returning a response.
  Object? error;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final e = error;
    if (e != null) {
      throw e;
    }
    final body = jsonEncode(responseBody);

    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [contentType],
      },
    );
  }
}

/// Minimal valid primary action used in test data.
const _testAction = {
  'actionId': '',
  'label': '',
  'route': '',
  'authRequired': false,
};

const _readyMaterialization = {
  'materializationStatus': 'ready',
  'sourceVersion': 3,
  'computedAt': '2026-07-11T08:00:00.000Z',
  'retryAfterSeconds': null,
};

void main() {
  late Dio dio;
  late TodaySuggestionApi api;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
    api = TodaySuggestionApi(dio);
  });

  group('fetchSuggestions', () {
    test('maps full bundle correctly', () async {
      final adapter = _JsonAdapter(
        responseBody: {
          ..._readyMaterialization,
          'generatedAt': '2026-07-11T08:00:00.000Z',
          'primary': {
            'id': 's1',
            'type': 'compliance',
            'cardTone': 'soft',
            'icon': 'pill',
            'title': '吃药提醒',
            'reason': '需要按时服药',
            'evidence': [],
            'boundary': '',
            'primaryAction': {
              'actionId': 'a1',
              'label': '查看',
              'route': '/medicine',
              'authRequired': true,
            },
            'secondaryActions': null,
            'confidence': 'high',
            'ruleId': 'rule-1',
            'ruleVersion': 'v1',
            'triggerType': 'timer',
            'lifecycleState': 'active',
            'notificationEligible': true,
            'feedbackOptions': ['accepted', 'later'],
            'subtype': null,
          },
          'secondary': [],
          'observations': [],
        },
      );
      dio.httpClientAdapter = adapter;

      final ds = TodaySuggestionRemoteDataSource(api: api);
      final result = await expectTaskRight(
        ds.fetchSuggestions(language: 'zh-CN'),
      );

      expect(result.generatedAt, '2026-07-11T08:00:00.000Z');
      expect(
        result.materializationStatus,
        TodaySuggestionMaterializationStatus.ready,
      );
      expect(result.sourceVersion, 3);
      expect(result.computedAt, DateTime.utc(2026, 7, 11, 8));
      expect(result.retryAfterSeconds, isNull);
      expect(result.primary, isNotNull);
      expect(result.primary!.id, 's1');
      expect(result.primary!.type, TodaySuggestionType.compliance);
      expect(result.primary!.confidence, TodaySuggestionConfidence.high);
      expect(result.primary!.triggerType, TodaySuggestionTriggerType.timer);
      expect(
        result.primary!.lifecycleState,
        TodaySuggestionLifecycleState.active,
      );
      expect(result.primary!.primaryAction, isNotNull);
      expect(result.primary!.primaryAction.actionId, 'a1');
      expect(result.primary!.feedbackOptions, [
        TodaySuggestionFeedback.accepted,
        TodaySuggestionFeedback.later,
      ]);
    });

    test('maps bundle with null primary', () async {
      final adapter = _JsonAdapter(
        responseBody: {
          ..._readyMaterialization,
          'generatedAt': '2026-07-11T08:00:00.000Z',
          'primary': null,
          'secondary': null,
          'observations': null,
        },
      );
      dio.httpClientAdapter = adapter;

      final ds = TodaySuggestionRemoteDataSource(api: api);
      final result = await expectTaskRight(
        ds.fetchSuggestions(language: 'zh-CN'),
      );

      expect(result.primary, isNull);
      expect(result.secondary, isNull);
      expect(result.observations, isNull);
    });

    test('maps secondary and observations cards', () async {
      final adapter = _JsonAdapter(
        responseBody: {
          ..._readyMaterialization,
          'generatedAt': '2026-07-11T08:00:00.000Z',
          'primary': null,
          'secondary': [
            {
              'id': 's2',
              'type': 'behavior_advice',
              'cardTone': 'soft',
              'icon': 'water',
              'title': '多喝水',
              'reason': '保持水分',
              'evidence': [],
              'boundary': '',
              'primaryAction': _testAction,
              'secondaryActions': null,
              'confidence': 'medium',
              'ruleId': '',
              'ruleVersion': '',
              'triggerType': 'event',
              'lifecycleState': 'active',
              'notificationEligible': null,
              'feedbackOptions': null,
              'subtype': null,
            },
          ],
          'observations': [
            {
              'id': 'o1',
              'type': 'trend',
              'cardTone': 'neutral',
              'icon': 'chart',
              'title': '趋势观察',
              'reason': '近期数据',
              'evidence': [],
              'boundary': '仅供参考',
              'primaryAction': _testAction,
              'secondaryActions': null,
              'confidence': 'low',
              'ruleId': '',
              'ruleVersion': '',
              'triggerType': 'timer',
              'lifecycleState': 'generated',
              'notificationEligible': false,
              'feedbackOptions': null,
              'subtype': 'custom',
            },
          ],
        },
      );
      dio.httpClientAdapter = adapter;

      final ds = TodaySuggestionRemoteDataSource(api: api);
      final result = await expectTaskRight(
        ds.fetchSuggestions(language: 'zh-CN'),
      );

      expect(result.secondary!.length, 1);
      expect(result.secondary![0].type, TodaySuggestionType.behaviorAdvice);
      expect(result.secondary![0].confidence, TodaySuggestionConfidence.medium);
      expect(
        result.secondary![0].triggerType,
        TodaySuggestionTriggerType.event,
      );

      expect(result.observations!.length, 1);
      expect(result.observations![0].type, TodaySuggestionType.trend);
      expect(result.observations![0].boundary, '仅供参考');
      expect(result.observations![0].subtype, 'custom');
    });

    test('maps evidence items', () async {
      final adapter = _JsonAdapter(
        responseBody: {
          ..._readyMaterialization,
          'generatedAt': '2026-07-11T08:00:00.000Z',
          'primary': {
            'id': 's1',
            'type': 'confirmed_risk',
            'cardTone': 'urgent',
            'icon': 'alert',
            'title': '风险提醒',
            'reason': '药物相互作用',
            'evidence': [
              {
                'kind': 'medicine',
                'label': 'Aspirin',
                'value': '100mg',
                'recordId': null,
                'medicineId': 'med-1',
              },
              {
                'kind': 'record',
                'label': '血压',
                'value': '140/90',
                'recordId': 'rec-1',
                'medicineId': null,
              },
            ],
            'boundary': '',
            'primaryAction': _testAction,
            'secondaryActions': null,
            'confidence': 'high',
            'ruleId': '',
            'ruleVersion': '',
            'triggerType': 'event',
            'lifecycleState': 'active',
            'notificationEligible': null,
            'feedbackOptions': null,
            'subtype': null,
          },
          'secondary': null,
          'observations': null,
        },
      );
      dio.httpClientAdapter = adapter;

      final ds = TodaySuggestionRemoteDataSource(api: api);
      final result = await expectTaskRight(
        ds.fetchSuggestions(language: 'zh-CN'),
      );

      expect(result.primary!.evidence.length, 2);
      expect(result.primary!.evidence[0].label, 'Aspirin');
      expect(result.primary!.evidence[0].medicineId, 'med-1');
      expect(result.primary!.evidence[1].label, '血压');
      expect(result.primary!.evidence[1].recordId, 'rec-1');
    });
  });

  group('submitFeedback', () {
    test('maps feedback result correctly', () async {
      final adapter = _JsonAdapter(
        responseBody: {
          'suggestionId': 's1',
          'feedback': 'accepted',
          'appliedEffect': 'noted',
          'expiresAt': '2026-07-12T08:00:00.000Z',
        },
      );
      dio.httpClientAdapter = adapter;

      final ds = TodaySuggestionRemoteDataSource(api: api);
      final result = await expectTaskRight(
        ds.submitFeedback(id: 's1', feedback: TodaySuggestionFeedback.accepted),
      );

      expect(result.suggestionId, 's1');
      expect(result.feedback, TodaySuggestionFeedback.accepted);
      expect(result.appliedEffect, TodaySuggestionFeedbackEffect.noted);
      expect(result.expiresAt, '2026-07-12T08:00:00.000Z');
    });

    test('maps all feedback types', () async {
      for (final feedback in TodaySuggestionFeedback.values) {
        final adapter = _JsonAdapter(
          responseBody: {
            'suggestionId': 's1',
            'feedback': _feedbackToString(feedback),
            'appliedEffect': 'noted',
            'expiresAt': null,
          },
        );
        dio.httpClientAdapter = adapter;

        final ds = TodaySuggestionRemoteDataSource(api: api);
        final result = await expectTaskRight(
          ds.submitFeedback(id: 's1', feedback: feedback),
        );

        expect(
          result.feedback,
          feedback,
          reason: 'feedback round-trip failed for $feedback',
        );
      }
    });
  });

  group('explainSuggestion', () {
    test('maps explanation correctly', () async {
      final adapter = _JsonAdapter(
        responseBody: {
          'suggestionId': 's1',
          'reason': '基于您的用药记录和血压数据',
          'boundary': '本建议仅供参考',
          'aiGenerated': true,
          'locale': 'zh-CN',
        },
      );
      dio.httpClientAdapter = adapter;

      final ds = TodaySuggestionRemoteDataSource(api: api);
      final result = await expectTaskRight(
        ds.explainSuggestion(id: 's1', language: 'zh-CN'),
      );

      expect(result.suggestionId, 's1');
      expect(result.reason, '基于您的用药记录和血压数据');
      expect(result.boundary, '本建议仅供参考');
      expect(result.aiGenerated, isTrue);
      expect(result.locale, 'zh-CN');
    });
  });

  group('fetchHistory', () {
    test('maps history correctly', () async {
      final adapter = _JsonAdapter(
        responseBody: {
          'items': [
            {
              'id': 'h1',
              'date': '2026-07-10',
              'type': 'compliance',
              'title': '服药提醒',
              'reason': '按时服药',
              'ruleId': 'rule-1',
              'ruleVersion': 'v1',
              'triggerType': 'timer',
              'lifecycleState': 'expired',
              'confidence': 'high',
              'generatedAt': '2026-07-10T08:00:00.000Z',
              'subtype': null,
              'feedback': 'accepted',
              'feedbackAt': '2026-07-10T09:00:00.000Z',
              'expiredAt': '2026-07-10T12:00:00.000Z',
            },
          ],
          'total': 1,
          'startDate': '2026-07-01',
          'endDate': '2026-07-10',
        },
      );
      dio.httpClientAdapter = adapter;

      final ds = TodaySuggestionRemoteDataSource(api: api);
      final result = await expectTaskRight(
        ds.fetchHistory(
          language: 'zh-CN',
          startDate: '2026-07-01',
          endDate: '2026-07-10',
        ),
      );

      expect(result.items.length, 1);
      expect(result.items[0].id, 'h1');
      expect(result.items[0].type, TodaySuggestionType.compliance);
      expect(result.items[0].feedback, TodaySuggestionFeedback.accepted);
      expect(result.total, 1);
      expect(result.startDate, '2026-07-01');
      expect(result.endDate, '2026-07-10');
    });

    test('maps history item without feedback', () async {
      final adapter = _JsonAdapter(
        responseBody: {
          'items': [
            {
              'id': 'h2',
              'date': '2026-07-09',
              'type': 'behavior_advice',
              'title': '多喝水',
              'reason': '保持水分',
              'ruleId': '',
              'ruleVersion': '',
              'triggerType': 'event',
              'lifecycleState': 'dismissed',
              'confidence': 'low',
              'generatedAt': '2026-07-09T08:00:00.000Z',
              'subtype': 'custom',
              'feedback': null,
              'feedbackAt': null,
              'expiredAt': null,
            },
          ],
          'total': 1,
          'startDate': '2026-07-01',
          'endDate': '2026-07-09',
        },
      );
      dio.httpClientAdapter = adapter;

      final ds = TodaySuggestionRemoteDataSource(api: api);
      final result = await expectTaskRight(ds.fetchHistory(language: 'zh-CN'));

      expect(result.items[0].feedback, isNull);
      expect(result.items[0].feedbackAt, isNull);
      expect(result.items[0].subtype, 'custom');
    });
  });

  group('enum mapping fallbacks', () {
    test('unknown confidence fallback to medium', () async {
      final adapter = _JsonAdapter(
        responseBody: {
          ..._readyMaterialization,
          'generatedAt': '2026-07-11T08:00:00.000Z',
          'primary': {
            'id': 's1',
            'type': 'behavior_advice',
            'cardTone': 'soft',
            'icon': 'pill',
            'title': 't',
            'reason': 'r',
            'evidence': [],
            'boundary': '',
            'primaryAction': _testAction,
            'secondaryActions': null,
            'confidence': 'unknown_value',
            'ruleId': '',
            'ruleVersion': '',
            'triggerType': 'unknown',
            'lifecycleState': 'unknown',
            'notificationEligible': null,
            'feedbackOptions': null,
            'subtype': null,
          },
          'secondary': null,
          'observations': null,
        },
      );
      dio.httpClientAdapter = adapter;

      final ds = TodaySuggestionRemoteDataSource(api: api);
      final result = await expectTaskRight(
        ds.fetchSuggestions(language: 'zh-CN'),
      );

      expect(result.primary!.confidence, TodaySuggestionConfidence.medium);
      expect(result.primary!.triggerType, TodaySuggestionTriggerType.timer);
    });
  });

  group('failure branches', () {
    test('404 Problem Details keeps code and status', () async {
      final adapter = _JsonAdapter(
        statusCode: 404,
        contentType: 'application/problem+json',
        responseBody: {
          'type': 'https://api.lumos.example/problems/SUGGESTION_NOT_FOUND',
          'title': 'Not found',
          'detail': '建议不存在或已过期',
          'code': 'SUGGESTION_NOT_FOUND',
        },
      );
      dio.httpClientAdapter = adapter;

      final ds = TodaySuggestionRemoteDataSource(api: api);
      final failure = await expectTaskLeft(
        ds.fetchSuggestions(language: 'zh-CN'),
      );

      expect(failure.code, 'SUGGESTION_NOT_FOUND');
      expect(failure.statusCode, 404);
    });

    test('network timeout maps to a network connectivity Left', () async {
      final adapter = _JsonAdapter(
        error: DioException(
          requestOptions: RequestOptions(
            path: '/api/v1/user/today/suggestions',
          ),
          type: DioExceptionType.connectionTimeout,
        ),
      );
      dio.httpClientAdapter = adapter;

      final ds = TodaySuggestionRemoteDataSource(api: api);
      final failure = await expectTaskLeft(
        ds.fetchSuggestions(language: 'zh-CN'),
      );

      expect(failure.isNetworkConnectivityError, isTrue);
    });

    test(
      'non-Problem Details error body propagates FormatException from run()',
      () async {
        final adapter = _JsonAdapter(
          statusCode: 400,
          responseBody: {'error': 'oops'},
        );
        dio.httpClientAdapter = adapter;

        final ds = TodaySuggestionRemoteDataSource(api: api);
        await expectLater(
          ds.fetchSuggestions(language: 'zh-CN').run(),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'empty success body maps to a Left(network emptyResponse) via requireData',
      () async {
        // HTTP 200 with a JSON `null` body: the generated client leaves
        // response.data null, so requireData throws LucentFailure.network(
        // emptyResponse), which maps to a network Left.
        final adapter = _JsonAdapter(statusCode: 200, responseBody: null);
        dio.httpClientAdapter = adapter;

        final ds = TodaySuggestionRemoteDataSource(api: api);
        final failure = await expectTaskLeft(
          ds.fetchSuggestions(language: 'zh-CN'),
        );

        expect(failure.kind, LucentFailureKind.network);
        expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
      },
    );
  });
}

String _feedbackToString(TodaySuggestionFeedback feedback) {
  return switch (feedback) {
    TodaySuggestionFeedback.accepted => 'accepted',
    TodaySuggestionFeedback.later => 'later',
    TodaySuggestionFeedback.notApplicable => 'not_applicable',
    TodaySuggestionFeedback.suppress => 'suppress',
  };
}
