import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';

void main() {
  group('loginRouteForReturnTo', () {
    test('encodes simple tab paths', () {
      expect(loginRouteForReturnTo('/today'), '/login?return-to=%2Ftoday');
      expect(loginRouteForReturnTo('/record'), '/login?return-to=%2Frecord');
      expect(
        loginRouteForReturnTo('/medicine'),
        '/login?return-to=%2Fmedicine',
      );
    });

    test('encodes nested create paths', () {
      expect(
        loginRouteForReturnTo('/record/create'),
        '/login?return-to=%2Frecord%2Fcreate',
      );
      expect(
        loginRouteForReturnTo('/medicine/search'),
        '/login?return-to=%2Fmedicine%2Fsearch',
      );
    });

    test('encodes paths with existing query parameters', () {
      expect(
        loginRouteForReturnTo('/record/create?kind=water'),
        '/login?return-to=%2Frecord%2Fcreate%3Fkind%3Dwater',
      );
    });

    test('round-trips through Uri parse', () {
      final route = loginRouteForReturnTo('/record/create?kind=water');
      final uri = Uri.parse(route);
      expect(uri.path, '/login');
      expect(uri.queryParameters['return-to'], '/record/create?kind=water');
    });
  });

  group('loginRouteForCurrentLocation', () {
    testWidgets('returns encoded current location when valid', (tester) async {
      late final String route;
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/record/create?kind=water',
            routes: [
              GoRoute(
                path: '/record/create',
                builder: (context, state) {
                  route = loginRouteForCurrentLocation(context);
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(route, '/login?return-to=%2Frecord%2Fcreate%3Fkind%3Dwater');
    });

    testWidgets('falls back to root for empty location', (tester) async {
      late final String route;
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  route = loginRouteForCurrentLocation(context);
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(route, '/login?return-to=%2F');
    });
  });
}
