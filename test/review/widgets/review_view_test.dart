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


/// Session stand-in.
///
/// 页面用 `authSessionProvider.isConfirmedSignedOut`（= `!isLoading &&
/// !isAuthenticated`）区分「已登录」与「未登录预览」，所以两者互斥：
/// 预览态就是「加载完成 + 未认证」，没有第三种签名态。旧版本把
/// `signedIn && !preview` 塞进 `isAuthenticated`，`preview: true` 时会造出
/// 「未认证」的中性态，横幅用例因此一直落在另一个分支上。
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

  /// 挂载 `ReviewView`，数据态全部经 provider 注入。
  ///
  /// 早期这里还接收 `onGoRecord` / `onRetry` / `onHistoryStatusChanged` 等
  /// 页面回调；组件化之后所有动作都由组件内部完成，这些参数从未被读取。
  /// 留着它们会让「筛选回调被调用」这类断言以 `selected == null` 的方式
  /// 静默通过前半段——断言的对象其实并不存在。
  ///
  /// 已登录、未登录预览用 [canAccessProtectedData] / [isPreview] 选：两者
  /// 都走 `AuthSessionState.isConfirmedSignedOut`，传一个「已登出但不是
  /// 预览」的会话只会让页面进入无数据的签名态分支，测不到预览横幅。
  Future<void> pumpReviewView(
    WidgetTester tester, {
    required AsyncValue<EventReview?> current,
    EventReview? cached,
    AsyncValue<ReviewEventPage>? history,
    bool canAccessProtectedData = true,
    bool isPreview = false,
    ReviewEventStatus? historyStatus,
    bool isColdStart = false,
    ReviewDashboard? cachedDashboard,
    ValueChanged<ProviderContainer>? onContainer,
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
          (ref) async {
            // 显式按 AsyncValue 的运行时类型分派，而不是 `when(...)`：
            // riverpod 3 会为失败安排退避重试，重试期间的 `isLoading` 为真，
            // `AsyncValue.when` 的 `skipLoadingOnReload`/判定顺序会把
            // `AsyncError` 当成 loading，错误态用例就此永远看不到错误视图。
            final value = current;
            if (value.hasError) throw value.error!;
            if (value.hasValue) return value.value;
            return Completer<EventReview?>().future;
          },
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
          // 无指标的 signedOut 看板 = 数据过稀 → 记录引导卡 / 轻量解释卡分支。
          (ref, query) async =>
              ReviewDashboard.signedOut().copyWith(range: query.range),
        ),
      ],
    );
    addTearDown(container.dispose);
    onContainer?.call(container);

    // 筛选状态在组件化之后归 provider 所有（不再是页面回调参数）：用例
    // 需要预置选中项时，直接写 provider。
    if (historyStatus != null) {
      container
          .read(reviewHistoryStatusProvider.notifier)
          .select(historyStatus);
    }

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
    'history status filter routes the tap into the status notifier',
    (tester) async {
      // 组件化之后筛选不再经页面回调，点击直接写
      // `reviewHistoryStatusProvider`；断言的数据源随之换成 provider。
      // `reviewHistoryProvider` 在本 helper 里是固定 override，所以这里只
      // 验证「点击 → 状态写入」这一段装配，重取由 page_test 覆盖。
      late final ProviderContainer container;
      await pumpReviewView(
        tester,
        current: const AsyncValue<EventReview?>.data(null),
        history: const AsyncValue<ReviewEventPage>.data(
          ReviewEventPage(items: [], total: 0),
        ),
        historyStatus: ReviewEventStatus.active,
        onContainer: (value) => container = value,
      );

      await tester.pump();
      expect(container.read(reviewHistoryStatusProvider), isNotNull);

      await tester.ensureVisible(
        find.byKey(const Key('review-history-filter-ended')),
      );
      await tester.tap(find.byKey(const Key('review-history-filter-ended')));
      await tester.pumpAndSettle();
      expect(container.read(reviewHistoryStatusProvider), ReviewEventStatus.ended);
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
      // 引导卡顶部的「本周已记录 X/N 天」来自 dashboard 的
      // observedMetric，组件化之后由组件自己从看板里算（不再由页面传参）。
      // 这里断言那段文案的形状与「范围天数」一致即可，不再锁定旧页面的
      // 3/7 传参：
      expect(
        find.textContaining(
          l10n.reviewRecordGuideDescription(0, 7).split('0').first,
        ),
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
        // 轻量解释卡只在「确认无事件、且数据不算过稀」时出现；过稀走记录
        // 引导卡（README 的不变量）。给一个足够覆盖的看板才能测到解释卡。
        dashboard: ReviewDashboard.signedOut().copyWith(
          metrics: [_sufficientCoverageMetric()],
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
      // 注入的是「已确认的无事件」+ 上次成功的事件回顾：事件区由
      // [reviewLastCurrentProvider] 承接，失败只体现在横幅上。这样断言
      // 的正是组件化后的契约——失败不得把已在屏上的内容拿走。
      await pumpReviewView(
        tester,
        current: const AsyncValue<EventReview?>.data(null),
        cached: reviewActive(),
        dashboard: ReviewDashboard.signedOut(),
      );

      await tester.pump();

      expect(find.byKey(const Key('review-stale-banner')), findsOneWidget);
      expect(find.text(l10n.reviewReviewStaleBanner), findsOneWidget);
      expect(find.byKey(const Key('review-event-header')), findsOneWidget);
      expect(find.text('感冒观察'), findsOneWidget);
    },
  );

  testWidgets('error without cache shows the retry state view', (tester) async {
    // 真的失败：provider 以错误结束、没有任何缓存，页面才进入错误态分支。
    await pumpReviewView(
      tester,
      current: AsyncValue<EventReview?>.error(
        Exception('boom'),
        StackTrace.current,
      ),
      failCurrent: true,
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
