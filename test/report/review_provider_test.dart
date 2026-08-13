import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/report/data/providers/review.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/domain/repositories/review.dart';
import 'package:luminous/features/report/presentation/providers/review.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('reviewCurrentProvider', () {
    test(
      'loads the current review and caches it as the last success',
      () async {
        final review = _testReview(eventId: 'evt-1');
        final repo = _FakeReviewRepository(current: review);
        final container = _container(repo);
        addTearDown(container.dispose);

        final value = await container.read(reviewCurrentProvider.future);

        expect(value, same(review));
        expect(repo.currentCalls, 1);
        expect(container.read(reviewLastCurrentProvider), same(review));
      },
    );

    test('completes with null when the user has no events', () async {
      final repo = _FakeReviewRepository(current: null);
      final container = _container(repo);
      addTearDown(container.dispose);

      final value = await container.read(reviewCurrentProvider.future);

      expect(value, isNull);
      expect(repo.currentCalls, 1);
      expect(container.read(reviewLastCurrentProvider), isNull);
    });

    test('keeps the last success on failure and recovers on retry', () async {
      final firstReview = _testReview(eventId: 'evt-1');
      final repo = _FakeReviewRepository(current: firstReview);
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(reviewCurrentProvider.future);
      // 页面从首帧就同时 watch 缓存，这里先激活 lastCurrent 监听。
      expect(container.read(reviewLastCurrentProvider), same(firstReview));

      // 下一次刷新失败：AsyncError，但最后成功数据保留。
      repo.error = DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/user/reports/reviews/current',
        ),
        type: DioExceptionType.connectionTimeout,
      );
      container.invalidate(reviewCurrentProvider);
      await expectLater(
        container.read(reviewCurrentProvider.future),
        throwsA(isA<DioException>()),
      );
      expect(container.read(reviewLastCurrentProvider), same(firstReview));

      // retry 成功后更新缓存。
      final secondReview = _testReview(eventId: 'evt-2');
      repo.error = null;
      repo.current = secondReview;
      container.invalidate(reviewCurrentProvider);
      final retried = await container.read(reviewCurrentProvider.future);

      expect(retried, same(secondReview));
      expect(container.read(reviewLastCurrentProvider), same(secondReview));
    });

    test('refetches current when health events change', () async {
      final repo = _FakeReviewRepository(
        current: _testReview(eventId: 'evt-1'),
      );
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(reviewCurrentProvider.future);
      expect(repo.currentCalls, 1);

      container
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.healthEvents);
      // riverpod 调度器在事件循环末尾执行刷新，等几拍让依赖链重建完成。
      await _pumpEventQueue();
      final value = await container.read(reviewCurrentProvider.future);

      expect(value, isNotNull);
      expect(repo.currentCalls, 2);
    });

    test('clears the cached review when the user signs out', () async {
      // riverpod 3 的 updateOverrides 对 Notifier override 是 no-op，
      // 用可翻转状态的会话 Notifier 模拟登出。
      final auth = _SwitchableAuthSessionNotifier(
        AuthUser(
          id: 'user-1',
          email: 'test@example.com',
          nickname: 'Lumi',
          avatar: null,
          emailVerifiedAt: DateTime(2026, 1, 1),
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );
      final repo = _FakeReviewRepository(
        current: _testReview(eventId: 'evt-1'),
      );
      final container = ProviderContainer(
        retry: (count, error) => null,
        overrides: [
          authSessionProvider.overrideWith(() => auth),
          reviewRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(reviewCurrentProvider.future);
      expect(container.read(reviewLastCurrentProvider), isNotNull);

      // 登出：current 走 fallback，缓存必须清空。
      auth.signOut();
      await _pumpEventQueue();
      final value = await container.read(reviewCurrentProvider.future);

      expect(value, isNull);
      // 登出后缓存清空，不向新会话泄漏上一用户的 review。
      expect(container.read(reviewLastCurrentProvider), isNull);
      expect(repo.currentCalls, 1);
    });

    test(
      'returns null without calling the repository when signed out',
      () async {
        final repo = _FakeReviewRepository(
          current: _testReview(eventId: 'evt-1'),
        );
        final container = ProviderContainer(
          retry: (count, error) => null,
          overrides: [
            authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
            reviewRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        final value = await container.read(reviewCurrentProvider.future);

        expect(value, isNull);
        expect(repo.currentCalls, 0);
      },
    );
  });

  group('reviewHistoryProvider', () {
    test('loads and caches the recent history page', () async {
      final page = ReviewEventPage(
        items: [
          _testEvent(id: 'evt-2'),
          _testEvent(id: 'evt-1'),
        ],
        total: 2,
        nextCursor: null,
      );
      final repo = _FakeReviewRepository(page: page);
      final container = _container(repo);
      addTearDown(container.dispose);

      final value = await container.read(reviewHistoryProvider.future);

      expect(value.items, hasLength(2));
      expect(value.items.first.id, 'evt-2');
      // keepAlive 缓存：再次读取不重新请求。
      await container.read(reviewHistoryProvider.future);
      expect(repo.historyCalls, 1);
    });

    test('requests all events with a null status by default', () async {
      final repo = _FakeReviewRepository(
        page: const ReviewEventPage(items: [], total: 0),
      );
      final container = _container(repo);
      addTearDown(container.dispose);

      await container.read(reviewHistoryProvider.future);

      expect(repo.lastHistoryStatus, isNull);
    });

    test(
      'refetches with the selected status when the filter changes',
      () async {
        final repo = _FakeReviewRepository(
          page: const ReviewEventPage(items: [], total: 0),
        );
        final container = _container(repo);
        addTearDown(container.dispose);

        await container.read(reviewHistoryProvider.future);
        expect(repo.historyCalls, 1);

        container
            .read(reviewHistoryStatusProvider.notifier)
            .select(ReviewEventStatus.active);
        await _pumpEventQueue();
        await container.read(reviewHistoryProvider.future);

        expect(repo.historyCalls, 2);
        expect(repo.lastHistoryStatus, ReviewEventStatus.active);

        container
            .read(reviewHistoryStatusProvider.notifier)
            .select(ReviewEventStatus.ended);
        await _pumpEventQueue();
        await container.read(reviewHistoryProvider.future);

        expect(repo.historyCalls, 3);
        expect(repo.lastHistoryStatus, ReviewEventStatus.ended);
      },
    );

    test('returns an empty page when signed out', () async {
      final repo = _FakeReviewRepository();
      final container = ProviderContainer(
        retry: (count, error) => null,
        overrides: [
          authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
          reviewRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final value = await container.read(reviewHistoryProvider.future);

      expect(value.items, isEmpty);
      expect(value.total, 0);
      expect(repo.historyCalls, 0);
    });
  });

  group('reviewDetailProvider', () {
    test(
      'switching event id drops the previous result and refetches',
      () async {
        final reviewA = _testReview(eventId: 'evt-a');
        final reviewB = _testReview(eventId: 'evt-b');
        final repo = _FakeReviewRepository();
        final container = _container(repo);
        addTearDown(container.dispose);

        repo.detail = reviewA;
        final a = await container.read(reviewDetailProvider('evt-a').future);
        expect(a.event.id, 'evt-a');
        expect(repo.lastDetailEventId, 'evt-a');

        // 切换 event ID：新实例独立请求，不带入旧数据。
        repo.detail = reviewB;
        final b = await container.read(reviewDetailProvider('evt-b').future);
        expect(b.event.id, 'evt-b');
        expect(repo.lastDetailEventId, 'evt-b');
        expect(b, isNot(same(a)));
      },
    );

    test('throws AuthRequiredException when signed out', () async {
      final repo = _FakeReviewRepository(detail: _testReview(eventId: 'evt-1'));
      final container = ProviderContainer(
        retry: (count, error) => null,
        overrides: [
          authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
          reviewRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(reviewDetailProvider('evt-1').future),
        throwsA(isA<AuthRequiredException>()),
      );
      expect(repo.detailCalls, 0);
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// 让 riverpod 调度器（`Timer(Duration.zero)` 的刷新任务）跑完依赖链重建。
Future<void> _pumpEventQueue() async {
  for (var i = 0; i < 5; i += 1) {
    await Future<void>.delayed(Duration.zero);
  }
}

ProviderContainer _container(ReviewRepository repo) {
  // 关闭 riverpod 3 的默认指数退避重试，让失败立即以 AsyncError 暴露；
  // 生产代码的重试语义由 UI 层 ref.invalidate 驱动。
  return ProviderContainer(
    retry: (count, error) => null,
    overrides: [
      authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
      reviewRepositoryProvider.overrideWithValue(repo),
    ],
  );
}

ReviewEvent _testEvent({required String id}) {
  return ReviewEvent(
    id: id,
    kind: ReviewEventKind.symptom,
    title: '事件 $id',
    status: ReviewEventStatus.ended,
    startedAt: '2026-08-01T00:00:00.000Z',
    endedAt: '2026-08-10T00:00:00.000Z',
    outcome: ReviewEventOutcome.improved,
    currentMedicineIds: const [],
  );
}

EventReview _testReview({required String eventId}) {
  return EventReview(
    event: ReviewEvent(
      id: eventId,
      kind: ReviewEventKind.symptom,
      title: '事件 $eventId',
      status: ReviewEventStatus.active,
      startedAt: '2026-08-01T00:00:00.000Z',
      endedAt: null,
      outcome: null,
      currentMedicineIds: const ['med-1'],
    ),
    sections: const ReviewSections(
      whatHappened: ReviewSection(
        state: ReviewSectionState.available,
        facts: ReviewSectionFacts(
          code: 'fact.observed',
          arguments: {'count': 3},
        ),
      ),
      keyChanges: ReviewSection(
        state: ReviewSectionState.unknown,
        reasonCode: ReviewSectionReasonCodes.noObservations,
      ),
      completedActions: ReviewSection(
        state: ReviewSectionState.available,
        facts: ReviewSectionFacts(code: 'fact.doses', arguments: {'done': 6}),
      ),
      nextStep: ReviewSection(
        state: ReviewSectionState.unknown,
        reasonCode: ReviewSectionReasonCodes.insufficientCoverage,
      ),
    ),
    coverage: const ReviewCoverage(
      checkIns: ReviewCheckInCoverage(
        state: ReviewCoverageState.observed,
        coverage: ReviewCoverageLevel.sufficient,
        sources: [ReviewObservedSource.manual],
        observedCount: 3,
        windowStart: '2026-08-01T00:00:00.000Z',
        windowEnd: '2026-08-13T00:00:00.000Z',
      ),
      dailyRecords: ReviewObservedCoverage(
        state: ReviewCoverageState.observed,
        coverage: ReviewCoverageLevel.partial,
        sources: [ReviewObservedSource.derived],
        observedCount: 2,
        expectedCount: 7,
        windowStart: '2026-08-01T00:00:00.000Z',
        windowEnd: '2026-08-13T00:00:00.000Z',
      ),
      doseLogs: ReviewObservedCoverage(
        state: ReviewCoverageState.unknown,
        coverage: ReviewCoverageLevel.none,
        sources: [],
        observedCount: 0,
        windowStart: '2026-08-01T00:00:00.000Z',
        windowEnd: '2026-08-13T00:00:00.000Z',
      ),
    ),
    sourceTimestamps: const ReviewSourceTimestamps(
      checkIns: '2026-08-12',
      dailyRecords: null,
      doseLogs: null,
    ),
    availableActions: const [ReviewAction.checkIn, ReviewAction.export],
    generatedAt: '2026-08-13T10:00:00.000Z',
  );
}

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

/// 可翻转登录状态的会话 Notifier：模拟登出/切账户时
/// [AuthSessionState] 状态变化驱动的 provider 重建。
class _SwitchableAuthSessionNotifier extends AuthSessionNotifier {
  _SwitchableAuthSessionNotifier(this.user);

  final AuthUser? user;

  @override
  AuthSessionState build() => _stateFor(user);

  void signOut() {
    state = _stateFor(null);
  }

  AuthSessionState _stateFor(AuthUser? value) {
    return value == null
        ? const AuthSessionState(isAuthenticated: false, isLoading: false)
        : AuthSessionState(
            isAuthenticated: true,
            isLoading: false,
            user: value,
          );
  }
}

class _FakeReviewRepository implements ReviewRepository {
  _FakeReviewRepository({this.current, this.page, this.detail});

  EventReview? current;
  ReviewEventPage? page;
  EventReview? detail;
  Object? error;

  int currentCalls = 0;
  int historyCalls = 0;
  int detailCalls = 0;
  String? lastDetailEventId;
  ReviewEventStatus? lastHistoryStatus;

  @override
  Future<EventReview?> fetchCurrentReview() async {
    currentCalls += 1;
    if (error != null) {
      // ignore: only_throw_errors
      throw error!;
    }
    return current;
  }

  @override
  Future<ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) async {
    historyCalls += 1;
    lastHistoryStatus = status;
    if (error != null) {
      // ignore: only_throw_errors
      throw error!;
    }
    return page!;
  }

  @override
  Future<EventReview> fetchReview(String eventId) async {
    detailCalls += 1;
    lastDetailEventId = eventId;
    if (error != null) {
      // ignore: only_throw_errors
      throw error!;
    }
    return detail!;
  }
}
