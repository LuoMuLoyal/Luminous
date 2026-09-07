import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/sections/coverage_strip.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  Future<void> pumpStrip(
    WidgetTester tester, {
    required List<ReviewMetric> metrics,
    ValueChanged<ReviewDataKind>? onTap,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      TestForuiApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ReviewCoverageStrip(metrics: metrics, onTap: onTap),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  ReviewMetric metric({
    ReviewDataKind kind = ReviewDataKind.water,
    String function = '1.2',
    String unit = 'L',
    String delta = '-12%',
    ReviewMetricDirection direction = ReviewMetricDirection.down,
    ReviewObservedMetric? observed,
  }) {
    return ReviewMetric(
      kind: kind,
      icon: SemanticIcons.recordWater,
      color: SemanticColor.primary,
      value: function,
      unit: unit,
      status: ReviewStatus.stable,
      delta: delta,
      direction: direction,
      sparkline: const [],
      observedMetric: observed,
    );
  }

  const sufficientObserved = ReviewObservedMetric(
    value: 1.2,
    state: ReviewObservedMetricState.observed,
    coverage: ReviewObservedMetricCoverage.sufficient,
    sources: [ReviewObservedMetricSource.manual],
    observedCount: 4,
    expectedCount: 7,
    windowStart: '',
    windowEnd: '',
  );

  testWidgets('empty metrics render nothing', (tester) async {
    await pumpStrip(tester, metrics: []);
    expect(find.byType(ReviewCoverageStrip), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders coverage card with days count and delta', (
    tester,
  ) async {
    await pumpStrip(tester, metrics: [metric(observed: sufficientObserved)]);

    expect(find.text('饮水'), findsOneWidget);
    expect(find.text('4 / 7 天'), findsOneWidget);
    expect(find.text('1.2L'), findsOneWidget);
    expect(find.text('-12%'), findsOneWidget);
  });

  testWidgets('sparse metric shows sparse label and -- value', (tester) async {
    await pumpStrip(
      tester,
      metrics: [
        metric(
          observed: const ReviewObservedMetric(
            value: null,
            state: ReviewObservedMetricState.unknown,
            coverage: ReviewObservedMetricCoverage.none,
            sources: [],
            observedCount: 0,
            expectedCount: 7,
            windowStart: '',
            windowEnd: '',
          ),
        ),
      ],
    );

    expect(find.text('数据太少'), findsOneWidget);
    expect(find.text('--'), findsOneWidget);
  });

  testWidgets('tapping a card calls onTap with its kind', (tester) async {
    ReviewDataKind? tapped;
    await pumpStrip(
      tester,
      metrics: [metric(observed: sufficientObserved)],
      onTap: (kind) => tapped = kind,
    );

    await tester.tap(find.text('饮水'));
    await tester.pumpAndSettle();

    expect(tapped, ReviewDataKind.water);
  });
}
