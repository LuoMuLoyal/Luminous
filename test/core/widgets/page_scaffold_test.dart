import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/core/widgets/responsive_content_frame.dart';

Widget _appShell(Widget child) {
  return MaterialApp(
    theme: ThemeData.light().copyWith(
      extensions: const <ThemeExtension<dynamic>>[AppThemeSurface.light],
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  group('ResponsiveContentFrame', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        _appShell(const ResponsiveContentFrame(child: Text('Content'))),
      );

      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('PageScaffoldShell', () {
    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const PageScaffoldShell(
            title: 'Page Title',
            children: <Widget>[Text('Body')],
          ),
        ),
      );

      expect(find.text('Page Title'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('renders description when provided', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const PageScaffoldShell(
            title: 'Settings',
            description: 'Manage your preferences',
            children: <Widget>[Text('Content')],
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Manage your preferences'), findsOneWidget);
    });

    testWidgets('renders actions when provided', (tester) async {
      await tester.pumpWidget(
        _appShell(
          PageScaffoldShell(
            title: 'Profile',
            actions: <Widget>[
              TextButton(onPressed: () {}, child: const Text('Edit')),
            ],
            children: const <Widget>[Text('Content')],
          ),
        ),
      );

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await tester.pumpWidget(
        _appShell(
          PageScaffoldShell(
            title: 'Detail',
            leading: const Icon(Icons.arrow_back),
            children: const <Widget>[Text('Content')],
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('uses centerTitle layout', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const PageScaffoldShell(
            title: 'Centered',
            centerTitle: true,
            children: <Widget>[Text('Content')],
          ),
        ),
      );

      expect(find.text('Centered'), findsOneWidget);
    });

    testWidgets('renders with scrollable false', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const PageScaffoldShell(
            title: 'Fixed',
            scrollable: false,
            children: <Widget>[Text('Static')],
          ),
        ),
      );

      expect(find.text('Fixed'), findsOneWidget);
      expect(find.text('Static'), findsOneWidget);
    });

    testWidgets('renders with drawer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light().copyWith(
            extensions: const <ThemeExtension<dynamic>>[AppThemeSurface.light],
          ),
          home: PageScaffoldShell(
            title: 'With Drawer',
            drawer: const Drawer(child: Text('Drawer content')),
            children: const <Widget>[Text('Page')],
          ),
        ),
      );

      // Drawer is not in the widget tree until opened, but the shell renders
      expect(find.text('With Drawer'), findsOneWidget);
      expect(find.text('Page'), findsOneWidget);
    });

    testWidgets('renders PageSectionCard inside shell', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const PageScaffoldShell(
            title: 'Cards',
            children: <Widget>[
              PageSectionCard(
                title: 'Card Title',
                subtitle: 'Card subtitle',
                child: Text('Card body'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Cards'), findsOneWidget);
      expect(find.text('Card Title'), findsOneWidget);
      expect(find.text('Card subtitle'), findsOneWidget);
      expect(find.text('Card body'), findsOneWidget);
    });
  });
}
