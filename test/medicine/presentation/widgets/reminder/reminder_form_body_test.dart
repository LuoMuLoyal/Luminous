import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/presentation/providers/reminders.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/reminder_form_body.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../../helpers/test_forui_app.dart';

HealthContextSnapshot _buildSnapshot({List<CurrentMedicineItem>? medicines}) {
  return HealthContextSnapshot(
    summary: const HealthSummary(
      age: 30,
      onboardingCompleted: true,
      activeAllergyCount: 0,
      conditionCount: 0,
      currentMedicineCount: 1,
      missingCoreProfileFields: [],
    ),
    profile: const HealthProfile(
      birthDate: '1996-01-01',
      sexAtBirth: 'female',
      heightCm: 165.0,
      bloodType: 'A+',
      locale: 'zh-CN',
      timezone: 'Asia/Shanghai',
      unitSystem: 'metric',
      onboardingCompletedAt: '2026-07-11T08:00:00.000Z',
      extras: {},
    ),
    allergies: [],
    conditions: [],
    currentMedicines:
        medicines ??
        [
          const CurrentMedicineItem(
            id: 'med-1',
            source: 'cn',
            sourceRefId: 'ref-1',
            displayName: 'Aspirin',
            strengthText: '100mg',
            doseText: '1 tablet',
            route: 'oral',
            startedAt: '2026-07-01',
            endedAt: null,
            isCurrent: true,
            note: null,
            createdAt: '2026-07-11T08:00:00.000Z',
            updatedAt: '2026-07-11T08:00:00.000Z',
          ),
        ],
  );
}

Widget _buildForm({
  required HealthContextSnapshot snapshot,
  String? selectedMedicineId,
  bool isEdit = true,
  bool isSaving = false,
  ReminderFrequency frequency = ReminderFrequency.daily,
  Set<int> selectedWeekdays = const {},
  List<MedicineReminderTimeInput> times = const [],
  DateTime? startDate,
  DateTime? endDate,
  bool isActive = true,
  MedicineReminderSoundPreference soundPreference =
      MedicineReminderSoundPreference.defaultTone,
  VoidCallback? onDelete,
  VoidCallback? onSave,
}) {
  return ReminderFormBody(
    snapshot: snapshot,
    reminders: [],
    selectedMedicineId: selectedMedicineId ?? 'med-1',
    frequency: frequency,
    selectedWeekdays: selectedWeekdays,
    times: times,
    startDate: startDate,
    endDate: endDate,
    isActive: isActive,
    soundPreference: soundPreference,
    noteController: TextEditingController(),
    isSaving: isSaving,
    isEdit: isEdit,
    onMedicineChanged: (_) {},
    onFrequencyChanged: (_) {},
    onWeekdayToggled: (_) {},
    onAddTime: () {},
    onRemoveTime: (_) {},
    onStartDateTap: () {},
    onEndDateTap: () {},
    onClearEndDate: null,
    onActiveChanged: (_) {},
    onSoundChanged: (_) {},
    onSave: onSave ?? () {},
    onDelete: onDelete,
  );
}

