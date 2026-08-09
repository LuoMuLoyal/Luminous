import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/health_event/presentation/widgets/sheets/start_event.dart';

import '../../../../helpers/test_forui_app.dart';

void main() {
  Widget buildApp({
    required Future<void> Function({
      required String shortTitle,
      String? reasonRecordId,
      required List<String> currentMedicineIds,
    })
    onSubmit,
    String? reasonRecordId,
    List<String> currentMedicineIds = const [],
    List<HealthEventAssociationOption> reasonRecordOptions = const [],
    List<HealthEventAssociationOption> currentMedicineOptions = const [],
  }) {
    return TestForuiApp(
      home: Scaffold(
        body: StartEventSheet(
          heading: '开始健康观察',
          shortTitleLabel: '简短标题',
          cancelLabel: '取消',
          submitLabel: '开始',
          submittingLabel: '提交中',
          requiredMessage: '请输入标题',
          submitErrorLabel: '提交失败，请重试',
          reasonRecordId: reasonRecordId,
          currentMedicineIds: currentMedicineIds,
          reasonRecordOptions: reasonRecordOptions,
          currentMedicineOptions: currentMedicineOptions,
          reasonRecordLabel: '触发症状',
          currentMedicineLabel: '当前用药',
          onSubmit: onSubmit,
        ),
      ),
    );
  }

  testWidgets('requires a non-empty short title before submitting', (
    tester,
  ) async {
    var submitCount = 0;
    await tester.pumpWidget(
      buildApp(
        onSubmit:
            ({
              required shortTitle,
              reasonRecordId,
              required currentMedicineIds,
            }) async {
              submitCount++;
            },
      ),
    );

    await tester.tap(find.byKey(const Key('health-event-start-submit')));
    await tester.pumpAndSettle();

    expect(submitCount, 0);
    expect(
      find.byKey(const Key('health-event-start-validation-error')),
      findsOneWidget,
    );
  });

  testWidgets('cancel closes without invoking the submit callback', (
    tester,
  ) async {
    var submitCount = 0;
    await tester.pumpWidget(
      buildApp(
        onSubmit:
            ({
              required shortTitle,
              reasonRecordId,
              required currentMedicineIds,
            }) async {
              submitCount++;
            },
      ),
    );

    await tester.tap(find.byKey(const Key('health-event-start-cancel')));
    await tester.pumpAndSettle();

    expect(submitCount, 0);
  });

  testWidgets('submits the title and optional associations', (tester) async {
    String? receivedTitle;
    String? receivedReasonRecordId;
    List<String>? receivedMedicineIds;
    await tester.pumpWidget(
      buildApp(
        reasonRecordOptions: const [
          HealthEventAssociationOption(id: 'record-7', label: '头痛'),
        ],
        currentMedicineOptions: const [
          HealthEventAssociationOption(id: 'medicine-1', label: '药物 1'),
          HealthEventAssociationOption(id: 'medicine-2', label: '药物 2'),
        ],
        onSubmit:
            ({
              required shortTitle,
              reasonRecordId,
              required currentMedicineIds,
            }) async {
              receivedTitle = shortTitle;
              receivedReasonRecordId = reasonRecordId;
              receivedMedicineIds = currentMedicineIds;
            },
      ),
    );

    await tester.enterText(
      find.byKey(const Key('health-event-start-title-field')),
      '偏头痛观察',
    );
    await tester.tap(
      find.byKey(const Key('health-event-association-record-7')),
    );
    await tester.tap(
      find.byKey(const Key('health-event-association-medicine-1')),
    );
    await tester.tap(
      find.byKey(const Key('health-event-association-medicine-2')),
    );
    await tester.tap(find.byKey(const Key('health-event-start-submit')));
    await tester.pumpAndSettle();

    expect(receivedTitle, '偏头痛观察');
    expect(receivedReasonRecordId, 'record-7');
    expect(receivedMedicineIds, ['medicine-1', 'medicine-2']);
  });

  testWidgets('keeps the title and shows a retryable error after failure', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      buildApp(
        onSubmit:
            ({
              required shortTitle,
              reasonRecordId,
              required currentMedicineIds,
            }) async {
              attempts++;
              throw StateError('network');
            },
      ),
    );

    await tester.enterText(
      find.byKey(const Key('health-event-start-title-field')),
      '需要保留的标题',
    );
    await tester.tap(find.byKey(const Key('health-event-start-submit')));
    await tester.pumpAndSettle();

    expect(attempts, 1);
    expect(find.text('需要保留的标题'), findsOneWidget);
    expect(
      find.byKey(const Key('health-event-start-submit-error')),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);
  });
}
