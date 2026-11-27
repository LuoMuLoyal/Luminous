import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/today/domain/entities/briefing.dart';

void main() {
  group('TodayBriefingCardState', () {
    test('idle constructor sets idle status', () {
      const state = TodayBriefingCardState.idle();
      expect(state.status, TodayBriefingCardStatus.idle);
      expect(state.analysis, isNull);
      expect(state.streamingSummary, isNull);
      expect(state.errorMessage, isNull);
    });

    test('loading constructor sets loading status', () {
      const state = TodayBriefingCardState.loading();
      expect(state.status, TodayBriefingCardStatus.loading);
      expect(state.analysis, isNull);
      expect(state.streamingSummary, isNull);
    });

    test('loading constructor preserves previousAnalysis', () {
      final analysis = TodayBriefing(
        date: '2026-07-12',
        generatedAt: DateTime(2026, 7, 12),
        summary: 'Summary',
        bullets: const [],
        actionLabel: 'Action',
        confidenceNote: 'High',
      );
      final state = TodayBriefingCardState.loading(previousAnalysis: analysis);
      expect(state.status, TodayBriefingCardStatus.loading);
      expect(state.analysis, same(analysis));
    });

    test('loading constructor sets streamingSummary', () {
      const state = TodayBriefingCardState.loading(
        streamingSummary: 'Partial...',
      );
      expect(state.streamingSummary, 'Partial...');
    });

    test('success constructor sets success status and analysis', () {
      final analysis = TodayBriefing(
        date: '2026-07-12',
        generatedAt: DateTime(2026, 7, 12),
        summary: 'Summary',
        bullets: const [],
        actionLabel: 'Action',
        confidenceNote: 'High',
      );
      final state = TodayBriefingCardState.success(analysis);
      expect(state.status, TodayBriefingCardStatus.success);
      expect(state.analysis, same(analysis));
    });

    test('error constructor sets error status and message', () {
      const state = TodayBriefingCardState.error(message: 'Network failed');
      expect(state.status, TodayBriefingCardStatus.error);
      expect(state.errorMessage, 'Network failed');
      expect(state.analysis, isNull);
    });

    test('error constructor preserves previousAnalysis', () {
      final analysis = TodayBriefing(
        date: '2026-07-12',
        generatedAt: DateTime(2026, 7, 12),
        summary: 'Summary',
        bullets: const [],
        actionLabel: 'Action',
        confidenceNote: 'High',
      );
      final state = TodayBriefingCardState.error(
        message: 'Failed',
        previousAnalysis: analysis,
      );
      expect(state.analysis, same(analysis));
    });

    test('disabled constructor sets disabled status', () {
      const state = TodayBriefingCardState.disabled();
      expect(state.status, TodayBriefingCardStatus.disabled);
      expect(state.analysis, isNull);
    });
  });

  group('TodayBriefingCardState computed getters', () {
    test('isLoading is true for loading status', () {
      const state = TodayBriefingCardState.loading();
      expect(state.isLoading, isTrue);
    });

    test('isLoading is false for idle status', () {
      const state = TodayBriefingCardState.idle();
      expect(state.isLoading, isFalse);
    });

    test('isDisabled is true for disabled status', () {
      const state = TodayBriefingCardState.disabled();
      expect(state.isDisabled, isTrue);
    });

    test('isDisabled is false for idle status', () {
      const state = TodayBriefingCardState.idle();
      expect(state.isDisabled, isFalse);
    });

    test('hasAnalysis is true when analysis is non-null', () {
      final analysis = TodayBriefing(
        date: '2026-07-12',
        generatedAt: DateTime(2026, 7, 12),
        summary: 'Summary',
        bullets: const [],
        actionLabel: 'Action',
        confidenceNote: 'High',
      );
      final state = TodayBriefingCardState.success(analysis);
      expect(state.hasAnalysis, isTrue);
    });

    test('hasAnalysis is false when analysis is null', () {
      const state = TodayBriefingCardState.idle();
      expect(state.hasAnalysis, isFalse);
    });
  });

  group('TodayBriefing', () {
    test('stores all fields correctly', () {
      final bullets = [
        const TodayBriefingBullet(
          kind: TodayBriefingBulletKind.medication,
          text: 'Take meds',
        ),
        const TodayBriefingBullet(
          kind: TodayBriefingBulletKind.hydration,
          text: 'Drink water',
        ),
      ];
      final analysis = TodayBriefing(
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
      expect(analysis.bullets[0].kind, TodayBriefingBulletKind.medication);
      expect(analysis.bullets[0].text, 'Take meds');
      expect(analysis.bullets[1].kind, TodayBriefingBulletKind.hydration);
      expect(analysis.actionLabel, 'View details');
      expect(analysis.confidenceNote, 'High confidence');
    });
  });

  group('TodayBriefingCardStatus', () {
    test('has all expected values', () {
      expect(
        TodayBriefingCardStatus.values,
        containsAll([
          TodayBriefingCardStatus.idle,
          TodayBriefingCardStatus.loading,
          TodayBriefingCardStatus.success,
          TodayBriefingCardStatus.error,
          TodayBriefingCardStatus.disabled,
        ]),
      );
    });
  });

  group('TodayBriefingBulletKind', () {
    test('has all expected values', () {
      expect(
        TodayBriefingBulletKind.values,
        containsAll([
          TodayBriefingBulletKind.medication,
          TodayBriefingBulletKind.hydration,
          TodayBriefingBulletKind.sleep,
          TodayBriefingBulletKind.general,
        ]),
      );
    });
  });
}
