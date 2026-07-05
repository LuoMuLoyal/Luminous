import 'package:go_router/go_router.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_page.dart';
import 'package:luminous/features/mine/presentation/pages/mine_page.dart';
import 'package:luminous/features/record/presentation/pages/record_page.dart';
import 'package:luminous/features/report/presentation/pages/report_page.dart';
import 'package:luminous/features/shell/presentation/shell_page.dart';
import 'package:luminous/features/today/presentation/pages/today_page.dart';

import 'router/router_account.dart';
import 'router/router_assistant.dart';
import 'router/router_auth.dart';
import 'router/router_medicine.dart';
import 'router/router_mine.dart';
import 'router/router_notifications.dart';
import 'router/router_record.dart';
import 'router/router_scan.dart';
import 'router/router_settings.dart';

/// Named route constants used throughout the codebase.
///
/// Prefer these over hardcoded path strings to avoid typos and make
/// route changes easier to audit.
class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const register = '/register';
  static const account = '/account';
}

/// The main application router.
///
/// The five main tabs live inside a [StatefulShellRoute.indexedStack] so that
/// the desktop sidebar / mobile bottom navigation stays visible while
/// navigating between Tab roots.
///
/// Settings, Assistant, Notifications, and all create/detail/edit sub-pages are
/// top-level full-screen routes so they hide the tab chrome and can be pushed
/// and popped naturally.
final router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellPage(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const TodayPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/record',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const RecordPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/medicine',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const MedicinePage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/report',
              pageBuilder: (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const ReportPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mine',
              pageBuilder: (context, state) =>
                  NoTransitionPage(key: state.pageKey, child: const MinePage()),
            ),
          ],
        ),
      ],
    ),
    // -- full-screen routes (hide tab chrome) --
    ...settingsRoutes,
    ...authRoutes,
    ...accountRoutes,
    ...recordRoutes,
    ...medicineRoutes,
    ...mineRoutes,
    ...notificationsRoutes,
    assistantRoute,
    scanRoute,
  ],
);
