import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/search/presentation/pages/search_page.dart';
import 'package:luminous/features/search/presentation/providers/search_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_forui_app.dart';

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

class _FakeMedicineSearchNotifier extends MedicineSearchNotifier {
  @override
  MedicineSearchState build() => const MedicineSearchState();
}

Widget _testableRouter({
  required String initialLocation,
  required WidgetTester tester,
}) {
  SharedPreferences.setMockInitialValues(const <String, Object>{});
  final testRouter = GoRouter(
    initialLocation: initialLocation,
    routes: router.configuration.routes,
  );
  addTearDown(testRouter.dispose);
  return ProviderScope(
    overrides: [
      medicineSearchNotifierProvider.overrideWith(
        () => _FakeMedicineSearchNotifier(),
      ),
    ],
    child: TestForuiRouterApp(routerConfig: testRouter),
  );
}

void main() {
  group('main tab roots are nested inside StatefulShellRoute', () {
    const shellPaths = <String>[
      '/',
      '/record',
      '/medicine',
      '/report',
      '/mine',
    ];

    for (final path in shellPaths) {
      test(path, () {
        expect(_routeIsInsideShell(path), isTrue);
      });
    }
  });

  group('create/detail/edit sub-pages are top-level full-screen', () {
    const fullScreenPaths = <String>[
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
      '/settings/more',
      '/settings/notifications',
      '/settings/notifications/sleep',
      '/settings/ai',
      '/settings/export',
      '/settings/help',
      '/settings/about',
      '/assistant',
      '/notifications',
      '/notifications/123',
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

  group('deep links to full-screen routes hide the desktop shell', () {
    testWidgets('/medicine/search hides sidebar on desktop', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1440, 1000);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      await tester.pumpWidget(
        _testableRouter(initialLocation: '/medicine/search', tester: tester),
      );
      await tester.pumpAndSettle();

      expect(find.text('Luminous'), findsNothing);
      expect(find.byType(SearchPage), findsOneWidget);
    });
  });

  group('deep links to full-screen routes hide mobile bottom navigation', () {
    testWidgets('/medicine/search hides bottom nav on mobile', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(() {
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      await tester.pumpWidget(
        _testableRouter(initialLocation: '/medicine/search', tester: tester),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(SearchPage), findsOneWidget);
    });
  });
}
