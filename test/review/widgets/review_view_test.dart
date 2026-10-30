import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/auth_session_adapter.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/presentation/providers/dashboard.dart';
import 'package:luminous/features/review/presentation/providers/review.dart';
import 'package:luminous/features/review/presentation/widgets/views/review_view.dart';
import 'package:luminous/features/review/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/composition.dart';
import '../../helpers/kv_test_store.dart';
import '../../helpers/test_forui_app.dart';
import 'review_fixtures.dart';


/// Session stand-in: the page reads auth only to decide preview vs signed-in.
class _StubSessionNotifier extends AuthSessionNotifier {
  _StubSessionNotifier({required this.signedIn, required this.preview});

  final bool signedIn;
  final bool preview;

  @override
  AuthSessionState build() => AuthSessionState(
    isAuthenticated: signedIn && !preview,
    isLoading: false,
    isTimeout: false,
  );
}

/// Isolates the dashboard cache per test: the real notifier is global, so a
/// value written by one case would leak into the next.
class _StubLastDashboard extends ReviewLastDashboardNotifier {
  _StubLastDashboard(this._value);

  final ReviewDashboard? _value;

  @override
  ReviewDashboard? build() => _value;
}

/// Seeds the "last known review" cache so stale-content branches are
/// exercisable without depending on a previous fetch having happened.
class _StubLastCurrent extends ReviewLastCurrentNotifier {
  _StubLastCurrent(this._value);

  final EventReview? _value;