Future<void> _pumpForm(WidgetTester tester, Widget form) async {
  await tester.pumpWidget(
    TestForuiRouterApp(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: SizedBox(
                  width: 400,
                  child: SingleChildScrollView(child: form),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/medicine/search',
            builder: (context, state) => const Scaffold(body: SizedBox()),
          ),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ReminderFormBody', () {
    testWidgets('shows error view when no current medicines', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await _pumpForm(
        tester,
        _buildForm(snapshot: _buildSnapshot(medicines: [])),
      );

      expect(find.text(l10n.medicineNoMedicineTitle), findsOneWidget);
    });

    testWidgets('renders save button', (tester) async {
      await _pumpForm(tester, _buildForm(snapshot: _buildSnapshot()));

      expect(
        find.byKey(const Key('medicine-reminder-save-button')),
        findsOneWidget,
      );
    });

    testWidgets('save button disabled when isSaving', (tester) async {
      await _pumpForm(
        tester,
        _buildForm(snapshot: _buildSnapshot(), isSaving: true),
      );

      final button = tester.widget<FButton>(
        find.byKey(const Key('medicine-reminder-save-button')),
      );
      expect(button.onPress, isNull);
    });

    testWidgets('renders delete button when onDelete is provided', (
      tester,
    ) async {
      await _pumpForm(
        tester,
        _buildForm(snapshot: _buildSnapshot(), isEdit: true, onDelete: () {}),
      );

      expect(
        find.byKey(const Key('medicine-reminder-form-delete-button')),
        findsOneWidget,
      );
    });

    testWidgets('does not render delete button when onDelete is null', (
      tester,
    ) async {
      await _pumpForm(
        tester,
        _buildForm(snapshot: _buildSnapshot(), onDelete: null),
      );

      expect(
        find.byKey(const Key('medicine-reminder-form-delete-button')),
        findsNothing,
      );
    });

    testWidgets('delete button disabled when isSaving', (tester) async {
      await _pumpForm(
        tester,
        _buildForm(
          snapshot: _buildSnapshot(),
          isEdit: true,
          isSaving: true,
          onDelete: () {},
        ),
      );

      final button = tester.widget<FButton>(
        find.byKey(const Key('medicine-reminder-form-delete-button')),
      );
      expect(button.onPress, isNull);
    });

    testWidgets('renders section titles', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await _pumpForm(tester, _buildForm(snapshot: _buildSnapshot()));

      expect(
        find.text(l10n.medicineReminderMedicineSectionTitle),
        findsOneWidget,
      );
      expect(
        find.text(l10n.medicineReminderSettingsSectionTitle),
        findsOneWidget,
      );
      expect(find.text(l10n.medicineReminderMethodLabel), findsOneWidget);
    });

    testWidgets('renders note text field', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await _pumpForm(tester, _buildForm(snapshot: _buildSnapshot()));

      expect(find.text(l10n.medicineReminderNoteOptionalLabel), findsOneWidget);
    });

    testWidgets('renders frequency segments', (tester) async {
      await _pumpForm(
        tester,
        _buildForm(
          snapshot: _buildSnapshot(),
          frequency: ReminderFrequency.weekly,
        ),
      );

      expect(find.text('每日'), findsOneWidget);
      expect(find.text('每周'), findsOneWidget);
      expect(find.text('自定义'), findsOneWidget);
    });

    testWidgets('renders weekday picker when frequency is weekly', (
      tester,
    ) async {
      await _pumpForm(
        tester,
        _buildForm(
          snapshot: _buildSnapshot(),
          frequency: ReminderFrequency.weekly,
          selectedWeekdays: {1, 3},
        ),
      );

      expect(find.byType(FilterChip), findsNWidgets(7));
    });

    testWidgets('does not render weekday picker when frequency is daily', (
      tester,
    ) async {
      await _pumpForm(
        tester,
        _buildForm(
          snapshot: _buildSnapshot(),
          frequency: ReminderFrequency.daily,
        ),
      );

      expect(find.byType(FilterChip), findsNothing);
    });

    testWidgets('renders time picker row', (tester) async {
      await _pumpForm(
        tester,
        _buildForm(
          snapshot: _buildSnapshot(),
          times: [const MedicineReminderTimeInput(hour: 8, minute: 0)],
        ),
      );

      expect(find.text('08:00'), findsOneWidget);
    });

    testWidgets('renders start date and end date rows', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await _pumpForm(
        tester,
        _buildForm(
          snapshot: _buildSnapshot(),
          startDate: DateTime(2026, 7, 11),
        ),
      );

      expect(find.text(l10n.medicineReminderStartDateLabel), findsOneWidget);
      expect(find.text(l10n.medicineReminderEndDateLabel), findsOneWidget);
    });

    testWidgets('renders notification switch row', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      await _pumpForm(
        tester,
        _buildForm(snapshot: _buildSnapshot(), isActive: true),
      );

      expect(find.text(l10n.medicineReminderNotificationOn), findsOneWidget);
    });

    testWidgets('onSave is called when save button tapped', (tester) async {
      var saveCalled = false;
      await _pumpForm(
        tester,
        _buildForm(snapshot: _buildSnapshot(), onSave: () => saveCalled = true),
      );

      // Call onPress directly since the button may be off-screen in tests.
      final button = tester.widget<FButton>(
        find.byKey(const Key('medicine-reminder-save-button')),
      );
      button.onPress?.call();

      expect(saveCalled, isTrue);
    });
  });
}
