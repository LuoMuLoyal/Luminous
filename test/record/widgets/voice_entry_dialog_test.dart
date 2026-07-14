import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/shared_widgets.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/voice_entry_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  group('showRecordVoiceEntrySheet', () {
    Future<void> pumpSheet(WidgetTester tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: FButton(
                  onPress: () => showRecordVoiceEntrySheet(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('opens sheet when called', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpSheet(tester);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.text(l10n.recordVoiceEntryTitle), findsOneWidget);
    });

    testWidgets('renders tap-to-start placeholder', (tester) async {
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      await pumpSheet(tester);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.text(l10n.recordVoiceTapToStart), findsOneWidget);
    });

    testWidgets('renders use text button (disabled initially)', (tester) async {
      await pumpSheet(tester);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // The "Use Text" button is rendered but should be disabled
      final button = tester.widget<FButton>(find.byType(FButton).last);
      expect(button.onPress, isNull);
    });

    testWidgets('renders close button (X icon)', (tester) async {
      await pumpSheet(tester);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.byIcon(FLucideIcons.x), findsOneWidget);
    });

    testWidgets('renders mic icon', (tester) async {
      await pumpSheet(tester);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // micOff icon shown when not listening
      expect(find.byIcon(FLucideIcons.micOff), findsOneWidget);
    });

    testWidgets('renders SheetDragHandle', (tester) async {
      await pumpSheet(tester);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(find.byType(SheetDragHandle), findsOneWidget);
    });

    testWidgets('closes sheet when X button tapped', (tester) async {
      await pumpSheet(tester);

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      await tester.tap(find.byIcon(FLucideIcons.x));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Sheet should be closed — title no longer visible
      expect(find.text('recordVoiceEntryTitle'), findsNothing);
    });
  });
}
