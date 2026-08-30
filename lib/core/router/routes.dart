/// Core-level route constants used by cross-cutting utilities.
///
/// These intentionally mirror feature/app route declarations so core never
/// imports feature code; keep in sync with the typed routes — drift is
/// guarded by test/core/router/routes_test.dart.
abstract final class CoreRoutes {
  /// Login page path — mirrors `LoginRoute(path: '/login')`
  /// (features/auth/presentation/routes.dart) and `Routes.login`
  /// (lib/app/router.dart).
  static const String login = '/login';

  /// Home shell path — mirrors `Routes.home` (lib/app/router.dart).
  static const String home = '/';
}

/// Builds the login route location with a `return-to` hint, matching
/// `LoginRoute(returnTo: x).location` semantics (go_router decodes both
/// `+` and `%20` encodings, so literal strings may differ).
String loginRouteLocation(String returnTo) =>
    '${CoreRoutes.login}?return-to=${Uri.encodeQueryComponent(returnTo)}';
