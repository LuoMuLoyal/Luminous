import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart' hide HealthSummary;
import 'package:luminous/core/analytics/product_event_service.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/review/data/providers/review.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/domain/repositories/review.dart';
import 'package:luminous/features/review/presentation/pages/page.dart';
import 'package:luminous/features/review/presentation/providers/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/sections/legacy/readiness.dart';
import 'package:luminous/features/review/presentation/widgets/sections/period_switch.dart';
import 'package:luminous/features/review/presentation/widgets/sections/preview/export.dart';
import 'package:luminous/features/review/presentation/widgets/shared/top_bar.dart';
import 'package:luminous/features/review/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_forui_app.dart';
import '../review/widgets/review_fixtures.dart';

void main() {
  testWidgets(
    'Report page renders the review-first layout for signed-in mobile state',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        _buildApp(
          reviewRepository: _FakeReviewRepository(
            current: reviewActive(),
            page: reviewHistoryPage([
              reviewEventItem(id: 'evt-2', title: '嗓子疼观察'),
            ]),
          ),
          signedIn: true,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(l10n.tabReview), findsOneWidget);
      expect(find.byKey(const Key('review-event-header')), findsOneWidget);
      // 今日未确认：头部渲染去今日 check-in 浅链接（旧的 check-in/end 按钮已移除）。
      expect(find.byKey(const Key('review-go-today-check-in')), findsOneWidget);
      expect(
        find.byKey(const Key('review-what-happened-section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('review-key-changes-section')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('review-completed-actions-section')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('review-next-step-section')), findsOneWidget);

      // 旧 dashboard 主路径内容不再装配：不构建 ExportSection
      // 或 readiness 卡（canShowFullReport 整页锁所在），也不出现 7/30 天
      // 范围切换（ReviewTopBar/ReviewRangeMenu 仅 legacy 文件保留）。
      expect(find.byKey(const Key('report-readiness-card')), findsNothing);
      expect(find.byKey(const Key('report-export-section')), findsNothing);
      expect(find.byType(ReviewExportSection), findsNothing);
      expect(find.byType(ReviewReadinessSection), findsNothing);
      expect(find.byType(ReviewTopBar), findsNothing);
      expect(find.byType(ReviewRangeMenu), findsNothing);
      expect(find.text(l10n.reviewRangeLast7Days), findsNothing);
      expect(find.text(l10n.reviewRangeLast30Days), findsNothing);

      final scrollable = find.byType(Scrollable).first;
      final historySection = find.byKey(const Key('review-history-section'));
      await tester.scrollUntilVisible(
        historySection,
        260,
        scrollable: scrollable,
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(historySection, findsOneWidget);
      expect(find.text('嗓子疼观察'), findsOneWidget);
    },
  );

  testWidgets('Report page shows the skeleton while the review is loading', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final repo = _PendingReviewRepository();

    await tester.pumpWidget(_buildApp(reviewRepository: repo, signedIn: true));

    await tester.pump();

    expect(repo.currentCalls, 1);
    expect(find.byType(ReviewSkeletonView), findsOneWidget);
    expect(find.byKey(const Key('review-event-header')), findsNothing);

    repo.completeCurrent(reviewActive());
    repo.completeHistory(reviewHistoryPage(const []));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ReviewSkeletonView), findsNothing);
    expect(find.byKey(const Key('review-event-header')), findsOneWidget);
  });

  testWidgets(
    'Report page signed-out preview shows the sign-in banner and no dashboard sections',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      await tester.pumpWidget(
        _buildApp(reviewRepository: _FakeReviewRepository(), signedIn: false),
      );

      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('sign-in-hint-banner')), findsOneWidget);
      expect(find.byKey(const Key('review-record-guide-card')), findsOneWidget);
      expect(
        find.byKey(const Key('review-start-observation-action')),
        findsNothing,
      );
      expect(find.byKey(const Key('report-readiness-card')), findsNothing);
    },
  );

  testWidgets(
    'Report page cold-start no-event state shows the record guide and an empty history explanation',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await tester.pumpWidget(
        _buildApp(
          reviewRepository: _FakeReviewRepository(
            current: null,
            page: const ReviewEventPage(items: [], total: 0),
          ),
          signedIn: true,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byKey(const Key('review-record-guide-card')), findsOneWidget);
      expect(
        find.byKey(const Key('review-start-observation-action')),
        findsNothing,
      );
      expect(find.text(l10n.reviewRecordGuideTitle), findsOneWidget);
      // 无事件时不自动生成周报。
      expect(find.byKey(const Key('report-export-section')), findsNothing);
      expect(find.byKey(const Key('report-patterns-section')), findsNothing);
    },
  );

  testWidgets('Report page supports pull-to-refresh on mobile', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final repo = _FakeReviewRepository(
      current: reviewActive(),
      page: const ReviewEventPage(items: [], total: 0),
    );

    await tester.pumpWidget(_buildApp(reviewRepository: repo, signedIn: true));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(repo.currentCalls, 1);

    await tester.drag(find.byType(ListView).first, const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(repo.currentCalls, 2);
    expect(repo.historyCalls, 2);
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('Report page error state shows the retry view', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await tester.pumpWidget(
      _buildApp(reviewRepository: _ThrowingReviewRepository(), signedIn: true),
    );

    await tester.pumpAndSettle();

    expect(find.text(l10n.reviewReviewErrorTitle), findsOneWidget);
    expect(find.text(l10n.todayRetryAction), findsOneWidget);
  });

  testWidgets(
    'Report page desktop width renders the same review content without crash',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1440, 1000);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      await tester.pumpWidget(
        _buildApp(
          reviewRepository: _FakeReviewRepository(
            current: reviewActive(),
            page: const ReviewEventPage(items: [], total: 0),
          ),
          signedIn: true,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('review-event-header')), findsOneWidget);
      expect(
        find.byKey(const PageStorageKey<String>('report-mobile-scroll')),
        findsOneWidget,
      );
    },
  );

  testWidgets('legacy dashboard provider failure does not block the review', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    // 旧 dashboard provider 被 override 为必失败：主路径不应 watch 它，
    // review 内容照常渲染。
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          reviewRepositoryProvider.overrideWithValue(
            _FakeReviewRepository(
              current: reviewActive(),
              page: const ReviewEventPage(items: [], total: 0),
            ),
          ),
          reviewDashboardProvider.overrideWith(
            (ref, query) async => throw Exception('legacy dashboard down'),
          ),
          healthContextSnapshotProvider.overrideWith(
            (ref) async => _healthContextSnapshot,
          ),
          dailyRecordListForDateProvider.overrideWith(
            (ref, date) async => const DailyRecordListData(items: [], total: 0),
          ),
        ],
        child: const TestForuiApp(home: ReviewPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('review-event-header')), findsOneWidget);
    expect(find.byKey(const Key('review-go-today-check-in')), findsOneWidget);
    expect(find.text(l10n.reviewReviewErrorTitle), findsNothing);
  });

  testWidgets(
    'period switch maps 周|月 to the dashboard query and re-fetches with the selected range',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      final recordedQueries = <ReviewDashboardQuery>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
            reviewRepositoryProvider.overrideWithValue(
              _FakeReviewRepository(
                current: reviewActive(),
                page: const ReviewEventPage(items: [], total: 0),
              ),
            ),
            reviewDashboardProvider.overrideWith((ref, query) async {
              recordedQueries.add(query);
              // 返回带 range + 单个覆盖指标的 dashboard：趋势因 trends 为空
              // 不渲染，但周期反映所选范围；覆盖概览卡因此可显示出指标。
              return ReviewDashboard.signedOut().copyWith(
                range: query.range,
                metrics: const [
                  ReviewMetric(
                    kind: ReviewDataKind.water,
                    icon: SemanticIcons.recordWater,
                    color: SemanticColor.primary,
                    value: '1.2',
                    unit: 'L',
                    status: ReviewStatus.stable,
                    delta: '-12%',
                    direction: ReviewMetricDirection.down,
                    sparkline: [],
                    observedMetric: ReviewObservedMetric(
                      value: 1.2,
                      state: ReviewObservedMetricState.observed,
                      coverage: ReviewObservedMetricCoverage.sufficient,
                      sources: [ReviewObservedMetricSource.manual],
                      observedCount: 4,
                      expectedCount: 7,
                      windowStart: '',
                      windowEnd: '',
                    ),
                  ),
                ],
              );
            }),
            healthContextSnapshotProvider.overrideWith(
              (ref) async => _healthContextSnapshot,
            ),
            dailyRecordListForDateProvider.overrideWith(
              (ref, date) async =>
                  const DailyRecordListData(items: [], total: 0),
            ),
          ],
          child: const TestForuiApp(home: ReviewPage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // 默认周视角，且周 tab 渲染。
      expect(find.byType(ReviewPeriodSwitch), findsOneWidget);
      expect(find.text(l10n.reviewPeriodWeek), findsOneWidget);
      expect(find.text(l10n.reviewPeriodMonth), findsOneWidget);
      // 覆盖率概览行：dashboard 有覆盖指标时渲染。
      expect(
        find.byKey(const Key('review-coverage-card-water')),
        findsOneWidget,
      );
      expect(
        recordedQueries.any((q) => q.range == ReviewDashboardRange.last7Days),
        isTrue,
      );

      // 点「月」→ 查询切换为 last30Days，provider 重新请求。
      await tester.tap(find.text(l10n.reviewPeriodMonth));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        recordedQueries.any((q) => q.range == ReviewDashboardRange.last30Days),
        isTrue,
        reason: '切换月应重新请求 last30Days 查询',
      );
    },
  );

  testWidgets('coverage card tap selects the trend dimension', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          reviewRepositoryProvider.overrideWithValue(
            _FakeReviewRepository(
              current: reviewActive(),
              page: const ReviewEventPage(items: [], total: 0),
            ),
          ),
          reviewDashboardProvider.overrideWith((ref, query) async {
            // 两个维度 trend + 两个覆盖指标卡，便于观察维度联动切换。
            return ReviewDashboard.signedOut().copyWith(
              range: query.range,
              trends: const [
                ReviewTrendSeries(
                  kind: ReviewDataKind.water,
                  color: SemanticColor.primary,
                  unit: 'L',
                  values: [1.0, 1.1, 1.2],
                  currentValue: '1.2',
                ),
                ReviewTrendSeries(
                  kind: ReviewDataKind.sleep,
                  color: SemanticColor.info,
                  unit: 'h',
                  values: [6.5, 7.0, 6.5],
                  currentValue: '6.5',
                ),
              ],
              metrics: const [
                ReviewMetric(
                  kind: ReviewDataKind.water,
                  icon: SemanticIcons.recordWater,
                  color: SemanticColor.primary,
                  value: '1.2',
                  unit: 'L',
                  status: ReviewStatus.stable,
                  delta: '-12%',
                  direction: ReviewMetricDirection.down,
                  sparkline: [],
                ),
                ReviewMetric(
                  kind: ReviewDataKind.sleep,
                  icon: SemanticIcons.recordSleep,
                  color: SemanticColor.info,
                  value: '6.5',
                  unit: 'h',
                  status: ReviewStatus.stable,
                  delta: '+5%',
                  direction: ReviewMetricDirection.up,
                  sparkline: [],
                ),
              ],
            );
          }),
          healthContextSnapshotProvider.overrideWith(
            (ref) async => _healthContextSnapshot,
          ),
          dailyRecordListForDateProvider.overrideWith(
            (ref, date) async => const DailyRecordListData(items: [], total: 0),
          ),
        ],
        child: const TestForuiApp(home: ReviewPage()),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // 覆盖概览行两张卡可见，健康趋势标题可见。
    expect(find.byKey(const Key('review-coverage-card-water')), findsOneWidget);
    expect(find.byKey(const Key('review-coverage-card-sleep')), findsOneWidget);
    expect(find.text('健康趋势'), findsWidgets);

    // 点击睡眠覆盖卡 → 选中 sleep 维度，趋势卡切到睡眠当前值。
    await tester.tap(find.byKey(const Key('review-coverage-card-sleep')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('6.5h'), findsWidgets);
  });

  testWidgets(
    'period switch keeps the cached dashboard visible while the new range loads',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      // 第一次查询（周）立即返回带 trends 的数据；第二次查询（月）挂起
      // 不完成，用于模拟切换期间的加载窗口。
      final monthlyPending = Completer<ReviewDashboard>();
      var fetchCount = 0;
      ReviewDashboard dashboardWithTrends(ReviewDashboardRange range) {
        return ReviewDashboard.signedOut().copyWith(
          range: range,
          trends: const [
            ReviewTrendSeries(
              kind: ReviewDataKind.water,
              color: SemanticColor.primary,
              unit: 'L',
              values: [1.0, 1.2, 1.4],
              currentValue: '1.2',
            ),
          ],
        );
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
            reviewRepositoryProvider.overrideWithValue(
              _FakeReviewRepository(
                current: reviewActive(),
                page: const ReviewEventPage(items: [], total: 0),
              ),
            ),
            reviewDashboardProvider.overrideWith((ref, query) {
              fetchCount += 1;
              if (query.range == ReviewDashboardRange.last7Days) {
                return Future.value(dashboardWithTrends(query.range));
              }
              return monthlyPending.future;
            }),
            healthContextSnapshotProvider.overrideWith(
              (ref) async => _healthContextSnapshot,
            ),
            dailyRecordListForDateProvider.overrideWith(
              (ref, date) async =>
                  const DailyRecordListData(items: [], total: 0),
            ),
          ],
          child: const TestForuiApp(home: ReviewPage()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // 周数据加载完成，趋势卡可见。
      expect(find.byKey(const Key('review-trend-section')), findsOneWidget);

      // 切到月：新查询挂起，期间仍展示上次成功缓存（旧趋势卡不消失，
      // 不整页骨架）。
      await tester.tap(
        find.text(
          AppLocalizations.of(
            tester.element(find.byType(ReviewPage)),
          )!.reviewPeriodMonth,
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const Key('review-trend-section')),
        findsOneWidget,
        reason: '切换期间应继续显示缓存（旧数据 + 轻量加载态，不整页骨架）',
      );
      expect(
        find.byType(ReviewSkeletonView),
        findsNothing,
        reason: '周期切换不应触发整页骨架',
      );

      // 完成月请求后，趋势卡数据更新为月范围的 trends（仍保留该卡）。
      monthlyPending.complete(
        dashboardWithTrends(ReviewDashboardRange.last30Days),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const Key('review-trend-section')), findsOneWidget);
      expect(fetchCount, 2, reason: '切换月应触发一次重新请求');
    },
  );

  testWidgets('history status filter re-fetches with the selected status', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final reviewRepository = _FakeReviewRepository(
      current: null,
      pageResolver: (status) => switch (status) {
        ReviewEventStatus.active => reviewHistoryPage([
          reviewEventItem(
            id: 'evt-active-hist',
            title: '进行中的观察',
            status: ReviewEventStatus.active,
            outcome: null,
            endedAt: null,
          ),
        ]),
        _ => reviewHistoryPage([
          reviewEventItem(id: 'evt-ended-hist', title: '已结束的观察'),
        ]),
      },
    );

    await tester.pumpWidget(
      _buildApp(reviewRepository: reviewRepository, signedIn: true),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(reviewRepository.lastHistoryStatus, isNull);
    expect(find.text('已结束的观察'), findsOneWidget);

    // filter 按钮在屏幕下方，需要先滚动到可见位置。
    // scrollUntilVisible 可能不工作（嵌套 scrollable），
    // 直接 drag 主 ListView 将内容上移。
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(
      find.byKey(const Key('review-history-filter-active')),
      warnIfMissed: false,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(reviewRepository.historyCalls, 2);
    expect(reviewRepository.lastHistoryStatus, ReviewEventStatus.active);
    // 列表实际更新为过滤后数据，而不是沿用旧页。
    expect(find.text('进行中的观察'), findsOneWidget);
    expect(find.text('已结束的观察'), findsNothing);

    // filter 按钮可能已因上次滚动可见，但仍需确保在屏内。
    await tester.drag(find.byType(ListView).first, const Offset(0, -300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(
      find.byKey(const Key('review-history-filter-all')),
      warnIfMissed: false,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(reviewRepository.historyCalls, 3);
    expect(reviewRepository.lastHistoryStatus, isNull);
    expect(find.text('已结束的观察'), findsOneWidget);
    expect(find.text('进行中的观察'), findsNothing);
  });

  testWidgets('filtered history failure shows the retry row immediately', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
    final reviewRepository = _FakeReviewRepository(
      current: null,
      page: const ReviewEventPage(items: [], total: 0),
    )..throwOnStatus = ReviewEventStatus.active;

    await tester.pumpWidget(
      _buildApp(reviewRepository: reviewRepository, signedIn: true),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(reviewRepository.historyCalls, 1);

    // filter 按钮在屏幕下方，需要先滚动到可见位置。
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(
      find.byKey(const Key('review-history-filter-active')),
      warnIfMissed: false,
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // provider 已关闭自动重试：失败立即进入错误行，而不是被指数退避掩盖。
    expect(reviewRepository.historyCalls, 2);
    expect(find.text(l10n.reviewReviewHistoryLoadFailed), findsOneWidget);
    expect(find.byKey(const Key('review-history-retry')), findsOneWidget);
  });

  // ── review_opened 成功边界测量 ──────────────────────────────────────────

  testWidgets('records review_opened when review data is presented', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final service = _RecordingProductEventService();

    await tester.pumpWidget(
      _buildApp(
        reviewRepository: _FakeReviewRepository(
          current: reviewActive(),
          page: const ReviewEventPage(items: [], total: 0),
        ),
        signedIn: true,
        productEvents: service,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(service.reviewOpenedCalls, 1);
  });

  testWidgets(
    'inactive-tab transitions do not consume the session review_opened',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      final service = _RecordingProductEventService();
      final repo = _FakeReviewRepository(
        current: reviewActive(),
        page: const ReviewEventPage(items: [], total: 0),
      );
      final activeTab = ValueNotifier<bool>(false);
      addTearDown(activeTab.dispose);

      // The ReviewPage sits in a hidden shell branch (TickerMode disabled)
      // while the review data loads.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
            reviewRepositoryProvider.overrideWithValue(repo),
            reviewDashboardProvider.overrideWith(
              (ref, query) async => ReviewDashboard.signedOut(),
            ),
            healthContextSnapshotProvider.overrideWith(
              (ref) async => _healthContextSnapshot,
            ),
            dailyRecordListForDateProvider.overrideWith(
              (ref, date) async =>
                  const DailyRecordListData(items: [], total: 0),
            ),
            productEventServiceProvider.overrideWithValue(service),
          ],
          child: ValueListenableBuilder<bool>(
            valueListenable: activeTab,
            builder: (context, isActive, _) => TickerMode(
              enabled: isActive,
              child: const TestForuiApp(home: ReviewPage()),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // While the tab is hidden the page never presents the data (the watch
      // subscription is paused) — nothing may consume the once-per-session
      // review_opened.
      expect(find.byType(ReviewSkeletonView), findsOneWidget);
      expect(service.reviewOpenedCalls, 0);

      // Tab becomes visible: the buffered data presentation is delivered and
      // the first visible build records review_opened.
      activeTab.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const Key('review-event-header')), findsOneWidget);
      expect(service.reviewOpenedCalls, 1);

      // A user-visible refresh presents a new data instance — re-reported,
      // and the service still dedupes to one event per session.
      await tester.drag(find.byType(ListView).first, const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 500));

      expect(repo.currentCalls, 2);
      expect(service.reviewOpenedCalls, greaterThanOrEqualTo(2));
    },
  );

  testWidgets('does not record review_opened when the review fails', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final service = _RecordingProductEventService();

    await tester.pumpWidget(
      _buildApp(
        reviewRepository: _ThrowingReviewRepository(),
        signedIn: true,
        productEvents: service,
      ),
    );
    await tester.pumpAndSettle();

    expect(service.reviewOpenedCalls, 0);
  });

  testWidgets('does not record review_opened for signed-out previews', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final service = _RecordingProductEventService();

    await tester.pumpWidget(
      _buildApp(
        reviewRepository: _FakeReviewRepository(),
        signedIn: false,
        productEvents: service,
      ),
    );
    await tester.pumpAndSettle();

    expect(service.reviewOpenedCalls, 0);
  });

  testWidgets(
    're-presentation after refresh re-triggers; session dedupe lives in the service',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });
      final service = _RecordingProductEventService();
      final repo = _FakeReviewRepository(
        current: reviewActive(),
        page: const ReviewEventPage(items: [], total: 0),
      );

      await tester.pumpWidget(
        _buildApp(
          reviewRepository: repo,
          signedIn: true,
          productEvents: service,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(service.reviewOpenedCalls, 1);

      // Pull-to-refresh re-presents the data; the page reports each
      // presentation transition, and ProductEventService dedupes them to one
      // event per session (covered by the service unit tests). Riverpod may
      // emit the refresh completion more than once, so assert the floor.
      await tester.drag(find.byType(ListView).first, const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 500));

      expect(repo.currentCalls, 2);
      expect(service.reviewOpenedCalls, greaterThanOrEqualTo(2));
    },
  );
}

