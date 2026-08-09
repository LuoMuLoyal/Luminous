import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/check_in.dart';

import '../../../../helpers/test_forui_app.dart';

void main() {
  Widget buildApp({
    required Future<void> Function(HealthEventOutcome outcome) onSubmit,
  }) {
    return TestForuiApp(
      home: Scaffold(
        body: CheckInSheet(
          heading: '今天感觉如何？',
          improvedLabel: '好转',
          unchangedLabel: '差不多',
          worsenedLabel: '加重',
          cancelLabel: '取消',
          submitLabel: '确认',
          submittingLabel: '提交中',
          requiredMessage: '请选择结果',
          submitErrorLabel: '提交失败，请重试',
          onSubmit: onSubmit,
        ),
      ),
    );
  }

  testWidgets('requires one fixed outcome before submitting', (tester) async {
    HealthEventOutcome? received;
    await tester.pumpWidget(
      buildApp(onSubmit: (outcome) async => received = outcome),
    );

    await tester.tap(find.byKey(const Key('health-event-check-in-submit')));
    await tester.pumpAndSettle();

    expect(received, isNull);
    expect(
      find.byKey(const Key('health-event-check-in-validation-error')),
      findsOneWidget,
    );
  });

  testWidgets('selects a fixed outcome and passes it to the callback', (
    tester,
  ) async {
    HealthEventOutcome? received;
    await tester.pumpWidget(
      buildApp(onSubmit: (outcome) async => received = outcome),
    );

    await tester.tap(
      find.byKey(const Key('health-event-check-in-outcome-worsened')),
    );
    await tester.tap(find.byKey(const Key('health-event-check-in-submit')));
    await tester.pumpAndSettle();

    expect(received, HealthEventOutcome.worsened);
  });

  testWidgets('cancel closes without invoking the callback', (tester) async {
    var submitCount = 0;
    await tester.pumpWidget(buildApp(onSubmit: (_) async => submitCount++));

    await tester.tap(find.byKey(const Key('health-event-check-in-cancel')));
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
      find.byKey(const Key('health-event-check-in-outcome-improved')),
    );
    await tester.tap(find.byKey(const Key('health-event-check-in-submit')));
    await tester.pumpAndSettle();

    expect(attempts, 1);
    expect(
      find.byKey(const Key('health-event-check-in-submit-error')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('health-event-check-in-submit')));
    await tester.pumpAndSettle();
    expect(attempts, 2);
  });
}