  @override
  EventReview? build() => _value;
}
/// Minimal router for the review tests: every destination a component can
/// navigate to resolves to a placeholder page, so `context.push` / `go` never
/// throws while the assertion still runs against the review page itself.
GoRouter _buildReviewTestRouter({String initialLocation = '/'}) {
  Widget placeholder(BuildContext context, GoRouterState state) =>
      Scaffold(body: Text('placeholder:${state.uri.path}'));

  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const Scaffold(body: SingleChildScrollView(child: ReviewView())),
        routes: [
          GoRoute(path: 'record/create', builder: placeholder),
          GoRoute(path: 'review/:eventId', builder: placeholder),
        ],
      ),
      GoRoute(path: '/record', builder: placeholder),
      GoRoute(path: '/record/create', builder: placeholder),
      GoRoute(path: '/assistant', builder: placeholder),
    ],
  );
}
void main() {
  setUp(() {
    KvTestStore.install();
  });

  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  Future<void> pumpReviewView(
    WidgetTester tester, {
    required AsyncValue<EventReview?> current,
    EventReview? cached,
    AsyncValue<ReviewEventPage>? history,
    VoidCallback? onGoRecord,
    VoidCallback? onGoTodayCheckIn,
    VoidCallback? onRetry,
    bool canAccessProtectedData = true,
    bool isPreview = false,
    ReviewEventStatus? historyStatus,
    ValueChanged<ReviewEventStatus?>? onHistoryStatusChanged,
    bool isColdStart = false,
    int coldObserved = 0,
    ReviewDashboard? cachedDashboard,
    int coldExpected = 0,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    // 组件自取数据后，页面不再接受数据参数：状态通过 provider 注入。
    // loading / error 用 async 结果模拟，data 走 fake repository。
    late final ProviderContainer container;
    container = ProviderContainer(
      overrides: [
        ...compositionTestOverrides(),
        authSessionProvider.overrideWith(
          () => _StubSessionNotifier(
            signedIn: canAccessProtectedData,
            preview: isPreview,
          ),
        ),
        reviewCurrentProvider.overrideWith(
          (ref) => current.when(
            data: (value) async => value,
            loading: () => Completer<EventReview?>().future,
            error: (error, stack) async => throw error,
          ),
        ),
        reviewLastCurrentProvider.overrideWith(() => _StubLastCurrent(cached)),
        // 每个用例用独立的看板缓存：真实 provider 是全局 notifier，上一个用例
        // 写入的值会漏到下一个用例，让「首帧 loading」的判断失真。
        reviewLastDashboardProvider.overrideWith(
          () => _StubLastDashboard(cachedDashboard),
        ),
        reviewHistoryProvider.overrideWith(
          (ref) async =>
              history?.value ??
              const ReviewEventPage(items: [], total: 0),
        ),
        reviewDashboardProvider.overrideWith(
          (ref, query) async => isColdStart
              ? ReviewDashboard.signedOut().copyWith(range: query.range)
              : ReviewDashboard.signedOut().copyWith(range: query.range),
        ),
      ],
    );
    addTearDown(container.dispose);

    // 组件自取导航（去今日 check-in / 去 record / 历史行 push 详情），所以测试
    // 容器必须带 router。纯渲染的用例多包一层也无害，统一走 router 版本。
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestForuiRouterApp(routerConfig: _buildReviewTestRouter()),
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

    expect(find.byType(ReviewSkeletonView), findsOneWidget, reason: 'skeleton probe');
    expect(find.byKey(const Key('review-event-header')), findsNothing);
    expect(find.byKey(const Key('review-history-section')), findsNothing);
  });

  testWidgets(
    'active state renders header with go-today check-in and the four sections in order, history below',
    (tester) async {
      await pumpReviewView(
        tester,
        current: AsyncValue<EventReview?>.data(reviewActive()),
      );

      await tester.pump();

      expect(find.byKey(const Key('review-event-header')), findsOneWidget);
      expect(find.text('感冒观察'), findsOneWidget);
      // 状态 chip 文案与历史筛选按钮共用「进行中」文案，按 key 锁定头部 chip。
      expect(
        find.descendant(
          of: find.byKey(const Key('review-event-status-chip')),
          matching: find.text(l10n.reviewReviewStatusActive),
        ),
        findsOneWidget,
      );
      // 今日未确认：渲染去今日打卡 浅链接（旧的 check-in/end 按钮已移除）。
      expect(find.byKey(const Key('review-go-today-check-in')), findsOneWidget);

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

      // 「去今日 check-in」的跳转已收进组件内部（组件自取数据后不再接受
      // 回调），测试只断言入口可见并可点击；导航目标由路由层单测覆盖。
      await tester.tap(find.byKey(const Key('review-go-today-check-in')));
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
        matching: find.text(l10n.reviewReviewStatusEnded),
      ),
      findsOneWidget,
    );
    // 头部结果 chip 与变化趋势 chip 都可能出现「好转」。
    expect(find.text(l10n.reviewReviewOutcomeImproved), findsWidgets);
    // 无任何动作：ended 头部不再渲染去 check-in 入口。
    expect(find.byKey(const Key('review-go-today-check-in')), findsNothing);
  });

  testWidgets(
    'partial state shows short missing reasons without red attention states',
    (tester) async {
      await pumpReviewView(
        tester,
        current: AsyncValue<EventReview?>.data(reviewPartial()),
      );

      await tester.pump();

      expect(find.text(l10n.reviewReviewReasonNoObservations), findsOneWidget);
      expect(
        find.text(l10n.reviewReviewReasonNoCompletedActions),
        findsOneWidget,
      );
      expect(find.text(l10n.reviewReviewSectionKeyChanges), findsOneWidget);
      expect(
        find.text(l10n.reviewReviewSectionCompletedActions),
        findsOneWidget,
      );
      // 未知维度不影响其他可用 section：whatHappened / nextStep 照常渲染。
      expect(find.text('记录了 5 条症状'), findsOneWidget);
      expect(find.text(l10n.reviewReviewNextStepCheckInPrompt), findsOneWidget);
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

      await tester.ensureVisible(
        find.byKey(const Key('review-history-filter-ended')),
      );
      await tester.tap(find.byKey(const Key('review-history-filter-ended')));
      await tester.pumpAndSettle();
      expect(selected, ReviewEventStatus.ended);
    },
  );

  testWidgets(
    'cold-start no-event state shows the record guide and recent history by event',
    (tester) async {
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
        isColdStart: true,
      );

      await tester.pump();

      expect(find.byKey(const Key('review-record-guide-card')), findsOneWidget);
      expect(find.text(l10n.reviewRecordGuideTitle), findsOneWidget);
      expect(
        find.text(l10n.reviewRecordGuideDescription(3, 7)),
        findsOneWidget,
      );
      expect(find.byKey(const Key('health-event-start-action')), findsNothing);
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

      await tester.tap(find.byKey(const Key('review-record-guide-action')));
      // 「去 record」由组件内部导航，测试只断言入口可点。
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
      expect(find.text(l10n.reviewReviewNoEventDescription), findsOneWidget);
      expect(find.text(l10n.reviewReviewHistoryEmpty), findsOneWidget);
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
      expect(find.text(l10n.reviewReviewStaleBanner), findsOneWidget);
      expect(find.byKey(const Key('review-event-header')), findsOneWidget);
      expect(find.text('感冒观察'), findsOneWidget);
    },
  );

  testWidgets('error without cache shows the retry state view', (tester) async {
    await pumpReviewView(
      tester,
      current: AsyncValue<EventReview?>.error(
        Exception('boom'),
        StackTrace.current,
      ),
    );

    await tester.pump();

    expect(find.text(l10n.reviewReviewErrorTitle), findsOneWidget);
    expect(find.text(l10n.reviewReviewErrorDescription), findsOneWidget);
    expect(find.text(l10n.todayRetryAction), findsOneWidget);

    // 重试动作由组件内部 invalidate provider，不再经页面回调。
    await tester.tap(find.text(l10n.todayRetryAction));
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
      expect(find.byKey(const Key('review-record-guide-card')), findsNothing);
    },
  );
}
