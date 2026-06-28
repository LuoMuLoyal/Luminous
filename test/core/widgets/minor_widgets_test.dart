import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/widgets/app_icon_badge.dart';
import 'package:luminous/core/widgets/app_section_header.dart';
import 'package:luminous/core/widgets/app_text_action.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

Widget _appShell(Widget child) {
  return MaterialApp(
    theme: ThemeData.light().copyWith(
      extensions: const <ThemeExtension<dynamic>>[AppThemeSurface.light],
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  group('AppIconBadge', () {
    testWidgets('renders icon with color', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppIconBadge(icon: Icons.star, color: Colors.amber)),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('renders square by default', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppIconBadge(icon: Icons.favorite, color: Colors.red)),
      );

      expect(find.byType(DecoratedBox), findsOneWidget);
    });

    testWidgets('renders circle shape', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppIconBadge(
            icon: Icons.check,
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('AppSectionHeader', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppSectionHeader(title: 'Settings')),
      );

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders leading widget', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppSectionHeader(title: 'Profile', leading: Icon(Icons.person)),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('renders trailing widget', (tester) async {
      await tester.pumpWidget(
        _appShell(
          const AppSectionHeader(title: 'Actions', trailing: Text('Edit')),
        ),
      );

      expect(find.text('Actions'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('uses compact style when compact is true', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppSectionHeader(title: 'Compact', compact: true)),
      );

      expect(find.text('Compact'), findsOneWidget);
    });
  });

  group('AppTextAction', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppTextAction(label: 'View all', onTap: null)),
      );

      expect(find.text('View all'), findsOneWidget);
    });

    testWidgets('renders chevron icon by default', (tester) async {
      await tester.pumpWidget(
        _appShell(const AppTextAction(label: 'More', onTap: null)),
      );

      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('triggers callback on tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _appShell(AppTextAction(label: 'Tap me', onTap: () => tapped = true)),
      );

      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });
  });
}
