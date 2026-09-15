import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/controllers/meal_analysis_poller.dart';

import '../../../helpers/test_forui_app.dart';

void main() {
  /// Reads the poller out of a host widget so the test can drive [sync].
  Future<MealAnalysisPoller> pumpPoller(
    WidgetTester tester,
    ProviderContainer container,
  ) async {
    MealAnalysisPoller? poller;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestForuiApp(
          home: Consumer(
            builder: (context, ref, _) {
              poller ??= MealAnalysisPoller(recordId: 'meal-1', ref: ref);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    return poller!;
  }

  testWidgets('polls while analyzing and stops once the analysis settles', (
    tester,
  ) async {
    var loads = 0;
    final container = ProviderContainer(
      overrides: [
        dailyRecordDetailProvider('meal-1').overrideWith((ref) async {
          loads += 1;
          return _analyzingRecord();
        }),
      ],
    );
    addTearDown(container.dispose);

    // Initial load (the detail page reads the provider before the poller runs).
    await container.read(dailyRecordDetailProvider('meal-1').future);
    expect(loads, 1);

    final poller = await pumpPoller(tester, container);

    poller.sync(true);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(loads, 2, reason: '分析中时按初始间隔刷新详情');

    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(loads, 3, reason: '成功后回到初始间隔继续轮询');

    // Analysis finished: the next build stops the poller.
    poller.sync(false);
    await tester.pump(const Duration(seconds: 30));
    expect(loads, 3, reason: '不再是分析中时不再刷新');

    poller.dispose();
  });

  testWidgets('backs off on failures up to the maximum interval', (
    tester,
  ) async {
    var loads = 0;
    final container = ProviderContainer(
      overrides: [
        dailyRecordDetailProvider('meal-1').overrideWith((ref) async {
          loads += 1;
          throw StateError('detail fetch failed');
        }),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(dailyRecordDetailProvider('meal-1').future),
      throwsA(isA<StateError>()),
    );
    expect(loads, 1);

    final poller = await pumpPoller(tester, container);
    poller.sync(true);

    // Failure doubles the interval: 5s → 10s → 20s → 30s (capped).
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    expect(loads, 2);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump();
    expect(loads, 3);

    // The 20s step already exceeded the old schedule, so nothing fired yet.
    await tester.pump(const Duration(seconds: 19));
    expect(loads, 3);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(loads, 4);

    // Backed off to the 30s cap.
    await tester.pump(const Duration(seconds: 30));
    await tester.pump();
    expect(loads, 5);

    poller.sync(false);
    poller.dispose();
  });

  testWidgets('a disposed poller stops refreshing', (tester) async {
    var loads = 0;
    final container = ProviderContainer(
      overrides: [
        dailyRecordDetailProvider('meal-1').overrideWith((ref) async {
          loads += 1;
          return _analyzingRecord();
        }),
      ],
    );
    addTearDown(container.dispose);

    await container.read(dailyRecordDetailProvider('meal-1').future);
    final poller = await pumpPoller(tester, container);

    poller.sync(true);
    poller.dispose();
    await tester.pump(const Duration(seconds: 30));
    expect(loads, 1);
  });
}

DailyRecordItem _analyzingRecord() {
  return const DailyRecordItem(
    id: 'meal-1',
    kind: DailyRecordKind.meal,
    occurredAt: '2026-09-15',
    occurredTime: '12:30',
    createdAt: '2026-09-15T12:30:00Z',
    updatedAt: '2026-09-15T12:30:00Z',
  );
}
