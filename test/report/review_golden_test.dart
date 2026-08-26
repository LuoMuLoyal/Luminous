import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/presentation/widgets/views/review_view.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_forui_app.dart';
import 'widgets/review_fixtures.dart';

/// Review 四状态（active / ended / partial / no-event）的 zh/en、dark、
/// 大字体矩阵不溢出校验。
void main() {
  Future<void> pumpReviewView(
    WidgetTester tester, {
    required AsyncValue<EventReview?> current,
    AsyncValue<ReviewEventPage>? history,
    ThemeMode themeMode = ThemeMode.light,
    Locale locale = const Locale('zh'),
    double textScale = 1.0,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final body = ReviewView(
      currentAsync: current,
      cachedReview: null,
      historyAsync:
          history ??
          const AsyncValue<ReviewEventPage>.data(
            ReviewEventPage(items: [], total: 0),
          ),
      canAccessProtectedData: true,
      isPreview: false,
      onRetry: () {},
      onStartObservation: () {},
      onCheckIn: () {},
      onEndEvent: () {},
      onSignIn: () {},
    );

    await tester.pumpWidget(
      TestForuiApp(
        themeMode: themeMode,
        locale: locale,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(body: SingleChildScrollView(child: body)),
        ),
      ),
    );
    await tester.pump();
  }

  /// 旧 dashboard 痕迹不得出现在 Review 首屏：无综合分数、无整页 readiness
  /// 锁、无默认导出矩阵（Task 9 校验点）。
  void expectNoLegacyDashboardTraces(WidgetTester tester) {
    expect(find.byKey(const Key('report-score-hero')), findsNothing);
    expect(find.byKey(const Key('report-readiness-card')), findsNothing);
    expect(find.byKey(const Key('report-export-section')), findsNothing);
  }

  const historyWithEnded = AsyncValue<ReviewEventPage>.data(
    ReviewEventPage(
      items: [
        ReviewEvent(
          id: 'evt-2',
          kind: ReviewEventKind.symptom,
          title: '嗓子疼观察',
          status: ReviewEventStatus.ended,
          startedAt: '2026-07-20T00:00:00.000Z',
          endedAt: '2026-07-28T00:00:00.000Z',
          outcome: ReviewEventOutcome.improved,
          currentMedicineIds: [],
        ),
        ReviewEvent(
          id: 'evt-1',
          kind: ReviewEventKind.other,
          title: '头痛观察',
          status: ReviewEventStatus.ended,
          startedAt: '2026-06-01T00:00:00.000Z',
          endedAt: '2026-06-10T00:00:00.000Z',
          outcome: ReviewEventOutcome.worsened,
          currentMedicineIds: ['med-1'],
        ),
      ],
      total: 2,
    ),
  );

  // ── 矩阵：zh / en / dark / 大字体 各跑一遍四状态（widget 断言） ──

  // zh / light 基线断言（替代原 golden 测试）
  testWidgets('zh: active 状态断言', (tester) async {
    await pumpReviewView(
      tester,
      current: AsyncValue<EventReview?>.data(reviewActive()),
      history: historyWithEnded,
    );

    expect(find.byKey(const Key('review-event-header')), findsOneWidget);
    expect(find.byKey(const Key('review-check-in-action')), findsOneWidget);
    expectNoLegacyDashboardTraces(tester);
  });

  testWidgets('zh: ended 状态断言', (tester) async {
    await pumpReviewView(
      tester,
      current: AsyncValue<EventReview?>.data(reviewEnded()),
      history: historyWithEnded,
    );

    expect(find.byKey(const Key('review-event-header')), findsOneWidget);
    expect(find.byKey(const Key('review-check-in-action')), findsNothing);
    expectNoLegacyDashboardTraces(tester);
  });

  testWidgets('zh: partial 状态断言（unknown 段落）', (tester) async {
    await pumpReviewView(
      tester,
      current: AsyncValue<EventReview?>.data(reviewPartial()),
      history: historyWithEnded,
    );

    expect(find.byKey(const Key('review-event-header')), findsOneWidget);
    // 未知段落不锁页：可用段落照常渲染。
    expect(
      find.byKey(const Key('review-what-happened-section')),
      findsOneWidget,
    );
    expectNoLegacyDashboardTraces(tester);
  });

  testWidgets('zh: no-event 状态断言（开始观察 + 最近历史）', (tester) async {
    await pumpReviewView(
      tester,
      current: const AsyncValue<EventReview?>.data(null),
      history: historyWithEnded,
    );

    expect(find.byKey(const Key('review-no-event-card')), findsOneWidget);
    expect(
      find.byKey(const Key('review-start-observation-action')),
      findsOneWidget,
    );
    expectNoLegacyDashboardTraces(tester);
  });

  // ── 矩阵：en / dark / 大字体 各跑一遍四状态（widget 断言） ──

  final states = <String, AsyncValue<EventReview?>>{
    'active': AsyncValue<EventReview?>.data(reviewActive()),
    'ended': AsyncValue<EventReview?>.data(reviewEnded()),
    'partial': AsyncValue<EventReview?>.data(reviewPartial()),
    'no_event': const AsyncValue<EventReview?>.data(null),
  };

  for (final entry in states.entries) {
    final stateName = entry.key;
    final current = entry.value;

    testWidgets('en: $stateName 渲染且不溢出', (tester) async {
      await pumpReviewView(
        tester,
        current: current,
        history: historyWithEnded,
        locale: const Locale('en'),
      );

      expect(tester.takeException(), isNull);
      expectNoLegacyDashboardTraces(tester);
    });

    testWidgets('dark: $stateName 渲染且不溢出', (tester) async {
      await pumpReviewView(
        tester,
        current: current,
        history: historyWithEnded,
        themeMode: ThemeMode.dark,
      );

      expect(tester.takeException(), isNull);
      expectNoLegacyDashboardTraces(tester);
    });

    testWidgets('大字体(2x): $stateName 渲染且不溢出', (tester) async {
      await pumpReviewView(
        tester,
        current: current,
        history: historyWithEnded,
        textScale: 2.0,
      );

      expect(tester.takeException(), isNull);
      expectNoLegacyDashboardTraces(tester);
    });
  }

  testWidgets('大字体 + 超长标题 + unknown reason 不溢出', (tester) async {
    const longTitle = '这是一段特别长的健康观察标题，用于验证大字体下长文本换行不会导致横向溢出，超过二十四个字符';
    final longPartial = reviewPartial().copyWith(
      event: const ReviewEvent(
        id: 'evt-long',
        kind: ReviewEventKind.other,
        title: longTitle,
        status: ReviewEventStatus.active,
        startedAt: '2026-08-01T00:00:00.000Z',
        endedAt: null,
        outcome: null,
        currentMedicineIds: ['med-1', 'med-2'],
      ),
    );

    await pumpReviewView(
      tester,
      current: AsyncValue<EventReview?>.data(longPartial),
      history: historyWithEnded,
      textScale: 2.0,
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('review-event-header')), findsOneWidget);
    expect(find.text(longTitle), findsOneWidget);
    expectNoLegacyDashboardTraces(tester);
  });
}
