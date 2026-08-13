import 'dart:async';

import 'package:integration_test/integration_test.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/domain/repositories/health_event.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/domain/repositories/review.dart';

import '../support/e2e_test_helpers.dart';

/// 五 Tab 闭环 e2e（离线/mock）：开始事件 → Record 写症状 → Medicine
/// 槽位确认 → Review 看到更新 → 结束并确认结果。
///
/// 运行环境说明（Windows 桌面窗口）：
/// - 桌面布局未做功能对等：Today 健康事件卡片是移动布局专属，因此
///   「开始事件」走 Review 无事件卡的同一入口（同一 StartEventSheet +
///   ActiveHealthEvent notifier + DataChangeBus 链路）；Medicine 剂量确认
///   卡片桌面同样渲染（medicine 页桌面/移动共用 dashboard 视图），可完整
///   确认槽位。
/// - 视口 resize 到手机宽度会触发 riverpod 3.3.1 在 TickerMode 重建期间的
///   setState-during-build 竞态，本环境无法以移动视口运行（见迁移日志）。
///
/// [E2eHealthEventLoopStore] 是 HealthEventRepository 与 ReviewRepository
/// 共享的内存事实源：开始/结束写入 store，Review 读取 store，事件落库后
/// DataChangeBus 驱动 review providers 自动刷新，闭环在 UI 层真实成立。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('闭环：开始事件 → Record 写症状 → Medicine 槽位 → Review 看到更新 → 结束并确认结果', (
    tester,
  ) async {
    final loop = E2eHealthEventLoopStore();
    final doseLogs = E2eDoseLogRemoteDataSource();
    final dailyRecords = E2eDailyRecordRepository();

    final container = await pumpOfflineApp(
      tester,
      authSessionOverride: SignedInAuthSessionNotifier.new,
      healthEventRepository: loop.healthEvents,
      reviewRepository: loop.review,
      dailyRecordRepository: dailyRecords,
      medicineWorkspaceRepository: E2eMedicineWorkspaceRepository(),
      doseLogRemoteDataSource: doseLogs,
    );

    // ── 1. 开始事件（Review 无事件卡入口，桌面布局下 Today 无健康
    //        事件卡片；链路与 Today 的 health-event-start-action 相同）─
    await openTab(tester, '报告');
    await tapVisible(
      tester,
      find.byKey(const Key('review-start-observation-action')),
    );
    await tester.enterText(
      find.byKey(const Key('health-event-start-title-field')),
      '闭环观察',
    );
    await tester.tap(find.byKey(const Key('health-event-start-submit')));
    await settleE2e(tester, frames: 10);

    expect(loop.active, isNotNull, reason: '开始事件应写入共享事实源');

    // ── 2. Record 写症状 ─────────────────────────────────────────
    await openTab(tester, '记录');
    unawaited(container.read(appRouterProvider).push('/record/create'));
    await settleE2e(tester);

    // 类型切到「症状」。
    await tester.tap(find.byKey(const Key('daily-record-kind-water')));
    await settleE2e(tester);
    await tester.tap(find.text('症状').last);
    await settleE2e(tester);
    expect(find.byKey(const Key('daily-record-kind-symptom')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('daily-record-title-field')),
      '闭环症状',
    );
    await tester.enterText(
      find.byKey(const Key('daily-record-value-field')),
      '头痛',
    );
    final saveButton = find.byKey(const Key('record-create-save-action'));
    // 保存按钮在页面底部：先滚动到可见（桌面窗口高度小）。
    for (var i = 0; i < 6; i += 1) {
      await tester.drag(
        find.byKey(const Key('daily-record-note-field')),
        const Offset(0, -300),
      );
      await settleE2e(tester);
    }
    await tester.ensureVisible(saveButton);
    await settleE2e(tester);
    await tester.tap(saveButton, warnIfMissed: false);
    await settleE2e(tester, frames: 10);

    final input = dailyRecords.createInput;
    expect(input, isNotNull, reason: '症状记录应经 repository 落库');
    expect(input!.kind, DailyRecordKind.symptom);
    expect(input.value, '头痛');

    // ── 3. Medicine 确认槽位（桌面同样渲染剂量确认卡片） ─────────
    await openTab(tester, '用药');
    await tapMedicineDoseAction(tester, '已服用');
    expect(doseLogs.markCurrentMedicineId, 'e2e-medicine-1');
    expect(doseLogs.markStatus, 'taken');
    expect(doseLogs.markDate, todayDateString());

    // ── 4. Review 看到更新（active 事件 + 今日 check-in 入口） ──
    await openTab(tester, '报告');
    await pumpUntilFound(
      tester,
      find.text('闭环观察'),
      timeout: const Duration(seconds: 10),
    );
    expect(find.byKey(const Key('review-event-header')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('review-event-status-chip')),
        matching: find.text('进行中'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('review-check-in-action')), findsOneWidget);
    expect(find.byKey(const Key('report-readiness-card')), findsNothing);

    // ── 5. 结束并确认结果 ────────────────────────────────────────
    await tapVisible(tester, find.byKey(const Key('review-end-event-action')));
    await tester.tap(
      find.byKey(const Key('health-event-end-outcome-improved')),
    );
    await settleE2e(tester);
    await tester.tap(find.byKey(const Key('health-event-end-submit')));
    await settleE2e(tester, frames: 10);

    expect(loop.active, isNull, reason: '事件结束后共享事实源不再有 active');
    expect(loop.ended.length, 1);

    // Review 自动刷新为无事件 + 历史出现已结束事件（结果「好转」）。
    await pumpUntilFound(
      tester,
      find.byKey(const Key('review-no-event-card')),
      timeout: const Duration(seconds: 10),
    );
    final scrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byKey(const Key('review-history-item-e2e-event-1')),
      260,
      scrollable: scrollable,
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.byKey(const Key('review-history-item-e2e-event-1')),
      findsOneWidget,
    );
    expect(find.text('好转'), findsWidgets);

    // Allow pending Dio interceptor callbacks to settle.
    await settleE2e(tester, frames: 30);
  });
}

