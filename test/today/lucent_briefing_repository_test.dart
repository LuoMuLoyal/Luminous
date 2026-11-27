import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/features/today/data/datasources/briefing_remote.dart';
import 'package:luminous/features/today/data/repositories/lucent_briefing.dart';
import 'package:luminous/features/today/domain/entities/briefing.dart';
import 'package:luminous/features/today/domain/repositories/briefing.dart';
import 'package:luminous/shared/domain/failure.dart';

import '../helpers/task_either.dart';

class _FakeTodayBriefingRemoteDataSource
    implements TodayBriefingRemoteDataSource {
  _FakeTodayBriefingRemoteDataSource();

  List<TodayBriefingRemoteEvent> streamEvents = [];
  Object? streamError;
  lucent.AnalysisReadResponse? readResult;
  lucent.AnalysisReadResponse? refreshResult;
  Object? readError;
  Object? refreshError;

  @override
  final lucent.TodayAnalysisApi api = lucent.TodayAnalysisApi(
    Dio(BaseOptions(baseUrl: 'http://localhost')),
  );

  @override
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));

  @override
  Future<lucent.AnalysisReadResponse> read({String? date}) async {
    final error = readError;
    if (error != null) throw error;
    if (readResult == null) {
      throw StateError('read() not stubbed');
    }
    return readResult!;
  }

  @override
  Future<lucent.AnalysisReadResponse> refresh({String? date}) async {
    final error = refreshError;
    if (error != null) throw error;
    if (refreshResult == null) {
      throw StateError('refresh() not stubbed');
    }
    return refreshResult!;
  }

  @override
  Stream<TodayBriefingRemoteEvent> generateStream({String? date}) async* {
    if (streamError != null) {
      throw streamError!;
    }
    for (final event in streamEvents) {
      yield event;
    }
  }
}

lucent.AnalysisReadResponseAnalysis _buildDto({
  String date = '2026-07-10',
  String summary = '今日健康状况良好',
  String actionLabel = '多喝水',
  String confidenceNote = '基于最近7天数据',
  bool briefingGenerated = true,
  List<lucent.AnalysisReadResponseAnalysisBullets>? bullets,
}) {
  return lucent.AnalysisReadResponseAnalysis(
    date: date,
    generatedAt: '2026-07-10T08:00:00.000Z',
    summary: summary,
    bullets: bullets ?? [],
    actionLabel: actionLabel,
    action: 'navigate_to_record',
    confidenceNote: confidenceNote,
    briefingGenerated: briefingGenerated,
  );
}

lucent.AnalysisReadResponse _buildReadDto({
  lucent.AnalysisReadResponseStatusEnum status =
      lucent.AnalysisReadResponseStatusEnum.ready,
  lucent.AnalysisReadResponseAnalysis? analysis,
  String? computedAt = '2026-07-10T08:00:00.000Z',
}) {
  return lucent.AnalysisReadResponse(
    status: status,
    analysis: analysis,
    sourceVersion: 1,
    computedVersion: 1,
    computedAt: computedAt,
    retryAfterSeconds: null,
  );
}

lucent.AnalysisReadResponseAnalysisBullets _bullet({
  required String kind,
  required String text,
}) {
  return lucent.AnalysisReadResponseAnalysisBullets.fromJson(<String, Object?>{
    'kind': kind,
    'text': text,
  });
}

