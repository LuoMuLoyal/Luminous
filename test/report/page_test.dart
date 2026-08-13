import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_event/data/providers/health_event.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/domain/repositories/health_event.dart';
import 'package:luminous/features/report/data/providers/review.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/domain/repositories/review.dart';
import 'package:luminous/features/report/presentation/pages/page.dart';
import 'package:luminous/features/report/presentation/widgets/views/skeleton_view.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/test_forui_app.dart';
import 'widgets/review_fixtures.dart';

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

      expect(find.text(l10n.tabReport), findsOneWidget);
      expect(find.byKey(const Key('review-event-header')), findsOneWidget);
      expect(find.byKey(const Key('review-check-in-action')), findsOneWidget);
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

      // 旧 dashboard 主路径内容不再装配。
      expect(find.byKey(const Key('report-readiness-card')), findsNothing);
      expect(find.byKey(const Key('report-score-hero')), findsNothing);
      expect(find.byKey(const Key('report-export-section')), findsNothing);

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
    expect(find.byType(ReportSkeletonView), findsOneWidget);
    expect(find.byKey(const Key('review-event-header')), findsNothing);

    repo.completeCurrent(reviewActive());
    repo.completeHistory(reviewHistoryPage(const []));
    await tester.pumpAndSettle();
    expect(find.byType(ReportSkeletonView), findsNothing);
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
      expect(find.byKey(const Key('review-no-event-card')), findsOneWidget);
      expect(
        find.byKey(const Key('review-start-observation-action')),
        findsNothing,
      );
      expect(find.byKey(const Key('report-readiness-card')), findsNothing);
      expect(find.byKey(const Key('report-score-hero')), findsNothing);
    },
  );

  testWidgets(
    'Report page no-event state offers the start entry and an empty history explanation',
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

      expect(find.byKey(const Key('review-no-event-card')), findsOneWidget);
      expect(
        find.byKey(const Key('review-start-observation-action')),
        findsOneWidget,
      );
      expect(find.text(l10n.reportReviewHistoryEmpty), findsOneWidget);
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
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

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

    expect(find.text(l10n.reportReviewErrorTitle), findsOneWidget);
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

  // ── 事件交互接线（真实 ActiveHealthEvent → HealthEventRepository）──

  testWidgets('start observation entry creates an event with the title', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final healthEvents = _FakeHealthEventRepository();

    await tester.pumpWidget(
      _buildApp(
        reviewRepository: _FakeReviewRepository(
          current: null,
          page: const ReviewEventPage(items: [], total: 0),
        ),
        healthEvents: healthEvents,
        signedIn: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('review-start-observation-action')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('health-event-start-title-field')),
      '头痛观察',
    );
    await tester.tap(find.byKey(const Key('health-event-start-submit')));
    await tester.pumpAndSettle();

    expect(healthEvents.createdTitle, '头痛观察');
  });

  testWidgets('active event header check-in calls the repository checkIn', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final healthEvents = _FakeHealthEventRepository();

    await tester.pumpWidget(
      _buildApp(
        reviewRepository: _FakeReviewRepository(
          current: reviewActive(),
          page: const ReviewEventPage(items: [], total: 0),
        ),
        healthEvents: healthEvents,
        signedIn: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('review-check-in-action')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('health-event-check-in-outcome-improved')),
    );
    await tester.tap(find.byKey(const Key('health-event-check-in-submit')));
    await tester.pumpAndSettle();

    // 以当前 review 的事件 ID check-in，日期为本地 YYYY-MM-DD。
    expect(healthEvents.checkedInEventId, 'evt-active');
    expect(healthEvents.checkedInDate, matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    expect(healthEvents.checkedInOutcome, HealthEventOutcome.improved);
  });

  testWidgets('active event header end action calls the repository end', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    final healthEvents = _FakeHealthEventRepository();

    await tester.pumpWidget(
      _buildApp(
        reviewRepository: _FakeReviewRepository(
          current: reviewActive(),
          page: const ReviewEventPage(items: [], total: 0),
        ),
        healthEvents: healthEvents,
        signedIn: true,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.byKey(const Key('review-end-event-action')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('health-event-end-outcome-improved')),
    );
    await tester.tap(find.byKey(const Key('health-event-end-submit')));
    await tester.pumpAndSettle();

    expect(healthEvents.endedEventId, 'evt-active');
    expect(healthEvents.endedOutcome, HealthEventOutcome.improved);
  });
}

