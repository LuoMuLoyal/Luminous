import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/review/domain/entities/ai_summary.dart';

void main() {
  group('ReviewAiSummaryRange', () {
    test('last7Days has correct apiValue', () {
      expect(ReviewAiSummaryRange.last7Days.apiValue, 'last_7_days');
    });

    test('last30Days has correct apiValue', () {
      expect(ReviewAiSummaryRange.last30Days.apiValue, 'last_30_days');
    });

    test('custom has correct apiValue', () {
      expect(ReviewAiSummaryRange.custom.apiValue, 'custom');
    });
  });

  group('ReviewAiSummaryCardState', () {
    test('idle constructor sets idle status', () {
      const state = ReviewAiSummaryCardState.idle();
      expect(state.status, ReviewAiSummaryCardStatus.idle);
      expect(state.summary, isNull);
      expect(state.streamingSummary, isNull);
      expect(state.errorMessage, isNull);
    });

    test('loading constructor sets loading status', () {
      const state = ReviewAiSummaryCardState.loading();
      expect(state.status, ReviewAiSummaryCardStatus.loading);
      expect(state.summary, isNull);
      expect(state.streamingSummary, isNull);
    });

    test('loading constructor preserves previousSummary', () {
      final summary = _buildSummary();
      final state = ReviewAiSummaryCardState.loading(previousSummary: summary);
      expect(state.status, ReviewAiSummaryCardStatus.loading);
      expect(state.summary, same(summary));
    });

    test('loading constructor sets streamingSummary', () {
      const state = ReviewAiSummaryCardState.loading(
        streamingSummary: 'Partial...',
      );
      expect(state.streamingSummary, 'Partial...');
    });

    test('success constructor sets success status and summary', () {
      final summary = _buildSummary();
      final state = ReviewAiSummaryCardState.success(summary);
      expect(state.status, ReviewAiSummaryCardStatus.success);
      expect(state.summary, same(summary));
    });

    test('error constructor sets error status and message', () {
      const state = ReviewAiSummaryCardState.error(message: 'Network failed');
      expect(state.status, ReviewAiSummaryCardStatus.error);
      expect(state.errorMessage, 'Network failed');
      expect(state.summary, isNull);
    });

    test('error constructor preserves previousSummary', () {
      final summary = _buildSummary();
      final state = ReviewAiSummaryCardState.error(
        message: 'Failed',
        previousSummary: summary,
      );
      expect(state.summary, same(summary));
    });

    test('disabled constructor sets disabled status', () {
      const state = ReviewAiSummaryCardState.disabled();
      expect(state.status, ReviewAiSummaryCardStatus.disabled);
      expect(state.summary, isNull);
    });
  });

  group('ReviewAiSummaryCardState computed getters', () {
    test('isLoading is true for loading status', () {
      const state = ReviewAiSummaryCardState.loading();
      expect(state.isLoading, isTrue);
    });

    test('isLoading is false for idle status', () {
      const state = ReviewAiSummaryCardState.idle();
      expect(state.isLoading, isFalse);
    });

    test('isDisabled is true for disabled status', () {
      const state = ReviewAiSummaryCardState.disabled();
      expect(state.isDisabled, isTrue);
    });

    test('isDisabled is false for idle status', () {
      const state = ReviewAiSummaryCardState.idle();
      expect(state.isDisabled, isFalse);
    });

    test('hasSummary is true when summary is non-null', () {
      final summary = _buildSummary();
      final state = ReviewAiSummaryCardState.success(summary);
      expect(state.hasSummary, isTrue);
    });

    test('hasSummary is false when summary is null', () {
      const state = ReviewAiSummaryCardState.idle();
      expect(state.hasSummary, isFalse);
    });
  });

  group('ReviewAiSummary', () {
    test('stores all fields correctly', () {
      final summary = ReviewAiSummary(
        range: ReviewAiSummaryRange.last7Days,
        startDate: '2026-07-05',
        endDate: '2026-07-12',
        generatedAt: DateTime(2026, 7, 12, 10, 30),
        summary: 'Weekly summary',
        coverage: const ReviewAiSummaryCoverage(
          medication: ReviewAiSummaryCoverageDimension(
            trackedDays: 5,
            totalDays: 7,
          ),
          water: ReviewAiSummaryCoverageDimension(trackedDays: 3, totalDays: 7),
          sleep: ReviewAiSummaryCoverageDimension(trackedDays: 0, totalDays: 7),
        ),
        observedPattern: const ReviewAiSummaryObservedPattern(
          kind: ReviewAiSummaryPatternKind.medication,
          text: '用药完成率稳定。',
          source: '用药提醒记录',
        ),
        lowRiskAction: const ReviewAiSummaryLowRiskAction(
          label: '继续记录',
          text: '建议保持当前节奏。',
        ),
        disclaimer: '仅基于近 7 天数据。',
      );

      expect(summary.range, ReviewAiSummaryRange.last7Days);
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
        ReviewAiSummaryPatternKind.medication,
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

  group('ReviewAiSummaryCardStatus', () {
    test('has all expected values', () {
      expect(
        ReviewAiSummaryCardStatus.values,
        containsAll([
          ReviewAiSummaryCardStatus.idle,
          ReviewAiSummaryCardStatus.loading,
          ReviewAiSummaryCardStatus.success,
          ReviewAiSummaryCardStatus.error,
          ReviewAiSummaryCardStatus.disabled,
        ]),
      );
    });
  });

  group('ReviewAiSummaryPatternKind', () {
    test('has all expected values', () {
      expect(
        ReviewAiSummaryPatternKind.values,
        containsAll([
          ReviewAiSummaryPatternKind.medication,
          ReviewAiSummaryPatternKind.hydration,
          ReviewAiSummaryPatternKind.sleep,
        ]),
      );
    });
  });
}

ReviewAiSummary _buildSummary() {
  return ReviewAiSummary(
    range: ReviewAiSummaryRange.last7Days,
    startDate: '2026-07-05',
    endDate: '2026-07-12',
    generatedAt: DateTime(2026, 7, 12),
    summary: 'Summary',
    coverage: const ReviewAiSummaryCoverage(
      medication: ReviewAiSummaryCoverageDimension(
        trackedDays: 5,
        totalDays: 7,
      ),
      water: ReviewAiSummaryCoverageDimension(trackedDays: 3, totalDays: 7),
      sleep: ReviewAiSummaryCoverageDimension(trackedDays: 0, totalDays: 7),
    ),
    observedPattern: null,
    lowRiskAction: null,
    disclaimer: 'Disclaimer',
  );
}