void main() {
  group('LucentTodayBriefingRepository', () {
    late _FakeTodayBriefingRemoteDataSource dataSource;
    late LucentTodayBriefingRepository repo;

    setUp(() {
      dataSource = _FakeTodayBriefingRemoteDataSource();
      repo = LucentTodayBriefingRepository(dataSource: dataSource);
    });

    // ─── read ──────────────────────────────────────────────────────────
    group('read', () {
      test('maps ready read DTO to TodayBriefing', () async {
        dataSource.readResult = _buildReadDto(
          analysis: _buildDto(
            date: '2026-07-11',
            summary: '今日健康提醒',
            actionLabel: '按时服药',
            confidenceNote: '高置信度',
            briefingGenerated: true,
            bullets: [_bullet(kind: 'medication', text: '记得服用阿司匹林')],
          ),
        );

        final analysis = await expectTaskRight(
          repo.read(DateTime.utc(2026, 7, 11)),
        );

        expect(analysis.date, '2026-07-11');
        expect(analysis.summary, '今日健康提醒');
        expect(
          analysis.materializationStatus,
          TodayBriefingMaterializationStatus.ready,
        );
        expect(analysis.briefingGenerated, isTrue);
      });

      test('maps empty read DTO to empty analysis', () async {
        dataSource.readResult = _buildReadDto(
          status: lucent.AnalysisReadResponseStatusEnum.empty,
          analysis: null,
        );

        final analysis = await expectTaskRight(
          repo.read(DateTime.utc(2026, 7, 11)),
        );

        expect(
          analysis.materializationStatus,
          TodayBriefingMaterializationStatus.empty,
        );
        expect(analysis.summary, '');
      });

      test('maps pending read DTO preserving computedAt', () async {
        dataSource.readResult = _buildReadDto(
          status: lucent.AnalysisReadResponseStatusEnum.pending,
          analysis: null,
          computedAt: '2026-07-10T08:00:00.000Z',
        );

        final analysis = await expectTaskRight(
          repo.read(DateTime.utc(2026, 7, 11)),
        );

        expect(
          analysis.materializationStatus,
          TodayBriefingMaterializationStatus.pending,
        );
        expect(
          analysis.generatedAt,
          DateTime.parse('2026-07-10T08:00:00.000Z'),
        );
        // 服务端未下发 analysis 时合成的是**空**占位对象,却把 briefingGenerated 置为
        // false;展示层不得据此宣称「规则摘要」(摘要正文为空即为无内容)。
        expect(analysis.summary, '');
        expect(analysis.briefingGenerated, isFalse);
      });

      test('maps stale read DTO', () async {
        dataSource.readResult = _buildReadDto(
          status: lucent.AnalysisReadResponseStatusEnum.stale,
          analysis: _buildDto(briefingGenerated: false),
        );

        final analysis = await expectTaskRight(
          repo.read(DateTime.utc(2026, 7, 11)),
        );

        expect(
          analysis.materializationStatus,
          TodayBriefingMaterializationStatus.stale,
        );
        expect(analysis.briefingGenerated, isFalse);
      });

      test('maps failed read DTO', () async {
        dataSource.readResult = _buildReadDto(
          status: lucent.AnalysisReadResponseStatusEnum.failed,
          analysis: null,
        );

        final analysis = await expectTaskRight(
          repo.read(DateTime.utc(2026, 7, 11)),
        );

        expect(
          analysis.materializationStatus,
          TodayBriefingMaterializationStatus.failed,
        );
      });
    });

    // ─── refresh ───────────────────────────────────────────────────────
    group('refresh', () {
      test('maps ready refresh response to TodayBriefing', () async {
        dataSource.refreshResult = _buildReadDto(
          analysis: _buildDto(
            date: '2026-07-11',
            summary: '刷新后的摘要',
            briefingGenerated: true,
          ),
        );

        final analysis = await expectTaskRight(
          repo.refresh(DateTime.utc(2026, 7, 11)),
        );

        expect(analysis.summary, '刷新后的摘要');
        expect(
          analysis.materializationStatus,
          TodayBriefingMaterializationStatus.ready,
        );
      });

      test('maps pending refresh response to pending analysis', () async {
        dataSource.refreshResult = _buildReadDto(
          status: lucent.AnalysisReadResponseStatusEnum.pending,
          analysis: null,
        );

        final analysis = await expectTaskRight(
          repo.refresh(DateTime.utc(2026, 7, 11)),
        );

        expect(
          analysis.materializationStatus,
          TodayBriefingMaterializationStatus.pending,
        );
      });
    });

    // ─── failure branches ──────────────────────────────────────────────
    group('failure branches', () {
      test('read network timeout maps to a network Left', () async {
        dataSource.readError = DioException(
          requestOptions: RequestOptions(path: '/api/v1/user/today/analysis'),
          type: DioExceptionType.connectionTimeout,
        );

        final failure = await expectTaskLeft(
          repo.read(DateTime.utc(2026, 7, 11)),
        );

        expect(failure.isNetworkConnectivityError, isTrue);
      });

      test('read 403 Problem Details keeps code and status', () async {
        const path = '/api/v1/user/today/analysis';
        dataSource.readError = DioException(
          requestOptions: RequestOptions(path: path),
          response: Response<Object>(
            requestOptions: RequestOptions(path: path),
            statusCode: 403,
            headers: Headers()
              ..set(Headers.contentTypeHeader, 'application/problem+json'),
            data: <String, dynamic>{
              'type': 'https://api.lumos.example/problems/FORBIDDEN',
              'title': 'Forbidden',
              'detail': 'AI 摘要未启用',
              'code': 'FORBIDDEN',
            },
          ),
        );

        final failure = await expectTaskLeft(
          repo.read(DateTime.utc(2026, 7, 11)),
        );

        expect(failure.code, 'FORBIDDEN');
        expect(failure.statusCode, 403);
        expect(failure.kind, LucentFailureKind.authentication);
      });

      test('refresh network failure maps to a network Left', () async {
        dataSource.refreshError = DioException(
          requestOptions: RequestOptions(path: '/api/v1/user/today/analysis'),
          type: DioExceptionType.connectionError,
        );

        final failure = await expectTaskLeft(
          repo.refresh(DateTime.utc(2026, 7, 11)),
        );

        expect(failure.isNetworkConnectivityError, isTrue);
      });
    });

    // ─── generateStream ────────────────────────────────────────────────
    group('generateStream', () {
      test('emits summary event from remote summary event', () async {
        dataSource.streamEvents = [
          const TodayBriefingRemoteSummaryEvent('正在分析...'),
          TodayBriefingRemoteResultEvent(_buildDto()),
        ];

        final events = await repo.generateStream().toList();

        expect(events, hasLength(2));
        expect(events[0], isA<TodayBriefingSummaryEvent>());
        expect((events[0] as TodayBriefingSummaryEvent).summary, '正在分析...');
        expect(events[1], isA<TodayBriefingResultEvent>());
      });

      test('maps result event to TodayBriefing correctly', () async {
        final dto = _buildDto(
          date: '2026-07-11',
          summary: '今日健康提醒',
          actionLabel: '按时服药',
          confidenceNote: '高置信度',
          briefingGenerated: true,
          bullets: [
            _bullet(kind: 'medication', text: '记得服用阿司匹林'),
            _bullet(kind: 'hydration', text: '饮水量不足'),
            _bullet(kind: 'sleep', text: '睡眠时长偏短'),
            _bullet(kind: 'general', text: '注意休息'),
          ],
        );

        dataSource.streamEvents = [TodayBriefingRemoteResultEvent(dto)];

        final events = await repo.generateStream().toList();

        expect(events, hasLength(1));
        final result = events[0] as TodayBriefingResultEvent;
        final analysis = result.analysis;

        expect(analysis.date, '2026-07-11');
        expect(analysis.summary, '今日健康提醒');
        expect(analysis.actionLabel, '按时服药');
        expect(analysis.confidenceNote, '高置信度');
        expect(
          analysis.generatedAt,
          DateTime.parse('2026-07-10T08:00:00.000Z'),
        );
        expect(analysis.bullets, hasLength(4));

        expect(analysis.bullets[0].kind, TodayBriefingBulletKind.medication);
        expect(analysis.bullets[0].text, '记得服用阿司匹林');

        expect(analysis.bullets[1].kind, TodayBriefingBulletKind.hydration);
        expect(analysis.bullets[1].text, '饮水量不足');

        expect(analysis.bullets[2].kind, TodayBriefingBulletKind.sleep);
        expect(analysis.bullets[2].text, '睡眠时长偏短');

        expect(analysis.bullets[3].kind, TodayBriefingBulletKind.general);
        expect(analysis.bullets[3].text, '注意休息');
      });

      test('maps unknown bullet kind to general', () async {
        final dto = _buildDto(
          bullets: [_bullet(kind: 'unknown_kind', text: 'Unknown category')],
        );

        dataSource.streamEvents = [TodayBriefingRemoteResultEvent(dto)];

        final events = await repo.generateStream().toList();

        final result = events[0] as TodayBriefingResultEvent;
        expect(
          result.analysis.bullets[0].kind,
          TodayBriefingBulletKind.general,
        );
      });

      test('emits multiple summary events before result', () async {
        dataSource.streamEvents = [
          const TodayBriefingRemoteSummaryEvent('正在分析数据...'),
          const TodayBriefingRemoteSummaryEvent('生成建议中...'),
          const TodayBriefingRemoteSummaryEvent('即将完成...'),
          TodayBriefingRemoteResultEvent(_buildDto()),
        ];

        final events = await repo.generateStream().toList();

        expect(events, hasLength(4));
        expect(events[0], isA<TodayBriefingSummaryEvent>());
        expect(events[1], isA<TodayBriefingSummaryEvent>());
        expect(events[2], isA<TodayBriefingSummaryEvent>());
        expect(events[3], isA<TodayBriefingResultEvent>());
      });

      test('emits only result event when no summaries', () async {
        dataSource.streamEvents = [TodayBriefingRemoteResultEvent(_buildDto())];

        final events = await repo.generateStream().toList();

        expect(events, hasLength(1));
        expect(events[0], isA<TodayBriefingResultEvent>());
      });

      test('emits no events when stream is empty', () async {
        dataSource.streamEvents = [];

        final events = await repo.generateStream().toList();

        expect(events, isEmpty);
      });

      test('propagates stream errors', () async {
        dataSource.streamError = const LucentFailure(
          kind: LucentFailureKind.server,
          message: 'AI service unavailable.',
        );

        expect(
          () => repo.generateStream().toList(),
          throwsA(isA<LucentFailure>()),
        );
      });

      test('passes date parameter to dataSource', () async {
        dataSource.streamEvents = [];

        await repo.generateStream(date: '2026-07-11').toList();

        // The fake dataSource ignores date, but we verify the call doesn't throw
        // and the stream completes normally.
      });

      test('maps empty bullets list', () async {
        final dto = _buildDto(bullets: []);

        dataSource.streamEvents = [TodayBriefingRemoteResultEvent(dto)];

        final events = await repo.generateStream().toList();

        final result = events[0] as TodayBriefingResultEvent;
        expect(result.analysis.bullets, isEmpty);
      });
    });

    // ─── generate ──────────────────────────────────────────────────────
    group('generate', () {
      test('returns analysis from stream result event', () async {
        final dto = _buildDto(date: '2026-07-10', summary: '健康日报');

        dataSource.streamEvents = [
          const TodayBriefingRemoteSummaryEvent('分析中...'),
          TodayBriefingRemoteResultEvent(dto),
        ];

        final analysis = await expectTaskRight(repo.generate());

        expect(analysis.date, '2026-07-10');
        expect(analysis.summary, '健康日报');
      });

      test(
        'stream ending without a result event becomes a business Left',
        () async {
          dataSource.streamEvents = [
            const TodayBriefingRemoteSummaryEvent('分析中...'),
          ];

          final failure = await expectTaskLeft(repo.generate());

          expect(failure.kind, LucentFailureKind.business);
          expect(failure.code, 'AI_EMPTY_RESULT');
        },
      );

      test('empty stream becomes a business Left', () async {
        dataSource.streamEvents = [];

        final failure = await expectTaskLeft(repo.generate());

        expect(failure.kind, LucentFailureKind.business);
        expect(failure.code, 'AI_EMPTY_RESULT');
      });

      test('returns analysis immediately when result is first event', () async {
        final dto = _buildDto();

        dataSource.streamEvents = [TodayBriefingRemoteResultEvent(dto)];

        final analysis = await expectTaskRight(repo.generate());

        expect(analysis.date, '2026-07-10');
      });

      test('passes date parameter through', () async {
        final dto = _buildDto(date: '2026-07-15');

        dataSource.streamEvents = [TodayBriefingRemoteResultEvent(dto)];

        final analysis = await expectTaskRight(
          repo.generate(date: '2026-07-15'),
        );

        expect(analysis.date, '2026-07-15');
      });

      test('stream errors surface as a Left failure', () async {
        dataSource.streamError = Exception('Stream failed');

        final failure = await expectTaskLeft(repo.generate());

        expect(failure.kind, LucentFailureKind.unknown);
      });
    });
  });
}