Widget _buildApp({
  required ReviewRepository reviewRepository,
  required bool signedIn,
  HealthEventRepository? healthEvents,
}) {
  return ProviderScope(
    overrides: [
      authSessionProvider.overrideWith(
        signedIn
            ? _SignedInAuthSessionNotifier.new
            : _SignedOutAuthSessionNotifier.new,
      ),
      reviewRepositoryProvider.overrideWithValue(reviewRepository),
      if (healthEvents != null)
        healthEventRepositoryProvider.overrideWithValue(healthEvents),
      healthContextSnapshotProvider.overrideWith(
        (ref) async => _healthContextSnapshot,
      ),
    ],
    child: const TestForuiApp(home: ReportPage()),
  );
}

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
  _FakeReviewRepository({this.current, this.page});

  EventReview? current;
  ReviewEventPage? page;

  int currentCalls = 0;
  int historyCalls = 0;

  @override
  Future<EventReview?> fetchCurrentReview() async {
    currentCalls += 1;
    return current;
  }

  @override
  Future<ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) async {
    historyCalls += 1;
    return page ?? const ReviewEventPage(items: [], total: 0);
  }

  @override
  Future<EventReview> fetchReview(String eventId) async {
    throw UnimplementedError();
  }
}

class _PendingReviewRepository implements ReviewRepository {
  final _pendingCurrent = Completer<EventReview?>();
  final _pendingHistory = Completer<ReviewEventPage>();

  int currentCalls = 0;
  int historyCalls = 0;

  @override
  Future<EventReview?> fetchCurrentReview() {
    currentCalls += 1;
    return _pendingCurrent.future;
  }

  @override
  Future<ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) {
    historyCalls += 1;
    return _pendingHistory.future;
  }

  @override
  Future<EventReview> fetchReview(String eventId) async {
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
  Future<EventReview?> fetchCurrentReview() async {
    throw Exception('Test error');
  }

  @override
  Future<ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) async {
    throw Exception('Test error');
  }

  @override
  Future<EventReview> fetchReview(String eventId) async {
    throw Exception('Test error');
  }
}

/// 记录 create/checkIn/end 调用参数的 fake，验证 page 层交互真实到达
/// HealthEventRepository（沿用 today_health_event_section_test 惯例）。
class _FakeHealthEventRepository implements HealthEventRepository {
  String? createdTitle;
  String? createdReasonRecordId;
  List<String>? createdMedicineIds;
  String? checkedInEventId;
  String? checkedInDate;
  HealthEventOutcome? checkedInOutcome;
  String? endedEventId;
  HealthEventOutcome? endedOutcome;

  @override
  Future<HealthEvent?> fetchActive() async => null;

  @override
  Future<HealthEvent?> fetchById(String eventId) async => null;

  @override
  Future<List<HealthEvent>> fetchHistory() async => const [];

  @override
  Future<HealthEvent> create({
    required String title,
    String? reasonRecordId,
    List<String> currentMedicineIds = const [],
  }) async {
    createdTitle = title;
    createdReasonRecordId = reasonRecordId;
    createdMedicineIds = currentMedicineIds;
    return _createdEvent(title);
  }

  @override
  Future<HealthEvent> checkIn({
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
  }) async {
    checkedInEventId = eventId;
    checkedInDate = date;
    checkedInOutcome = outcome;
    return _createdEvent('感冒观察');
  }

  @override
  Future<HealthEvent> end({
    required String eventId,
    required HealthEventOutcome outcome,
  }) async {
    endedEventId = eventId;
    endedOutcome = outcome;
    return _createdEvent('感冒观察');
  }

  HealthEvent _createdEvent(String title) {
    return HealthEvent(
      id: 'event-1',
      title: title,
      status: HealthEventStatus.active,
      startedAt: '2026-08-13T00:00:00.000Z',
      currentMedicineIds: const [],
      coverage: const HealthEventCoverage(checkInCount: 0),
    );
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
