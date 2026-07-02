import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/presentation/widgets/forms/daily_record_form_fields.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../helpers/test_forui_app.dart';

void main() {
  testWidgets('DailyRecordFormFields shows water fields', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await _pumpForm(tester, DailyRecordKind.water);

    expect(
      find.byType(DropdownButtonFormField<DailyRecordKind>),
      findsOneWidget,
    );
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.byKey(const Key('daily-record-value-field')), findsOneWidget);
    expect(find.byKey(const Key('daily-record-unit-field')), findsOneWidget);
    expect(find.text(l10n.recordWaterUnitMl), findsOneWidget);
    await tester.tap(find.byKey(const Key('daily-record-unit-field')));
    await tester.pumpAndSettle();
    expect(find.text(l10n.recordWaterUnitCup).last, findsOneWidget);
    expect(find.text(l10n.recordWaterUnitTimes).last, findsOneWidget);
    expect(find.byKey(const Key('daily-record-title-field')), findsNothing);
    expect(find.byKey(const Key('daily-record-note-field')), findsOneWidget);
  });

  testWidgets('DailyRecordFormFields shows vital fields', (tester) async {
    await _pumpForm(tester, DailyRecordKind.vital);

    expect(
      find.byType(DropdownButtonFormField<DailyRecordKind>),
      findsOneWidget,
    );
    expect(find.byKey(const Key('daily-record-value-field')), findsOneWidget);
    expect(find.byKey(const Key('daily-record-unit-field')), findsOneWidget);
    expect(find.byKey(const Key('daily-record-title-field')), findsOneWidget);
    expect(find.byKey(const Key('daily-record-note-field')), findsOneWidget);
  });

  testWidgets('DailyRecordFormFields shows symptom fields', (tester) async {
    final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

    await _pumpForm(tester, DailyRecordKind.symptom);

    expect(
      find.byType(DropdownButtonFormField<DailyRecordKind>),
      findsOneWidget,
    );
    expect(find.byKey(const Key('daily-record-value-field')), findsOneWidget);
    expect(find.text(l10n.recordCreateValueSymptom), findsOneWidget);
    expect(find.byKey(const Key('daily-record-unit-field')), findsNothing);
    expect(find.byKey(const Key('daily-record-title-field')), findsOneWidget);
    expect(find.byKey(const Key('daily-record-note-field')), findsOneWidget);
  });

  testWidgets('DailyRecordFormFields shows note fields', (tester) async {
    await _pumpForm(tester, DailyRecordKind.note);

    expect(
      find.byType(DropdownButtonFormField<DailyRecordKind>),
      findsOneWidget,
    );
    expect(find.byKey(const Key('daily-record-value-field')), findsNothing);
    expect(find.byKey(const Key('daily-record-unit-field')), findsNothing);
    expect(find.byKey(const Key('daily-record-title-field')), findsOneWidget);
    expect(find.byKey(const Key('daily-record-note-field')), findsOneWidget);
  });
}

Future<void> _pumpForm(WidgetTester tester, DailyRecordKind kind) async {
  await tester.pumpWidget(
    TestForuiApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: DailyRecordFormFields(
            kind: kind,
            onKindChanged: (_) {},
            valueController: TextEditingController(),
            unitController: TextEditingController(),
            titleController: TextEditingController(),
            noteController: TextEditingController(),
          ),
        ),
      ),
    ),
  );
}
