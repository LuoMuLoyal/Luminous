import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/app_back_button.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

/// Wraps widget tree with MaterialApp + GoRouter + AppThemeSurface.
Widget _appShell(Widget child) {
  final router = GoRouter(
    initialLocation: '/test',
    routes: [
      GoRoute(
        path: '/test',
        builder: (_, __) => Scaffold(body: child),
      ),
      GoRoute(
        path: '/today',
        builder: (_, __) => const Scaffold(body: Text('Today fallback')),
      ),
      GoRoute(
        path: '/other',
        builder: (_, __) => const Scaffold(body: Text('Other page')),
      ),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    theme: ThemeData.light().copyWith(
      extensions: const <ThemeExtension<dynamic>>[AppThemeSurface.light],
    ),
  );
}

void main() {
  group('AppBackButton', () {
    testWidgets('renders a BackButton', (tester) async {
      await tester.pumpWidget(_appShell(const AppBackButton()));
      await tester.pump();

      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('calls custom onPressed when provided', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        _appShell(AppBackButton(onPressed: () => pressed = true)),
      );
      await tester.pump();

      await tester.tap(find.byType(BackButton));
      expect(pressed, isTrue);
    });

    testWidgets('navigates to fallback route when cannot pop', (tester) async {
      await tester.pumpWidget(_appShell(const AppBackButton()));
      await tester.pump();

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Today fallback'), findsOneWidget);
    });
  });
}
