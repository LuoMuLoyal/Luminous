import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/presentation/widgets/sections/completed_actions.dart';
import 'package:luminous/features/report/presentation/widgets/sections/key_changes.dart';
import 'package:luminous/features/report/presentation/widgets/sections/next_step.dart';
import 'package:luminous/features/report/presentation/widgets/sections/review_history.dart';
import 'package:luminous/features/report/presentation/widgets/sections/what_happened.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';
import 'review_fixtures.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  Future<void> pumpSection(WidgetTester tester, Widget section) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(body: SingleChildScrollView(child: section)),
      ),
    );
    await tester.pump();
  }

  group('WhatHappenedSection', () {
    testWidgets('renders observed facts from the health_event code', (
      tester,
    ) async {
      await pumpSection(
        tester,
        WhatHappenedSection(section: reviewActive().sections.whatHappened),
      );

      expect(find.text(l10n.reportReviewSectionWhatHappened), findsOneWidget);
      expect(find.text('记录了 5 条症状'), findsOneWidget);
      expect(find.text('确认了 3 次结果'), findsOneWidget);
      expect(find.textContaining('至今'), findsOneWidget);
    });

    testWidgets('unknown state shows the localized reason without a score', (
      tester,
    ) async {
      await pumpSection(
        tester,
        WhatHappenedSection(
          section: reviewUnknownSection(
            ReviewSectionReasonCodes.noObservations,
          ),
        ),
      );

      expect(find.text(l10n.reportReviewSectionWhatHappened), findsOneWidget);
      expect(find.text(l10n.reportReviewReasonNoObservations), findsOneWidget);
      expect(find.textContaining('需关注'), findsNothing);
      expect(find.textContaining('分'), findsNothing);
    });

    testWidgets('unrecognized facts code degrades to the generic reason', (
      tester,
    ) async {
      await pumpSection(
        tester,
        WhatHappenedSection(
          section: reviewFactsSection('some_future_code', {'anything': 1}),
        ),
      );

      expect(find.text(l10n.reportReviewReasonUnknown), findsOneWidget);
    });

    testWidgets('renders the triggering record row after the window row', (
      tester,
    ) async {
      await pumpSection(
        tester,
        WhatHappenedSection(
          section: reviewFactsSection('health_event', {
            'kind': 'symptom',
            'title': '感冒观察',
            'startedAt': '2026-08-01T00:00:00.000Z',
            'endedAt': null,
            'medicineIds': <String>[],
            'symptomRecordCount': 1,
            'checkInCount': 0,
            'reasonRecordTitle': '头晕',
          }),
        ),
      );

      expect(find.text('由记录触发：头晕'), findsOneWidget);
      // 触发记录行位于窗口行之后、症状计数之前。
      final windowDy = tester.getTopLeft(find.textContaining('至今')).dy;
      final reasonDy = tester.getTopLeft(find.text('由记录触发：头晕')).dy;
      final symptomDy = tester
          .getTopLeft(find.text(l10n.reportReviewWhatHappenedSymptomCount(1)))
          .dy;
      expect(reasonDy, greaterThan(windowDy));
      expect(reasonDy, lessThan(symptomDy));
    });

    testWidgets('omits the triggering record row when the argument is absent', (
      tester,
    ) async {
      await pumpSection(
        tester,
        WhatHappenedSection(
          section: reviewFactsSection('health_event', {
            'kind': 'symptom',
            'title': '感冒观察',
            'startedAt': '2026-08-01T00:00:00.000Z',
            'endedAt': null,
            'medicineIds': <String>[],
            'symptomRecordCount': 1,
            'checkInCount': 0,
          }),
        ),
      );

      expect(find.textContaining('由记录触发'), findsNothing);
    });
  });

  group('KeyChangesSection', () {
    testWidgets('renders outcome, water and sleep trend rows', (tester) async {
      await pumpSection(
        tester,
        KeyChangesSection(section: reviewActive().sections.keyChanges),
      );

      expect(find.text(l10n.reportReviewSectionKeyChanges), findsOneWidget);
      expect(find.text(l10n.reportReviewChangeOutcomeTitle), findsOneWidget);
      expect(find.text('从「加重」变为「好转」，共确认 6 次'), findsOneWidget);
      expect(find.text(l10n.reportReviewChangeWaterTitle), findsOneWidget);
      expect(find.text(l10n.reportReviewChangeDirectionUp), findsOneWidget);
      expect(find.text('1200 毫升 → 1800 毫升，观察 8 天'), findsOneWidget);
      expect(find.text(l10n.reportReviewChangeSleepTitle), findsNothing);
    });

    testWidgets('unknown state shows the coverage reason', (tester) async {
      await pumpSection(
        tester,
        KeyChangesSection(
          section: reviewUnknownSection(
            ReviewSectionReasonCodes.insufficientCoverage,
          ),
        ),
      );

      expect(
        find.text(l10n.reportReviewReasonInsufficientCoverage),
        findsOneWidget,
      );
      expect(find.textContaining('需关注'), findsNothing);
      // 覆盖不足时后端不发 observed_changes，客户端不渲染任何趋势行
      // （包括结果变化与单维数值趋势）。
      expect(find.text(l10n.reportReviewChangeOutcomeTitle), findsNothing);
      expect(find.text(l10n.reportReviewChangeWaterTitle), findsNothing);
      expect(find.text(l10n.reportReviewChangeSleepTitle), findsNothing);
    });

    testWidgets('missing direction shows unknown instead of flat', (
      tester,
    ) async {
      await pumpSection(
        tester,
        KeyChangesSection(
          section: reviewFactsSection('observed_changes', {
            'water': {
              'direction': null,
              'firstValue': 1200,
              'lastValue': 1300,
              'firstDate': '2026-08-02',
              'lastDate': '2026-08-03',
              'observedDays': 2,
            },
          }),
        ),
      );

      expect(
        find.text(l10n.reportReviewChangeDirectionUnknown),
        findsOneWidget,
      );
      expect(find.text(l10n.reportReviewChangeDirectionFlat), findsNothing);
    });
  });

  group('CompletedActionsSection', () {
    testWidgets('renders dose slot counts and check-in records', (
      tester,
    ) async {
      await pumpSection(
        tester,
        CompletedActionsSection(
          section: reviewActive().sections.completedActions,
        ),
      );

      expect(
        find.text(l10n.reportReviewSectionCompletedActions),
        findsOneWidget,
      );
      expect(find.text(l10n.reportReviewDoseSectionTitle), findsOneWidget);
      expect(find.text('已确认服药 9 次'), findsOneWidget);
      expect(find.text('跳过 2 次'), findsOneWidget);
      expect(find.text('未确认 1 次'), findsOneWidget);
      // 契约日期经 reviewShortDateLabel 本地化，与 header/history 一致。
      expect(find.text('8月2日 · 加重'), findsOneWidget);
      expect(find.text('8月3日 · 差不多'), findsOneWidget);
    });

    testWidgets('unknown state shows the completed-actions reason', (
      tester,
    ) async {
      await pumpSection(
        tester,
        CompletedActionsSection(
          section: reviewUnknownSection(
            ReviewSectionReasonCodes.noCompletedActions,
          ),
        ),
      );

      expect(
        find.text(l10n.reportReviewReasonNoCompletedActions),
        findsOneWidget,
      );
    });
  });

  group('NextStepSection', () {
    testWidgets('active event without today check-in prompts a check-in', (
      tester,
    ) async {
      await pumpSection(
        tester,
        NextStepSection(section: reviewActive().sections.nextStep),
      );

      expect(find.text(l10n.reportReviewSectionNextStep), findsOneWidget);
      expect(find.text(l10n.reportReviewNextStepCheckInPrompt), findsOneWidget);
    });

    testWidgets('active event with today check-in confirms it', (tester) async {
      await pumpSection(
        tester,
        NextStepSection(
          section: reviewFactsSection('active_check_in', {
            'hasTodayCheckIn': true,
          }),
        ),
      );

      expect(
        find.text(l10n.reportReviewNextStepCheckInDonePrompt),
        findsOneWidget,
      );
    });

    testWidgets('ended event shows the confirmed outcome', (tester) async {
      await pumpSection(
        tester,
        NextStepSection(
          section: reviewFactsSection('event_ended', {'outcome': 'worsened'}),
        ),
      );

      expect(find.text('这段观察已结束，结果：加重'), findsOneWidget);
    });

    testWidgets('renders structured red flags without generated copy', (
      tester,
    ) async {
      await pumpSection(
        tester,
        NextStepSection(
          section: reviewFactsSection('active_check_in', {
            'hasTodayCheckIn': false,
            'redFlags': [
              {
                'rule': 'severeAllergy',
                'medicineName': '阿莫西林',
                'relatedLabel': '青霉素',
              },
              {'rule': 'informationGap', 'medicineName': '布洛芬'},
              {'rule': 'future_rule', 'medicineName': '对乙酰氨基酚'},
            ],
          }),
        ),
      );

      expect(find.text(l10n.reportReviewRedFlagSectionTitle), findsOneWidget);
      expect(find.text('「阿莫西林」可能含有严重过敏成分「青霉素」'), findsOneWidget);
      expect(find.text('「布洛芬」缺少关键用药信息'), findsOneWidget);
      // 契约外规则按通用文案展示，不生成任何泛化建议。
      expect(find.text('「对乙酰氨基酚」存在安全提醒'), findsOneWidget);
    });

    testWidgets('unknown state shows the reason', (tester) async {
      await pumpSection(
        tester,
        NextStepSection(
          section: reviewUnknownSection(
            ReviewSectionReasonCodes.insufficientCoverage,
          ),
        ),
      );

      expect(
        find.text(l10n.reportReviewReasonInsufficientCoverage),
        findsOneWidget,
      );
    });
  });

  group('ReviewHistorySection', () {
    testWidgets('lists events most recent first, by event not by month', (
      tester,
    ) async {
      await pumpSection(
        tester,
        ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.data(
            reviewHistoryPage([
              reviewEventItem(id: 'evt-2', title: '嗓子疼观察'),
              reviewEventItem(
                id: 'evt-1',
                title: '头痛观察',
                outcome: ReviewEventOutcome.worsened,
              ),
            ]),
          ),
        ),
      );

      expect(find.text(l10n.reportReviewHistoryTitle), findsOneWidget);
      expect(find.text('嗓子疼观察'), findsOneWidget);
      expect(find.text('头痛观察'), findsOneWidget);
      final firstDy = tester
          .getTopLeft(find.byKey(const Key('review-history-item-evt-2')))
          .dy;
      final secondDy = tester
          .getTopLeft(find.byKey(const Key('review-history-item-evt-1')))
          .dy;
      expect(firstDy, lessThan(secondDy));
    });

    testWidgets('shows the empty explanation when there are no events', (
      tester,
    ) async {
      await pumpSection(
        tester,
        const ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.data(
            ReviewEventPage(items: [], total: 0),
          ),
        ),
      );

      expect(find.text(l10n.reportReviewHistoryEmpty), findsOneWidget);
    });

    testWidgets('shows a progress placeholder while history loads', (
      tester,
    ) async {
      await pumpSection(
        tester,
        const ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.loading(),
        ),
      );

      expect(find.byType(FProgress), findsOneWidget);
    });

    testWidgets('shows a lightweight failure line with an inline retry', (
      tester,
    ) async {
      var retryTapped = false;
      await pumpSection(
        tester,
        ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.error(
            Exception('boom'),
            StackTrace.current,
          ),
          onRetry: () => retryTapped = true,
        ),
      );

      expect(find.text(l10n.reportReviewHistoryLoadFailed), findsOneWidget);
      final retryButton = find.byKey(const Key('review-history-retry'));
      expect(retryButton, findsOneWidget);
      await tester.tap(retryButton);
      expect(retryTapped, isTrue);
      await tester.pumpAndSettle();
    });

    testWidgets('renders the status filter with all selected by default', (
      tester,
    ) async {
      await pumpSection(
        tester,
        const ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.data(
            ReviewEventPage(items: [], total: 0),
          ),
        ),
      );

      expect(find.text(l10n.reportReviewHistoryFilterAll), findsOneWidget);
      expect(find.text(l10n.reportReviewStatusActive), findsOneWidget);
      expect(find.text(l10n.reportReviewStatusEnded), findsOneWidget);
      // 默认选中「全部」：all 按钮 primary，其余 outline。
      expect(_filterButtonVariant(tester, 'all'), FButtonVariant.primary);
      expect(_filterButtonVariant(tester, 'active'), FButtonVariant.outline);
      expect(_filterButtonVariant(tester, 'ended'), FButtonVariant.outline);
    });

    testWidgets('marks the selected filter as primary', (tester) async {
      await pumpSection(
        tester,
        const ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.data(
            ReviewEventPage(items: [], total: 0),
          ),
          selectedStatus: ReviewEventStatus.ended,
        ),
      );

      expect(_filterButtonVariant(tester, 'ended'), FButtonVariant.primary);
      expect(_filterButtonVariant(tester, 'all'), FButtonVariant.outline);
      expect(_filterButtonVariant(tester, 'active'), FButtonVariant.outline);
    });

    testWidgets('tapping a filter emits the selected status', (tester) async {
      ReviewEventStatus? selected;
      await pumpSection(
        tester,
        ReviewHistorySection(
          history: const AsyncValue<ReviewEventPage>.data(
            ReviewEventPage(items: [], total: 0),
          ),
          selectedStatus: null,
          onStatusChanged: (status) => selected = status,
        ),
      );

      await tester.tap(find.byKey(const Key('review-history-filter-active')));
      await tester.pumpAndSettle();
      expect(selected, ReviewEventStatus.active);

      await tester.tap(find.byKey(const Key('review-history-filter-ended')));
      await tester.pumpAndSettle();
      expect(selected, ReviewEventStatus.ended);
    });

    testWidgets('tapping a history row emits the event through onEventTap', (
      tester,
    ) async {
      ReviewEvent? tapped;
      await pumpSection(
        tester,
        ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.data(
            reviewHistoryPage([reviewEventItem(id: 'evt-1', title: '头痛观察')]),
          ),
          onEventTap: (event) => tapped = event,
        ),
      );

      await tester.tap(find.byKey(const Key('review-history-item-evt-1')));
      await tester.pumpAndSettle();
      expect(tapped?.id, 'evt-1');
    });

    testWidgets('history rows stay read-only without onEventTap', (
      tester,
    ) async {
      await pumpSection(
        tester,
        ReviewHistorySection(
          history: AsyncValue<ReviewEventPage>.data(
            reviewHistoryPage([reviewEventItem(id: 'evt-1', title: '头痛观察')]),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('review-history-item-evt-1')));
      await tester.pumpAndSettle();
      // 不可点时整行不应被包成 FTappable，也不应抛错或触发任何动作。
      expect(find.byType(FTappable), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

/// 读取历史筛选按钮当前使用的 [FButtonVariant]。
FButtonVariant _filterButtonVariant(WidgetTester tester, String key) {
  final button = tester.widget<FButton>(
    find.byKey(Key('review-history-filter-$key')),
  );
  return button.variant;
}
