import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/providers/dashboard.dart';

void main() {
  late ProviderContainer container;

  /// Builds a container with the auth session overridden to confirmed-signed-out
  /// so that `authGuarded` calls `signedOutFallback` instead of hanging.
  ProviderContainer buildSignedOutContainer() {
    final c = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(() => _SignedOutSessionNotifier()),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  group('ReviewDashboardSelectedQueryNotifier', () {
    test('initial state is last7Days range', () {
      final query = container.read(reviewDashboardSelectedQueryProvider);
      expect(query.range, ReviewDashboardRange.last7Days);
      expect(query.startDate, isNull);
      expect(query.endDate, isNull);
      expect(query.isCustom, isFalse);
    });

    test('setQuery replaces entire query', () {
      final newQuery = ReviewDashboardQuery(
        range: ReviewDashboardRange.last30Days,
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 7, 12),
      );
      container
          .read(reviewDashboardSelectedQueryProvider.notifier)
          .setQuery(newQuery);

      final query = container.read(reviewDashboardSelectedQueryProvider);
      expect(query.range, ReviewDashboardRange.last30Days);
      expect(query.startDate, DateTime(2026, 7, 1));
      expect(query.endDate, DateTime(2026, 7, 12));
    });

    test('setRange updates range and clears custom dates', () {
      // First set a custom range
      container
          .read(reviewDashboardSelectedQueryProvider.notifier)
          .setCustomRange(DateTime(2026, 6, 1), DateTime(2026, 6, 30));

      // Then switch to a preset range
      container
          .read(reviewDashboardSelectedQueryProvider.notifier)
          .setRange(ReviewDashboardRange.last7Days);

      final query = container.read(reviewDashboardSelectedQueryProvider);
      expect(query.range, ReviewDashboardRange.last7Days);
      expect(query.startDate, isNull);
      expect(query.endDate, isNull);
      expect(query.isCustom, isFalse);
    });

    test('setRange sets custom range correctly', () {
      container
          .read(reviewDashboardSelectedQueryProvider.notifier)
          .setRange(ReviewDashboardRange.custom);

      final query = container.read(reviewDashboardSelectedQueryProvider);
      expect(query.range, ReviewDashboardRange.custom);
      expect(query.isCustom, isTrue);
    });

    test('setCustomRange sets range to custom with dates', () {
      container
          .read(reviewDashboardSelectedQueryProvider.notifier)
          .setCustomRange(DateTime(2026, 6, 1), DateTime(2026, 6, 30));

      final query = container.read(reviewDashboardSelectedQueryProvider);
      expect(query.range, ReviewDashboardRange.custom);
      expect(query.startDate, DateTime(2026, 6, 1));
      expect(query.endDate, DateTime(2026, 6, 30));
      expect(query.isCustom, isTrue);
    });
  });

  group('ReviewDashboardQuery.isCustom', () {
    test('is true when range is custom', () {
      const query = ReviewDashboardQuery(range: ReviewDashboardRange.custom);
      expect(query.isCustom, isTrue);
    });

    test('is false when range is last7Days', () {
      const query = ReviewDashboardQuery(range: ReviewDashboardRange.last7Days);
      expect(query.isCustom, isFalse);
    });

    test('is false when range is last30Days', () {
      const query = ReviewDashboardQuery(
        range: ReviewDashboardRange.last30Days,
      );
      expect(query.isCustom, isFalse);
    });
  });

  group('ReviewDashboardRange', () {
    test('last7Days has correct apiValue', () {
      expect(ReviewDashboardRange.last7Days.apiValue, 'last_7_days');
    });

    test('last30Days has correct apiValue', () {
      expect(ReviewDashboardRange.last30Days.apiValue, 'last_30_days');
    });

    test('custom has correct apiValue', () {
      expect(ReviewDashboardRange.custom.apiValue, 'custom');
    });
  });

  group('reviewDashboardProvider signed-out fallback', () {
    test('returns signed-out dashboard with query range', () async {
      final sc = buildSignedOutContainer();
      await withClock(Clock.fixed(DateTime(2026, 7, 12, 10, 30)), () async {
        const query = ReviewDashboardQuery(
          range: ReviewDashboardRange.last7Days,
        );

        final result = await sc.read(reviewDashboardProvider(query).future);

        expect(result.range, ReviewDashboardRange.last7Days);
        expect(result.startDate, '2026-07-05');
        expect(result.endDate, '2026-07-12');
      });
    });

    test('signed-out fallback uses custom query dates when provided', () async {
      final sc = buildSignedOutContainer();
      final query = ReviewDashboardQuery(
        range: ReviewDashboardRange.custom,
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 30),
      );

      final result = await sc.read(reviewDashboardProvider(query).future);

      expect(result.range, ReviewDashboardRange.custom);
      expect(result.startDate, '2026-06-01');
      expect(result.endDate, '2026-06-30');
    });

    test('signed-out fallback uses last30Days range', () async {
      final sc = buildSignedOutContainer();
      await withClock(Clock.fixed(DateTime(2026, 7, 12, 10, 30)), () async {
        const query = ReviewDashboardQuery(
          range: ReviewDashboardRange.last30Days,
        );

        final result = await sc.read(reviewDashboardProvider(query).future);

        expect(result.range, ReviewDashboardRange.last30Days);
        expect(result.startDate, '2026-07-05');
        expect(result.endDate, '2026-07-12');
      });
    });
  });

  group('ReviewDashboard.signedOut', () {
    // Uses the default container — no auth override needed since we call
    // the factory directly.

    test('creates a dashboard with insufficientData status', () {
      final dashboard = ReviewDashboard.signedOut();
      expect(dashboard.range, ReviewDashboardRange.last7Days);
      expect(dashboard.startDate, '----.--.--');
      expect(dashboard.endDate, '----.--.--');
      expect(dashboard.generatedAt, '');
      expect(dashboard.metrics, isEmpty);
      expect(dashboard.trends, isEmpty);
      expect(dashboard.findings, isEmpty);
      expect(dashboard.exportActions, isEmpty);
      expect(dashboard.patterns, isEmpty);
      expect(dashboard.aiSummaryEnabled, isFalse);
    });
  });
}

/// A minimal [AuthSessionNotifier] that returns a confirmed-signed-out state
/// immediately, so `authGuarded` calls `signedOutFallback`.
class _SignedOutSessionNotifier extends AuthSessionNotifier {
  @override
  AuthSessionState build() => const AuthSessionState();
}
