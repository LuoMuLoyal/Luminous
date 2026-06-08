import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/presentation/widgets/daily_record_form_fields.dart';
import 'package:luminous/l10n/app_localizations.dart';

void main() {
  testWidgets('DailyRecordFormFields shows water fields', (tester) async {
    await _pumpForm(tester, DailyRecordKind.water);

    expect(
      find.byType(DropdownButtonFormField<DailyRecordKind>),
      findsOneWidget,
    );
    expect(find.byKey(const Key('daily-record-value-field')), findsOneWidget);
    expect(find.byKey(const Key('daily-record-unit-field')), findsOneWidget);
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
    MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: const Locale('zh'),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
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