Widget _buildApp({
  required ReviewRepository reviewRepository,
  required bool signedIn,
  HealthContextSnapshot snapshot = _healthContextSnapshot,
  DailyRecordListData records = const DailyRecordListData(items: [], total: 0),
  ProductEventService? productEvents,
}) {
  return ProviderScope(
    overrides: [
      authSessionProvider.overrideWith(
        signedIn
            ? _SignedInAuthSessionNotifier.new
            : _SignedOutAuthSessionNotifier.new,
      ),
      reviewRepositoryProvider.overrideWithValue(reviewRepository),
      // dashboard provider：测试环境无后端，返回空 trends 的 signedOut
      // dashboard，折线图因 trendSeries 为空不渲染。
      reviewDashboardProvider.overrideWith(
        (ref, query) async => ReviewDashboard.signedOut(),
      ),
      healthContextSnapshotProvider.overrideWith((ref) async => snapshot),
      dailyRecordListForDateProvider.overrideWith((ref, date) async => records),
      if (productEvents != null)
        productEventServiceProvider.overrideWithValue(productEvents),
    ],
    child: const TestForuiApp(home: ReviewPage()),
  );
}

/// Records review_opened calls instead of posting events.
class _RecordingProductEventService extends ProductEventService {
  _RecordingProductEventService() : super(api: _MockProductEventsApi());

