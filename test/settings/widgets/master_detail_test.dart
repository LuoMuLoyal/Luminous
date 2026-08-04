import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/settings/presentation/widgets/master_detail.dart';

// ignore_for_file: prefer_const_constructors

import '../../helpers/test_forui_app.dart';

void main() {
  group('MasterNavItem', () {
    testWidgets('renders label and icon', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: MasterNavItem(
            icon: SemanticIcons.actionSettings,
            label: 'Test Label',
            selected: false,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.byIcon(SemanticIcons.actionSettings), findsOneWidget);
    });

    testWidgets('selected state shows primary color and trailing icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: MasterNavItem(
            icon: SemanticIcons.actionSettings,
            label: 'Selected',
            selected: true,
            onTap: () {},
          ),
        ),
      );

      // Trailing "next" icon should be visible when selected.
      expect(find.byIcon(SemanticIcons.actionNext), findsOneWidget);
    });

    testWidgets('unselected state does not show trailing icon', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: MasterNavItem(
            icon: SemanticIcons.actionSettings,
            label: 'Unselected',
            selected: false,
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(SemanticIcons.actionNext), findsNothing);
    });

    testWidgets('tap triggers onTap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        TestForuiApp(
          home: MasterNavItem(
            icon: SemanticIcons.actionSettings,
            label: 'Tap me',
            selected: false,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      // FTappable has 100ms pending timer.
      await tester.pump(const Duration(milliseconds: 150));

      expect(tapped, isTrue);
    });
  });

  group('SettingsMasterDetail', () {
    testWidgets('renders header, groups, and sign-out tile', (tester) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: SettingsMasterDetail(
            accountHeader: Text('Account'),
            signOutTile: Text('Sign Out'),
            groups: [
              SettingsGroup(
                label: 'General',
                icon: SemanticIcons.actionSettings,
                body: Text('General content'),
              ),
              SettingsGroup(
                label: 'Security',
                icon: SemanticIcons.actionHelp,
                body: Text('Security content'),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      // First group (index 0) should be displayed by default.
      expect(find.text('General content'), findsOneWidget);
      // Second group not shown until clicked.
      expect(find.text('Security content'), findsNothing);
    });

    testWidgets('selecting a different group displays its body', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestForuiApp(
          home: SettingsMasterDetail(
            accountHeader: const SizedBox(),
            signOutTile: const SizedBox(),
            groups: const [
              SettingsGroup(
                label: 'First',
                icon: SemanticIcons.actionSettings,
                body: Text('First body'),
              ),
              SettingsGroup(
                label: 'Second',
                icon: SemanticIcons.actionHelp,
                body: Text('Second body'),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('First body'), findsOneWidget);
      expect(find.text('Second body'), findsNothing);

      await tester.tap(find.text('Second'));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump();

      expect(find.text('First body'), findsNothing);
      expect(find.text('Second body'), findsOneWidget);
    });
  });
}
