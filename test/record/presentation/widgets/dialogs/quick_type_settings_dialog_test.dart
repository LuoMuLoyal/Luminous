import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/quick_type_settings_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_forui_app.dart';

void main() {
  Future<void> pumpDialog(WidgetTester tester, RecordQuickAction action) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    await tester.pumpWidget(
      ProviderScope(
        child: TestForuiApp(
          home: Builder(
            builder: (context) => Center(
              child: FButton(
                onPress: () => showAppDialog<void>(
                  context: context,
                  scrollable: false,
                  builder: (_) => QuickEntryTypeSettingsDialog(
                    action: action,
                    l10n: AppLocalizations.of(context)!,
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('QuickEntryTypeSettingsDialog', () {
    testWidgets('water long-press dialog exposes default amount and badge', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        RecordDashboard.quickActionFor(RecordEntryType.water)!,
      );

      expect(find.byKey(const Key('quick-type-water-default')), findsOneWidget);
      expect(find.byKey(const Key('quick-type-water-badge')), findsOneWidget);

      // Tapping the default amount opens a choice list; picking 500 ml applies it.
      await tester.tap(find.byKey(const Key('quick-type-water-default')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('500 ml').last);
      await tester.pumpAndSettle();
      expect(find.text('500 ml'), findsOneWidget);
    });

    testWidgets('symptom long-press dialog shows the type rule', (
      tester,
    ) async {
      await pumpDialog(
        tester,
        RecordDashboard.quickActionFor(RecordEntryType.symptom)!,
      );

      expect(find.text('症状：单选立即保存，多选确认保存'), findsOneWidget);
      expect(find.byKey(const Key('quick-type-water-default')), findsNothing);
    });
  });
}