  int reviewOpenedCalls = 0;

  @override
  Future<void> trackReviewOpened() async {
    reviewOpenedCalls += 1;
  }
}

class _MockProductEventsApi extends Mock implements ProductEventsApi {}

class _SignedInAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return AuthSessionState(
      isAuthenticated: true,
      isLoading: false,
      user: AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        nickname: 'Lumi',
        avatar: null,
        emailVerifiedAt: DateTime.parse('2026-01-01T00:00:00Z'),
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00Z'),
      ),
    );
  }
}

class _SignedOutAuthSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() {
    return const AuthSessionState(isAuthenticated: false, isLoading: false);
  }
}

class _FakeReviewRepository implements ReviewRepository {
  _FakeReviewRepository({this.current, this.page, this.pageResolver});

  EventReview? current;
  ReviewEventPage? page;

  /// 按 status 返回不同页面的解析器（用于筛选列表更新断言）。
  ReviewEventPage Function(ReviewEventStatus? status)? pageResolver;

  /// 命中该 status 时抛错（用于「筛选失败立即渲染失败行」断言）。
  ReviewEventStatus? throwOnStatus;

  int currentCalls = 0;
  int historyCalls = 0;
  ReviewEventStatus? lastHistoryStatus;

  @override
  TaskEither<LucentFailure, EventReview?> fetchCurrentReview() {
    currentCalls += 1;
    return TaskEither.right(current);
  }

