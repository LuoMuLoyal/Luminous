import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';

String _joinPath(String parent, String child) {
  if (child.startsWith('/')) return child;
  if (parent.isEmpty || parent == '/') return '/$child';
  if (parent.endsWith('/')) return '$parent$child';
  return '$parent/$child';
}

bool _pathMatches(String pattern, String path) {
  final patternSegments = pattern
      .split('/')
      .where((s) => s.isNotEmpty)
      .toList();
  final pathSegments = path.split('/').where((s) => s.isNotEmpty).toList();
  if (patternSegments.length != pathSegments.length) return false;
  for (var i = 0; i < patternSegments.length; i++) {
    final segment = patternSegments[i];
    if (segment.startsWith(':')) continue;
    if (segment != pathSegments[i]) return false;
  }
  return true;
}

bool _isInsideStatefulShell(
  List<RouteBase> routes,
  String path, {
  String parentPath = '',
  bool insideShell = false,
}) {
  for (final route in routes) {
    if (route is GoRoute) {
      final fullPath = _joinPath(parentPath, route.path);
      if (_pathMatches(fullPath, path)) {
        return insideShell;
      }
      if (route.routes.isNotEmpty) {
        final found = _isInsideStatefulShell(
          route.routes,
          path,
          parentPath: fullPath,
          insideShell: insideShell,
        );
        if (found) return true;
      }
    } else if (route is ShellRoute) {
      final found = _isInsideStatefulShell(
        route.routes,
        path,
        parentPath: parentPath,
        insideShell: insideShell,
      );
      if (found) return true;
    } else if (route is StatefulShellRoute) {
      for (final branch in route.branches) {
        final found = _isInsideStatefulShell(
          branch.routes,
          path,
          parentPath: parentPath,
          insideShell: true,
        );
        if (found) return true;
      }
    }
  }
  return false;
}

bool _routeIsInsideShell(String path) =>
    _isInsideStatefulShell(router.configuration.routes, path);

void main() {
  group('business routes are nested inside StatefulShellRoute', () {
    const shellPaths = <String>[
      '/',
      '/record',
      '/medicine',
      '/report',
      '/mine',
      '/medicine/search',
      '/medicine/risk-check',
      '/medicine/reminders/new',
      '/medicine/reminders/123',
      '/medicine/reminders/123/edit',
      '/record/create',
      '/record/123',
      '/record/123/edit',
      '/mine/profile/edit',
      '/mine/allergy/new',
      '/mine/allergy/123/edit',
      '/mine/condition/new',
      '/mine/condition/123/edit',
      '/mine/medicine/new',
      '/mine/medicine/123/edit',
      '/settings',
      '/settings/language',
      '/settings/theme',
      '/settings/notifications',
      '/settings/more',
      '/assistant',
      '/notifications',
      '/notifications/123',
    ];

    for (final path in shellPaths) {
      test(path, () {
        expect(_routeIsInsideShell(path), isTrue);
      });
    }
  });

  group('auth and account routes remain top-level full-screen', () {
    const fullScreenPaths = <String>[
      '/login',
      '/login/oauth/wechat',
      '/register',
      '/forgot-password',
      '/account',
      '/account/oauth/wechat',
      '/account/change-email',
    ];

    for (final path in fullScreenPaths) {
      test(path, () {
        expect(_routeIsInsideShell(path), isFalse);
      });
    }
  });
}
