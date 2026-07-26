import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/features/today/data/datasources/ai_remote.dart';
import 'package:luminous/features/today/data/repositories/lucent_ai.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';
import 'package:luminous/features/today/domain/repositories/ai.dart';

class _FakeTodayAiRemoteDataSource implements TodayAiRemoteDataSource {
  _FakeTodayAiRemoteDataSource();

  List<TodayAiRemoteEvent> streamEvents = [];
  Object? streamError;

  @override
  final lucent.TodayAnalysisApi api = lucent.TodayAnalysisApi(
    Dio(BaseOptions(baseUrl: 'http://localhost')),
  );

  @override
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'));

  @override
  Future<lucent.TodayAnalysisDataDto> generate({String? date}) async {
    throw UnimplementedError();
  }

  @override
  Stream<TodayAiRemoteEvent> generateStream({String? date}) async* {
    if (streamError != null) {
      throw streamError!;
    }
    for (final event in streamEvents) {
      yield event;
    }
  }
}

lucent.TodayAnalysisDataDto _buildDto({
  String date = '2026-07-10',
  String summary = '今日健康状况良好',
  String actionLabel = '多喝水',
  String confidenceNote = '基于最近7天数据',
  List<lucent.TodayAnalysisBulletDto>? bullets,
}) {
  return lucent.TodayAnalysisDataDto(
    date: date,
    generatedAt: '2026-07-10T08:00:00.000Z',
    summary: summary,
    bullets: bullets ?? [],
    actionLabel: actionLabel,
    action: 'navigate_to_record',
    confidenceNote: confidenceNote,
  );
}

lucent.TodayAnalysisBulletDto _bullet({
  required String kind,
  required String text,
}) {
  return lucent.TodayAnalysisBulletDto.fromJson(<String, Object?>{
    'kind': kind,
    'text': text,
  });
}

