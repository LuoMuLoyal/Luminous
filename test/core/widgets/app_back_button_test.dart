import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/common/app_back_button.dart';

import '../../helpers/test_forui_app.dart';

/// Wraps widget tree with Forui-aware MaterialApp + GoRouter.
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
  return TestForuiRouterApp(routerConfig: router);
}

void main() {
  group('AppBackButton', () {
    testWidgets('renders a Forui icon button', (tester) async {
      await tester.pumpWidget(_appShell(const AppBackButton()));
      await tester.pump();

      expect(find.byType(FButton), findsOneWidget);
      expect(find.byIcon(FLucideIcons.chevronLeft), findsOneWidget);
    });

    testWidgets('calls custom onPressed when provided', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(
        _appShell(AppBackButton(onPressed: () => pressed = true)),
      );
      await tester.pump();

      await tester.tap(find.byType(FButton));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('navigates to fallback route when cannot pop', (tester) async {
      await tester.pumpWidget(_appShell(const AppBackButton()));
      await tester.pump();

      await tester.tap(find.byType(FButton));
      await tester.pumpAndSettle();

      expect(find.text('Today fallback'), findsOneWidget);
    });
  });
}
