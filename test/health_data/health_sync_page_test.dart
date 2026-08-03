import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/health_data/data/providers/health_sync.dart';
import 'package:luminous/features/health_data/domain/entities/health_metric.dart';
import 'package:luminous/features/health_data/domain/entities/health_sync_result.dart';
import 'package:luminous/features/health_data/presentation/pages/health_sync.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/mocks/health_data.dart';
import '../helpers/test_forui_app.dart';

void main() {
  late FakeHealthSyncRepository repo;

  setUp(() {
    repo = FakeHealthSyncRepository();
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(800, 1600);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [healthSyncRepositoryProvider.overrideWithValue(repo)],
        child: const TestForuiApp(home: HealthSyncPage()),
      ),
    );
    await tester.pump();
  }

  AppLocalizations l10n(WidgetTester tester) {
    return AppLocalizations.of(tester.element(find.byType(HealthSyncPage)))!;
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('shows not-available message when platform is unavailable', (
    tester,
  ) async {
    repo.available = false;
    await pumpPage(tester);

    expect(find.text(l10n(tester).healthSyncNotAvailable), findsOneWidget);
    expect(find.text(l10n(tester).healthSyncFetchButton), findsNothing);
  });

  testWidgets('renders metric types, time range and fetch button initially', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text(l10n(tester).healthSyncMetricTypes), findsOneWidget);
    expect(find.text(l10n(tester).healthSyncTimeRange), findsWidgets);
    expect(find.text(l10n(tester).healthSyncFetchButton), findsOneWidget);
    expect(find.text(l10n(tester).healthSyncMetricHeartRate), findsOneWidget);
    expect(find.text(l10n(tester).healthSyncMetricSteps), findsOneWidget);
    expect(find.text(l10n(tester).healthSyncMetricSleep), findsOneWidget);
  });

  testWidgets('fetch flow: permission → fetch → import → result', (
    tester,
  ) async {
    repo.fetchResult = [
      HealthMetric(
        type: HealthMetricType.heartRate,
        value: 72,
        unit: 'bpm',
        recordedAt: DateTime(2026, 7, 12, 8, 30),
      ),
    ];
    repo.syncResult = const HealthSyncResult(
      successCount: 1,
      skippedCount: 0,
      failedCount: 0,
    );
    await pumpPage(tester);

    await tapVisible(tester, find.text(l10n(tester).healthSyncFetchButton));

    // Metrics preview + import button
    expect(find.text(l10n(tester).healthSyncPreviewTitle), findsOneWidget);
    expect(find.text(l10n(tester).healthSyncImportButton(1)), findsOneWidget);

    await tapVisible(tester, find.text(l10n(tester).healthSyncImportButton(1)));

    expect(find.text(l10n(tester).healthSyncResultTitle), findsOneWidget);
    expect(find.text(l10n(tester).healthSyncResultSuccess(1)), findsOneWidget);
    expect(find.text(l10n(tester).healthSyncResultSkipped(0)), findsOneWidget);
  });

  testWidgets('shows error banner when fetch fails', (tester) async {
    repo.fetchError = Exception('health data unavailable');
    await pumpPage(tester);

    await tapVisible(tester, find.text(l10n(tester).healthSyncFetchButton));

    expect(find.textContaining('health data unavailable'), findsOneWidget);
    // Fetch button returns after failure
    expect(find.text(l10n(tester).healthSyncFetchButton), findsOneWidget);
  });

  testWidgets('shows failed row in sync result when failures exist', (
    tester,
  ) async {
    repo.fetchResult = [
      HealthMetric(
        type: HealthMetricType.heartRate,
        value: 72,
        unit: 'bpm',
        recordedAt: DateTime(2026, 7, 12, 8, 30),
      ),
    ];
    repo.syncResult = const HealthSyncResult(
      successCount: 0,
      skippedCount: 0,
      failedCount: 1,
      errors: ['boom'],
    );
    await pumpPage(tester);

    await tapVisible(tester, find.text(l10n(tester).healthSyncFetchButton));
    await tapVisible(tester, find.text(l10n(tester).healthSyncImportButton(1)));

    expect(find.text(l10n(tester).healthSyncResultFailed(1)), findsOneWidget);
    expect(find.text(l10n(tester).healthSyncResultSuccess(0)), findsOneWidget);
  });

  testWidgets('reset button clears fetched metrics', (tester) async {
    repo.fetchResult = [
      HealthMetric(
        type: HealthMetricType.heartRate,
        value: 72,
        unit: 'bpm',
        recordedAt: DateTime(2026, 7, 12, 8, 30),
      ),
    ];
    await pumpPage(tester);

    await tapVisible(tester, find.text(l10n(tester).healthSyncFetchButton));
    expect(find.text(l10n(tester).healthSyncPreviewTitle), findsOneWidget);

    await tapVisible(tester, find.text(l10n(tester).healthSyncResetButton));

    expect(find.text(l10n(tester).healthSyncPreviewTitle), findsNothing);
    expect(find.text(l10n(tester).healthSyncFetchButton), findsOneWidget);
  });

  testWidgets('shows loading progress while syncing', (tester) async {
    repo.fetchResult = [
      HealthMetric(
        type: HealthMetricType.heartRate,
        value: 72,
        unit: 'bpm',
        recordedAt: DateTime(2026, 7, 12, 8, 30),
      ),
    ];
    // Block the sync future so the loading state stays visible
    final completer = Completer<HealthSyncResult>();
    repo.blockSync = completer.future;
    await pumpPage(tester);

    await tapVisible(tester, find.text(l10n(tester).healthSyncFetchButton));
    await tester.ensureVisible(
      find.text(l10n(tester).healthSyncImportButton(1)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n(tester).healthSyncImportButton(1)));
    await tester.pump();

    expect(find.text(l10n(tester).healthSyncSyncing), findsOneWidget);
    expect(find.byType(FProgress), findsOneWidget);

    completer.complete(
      const HealthSyncResult(successCount: 1, skippedCount: 0, failedCount: 0),
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n(tester).healthSyncResultTitle), findsOneWidget);
  });
}
