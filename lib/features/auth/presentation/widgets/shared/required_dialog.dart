import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/features/auth/presentation/routes.dart';

export 'package:luminous/core/widgets/auth/required_dialog.dart';

/// Checks the auth session and either pushes [route] directly (if
/// authenticated) or shows the auth-required dialog (if not).
///
/// This function depends on auth routes ([LoginRoute]) and therefore stays
/// in the auth feature rather than in [core/widgets/auth/].
Future<void> pushAuthRequiredRoute(BuildContext context, String route) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final session = container.read(authSessionProvider);
  if (session.canAccessProtectedData) {
    unawaited(context.push(route));
    return;
  }

  if (session.isLoading) {
    return;
  }

  // When not signed in, show login dialog and return to current location
  // after login. The user can then retry navigating to the target route.
  await showAuthRequiredDialog(
    context,
    // The login action fires on a later user tap; guard the push in case the
    // calling surface was closed in between (a deactivated context pushed
    // through trips the `_dependents.isEmpty` assertion).
    onLogin: () {
      if (!context.mounted) return;
      unawaited(context.push(loginRouteForCurrentLocation(context)));
    },
  );
}

String loginRouteForReturnTo(String returnTo) {
  return LoginRoute(returnTo: returnTo).location;
}

String loginRouteForCurrentLocation(BuildContext context) {
  final location = GoRouterState.of(context).uri.toString();
  if (location.isEmpty || !location.startsWith('/')) {
    return loginRouteForReturnTo(Routes.home);
  }
  return loginRouteForReturnTo(location);
}
