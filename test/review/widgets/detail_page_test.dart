import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/analytics/product_event_service.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_mapper.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/review/data/providers/review.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/domain/repositories/review.dart';
import 'package:luminous/features/review/presentation/pages/detail.dart';
import 'package:luminous/features/review/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_forui_app.dart';
import 'review_fixtures.dart';

/// `/report/review/:eventId` 详情页：loading / error / data 三态 + 复用事件
/// 头部与四段 + review_opened 埋点。
void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('zh'));
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    required ReviewRepository repository,
    ProductEventService? productEvents,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        // 关闭 riverpod 3 的默认指数退避重试，让失败立即以 AsyncError 暴露；
        // 生产代码的重试语义由页面 ref.invalidate 驱动。
        retry: (count, error) => null,
        overrides: [
          authSessionProvider.overrideWith(_SignedInAuthSessionNotifier.new),
          reviewRepositoryProvider.overrideWithValue(repository),
          if (productEvents != null)
            productEventServiceProvider.overrideWithValue(productEvents),
        ],
        child: const TestForuiApp(home: ReviewDetailPage(eventId: 'evt-1')),
      ),
    );
  }

  group('ReviewDetailPage', () {
    testWidgets('loading state renders the skeleton without content', (
      tester,
    ) async {
      final repo = _PendingDetailRepository();
      await pumpPage(tester, repository: repo);

      await tester.pump();

      expect(find.byType(ReviewSkeletonView), findsOneWidget);
      expect(find.byKey(const Key('review-event-header')), findsNothing);

      // 数据到达后切换到内容。
      repo.complete(reviewActive());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('review-event-header')), findsOneWidget);
      expect(find.byType(ReviewSkeletonView), findsNothing);
    });

    testWidgets('error state shows the error view and retries via invalidate', (
      tester,
    ) async {
      final repo = _FlakyDetailRepository();
      await pumpPage(tester, repository: repo);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text(l10n.reviewReviewErrorTitle), findsOneWidget);
      expect(find.byKey(const Key('review-event-header')), findsNothing);

      // 重试：invalidate 重新拉取，第二次成功渲染内容。
      await tester.tap(find.text(l10n.todayRetryAction));
      await tester.pumpAndSettle();

      expect(repo.detailCalls, 2);
      expect(find.byKey(const Key('review-event-header')), findsOneWidget);
      expect(find.text(l10n.reviewReviewErrorTitle), findsNothing);
    });

    testWidgets(
      'data state reuses the event header and the four sections, read-only',
      (tester) async {
        await pumpPage(
          tester,
          repository: _DetailReviewRepository(reviewActive()),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text(l10n.reviewReviewDetailTitle), findsOneWidget);
        expect(find.byKey(const Key('review-event-header')), findsOneWidget);
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
        expect(
          find.byKey(const Key('review-next-step-section')),
          findsOneWidget,
        );
        // 详情页只读：不提供今日 check-in 与结束入口。
        expect(find.byKey(const Key('review-check-in-action')), findsNothing);
        expect(find.byKey(const Key('review-end-event-action')), findsNothing);
        // 历史区不属于详情页。
        expect(find.byKey(const Key('review-history-section')), findsNothing);
      },
    );

    testWidgets('records review_opened once when the detail is presented', (
      tester,
    ) async {
      final service = _RecordingProductEventService();
      await pumpPage(
        tester,
        repository: _DetailReviewRepository(reviewActive()),
        productEvents: service,
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('review-event-header')), findsOneWidget);
      expect(service.reviewOpenedCalls, 1);
    });

    testWidgets('does not record review_opened while loading or on error', (
      tester,
    ) async {
      final service = _RecordingProductEventService();
      final repo = _FlakyDetailRepository();
      await pumpPage(tester, repository: repo, productEvents: service);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text(l10n.reviewReviewErrorTitle), findsOneWidget);
      expect(service.reviewOpenedCalls, 0);
    });
  });
}

/// 立即返回固定详情的 fake。
class _DetailReviewRepository implements ReviewRepository {
  _DetailReviewRepository(this.detail);

  final EventReview detail;
  int detailCalls = 0;

  @override
  TaskEither<LucentFailure, EventReview?> fetchCurrentReview() =>
      TaskEither.right(null);

  @override
  TaskEither<LucentFailure, ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) => TaskEither.right(const ReviewEventPage(items: [], total: 0));

  @override
  TaskEither<LucentFailure, EventReview> fetchReview(String eventId) {
    detailCalls += 1;
    return TaskEither.right(detail);
  }
}

/// 详情请求挂起直至 complete() 的 fake（loading 态）。
class _PendingDetailRepository implements ReviewRepository {
  final _pending = Completer<EventReview>();
  int detailCalls = 0;

  @override
  TaskEither<LucentFailure, EventReview?> fetchCurrentReview() =>
      TaskEither.right(null);

  @override
  TaskEither<LucentFailure, ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) => TaskEither.right(const ReviewEventPage(items: [], total: 0));

  @override
  TaskEither<LucentFailure, EventReview> fetchReview(String eventId) {
    detailCalls += 1;
    return TaskEither.tryCatch(
      () => _pending.future,
      (error, stackTrace) => LucentErrorMapper.fromObject(error),
    );
  }

  void complete(EventReview review) => _pending.complete(review);
}

/// 首次失败、之后成功的 fake（error → retry 路径）。
class _FlakyDetailRepository implements ReviewRepository {
  int detailCalls = 0;

  @override
  TaskEither<LucentFailure, EventReview?> fetchCurrentReview() =>
      TaskEither.right(null);

  @override
  TaskEither<LucentFailure, ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) => TaskEither.right(const ReviewEventPage(items: [], total: 0));

  @override
  TaskEither<LucentFailure, EventReview> fetchReview(String eventId) {
    detailCalls += 1;
    if (detailCalls == 1) {
      return TaskEither.left(LucentFailure.unknown(message: 'Test error'));
    }
    return TaskEither.right(reviewActive());
  }
}

/// 记录 review_opened 调用次数而非上报事件。
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
