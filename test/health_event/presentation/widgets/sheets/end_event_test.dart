import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/end_event.dart';

import '../../../../helpers/test_forui_app.dart';

void main() {
  Widget buildApp({
    required Future<void> Function(HealthEventOutcome outcome) onSubmit,
  }) {
    return TestForuiApp(
      home: Scaffold(
        body: EndEventSheet(
          heading: '结束健康观察',
          improvedLabel: '好转',
          unchangedLabel: '差不多',
          worsenedLabel: '加重',
          cancelLabel: '取消',
          submitLabel: '结束观察',
          submittingLabel: '提交中',
          requiredMessage: '请选择结果',
          submitErrorLabel: '提交失败，请重试',
          onSubmit: onSubmit,
        ),
      ),
    );
  }

  testWidgets('selects improved and submits that fixed outcome', (
    tester,
  ) async {
    HealthEventOutcome? received;
    await tester.pumpWidget(
      buildApp(onSubmit: (outcome) async => received = outcome),
    );

    await tester.tap(
      find.byKey(const Key('health-event-end-outcome-improved')),
    );
    await tester.tap(find.byKey(const Key('health-event-end-submit')));
    await tester.pumpAndSettle();

    expect(received, HealthEventOutcome.improved);
  });

  testWidgets('requires an outcome and cancel never invokes the callback', (
    tester,
  ) async {
    var submitCount = 0;
    await tester.pumpWidget(buildApp(onSubmit: (_) async => submitCount++));

    await tester.tap(find.byKey(const Key('health-event-end-submit')));
    await tester.pumpAndSettle();
    expect(submitCount, 0);
    expect(
      find.byKey(const Key('health-event-end-validation-error')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('health-event-end-cancel')));
    await tester.pumpAndSettle();
    expect(submitCount, 0);
  });

  testWidgets('keeps the selected outcome after a failed submission', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      buildApp(
        onSubmit: (_) async {
          attempts++;
          throw StateError('network');
        },
      ),
    );

    await tester.tap(
      find.byKey(const Key('health-event-end-outcome-worsened')),
    );
    await tester.tap(find.byKey(const Key('health-event-end-submit')));
    await tester.pumpAndSettle();

    expect(attempts, 1);
    expect(
      find.byKey(const Key('health-event-end-submit-error')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('health-event-end-submit')));
    await tester.pumpAndSettle();
    expect(attempts, 2);
  });
}
