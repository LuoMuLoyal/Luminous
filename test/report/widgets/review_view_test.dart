import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/presentation/widgets/views/review_view.dart';
import 'package:luminous/features/report/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';
import 'review_fixtures.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  Future<void> pumpReviewView(
    WidgetTester tester, {
    required AsyncValue<EventReview?> current,
    EventReview? cached,
    AsyncValue<ReviewEventPage>? history,
    VoidCallback? onStartObservation,
    VoidCallback? onCheckIn,
    VoidCallback? onEndEvent,
    VoidCallback? onRetry,
    bool canAccessProtectedData = true,
    bool isPreview = false,
    ReviewEventStatus? historyStatus,
    ValueChanged<ReviewEventStatus?>? onHistoryStatusChanged,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReviewView(
              currentAsync: current,
              cachedReview: cached,
              historyAsync:
                  history ??
                  const AsyncValue<ReviewEventPage>.data(
                    ReviewEventPage(items: [], total: 0),
                  ),
              canAccessProtectedData: canAccessProtectedData,
              isPreview: isPreview,
              onRetry: onRetry ?? () {},
              onStartObservation: onStartObservation ?? () {},
              onCheckIn: onCheckIn ?? () {},
              onEndEvent: onEndEvent ?? () {},
              onSignIn: () {},
              historyStatus: historyStatus,
              onHistoryStatusChanged: onHistoryStatusChanged,
            ),
          ),
        ),
      ),
    );
  }

  // ── 六种状态 ──────────────────────────────────────────────────────

  testWidgets('loading state renders the skeleton without content', (
    tester,
  ) async {
    await pumpReviewView(
      tester,
      current: const AsyncValue<EventReview?>.loading(),
    );

    await tester.pump();

    expect(find.byType(ReportSkeletonView), findsOneWidget);
    expect(find.byKey(const Key('review-event-header')), findsNothing);
    expect(find.byKey(const Key('review-history-section')), findsNothing);
  });

  testWidgets(
    'active state renders header with check-in and the four sections in order, history below',
    (tester) async {
      var checkInTapped = false;
      await pumpReviewView(
        tester,
        current: AsyncValue<EventReview?>.data(reviewActive()),
        onCheckIn: () => checkInTapped = true,
      );

      await tester.pump();

      expect(find.byKey(const Key('review-event-header')), findsOneWidget);
      expect(find.text('感冒观察'), findsOneWidget);
      // 状态 chip 文案与历史筛选按钮共用「进行中」文案，按 key 锁定头部 chip。
      expect(
        find.descendant(
          of: find.byKey(const Key('review-event-status-chip')),
          matching: find.text(l10n.reportReviewStatusActive),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('review-check-in-action')), findsOneWidget);
      expect(find.byKey(const Key('review-end-event-action')), findsOneWidget);

      final orderKeys = <String>[
        'review-event-header',
        'review-what-happened-section',
        'review-key-changes-section',
        'review-completed-actions-section',
        'review-next-step-section',
        'review-history-section',
      ];
      final positions = <String, double>{
        for (final key in orderKeys)
          key: tester.getTopLeft(find.byKey(Key(key))).dy,
      };
      for (var index = 0; index < orderKeys.length - 1; index += 1) {
        expect(
          positions[orderKeys[index]]!,
          lessThan(positions[orderKeys[index + 1]]!),
          reason: '${orderKeys[index]} 应排在 ${orderKeys[index + 1]} 之前',
        );
      }

      await tester.tap(find.byKey(const Key('review-check-in-action')));
      expect(checkInTapped, isTrue);
      await tester.pumpAndSettle();
    },
  );

  testWidgets('ended state shows the confirmed outcome instead of check-in', (
    tester,
  ) async {
    await pumpReviewView(
      tester,
      current: AsyncValue<EventReview?>.data(reviewEnded()),
    );

    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const Key('review-event-status-chip')),
        matching: find.text(l10n.reportReviewStatusEnded),
      ),
      findsOneWidget,
    );
    // 头部结果 chip 与变化趋势 chip 都可能出现「好转」。
    expect(find.text(l10n.reportReviewOutcomeImproved), findsWidgets);
    expect(find.byKey(const Key('review-check-in-action')), findsNothing);
    expect(find.byKey(const Key('review-end-event-action')), findsNothing);
  });

  testWidgets(
    'partial state shows short missing reasons without red attention states',
    (tester) async {
      await pumpReviewView(
        tester,
        current: AsyncValue<EventReview?>.data(reviewPartial()),
      );

      await tester.pump();

      expect(find.text(l10n.reportReviewReasonNoObservations), findsOneWidget);
      expect(
        find.text(l10n.reportReviewReasonNoCompletedActions),
        findsOneWidget,
      );
      expect(find.text(l10n.reportReviewSectionKeyChanges), findsOneWidget);
      expect(
        find.text(l10n.reportReviewSectionCompletedActions),
        findsOneWidget,
      );
      // 未知维度不影响其他可用 section：whatHappened / nextStep 照常渲染。
      expect(find.text('记录了 5 条症状'), findsOneWidget);
      expect(find.text(l10n.reportReviewNextStepCheckInPrompt), findsOneWidget);
      // 未知段落不显示分数或红色「需关注」状态。
      expect(find.textContaining('需关注'), findsNothing);
      expect(find.byKey(const Key('report-score-hero')), findsNothing);
    },
  );

  testWidgets(
    'history status filter passes the selection through to the assembly layer',
    (tester) async {
      ReviewEventStatus? selected;
      await pumpReviewView(
        tester,
        current: const AsyncValue<EventReview?>.data(null),
        history: const AsyncValue<ReviewEventPage>.data(
          ReviewEventPage(items: [], total: 0),
        ),
        historyStatus: ReviewEventStatus.active,
        onHistoryStatusChanged: (status) => selected = status,
      );

      await tester.pump();

      await tester.tap(find.byKey(const Key('review-history-filter-ended')));
      await tester.pumpAndSettle();
      expect(selected, ReviewEventStatus.ended);
    },
  );

  testWidgets(
    'no-event state offers the start-observation entry and recent history by event',
    (tester) async {
      var startTapped = false;
      await pumpReviewView(
        tester,
        current: const AsyncValue<EventReview?>.data(null),
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
        onStartObservation: () => startTapped = true,
      );

      await tester.pump();

      expect(find.byKey(const Key('review-no-event-card')), findsOneWidget);
      expect(
        find.byKey(const Key('review-start-observation-action')),
        findsOneWidget,
      );
      // 最近事件按事件逐条展示，最近的在最上方。
      expect(
        find.byKey(const Key('review-history-item-evt-2')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('review-history-item-evt-1')),
        findsOneWidget,
      );
      final firstDy = tester
          .getTopLeft(find.byKey(const Key('review-history-item-evt-2')))
          .dy;
      final secondDy = tester
          .getTopLeft(find.byKey(const Key('review-history-item-evt-1')))
          .dy;
      expect(firstDy, lessThan(secondDy));

      await tester.tap(
        find.byKey(const Key('review-start-observation-action')),
      );
      expect(startTapped, isTrue);
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'no-event without any history keeps the lightweight explanation and no weekly report',
    (tester) async {
      await pumpReviewView(
        tester,
        current: const AsyncValue<EventReview?>.data(null),
        history: const AsyncValue<ReviewEventPage>.data(
          ReviewEventPage(items: [], total: 0),
        ),
      );

      await tester.pump();

      expect(find.byKey(const Key('review-no-event-card')), findsOneWidget);
      expect(find.text(l10n.reportReviewNoEventDescription), findsOneWidget);
      expect(find.text(l10n.reportReviewHistoryEmpty), findsOneWidget);
      expect(find.byKey(const Key('report-score-hero')), findsNothing);
      expect(find.byKey(const Key('report-readiness-card')), findsNothing);
    },
  );

  testWidgets(
    'error-with-cache keeps the stale review content with a lightweight banner',
    (tester) async {
      await pumpReviewView(
        tester,
        current: AsyncValue<EventReview?>.error(
          Exception('boom'),
          StackTrace.current,
        ),
        cached: reviewActive(),
      );

      await tester.pump();

      expect(find.byKey(const Key('review-stale-banner')), findsOneWidget);
      expect(find.text(l10n.reportReviewStaleBanner), findsOneWidget);
      expect(find.byKey(const Key('review-event-header')), findsOneWidget);
      expect(find.text('感冒观察'), findsOneWidget);
    },
  );

  testWidgets('error without cache shows the retry state view', (tester) async {
    var retryTapped = false;
    await pumpReviewView(
      tester,
      current: AsyncValue<EventReview?>.error(
        Exception('boom'),
        StackTrace.current,
      ),
      onRetry: () => retryTapped = true,
    );

    await tester.pump();

    expect(find.text(l10n.reportReviewErrorTitle), findsOneWidget);
    expect(find.text(l10n.reportReviewErrorDescription), findsOneWidget);
    expect(find.text(l10n.todayRetryAction), findsOneWidget);

    await tester.tap(find.text(l10n.todayRetryAction));
    expect(retryTapped, isTrue);
    await tester.pumpAndSettle();
  });

  testWidgets(
    'preview state hides the start action behind the sign-in banner',
    (tester) async {
      await pumpReviewView(
        tester,
        current: const AsyncValue<EventReview?>.data(null),
        history: const AsyncValue<ReviewEventPage>.data(
          ReviewEventPage(items: [], total: 0),
        ),
        canAccessProtectedData: false,
        isPreview: true,
      );

      await tester.pump();

      expect(find.byKey(const Key('sign-in-hint-banner')), findsOneWidget);
      expect(find.byKey(const Key('review-no-event-card')), findsOneWidget);
      expect(
        find.byKey(const Key('review-start-observation-action')),
        findsNothing,
      );
    },
  );
}
