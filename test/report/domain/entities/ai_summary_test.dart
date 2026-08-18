import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/report/domain/entities/ai_summary.dart';

void main() {
  group('ReportAiSummaryRange', () {
    test('last7Days has correct apiValue', () {
      expect(ReportAiSummaryRange.last7Days.apiValue, 'last_7_days');
    });

    test('last30Days has correct apiValue', () {
      expect(ReportAiSummaryRange.last30Days.apiValue, 'last_30_days');
    });

    test('custom has correct apiValue', () {
      expect(ReportAiSummaryRange.custom.apiValue, 'custom');
    });
  });

  group('ReportAiSummaryCardState', () {
    test('idle constructor sets idle status', () {
      const state = ReportAiSummaryCardState.idle();
      expect(state.status, ReportAiSummaryCardStatus.idle);
      expect(state.summary, isNull);
      expect(state.streamingSummary, isNull);
      expect(state.errorMessage, isNull);
    });

    test('loading constructor sets loading status', () {
      const state = ReportAiSummaryCardState.loading();
      expect(state.status, ReportAiSummaryCardStatus.loading);
      expect(state.summary, isNull);
      expect(state.streamingSummary, isNull);
    });

    test('loading constructor preserves previousSummary', () {
      final summary = _buildSummary();
      final state = ReportAiSummaryCardState.loading(previousSummary: summary);
      expect(state.status, ReportAiSummaryCardStatus.loading);
      expect(state.summary, same(summary));
    });

    test('loading constructor sets streamingSummary', () {
      const state = ReportAiSummaryCardState.loading(
        streamingSummary: 'Partial...',
      );
      expect(state.streamingSummary, 'Partial...');
    });

    test('success constructor sets success status and summary', () {
      final summary = _buildSummary();
      final state = ReportAiSummaryCardState.success(summary);
      expect(state.status, ReportAiSummaryCardStatus.success);
      expect(state.summary, same(summary));
    });

    test('error constructor sets error status and message', () {
      const state = ReportAiSummaryCardState.error(message: 'Network failed');
      expect(state.status, ReportAiSummaryCardStatus.error);
      expect(state.errorMessage, 'Network failed');
      expect(state.summary, isNull);
    });

    test('error constructor preserves previousSummary', () {
      final summary = _buildSummary();
      final state = ReportAiSummaryCardState.error(
        message: 'Failed',
        previousSummary: summary,
      );
      expect(state.summary, same(summary));
    });

    test('disabled constructor sets disabled status', () {
      const state = ReportAiSummaryCardState.disabled();
      expect(state.status, ReportAiSummaryCardStatus.disabled);
      expect(state.summary, isNull);
    });
  });

  group('ReportAiSummaryCardState computed getters', () {
    test('isLoading is true for loading status', () {
      const state = ReportAiSummaryCardState.loading();
      expect(state.isLoading, isTrue);
    });

    test('isLoading is false for idle status', () {
      const state = ReportAiSummaryCardState.idle();
      expect(state.isLoading, isFalse);
    });

    test('isDisabled is true for disabled status', () {
      const state = ReportAiSummaryCardState.disabled();
      expect(state.isDisabled, isTrue);
    });

    test('isDisabled is false for idle status', () {
      const state = ReportAiSummaryCardState.idle();
      expect(state.isDisabled, isFalse);
    });

    test('hasSummary is true when summary is non-null', () {
      final summary = _buildSummary();
      final state = ReportAiSummaryCardState.success(summary);
      expect(state.hasSummary, isTrue);
    });

    test('hasSummary is false when summary is null', () {
      const state = ReportAiSummaryCardState.idle();
      expect(state.hasSummary, isFalse);
    });
  });

  group('ReportAiSummary', () {
    test('stores all fields correctly', () {
      final summary = ReportAiSummary(
        range: ReportAiSummaryRange.last7Days,
        startDate: '2026-07-05',
        endDate: '2026-07-12',
        generatedAt: DateTime(2026, 7, 12, 10, 30),
        summary: 'Weekly summary',
        coverage: const ReportAiSummaryCoverage(
          medication: ReportAiSummaryCoverageDimension(
            trackedDays: 5,
            totalDays: 7,
          ),
          water: ReportAiSummaryCoverageDimension(trackedDays: 3, totalDays: 7),
          sleep: ReportAiSummaryCoverageDimension(trackedDays: 0, totalDays: 7),
        ),
        observedPattern: const ReportAiSummaryObservedPattern(
          kind: ReportAiSummaryPatternKind.medication,
          text: '用药完成率稳定。',
          source: '用药提醒记录',
        ),
        lowRiskAction: const ReportAiSummaryLowRiskAction(
          label: '继续记录',
          text: '建议保持当前节奏。',
        ),
        disclaimer: '仅基于近 7 天数据。',
      );

      expect(summary.range, ReportAiSummaryRange.last7Days);
      expect(summary.startDate, '2026-07-05');
      expect(summary.endDate, '2026-07-12');
      expect(summary.generatedAt, DateTime(2026, 7, 12, 10, 30));
      expect(summary.summary, 'Weekly summary');
      expect(summary.coverage.medication.trackedDays, 5);
      expect(summary.coverage.water.trackedDays, 3);
      expect(summary.coverage.sleep.trackedDays, 0);
      expect(summary.observedPattern, isNotNull);
      expect(
        summary.observedPattern!.kind,
        ReportAiSummaryPatternKind.medication,
      );
      expect(summary.observedPattern!.text, '用药完成率稳定。');
      expect(summary.observedPattern!.source, '用药提醒记录');
      expect(summary.lowRiskAction, isNotNull);
      expect(summary.lowRiskAction!.label, '继续记录');
      expect(summary.disclaimer, '仅基于近 7 天数据。');
    });

    test('observedPattern and lowRiskAction are nullable', () {
      final summary = _buildSummary();
      expect(summary.observedPattern, isNull);
      expect(summary.lowRiskAction, isNull);
    });
  });

  group('ReportAiSummaryCardStatus', () {
    test('has all expected values', () {
      expect(
        ReportAiSummaryCardStatus.values,
        containsAll([
          ReportAiSummaryCardStatus.idle,
          ReportAiSummaryCardStatus.loading,
          ReportAiSummaryCardStatus.success,
          ReportAiSummaryCardStatus.error,
          ReportAiSummaryCardStatus.disabled,
        ]),
      );
    });
  });

  group('ReportAiSummaryPatternKind', () {
    test('has all expected values', () {
      expect(
        ReportAiSummaryPatternKind.values,
        containsAll([
          ReportAiSummaryPatternKind.medication,
          ReportAiSummaryPatternKind.hydration,
          ReportAiSummaryPatternKind.sleep,
        ]),
      );
    });
  });
}

ReportAiSummary _buildSummary() {
  return ReportAiSummary(
    range: ReportAiSummaryRange.last7Days,
    startDate: '2026-07-05',
    endDate: '2026-07-12',
    generatedAt: DateTime(2026, 7, 12),
    summary: 'Summary',
    coverage: const ReportAiSummaryCoverage(
      medication: ReportAiSummaryCoverageDimension(
        trackedDays: 5,
        totalDays: 7,
      ),
      water: ReportAiSummaryCoverageDimension(trackedDays: 3, totalDays: 7),
      sleep: ReportAiSummaryCoverageDimension(trackedDays: 0, totalDays: 7),
    ),
    observedPattern: null,
    lowRiskAction: null,
    disclaimer: 'Disclaimer',
  );
}
