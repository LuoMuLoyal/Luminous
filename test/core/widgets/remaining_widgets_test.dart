import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/widgets/common/app_header_action_chip.dart';
import 'package:luminous/core/widgets/common/app_image_placeholder.dart';
import 'package:luminous/core/widgets/common/app_section_surface.dart';
import 'package:luminous/core/widgets/settings/app_setting_row.dart';
import 'package:luminous/core/widgets/settings/app_settings_navigation_row.dart';
import 'package:luminous/core/widgets/settings/app_settings_section.dart';
import 'package:luminous/core/widgets/settings/app_settings_switch_row.dart';

Widget _appShell(Widget child) {
  return MaterialApp(
    theme: ThemeData.light(),
    home: Scaffold(body: child),
  );
}

void main() {
  group('AppHeaderActionChip', () {
    testWidgets('renders label and icon', (tester) async {
      await tester.pumpWidget(
        _appShell(
          AppHeaderActionChip(
            label: 'Search',
            icon: Icons.search,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Search'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _appShell(
          AppHeaderActionChip(
            label: 'Tap me',
            icon: Icons.touch_app,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });
  });

  group('AppImagePlaceholder', () {
    testWidgets('renders label and default icon', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppImagePlaceholder(label: 'No image')),
      );

      expect(find.text('No image'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('renders custom icon', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppImagePlaceholder(label: 'Photo', icon: Icons.photo_camera),
        ),
      );

      expect(find.text('Photo'), findsOneWidget);
      expect(find.byIcon(Icons.photo_camera), findsOneWidget);
    });

    testWidgets('respects width and height', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppImagePlaceholder(label: 'Sized', width: 200, height: 150),
        ),
      );

      expect(find.text('Sized'), findsOneWidget);
    });
  });

  group('AppSectionSurface', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppSectionSurface(child: Text('Content'))),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('renders title and subtite when provided', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppSectionSurface(
            title: 'Section Title',
            subtitle: 'Section description',
            child: Text('Body'),
          ),
        ),
      );

      expect(find.text('Section Title'), findsOneWidget);
      expect(find.text('Section description'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('renders trailing widget', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppSectionSurface(
            title: 'With trailing',
            trailing: Text('Edit'),
            child: Text('Body'),
          ),
        ),
      );

      expect(find.text('With trailing'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });
  });

  group('AppSettingsSwitchRow', () {
    testWidgets('renders title and switch', (tester) async {
      await tester.pumpWidget(
        _appShell(
          AppSettingsSwitchRow(
            title: 'Enable feature',
            value: true,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Enable feature'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpWidget(
        _appShell(
          AppSettingsSwitchRow(
            title: 'Notifications',
            subtitle: 'Get push alerts',
            value: false,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Get push alerts'), findsOneWidget);
    });

    testWidgets('toggles when tapped', (tester) async {
      bool toggled = false;
      await tester.pumpWidget(
        _appShell(
          AppSettingsSwitchRow(
            title: 'Toggle me',
            value: false,
            onChanged: (v) => toggled = v,
          ),
        ),
      );

      await tester.tap(find.text('Toggle me'));
      expect(toggled, isTrue);
    });

    testWidgets('shows divider when showDivider is true', (tester) async {
      await tester.pumpWidget(
        _appShell(
          AppSettingsSwitchRow(
            title: 'Divided',
            value: true,
            onChanged: (_) {},
            showDivider: true,
          ),
        ),
      );

      expect(find.text('Divided'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
    });
  });

  group('AppSettingRow', () {
    testWidgets('renders title and triggers onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _appShell(
          AppSettingRow(title: 'Open settings', onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.text('Open settings'));
      expect(tapped, isTrue);
    });

    testWidgets('shows chevron when showChevron is true', (tester) async {
      await tester.pumpWidget(
        _appShell(
          AppSettingRow(title: 'With chevron', onTap: () {}, showChevron: true),
        ),
      );

      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('shows subtitle and value', (tester) async {
      await tester.pumpWidget(
        _appShell(
          AppSettingRow(
            title: 'Profile',
            subtitle: 'Manage your data',
            value: 'View',
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Manage your data'), findsOneWidget);
      expect(find.text('View'), findsOneWidget);
    });

    testWidgets('renders trailing widget', (tester) async {
      await tester.pumpWidget(
        _appShell(
          AppSettingRow(
            title: 'With trailing',
            onTap: () {},
            trailing: const Icon(Icons.star),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('shows divider when showDivider is true', (tester) async {
      await tester.pumpWidget(
        _appShell(
          AppSettingRow(title: 'Divided', onTap: () {}, showDivider: true),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
    });
  });

  group('AppSettingsNavigationRow', () {
    testWidgets('renders title and chevron', (tester) async {
      await tester.pumpWidget(
        _appShell(AppSettingsNavigationRow(title: 'Go to page', onTap: () {})),
      );

      expect(find.text('Go to page'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('renders subtitle and value', (tester) async {
      await tester.pumpWidget(
        _appShell(
          AppSettingsNavigationRow(
            title: 'Language',
            subtitle: 'App locale',
            value: 'English',
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('App locale'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('triggers onTap when enabled', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _appShell(
          AppSettingsNavigationRow(
            title: 'Navigate',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Navigate'));
      expect(tapped, isTrue);
    });

    testWidgets('shows divider when showDivider is true', (tester) async {
      await tester.pumpWidget(
        _appShell(
          AppSettingsNavigationRow(
            title: 'Divided',
            onTap: () {},
            showDivider: true,
          ),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
    });
  });

  group('AppSettingsSection', () {
    testWidgets('renders section label', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppSettingsSection(label: 'General')),
      );

      expect(find.text('General'), findsOneWidget);
    });
  });
}
