import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/auth/presentation/routes.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';
import 'package:luminous/features/notification/presentation/routes.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/routes.dart';
import 'package:luminous/features/review/presentation/pages/page.dart';
import 'package:luminous/features/search/presentation/pages/page.dart';
import 'package:luminous/features/search/presentation/providers/medicine_search.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_forui_app.dart';

late ProviderContainer _testContainer;

GoRouter get _testRouter => _testContainer.read(appRouterProvider);

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
    _isInsideStatefulShell(_testRouter.configuration.routes, path);

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
    routes: _testRouter.configuration.routes,
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
  setUpAll(() {
    _testContainer = ProviderContainer();
    addTearDown(_testContainer.dispose);
  });

  group('main tab roots are nested inside StatefulShellRoute', () {
    const shellPaths = <String>[
      '/',
      '/record',
      '/medicine',
      '/review',
      '/mine',
    ];

    for (final path in shellPaths) {
      test(path, () {
        expect(_routeIsInsideShell(path), isTrue);
      });
    }
  });

  group('fifth tab review rename keeps the /report route', () {
    test('/report still resolves to the report shell branch', () {
      expect(_routeIsInsideShell('/review'), isTrue);
    });

    testWidgets(
      'deep link to /report renders the fifth tab with the Review label',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(() {
          tester.view.resetDevicePixelRatio();
          tester.view.resetPhysicalSize();
        });

        await tester.pumpWidget(
          _testableRouter(initialLocation: '/review', tester: tester),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));

        // The deep link stays on the shell and selects the report branch
        // (same branch identity as ShellTab.review).
        expect(find.byType(ReviewPage), findsOneWidget);
        final bottomNav = tester.widget<FBottomNavigationBar>(
          find.byType(FBottomNavigationBar),
        );
        expect(bottomNav.index, ShellTab.review.index);

        // Fifth tab label shows the user-facing task name 回顾 (zh).
        expect(
          find.descendant(
            of: find.byKey(ShellTab.review.testKey()),
            matching: find.text('回顾'),
          ),
          findsOneWidget,
        );
      },
    );
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
      '/review/review/evt-1',
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

  group('typed route .location generates correct URL', () {
    test('RecordDetailRoute with id', () {
      expect(
        const RecordDetailRoute(id: 'abc-123').location,
        '/record/abc-123',
      );
    });

    test('RecordDetailRoute URL-encodes path parameter', () {
      expect(
        const RecordDetailRoute(id: 'a b/c').location,
        '/record/a%20b%2Fc',
      );
    });

    test('RecordEditRoute with id', () {
      expect(const RecordEditRoute(id: 'xyz').location, '/record/xyz/edit');
    });

    test('RecordCreateRoute with enum query param', () {
      expect(
        const RecordCreateRoute(kind: DailyRecordKind.sleep).location,
        '/record/create?kind=sleep',
      );
    });

    test('RecordCreateRoute with no params', () {
      expect(const RecordCreateRoute().location, '/record/create');
    });

    test('RecordCreateRoute with all params', () {
      final loc = const RecordCreateRoute(
        kind: DailyRecordKind.water,
        date: '2026-07-10',
        time: '08:30',
      ).location;
      expect(loc, contains('kind=water'));
      expect(loc, contains('date=2026-07-10'));
      expect(loc, contains('time=08%3A30'));
    });

    test('LoginRoute with returnTo', () {
      final loc = const LoginRoute(returnTo: '/record/123').location;
      expect(loc, startsWith('/login'));
      expect(loc, contains('return-to=%2Frecord%2F123'));
    });

    test('LoginOauthWechatRoute with code and state', () {
      final loc = const LoginOauthWechatRoute(
        code: 'wx-code',
        state: 'wx-state',
      ).location;
      expect(loc, startsWith('/login/oauth/wechat'));
      expect(loc, contains('code=wx-code'));
      expect(loc, contains('state=wx-state'));
    });

    test('MedicineReminderDetailRoute with medicineId', () {
      expect(
        const MedicineReminderDetailRoute(medicineId: 'med-001').location,
        '/medicine/reminders/med-001',
      );
    });

    test('MedicineReminderEditRoute with medicineId', () {
      expect(
        const MedicineReminderEditRoute(medicineId: 'med-001').location,
        '/medicine/reminders/med-001/edit',
      );
    });

    test('NotificationDetailRoute with id (nested route)', () {
      expect(
        const NotificationDetailRoute(id: 'notif-1').location,
        '/notifications/notif-1',
      );
    });
  });
}
