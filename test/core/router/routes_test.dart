import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/router/routes.dart';
import 'package:luminous/features/auth/presentation/routes.dart';

void main() {
  // Drift guard: core must not import feature code, so CoreRoutes/loginRouteLocation
  // mirror the auth feature's typed LoginRoute. Cross-layer imports are allowed in
  // tests; this keeps the two in sync.
  group('loginRouteLocation drift guard vs LoginRoute', () {
    const returnTos = <String>[
      '',
      '/',
      '/record/123',
      'a b',
      '中文',
      'x&y=z?q=1',
    ];

    for (final returnTo in returnTos) {
      test('matches LoginRoute(returnTo: $returnTo) query parameters', () {
        final actual = Uri.parse(loginRouteLocation(returnTo)).queryParameters;
        final expected = Uri.parse(
          LoginRoute(returnTo: returnTo).location,
        ).queryParameters;
        expect(actual, expected);
      });
    }
  });

  group('loginRouteLocation edge behavior', () {
    test('empty returnTo keeps the bare return-to= hint', () {
      expect(loginRouteLocation(''), '/login?return-to=');
    });
  });
}
