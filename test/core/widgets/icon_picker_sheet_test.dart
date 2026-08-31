import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/dialog/icon_picker_sheet.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../../helpers/test_forui_app.dart';

void main() {
  group('showAppIconPicker', () {
    /// Helper: renders a Scaffold with a button that opens the icon picker
    /// sheet, taps the button, and pumps until the sheet is visible.
    Future<void> openPicker(
      WidgetTester tester, {
      IconData? currentIcon,
      Map<IconPickerCategory, List<IconData>>? categories,
    }) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAppIconPicker(
                  context,
                  currentIcon: currentIcon,
                  categories: categories,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('renders 5 default categories with first icon tappable', (
      tester,
    ) async {
      await openPicker(tester);

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      // The first category label should be visible.
      expect(find.text(l10n.iconPickerCategoryFood), findsOneWidget);

      // The first icon in the Food category (droplets) should be present.
      expect(find.byIcon(FLucideIcons.droplets), findsOneWidget);

      // The ListView should contain 5 items (all default categories).
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.semanticChildCount, defaultIconPickerCategories.length);
    });

    testWidgets('search filter narrows to matching items', (tester) async {
      await openPicker(tester);

      // Type a search query that matches "coffee".
      await tester.enterText(find.byType(FTextField), 'coffee');
      await tester.pump(const Duration(milliseconds: 300));

      // Only the Food category should remain (coffee is in Food).
      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(find.text(l10n.iconPickerCategoryFood), findsOneWidget);
      // Other categories should be filtered out.
      expect(find.text(l10n.iconPickerCategoryHealth), findsNothing);
      expect(find.text(l10n.iconPickerCategoryStatus), findsNothing);
      expect(find.text(l10n.iconPickerCategoryBody), findsNothing);
      expect(find.text(l10n.iconPickerCategoryGeneral), findsNothing);
    });

    testWidgets('search with no match shows empty state', (tester) async {
      await openPicker(tester);

      await tester.enterText(find.byType(FTextField), 'xyz123');
      await tester.pump(const Duration(milliseconds: 300));

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));
      expect(find.text(l10n.iconPickerEmpty), findsOneWidget);
    });

    testWidgets('injected custom categories render only injected items', (
      tester,
    ) async {
      // Inject a single category with two icons.
      await openPicker(
        tester,
        categories: {
          IconPickerCategory.health: [
            FLucideIcons.heartPulse,
            FLucideIcons.thermometer,
          ],
        },
      );

      final l10n = await AppLocalizations.delegate.load(const Locale('zh'));

      // Only the Health category should be visible.
      expect(find.text(l10n.iconPickerCategoryHealth), findsOneWidget);
      // Other categories should not be present.
      expect(find.text(l10n.iconPickerCategoryFood), findsNothing);
      expect(find.text(l10n.iconPickerCategoryStatus), findsNothing);
      expect(find.text(l10n.iconPickerCategoryBody), findsNothing);
      expect(find.text(l10n.iconPickerCategoryGeneral), findsNothing);
    });

    testWidgets('tapping an icon returns it as the result', (tester) async {
      IconData? result;

      await tester.pumpWidget(
        TestForuiApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showAppIconPicker(context);
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap the droplets icon (first in Food category).
      await tester.tap(find.byIcon(FLucideIcons.droplets));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(result, FLucideIcons.droplets);
    });
  });
}
