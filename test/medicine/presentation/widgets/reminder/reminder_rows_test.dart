import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/reminder_rows.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../../../helpers/test_forui_app.dart';

AppLocalizations _getL10n(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold));
  return AppLocalizations.of(context)!;
}

CurrentMedicineItem _buildMedicine({
  String id = 'med-1',
  String displayName = '阿莫西林胶囊',
  String? strengthText = '0.25g',
  String? doseText = '每次1粒',
}) {
  return CurrentMedicineItem(
    id: id,
    source: 'cn',
    sourceRefId: null,
    displayName: displayName,
    strengthText: strengthText,
    doseText: doseText,
    route: '口服',
    startedAt: '2026-01-01',
    endedAt: null,
    isCurrent: true,
    note: null,
    createdAt: '2026-01-01',
    updatedAt: '2026-01-01',
  );
}

void main() {
  group('ReminderInfoRow', () {
    testWidgets('renders icon, label and value', (tester) async {
      await tester.pumpWidget(
        const TestForuiApp(
          home: Scaffold(
            body: ReminderInfoRow(
              icon: FLucideIcons.clock,
              label: '时间',
              value: '08:00',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('时间'), findsOneWidget);
      expect(find.text('08:00'), findsOneWidget);
      expect(find.byIcon(FLucideIcons.clock), findsOneWidget);
    });

    testWidgets('renders divider when showDivider is true', (tester) async {
      await tester.pumpWidget(
        const TestForuiApp(
          home: Scaffold(
            body: ReminderInfoRow(
              icon: FLucideIcons.pill,
              label: '药品',
              value: 'Test',
              showDivider: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('does not render divider when showDivider is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const TestForuiApp(
          home: Scaffold(
            body: ReminderInfoRow(
              icon: FLucideIcons.pill,
              label: '药品',
              value: 'Test',
              showDivider: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('药品'), findsOneWidget);
    });
  });

  group('ValueActionRow', () {
    testWidgets('renders title and value, calls onTap when pressed', (
      tester,
    ) async {
      var tapCount = 0;
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: ValueActionRow(
              icon: FLucideIcons.calendar,
              title: '日期',
              value: '2026-07-11',
              onTap: () => tapCount++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('日期'), findsOneWidget);
      expect(find.text('2026-07-11'), findsOneWidget);

      await tester.tap(find.text('日期'));
      await tester.pumpAndSettle();
      expect(tapCount, 1);
    });

    testWidgets('shows clear button when onClear is provided', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: ValueActionRow(
              icon: FLucideIcons.calendar,
              title: '日期',
              value: '2026-07-11',
              onTap: () {},
              onClear: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(FLucideIcons.x), findsOneWidget);
    });

    testWidgets('shows chevron when onClear is null', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: ValueActionRow(
              icon: FLucideIcons.calendar,
              title: '日期',
              value: '2026-07-11',
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(FLucideIcons.chevronRight), findsOneWidget);
    });
  });

  group('SwitchRow', () {
    testWidgets('renders title, subtitle and switch with correct value', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: SwitchRow(
              title: '提醒开关',
              subtitle: '开启后将接收提醒通知',
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('提醒开关'), findsOneWidget);
      expect(find.text('开启后将接收提醒通知'), findsOneWidget);
      expect(find.byType(FSwitch), findsOneWidget);
    });

    testWidgets('calls onChanged with new value when switch is toggled', (
      tester,
    ) async {
      bool? changedValue;
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: SwitchRow(
              title: '提醒',
              subtitle: '子标题',
              value: false,
              onChanged: (v) => changedValue = v,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FSwitch));
      await tester.pumpAndSettle();

      expect(changedValue, isTrue);
    });
  });

  group('UnavailableMethodRow', () {
    testWidgets('renders title, subtitle and status badge', (tester) async {
      await tester.pumpWidget(
        const TestForuiApp(
          home: Scaffold(
            body: UnavailableMethodRow(
              icon: FLucideIcons.phone,
              title: '电话提醒',
              subtitle: '通过电话语音通知',
              status: '不可用',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('电话提醒'), findsOneWidget);
      expect(find.text('通过电话语音通知'), findsOneWidget);
      expect(find.text('不可用'), findsOneWidget);
      expect(find.byType(FBadge), findsOneWidget);
    });
  });

  group('SelectedMedicineRow', () {
    testWidgets('renders medicine display name and dose text', (tester) async {
      final medicine = _buildMedicine();
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(body: SelectedMedicineRow(medicine: medicine)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('阿莫西林胶囊'), findsOneWidget);
      // doseText is "每次1粒", strengthText is "0.25g" → "0.25g · 每次1粒"
      expect(find.textContaining('0.25g'), findsOneWidget);
      expect(find.byIcon(FLucideIcons.pill), findsOneWidget);
    });

    testWidgets('shows not-set text when no dose info', (tester) async {
      final medicine = _buildMedicine(strengthText: null, doseText: null);

      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(body: SelectedMedicineRow(medicine: medicine)),
        ),
      );
      await tester.pumpAndSettle();

      final l10n = _getL10n(tester);
      expect(find.text(l10n.medicineDoseNotSet), findsOneWidget);
    });
  });

  group('SoundPreferenceRow', () {
    testWidgets('renders label and FSelect with current value', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: SoundPreferenceRow(
              value: MedicineReminderSoundPreference.defaultTone,
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final l10n = _getL10n(tester);
      expect(find.text(l10n.medicineReminderSoundLabel), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is FSelect<MedicineReminderSoundPreference>,
        ),
        findsOneWidget,
      );
    });

    testWidgets('calls onChanged when a different sound is selected', (
      tester,
    ) async {
      MedicineReminderSoundPreference? selected;
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: SoundPreferenceRow(
              value: MedicineReminderSoundPreference.defaultTone,
              onChanged: (v) => selected = v,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final selectFinder = find.byWidgetPredicate(
        (w) => w is FSelect<MedicineReminderSoundPreference>,
      );
      // Tap the FSelect to open the popover.
      await tester.tap(selectFinder);
      await tester.pumpAndSettle();

      final l10n = _getL10n(tester);
      // Tap the "silent" option.
      await tester.tap(find.text(l10n.medicineReminderSoundSilent));
      await tester.pumpAndSettle();

      expect(selected, MedicineReminderSoundPreference.silent);
    });
  });
}