/// 闭环共享内存事实源：Today 的事件操作（创建/结束）与 Review 读取
/// （current/history）落在同一份数据上。
class E2eHealthEventLoopStore {
  E2eHealthEventLoopStore()
    : healthEvents = E2eLoopHealthEventRepository._(),
      review = E2eLoopReviewRepository._() {
    healthEvents._store = this;
    review._store = this;
  }

  HealthEvent? active;
  final List<HealthEvent> ended = [];

  final E2eLoopHealthEventRepository healthEvents;
  final E2eLoopReviewRepository review;

  int _seq = 0;

  String get _nowIso => DateTime.now().toUtc().toIso8601String();

  HealthEvent start({
    required String title,
    List<String> currentMedicineIds = const [],
  }) {
    final event = HealthEvent(
      id: 'e2e-event-${++_seq}',
      title: title,
      status: HealthEventStatus.active,
      startedAt: _nowIso,
      currentMedicineIds: currentMedicineIds,
      coverage: const HealthEventCoverage(checkInCount: 0),
    );
    active = event;
    return event;
  }

  HealthEvent end(String eventId, HealthEventOutcome outcome) {
    final current = active;
    if (current == null || current.id != eventId) {
      throw StateError('没有可结束的事件 $eventId');
    }
    final endedEvent = current.copyWith(
      status: HealthEventStatus.ended,
      endedAt: _nowIso,
      outcome: outcome,
    );
    active = null;
    ended.insert(0, endedEvent);
    return endedEvent;
  }

  HealthEvent checkIn({
    required String eventId,
    required HealthEventOutcome outcome,
  }) {
    final current = active;
    if (current == null || current.id != eventId) {
      throw StateError('没有可打卡的事件 $eventId');
    }
    final updated = current.copyWith(
      checkIn: HealthEventCheckIn(
        id: 'e2e-checkin-1',
        eventId: eventId,
        date: todayDateString(),
        outcome: outcome,
        createdAt: _nowIso,
        updatedAt: _nowIso,
      ),
      coverage: current.coverage.copyWith(checkInCount: 1),
    );
    active = updated;
    return updated;
  }
}

class E2eLoopHealthEventRepository implements HealthEventRepository {
  E2eLoopHealthEventRepository._();

  late E2eHealthEventLoopStore _store;

  @override
  Future<HealthEvent?> fetchActive() async => _store.active;

  @override
  Future<HealthEvent?> fetchById(String eventId) async {
    final active = _store.active;
    if (active?.id == eventId) return active;
    for (final event in _store.ended) {
      if (event.id == eventId) return event;
    }
    return null;
  }

  @override
  Future<List<HealthEvent>> fetchHistory() async => _store.ended;

  @override
  Future<HealthEvent> create({
    required String title,
    String? reasonRecordId,
    List<String> currentMedicineIds = const [],
  }) async {
    return _store.start(title: title, currentMedicineIds: currentMedicineIds);
  }

  @override
  Future<HealthEvent> checkIn({
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
  }) async {
    return _store.checkIn(eventId: eventId, outcome: outcome);
  }

