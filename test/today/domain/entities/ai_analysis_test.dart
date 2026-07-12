import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/today/domain/entities/ai_analysis.dart';

void main() {
  group('TodayAiAnalysisCardState', () {
    test('idle constructor sets idle status', () {
      const state = TodayAiAnalysisCardState.idle();
      expect(state.status, TodayAiAnalysisCardStatus.idle);
      expect(state.analysis, isNull);
      expect(state.streamingSummary, isNull);
      expect(state.errorMessage, isNull);
    });

    test('loading constructor sets loading status', () {
      const state = TodayAiAnalysisCardState.loading();
      expect(state.status, TodayAiAnalysisCardStatus.loading);
      expect(state.analysis, isNull);
      expect(state.streamingSummary, isNull);
    });

    test('loading constructor preserves previousAnalysis', () {
      final analysis = TodayAiAnalysis(
        date: '2026-07-12',
        generatedAt: DateTime(2026, 7, 12),
        summary: 'Summary',
        bullets: const [],
        actionLabel: 'Action',
        confidenceNote: 'High',
      );
      final state = TodayAiAnalysisCardState.loading(
        previousAnalysis: analysis,
      );
      expect(state.status, TodayAiAnalysisCardStatus.loading);
      expect(state.analysis, same(analysis));
    });

    test('loading constructor sets streamingSummary', () {
      const state = TodayAiAnalysisCardState.loading(
        streamingSummary: 'Partial...',
      );
      expect(state.streamingSummary, 'Partial...');
    });

    test('success constructor sets success status and analysis', () {
      final analysis = TodayAiAnalysis(
        date: '2026-07-12',
        generatedAt: DateTime(2026, 7, 12),
        summary: 'Summary',
        bullets: const [],
        actionLabel: 'Action',
        confidenceNote: 'High',
      );
      final state = TodayAiAnalysisCardState.success(analysis);
      expect(state.status, TodayAiAnalysisCardStatus.success);
      expect(state.analysis, same(analysis));
    });

    test('error constructor sets error status and message', () {
      const state = TodayAiAnalysisCardState.error(message: 'Network failed');
      expect(state.status, TodayAiAnalysisCardStatus.error);
      expect(state.errorMessage, 'Network failed');
      expect(state.analysis, isNull);
    });

    test('error constructor preserves previousAnalysis', () {
      final analysis = TodayAiAnalysis(
        date: '2026-07-12',
        generatedAt: DateTime(2026, 7, 12),
        summary: 'Summary',
        bullets: const [],
        actionLabel: 'Action',
        confidenceNote: 'High',
      );
      final state = TodayAiAnalysisCardState.error(
        message: 'Failed',
        previousAnalysis: analysis,
      );
      expect(state.analysis, same(analysis));
    });

    test('disabled constructor sets disabled status', () {
      const state = TodayAiAnalysisCardState.disabled();
      expect(state.status, TodayAiAnalysisCardStatus.disabled);
      expect(state.analysis, isNull);
    });
  });

  group('TodayAiAnalysisCardState computed getters', () {
    test('isLoading is true for loading status', () {
      const state = TodayAiAnalysisCardState.loading();
      expect(state.isLoading, isTrue);
    });

    test('isLoading is false for idle status', () {
      const state = TodayAiAnalysisCardState.idle();
      expect(state.isLoading, isFalse);
    });

    test('isDisabled is true for disabled status', () {
      const state = TodayAiAnalysisCardState.disabled();
      expect(state.isDisabled, isTrue);
    });

    test('isDisabled is false for idle status', () {
      const state = TodayAiAnalysisCardState.idle();
      expect(state.isDisabled, isFalse);
    });

    test('hasAnalysis is true when analysis is non-null', () {
      final analysis = TodayAiAnalysis(
        date: '2026-07-12',
        generatedAt: DateTime(2026, 7, 12),
        summary: 'Summary',
        bullets: const [],
        actionLabel: 'Action',
        confidenceNote: 'High',
      );
      final state = TodayAiAnalysisCardState.success(analysis);
      expect(state.hasAnalysis, isTrue);
    });

    test('hasAnalysis is false when analysis is null', () {
      const state = TodayAiAnalysisCardState.idle();
      expect(state.hasAnalysis, isFalse);
    });
  });

  group('TodayAiAnalysis', () {
    test('stores all fields correctly', () {
      final bullets = [
        const TodayAiAnalysisBullet(
          kind: TodayAiAnalysisBulletKind.medication,
          text: 'Take meds',
        ),
        const TodayAiAnalysisBullet(
          kind: TodayAiAnalysisBulletKind.hydration,
          text: 'Drink water',
        ),
      ];
      final analysis = TodayAiAnalysis(
        date: '2026-07-12',
        generatedAt: DateTime(2026, 7, 12, 10, 30),
        summary: 'Daily summary',
        bullets: bullets,
        actionLabel: 'View details',
        confidenceNote: 'High confidence',
      );

      expect(analysis.date, '2026-07-12');
      expect(analysis.generatedAt, DateTime(2026, 7, 12, 10, 30));
      expect(analysis.summary, 'Daily summary');
      expect(analysis.bullets.length, 2);
      expect(analysis.bullets[0].kind, TodayAiAnalysisBulletKind.medication);
      expect(analysis.bullets[0].text, 'Take meds');
      expect(analysis.bullets[1].kind, TodayAiAnalysisBulletKind.hydration);
      expect(analysis.actionLabel, 'View details');
      expect(analysis.confidenceNote, 'High confidence');
    });
  });

  group('TodayAiAnalysisCardStatus', () {
    test('has all expected values', () {
      expect(
        TodayAiAnalysisCardStatus.values,
        containsAll([
          TodayAiAnalysisCardStatus.idle,
          TodayAiAnalysisCardStatus.loading,
          TodayAiAnalysisCardStatus.success,
          TodayAiAnalysisCardStatus.error,
          TodayAiAnalysisCardStatus.disabled,
        ]),
      );
    });
  });

  group('TodayAiAnalysisBulletKind', () {
    test('has all expected values', () {
      expect(
        TodayAiAnalysisBulletKind.values,
        containsAll([
          TodayAiAnalysisBulletKind.medication,
          TodayAiAnalysisBulletKind.hydration,
          TodayAiAnalysisBulletKind.sleep,
          TodayAiAnalysisBulletKind.general,
        ]),
      );
    });
  });
}
