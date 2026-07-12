import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/report/domain/entities/dashboard.dart';
import 'package:luminous/features/report/presentation/providers/dashboard.dart';

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

  group('ReportDashboardSelectedQueryNotifier', () {
    test('initial state is last7Days range', () {
      final query = container.read(reportDashboardSelectedQueryProvider);
      expect(query.range, ReportDashboardRange.last7Days);
      expect(query.startDate, isNull);
      expect(query.endDate, isNull);
      expect(query.isCustom, isFalse);
    });

    test('setQuery replaces entire query', () {
      final newQuery = ReportDashboardQuery(
        range: ReportDashboardRange.last30Days,
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 7, 12),
      );
      container
          .read(reportDashboardSelectedQueryProvider.notifier)
          .setQuery(newQuery);

      final query = container.read(reportDashboardSelectedQueryProvider);
      expect(query.range, ReportDashboardRange.last30Days);
      expect(query.startDate, DateTime(2026, 7, 1));
      expect(query.endDate, DateTime(2026, 7, 12));
    });

    test('setRange updates range and clears custom dates', () {
      // First set a custom range
      container
          .read(reportDashboardSelectedQueryProvider.notifier)
          .setCustomRange(DateTime(2026, 6, 1), DateTime(2026, 6, 30));

      // Then switch to a preset range
      container
          .read(reportDashboardSelectedQueryProvider.notifier)
          .setRange(ReportDashboardRange.last7Days);

      final query = container.read(reportDashboardSelectedQueryProvider);
      expect(query.range, ReportDashboardRange.last7Days);
      expect(query.startDate, isNull);
      expect(query.endDate, isNull);
      expect(query.isCustom, isFalse);
    });

    test('setRange sets custom range correctly', () {
      container
          .read(reportDashboardSelectedQueryProvider.notifier)
          .setRange(ReportDashboardRange.custom);

      final query = container.read(reportDashboardSelectedQueryProvider);
      expect(query.range, ReportDashboardRange.custom);
      expect(query.isCustom, isTrue);
    });

    test('setCustomRange sets range to custom with dates', () {
      container
          .read(reportDashboardSelectedQueryProvider.notifier)
          .setCustomRange(DateTime(2026, 6, 1), DateTime(2026, 6, 30));

      final query = container.read(reportDashboardSelectedQueryProvider);
      expect(query.range, ReportDashboardRange.custom);
      expect(query.startDate, DateTime(2026, 6, 1));
      expect(query.endDate, DateTime(2026, 6, 30));
      expect(query.isCustom, isTrue);
    });
  });

  group('ReportDashboardQuery.isCustom', () {
    test('is true when range is custom', () {
      const query = ReportDashboardQuery(range: ReportDashboardRange.custom);
      expect(query.isCustom, isTrue);
    });

    test('is false when range is last7Days', () {
      const query = ReportDashboardQuery(range: ReportDashboardRange.last7Days);
      expect(query.isCustom, isFalse);
    });

    test('is false when range is last30Days', () {
      const query = ReportDashboardQuery(
        range: ReportDashboardRange.last30Days,
      );
      expect(query.isCustom, isFalse);
    });
  });

  group('ReportDashboardRange', () {
    test('last7Days has correct apiValue', () {
      expect(ReportDashboardRange.last7Days.apiValue, 'last_7_days');
    });

    test('last30Days has correct apiValue', () {
      expect(ReportDashboardRange.last30Days.apiValue, 'last_30_days');
    });

    test('custom has correct apiValue', () {
      expect(ReportDashboardRange.custom.apiValue, 'custom');
    });
  });

  group('reportDashboardProvider signed-out fallback', () {
    test('returns signed-out dashboard with query range', () async {
      final sc = buildSignedOutContainer();
      await withClock(Clock.fixed(DateTime(2026, 7, 12, 10, 30)), () async {
        const query = ReportDashboardQuery(
          range: ReportDashboardRange.last7Days,
        );

        final result = await sc.read(reportDashboardProvider(query).future);

        expect(result.range, ReportDashboardRange.last7Days);
        expect(result.startDate, '2026-07-05');
        expect(result.endDate, '2026-07-12');
      });
    });

    test('signed-out fallback uses custom query dates when provided', () async {
      final sc = buildSignedOutContainer();
      final query = ReportDashboardQuery(
        range: ReportDashboardRange.custom,
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 30),
      );

      final result = await sc.read(reportDashboardProvider(query).future);

      expect(result.range, ReportDashboardRange.custom);
      expect(result.startDate, '2026-06-01');
      expect(result.endDate, '2026-06-30');
    });

    test('signed-out fallback uses last30Days range', () async {
      final sc = buildSignedOutContainer();
      await withClock(Clock.fixed(DateTime(2026, 7, 12, 10, 30)), () async {
        const query = ReportDashboardQuery(
          range: ReportDashboardRange.last30Days,
        );

        final result = await sc.read(reportDashboardProvider(query).future);

        expect(result.range, ReportDashboardRange.last30Days);
        expect(result.startDate, '2026-07-05');
        expect(result.endDate, '2026-07-12');
      });
    });
  });

  group('ReportDashboard.signedOut', () {
    // Uses the default container — no auth override needed since we call
    // the factory directly.

    test('creates a dashboard with insufficientData status', () {
      final dashboard = ReportDashboard.signedOut();
      expect(dashboard.range, ReportDashboardRange.last7Days);
      expect(dashboard.startDate, '----.--.--');
      expect(dashboard.endDate, '----.--.--');
      expect(dashboard.generatedAt, '');
      expect(dashboard.score.value, 0);
      expect(dashboard.score.maxValue, 100);
      expect(dashboard.score.status, ReportStatus.insufficientData);
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