  @override
  Future<HealthEvent> end({
    required String eventId,
    required HealthEventOutcome outcome,
  }) async {
    return _store.end(eventId, outcome);
  }
}

class E2eLoopReviewRepository implements ReviewRepository {
  E2eLoopReviewRepository._();

  late E2eHealthEventLoopStore _store;

  @override
  Future<EventReview?> fetchCurrentReview() async {
    final active = _store.active;
    if (active == null) return null;
    return _activeReview(active);
  }

  @override
  Future<ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) async {
    final items = _store.ended
        .where(
          (event) =>
              status == null ||
              (status == ReviewEventStatus.ended &&
                  event.status == HealthEventStatus.ended),
        )
        .map(
          (event) => ReviewEvent(
            id: event.id,
            kind: ReviewEventKind.symptom,
            title: event.title,
            status: ReviewEventStatus.ended,
            startedAt: event.startedAt,
            endedAt: event.endedAt,
            outcome: switch (event.outcome) {
              HealthEventOutcome.improved => ReviewEventOutcome.improved,
              HealthEventOutcome.unchanged => ReviewEventOutcome.unchanged,
              HealthEventOutcome.worsened => ReviewEventOutcome.worsened,
              null => ReviewEventOutcome.unknown,
            },
            currentMedicineIds: event.currentMedicineIds,
          ),
        )
        .toList();
    return ReviewEventPage(items: items, total: items.length);
  }

  @override
  Future<EventReview> fetchReview(String eventId) async {
    throw UnimplementedError('闭环 e2e 不需要事件详情回顾');
  }

  /// 从共享事实源构造 active 回顾：四段中「发生了什么」available（事实
  /// 来自事件本身），其余 unknown——与真实后端聚合口径一致地表达
  /// 「稀疏数据下不生成泛化内容」。
  EventReview _activeReview(HealthEvent event) {
    final window = _reviewWindow(event);
    return EventReview(
      event: ReviewEvent(
        id: event.id,
        kind: ReviewEventKind.symptom,
        title: event.title,
        status: ReviewEventStatus.active,
        startedAt: event.startedAt,
        endedAt: event.endedAt,
        outcome: null,
        currentMedicineIds: event.currentMedicineIds,
      ),
      sections: ReviewSections(
        whatHappened: ReviewSection(
          state: ReviewSectionState.available,
          facts: ReviewSectionFacts(
            code: 'health_event',
            arguments: {
              'kind': 'symptom',
              'title': event.title,
              'startedAt': event.startedAt,
              'endedAt': event.endedAt,
              'medicineIds': event.currentMedicineIds,
              'symptomRecordCount': 1,
              'checkInCount': event.coverage.checkInCount,
            },
          ),
        ),
        keyChanges: const ReviewSection(
          state: ReviewSectionState.unknown,
          reasonCode: ReviewSectionReasonCodes.noObservations,
        ),
        completedActions: const ReviewSection(
          state: ReviewSectionState.unknown,
          reasonCode: ReviewSectionReasonCodes.noCompletedActions,
        ),
        nextStep: const ReviewSection(
          state: ReviewSectionState.available,
          facts: ReviewSectionFacts(
            code: 'active_check_in',
            arguments: {'hasTodayCheckIn': false, 'redFlags': []},
          ),
        ),
      ),
      coverage: ReviewCoverage(
        checkIns: ReviewCheckInCoverage(
          state: ReviewCoverageState.observed,
          coverage: ReviewCoverageLevel.partial,
          sources: const [ReviewObservedSource.manual],
          observedCount: event.coverage.checkInCount,
          windowStart: window.start,
          windowEnd: window.end,
        ),
        dailyRecords: ReviewObservedCoverage(
          state: ReviewCoverageState.observed,
          coverage: ReviewCoverageLevel.partial,
          sources: const [ReviewObservedSource.manual],
          observedCount: 1,
          windowStart: window.start,
          windowEnd: window.end,
        ),
        doseLogs: ReviewObservedCoverage(
          state: ReviewCoverageState.unknown,
          coverage: ReviewCoverageLevel.unknown,
          sources: const [],
          observedCount: 0,
          windowStart: window.start,
          windowEnd: window.end,
        ),
      ),
      sourceTimestamps: const ReviewSourceTimestamps(),
      availableActions: const [ReviewAction.checkIn, ReviewAction.endEvent],
      generatedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  ({String start, String end}) _reviewWindow(HealthEvent event) {
    final start = DateTime.parse(event.startedAt).toUtc().toIso8601String();
    final end = DateTime.now().toUtc().toIso8601String();
    return (start: start, end: end);
  }
}