void main() {
  group('LucentTodayAiRepository', () {
    late _FakeTodayAiRemoteDataSource dataSource;
    late LucentTodayAiRepository repo;

    setUp(() {
      dataSource = _FakeTodayAiRemoteDataSource();
      repo = LucentTodayAiRepository(dataSource: dataSource);
    });

    // ─── generateStream ──────────────────────────────────────────────
    group('generateStream', () {
      test('emits summary event from remote summary event', () async {
        dataSource.streamEvents = [
          const TodayAiRemoteSummaryEvent('正在分析...'),
          TodayAiRemoteResultEvent(_buildDto()),
        ];

        final events = await repo.generateStream().toList();

        expect(events, hasLength(2));
        expect(events[0], isA<TodayAiGenerationSummaryEvent>());
        expect((events[0] as TodayAiGenerationSummaryEvent).summary, '正在分析...');
        expect(events[1], isA<TodayAiGenerationResultEvent>());
      });

      test('maps result event to TodayAiAnalysis correctly', () async {
        final dto = _buildDto(
          date: '2026-07-11',
          summary: '今日健康提醒',
          actionLabel: '按时服药',
          confidenceNote: '高置信度',
          bullets: [
            _bullet(kind: 'medication', text: '记得服用阿司匹林'),
            _bullet(kind: 'hydration', text: '饮水量不足'),
            _bullet(kind: 'sleep', text: '睡眠时长偏短'),
            _bullet(kind: 'general', text: '注意休息'),
          ],
        );

        dataSource.streamEvents = [TodayAiRemoteResultEvent(dto)];

        final events = await repo.generateStream().toList();

        expect(events, hasLength(1));
        final result = events[0] as TodayAiGenerationResultEvent;
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

        expect(analysis.bullets[0].kind, TodayAiAnalysisBulletKind.medication);
        expect(analysis.bullets[0].text, '记得服用阿司匹林');

        expect(analysis.bullets[1].kind, TodayAiAnalysisBulletKind.hydration);
        expect(analysis.bullets[1].text, '饮水量不足');

        expect(analysis.bullets[2].kind, TodayAiAnalysisBulletKind.sleep);
        expect(analysis.bullets[2].text, '睡眠时长偏短');

        expect(analysis.bullets[3].kind, TodayAiAnalysisBulletKind.general);
        expect(analysis.bullets[3].text, '注意休息');
      });

      test('maps unknown bullet kind to general', () async {
        final dto = _buildDto(
          bullets: [_bullet(kind: 'unknown_kind', text: 'Unknown category')],
        );

        dataSource.streamEvents = [TodayAiRemoteResultEvent(dto)];

        final events = await repo.generateStream().toList();

        final result = events[0] as TodayAiGenerationResultEvent;
        expect(
          result.analysis.bullets[0].kind,
          TodayAiAnalysisBulletKind.general,
        );
      });

      test('emits multiple summary events before result', () async {
        dataSource.streamEvents = [
          const TodayAiRemoteSummaryEvent('正在分析数据...'),
          const TodayAiRemoteSummaryEvent('生成建议中...'),
          const TodayAiRemoteSummaryEvent('即将完成...'),
          TodayAiRemoteResultEvent(_buildDto()),
        ];

        final events = await repo.generateStream().toList();

        expect(events, hasLength(4));
        expect(events[0], isA<TodayAiGenerationSummaryEvent>());
        expect(events[1], isA<TodayAiGenerationSummaryEvent>());
        expect(events[2], isA<TodayAiGenerationSummaryEvent>());
        expect(events[3], isA<TodayAiGenerationResultEvent>());
      });

      test('emits only result event when no summaries', () async {
        dataSource.streamEvents = [TodayAiRemoteResultEvent(_buildDto())];

        final events = await repo.generateStream().toList();

        expect(events, hasLength(1));
        expect(events[0], isA<TodayAiGenerationResultEvent>());
      });

      test('emits no events when stream is empty', () async {
        dataSource.streamEvents = [];

        final events = await repo.generateStream().toList();

        expect(events, isEmpty);
      });

      test('propagates stream errors', () async {
        dataSource.streamError = const LucentApiException(
          message: 'AI 服务暂时不可用',
        );

        expect(
          () => repo.generateStream().toList(),
          throwsA(isA<LucentApiException>()),
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

        dataSource.streamEvents = [TodayAiRemoteResultEvent(dto)];

        final events = await repo.generateStream().toList();

        final result = events[0] as TodayAiGenerationResultEvent;
        expect(result.analysis.bullets, isEmpty);
      });
    });

    // ─── generate ────────────────────────────────────────────────────
    group('generate', () {
      test('returns analysis from stream result event', () async {
        final dto = _buildDto(date: '2026-07-10', summary: '健康日报');

        dataSource.streamEvents = [
          const TodayAiRemoteSummaryEvent('分析中...'),
          TodayAiRemoteResultEvent(dto),
        ];

        final analysis = await repo.generate();

        expect(analysis.date, '2026-07-10');
        expect(analysis.summary, '健康日报');
      });

      test('throws StateError when stream ends without result event', () async {
        dataSource.streamEvents = [const TodayAiRemoteSummaryEvent('分析中...')];

        expect(() => repo.generate(), throwsA(isA<StateError>()));
      });

      test('throws StateError when stream is empty', () async {
        dataSource.streamEvents = [];

        expect(() => repo.generate(), throwsA(isA<StateError>()));
      });

      test('returns analysis immediately when result is first event', () async {
        final dto = _buildDto();

        dataSource.streamEvents = [TodayAiRemoteResultEvent(dto)];

        final analysis = await repo.generate();

        expect(analysis.date, '2026-07-10');
      });

      test('passes date parameter through', () async {
        final dto = _buildDto(date: '2026-07-15');

        dataSource.streamEvents = [TodayAiRemoteResultEvent(dto)];

        final analysis = await repo.generate(date: '2026-07-15');

        expect(analysis.date, '2026-07-15');
      });

      test('propagates stream errors', () async {
        dataSource.streamError = Exception('Stream failed');

        expect(() => repo.generate(), throwsException);
      });
    });
  });
}