  @override
  TaskEither<LucentFailure, ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) {
    historyCalls += 1;
    lastHistoryStatus = status;
    return TaskEither.tryCatch(() async {
      if (throwOnStatus != null && status == throwOnStatus) {
        throw Exception('history fetch failed for status filter');
      }
      return pageResolver?.call(status) ??
          page ??
          const ReviewEventPage(items: [], total: 0);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, EventReview> fetchReview(String eventId) {
    throw UnimplementedError();
  }
}

class _PendingReviewRepository implements ReviewRepository {
  final _pendingCurrent = Completer<EventReview?>();
  final _pendingHistory = Completer<ReviewEventPage>();

  int currentCalls = 0;
  int historyCalls = 0;

  @override
  TaskEither<LucentFailure, EventReview?> fetchCurrentReview() {
    currentCalls += 1;
    return TaskEither.tryCatch(
      () => _pendingCurrent.future,
      (error, stackTrace) => LucentErrorMapper.fromObject(error),
    );
  }

  @override
  TaskEither<LucentFailure, ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) {
    historyCalls += 1;
    return TaskEither.tryCatch(
      () => _pendingHistory.future,
      (error, stackTrace) => LucentErrorMapper.fromObject(error),
    );
  }

  @override
  TaskEither<LucentFailure, EventReview> fetchReview(String eventId) {
    throw UnimplementedError();
  }

  void completeCurrent(EventReview? review) {
    _pendingCurrent.complete(review);
  }

  void completeHistory(ReviewEventPage page) {
    _pendingHistory.complete(page);
  }
}

class _ThrowingReviewRepository implements ReviewRepository {
  @override
  TaskEither<LucentFailure, EventReview?> fetchCurrentReview() {
    return TaskEither.left(LucentFailure.unknown(message: 'Test error'));
  }

  @override
  TaskEither<LucentFailure, ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) {
    return TaskEither.left(LucentFailure.unknown(message: 'Test error'));
  }

  @override
  TaskEither<LucentFailure, EventReview> fetchReview(String eventId) {
    return TaskEither.left(LucentFailure.unknown(message: 'Test error'));
  }
}

const _healthContextSnapshot = HealthContextSnapshot(
  summary: HealthSummary(
    age: null,
    onboardingCompleted: true,
    activeAllergyCount: 0,
    conditionCount: 0,
    currentMedicineCount: 0,
    missingCoreProfileFields: [],
  ),
  profile: HealthProfile(
    birthDate: null,
    sexAtBirth: null,
    heightCm: null,
    weightKg: null,
    bloodType: null,
    locale: null,
    timezone: 'Asia/Shanghai',
    unitSystem: null,
    onboardingCompletedAt: null,
    emergencyContactName: null,
    emergencyContactPhone: null,
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);
