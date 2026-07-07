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
///
/// For routes with path parameters (e.g. `/record/:id`), use the base
/// constant and interpolate the segment, e.g. `'${AppRoutes.record}/$id'`.
class AppRoutes {
  const AppRoutes._();

  // -- Shell tabs --
  static const home = '/';
  static const record = '/record';
  static const medicine = '/medicine';
  static const report = '/report';
  static const mine = '/mine';

  // -- Auth --
  static const login = '/login';
  static const loginOauthWechat = '/login/oauth/wechat';
  static const loginOauthQq = '/login/oauth/qq';
  static const forgotPassword = '/forgot-password';
  static const register = '/register';

  // -- Account --
  static const account = '/account';
  static const accountOauthWechat = '/account/oauth/wechat';
  static const accountChangeEmail = '/account/change-email';

  // -- Settings --
  static const settings = '/settings';
  static const settingsLanguage = '/settings/language';
  static const settingsTheme = '/settings/theme';
  static const settingsMore = '/settings/more';
  static const settingsNotifications = '/settings/notifications';
  static const settingsNotificationsSleep = '/settings/notifications/sleep';
  static const settingsNotificationsDnd = '/settings/notifications/dnd';
  static const settingsAccessibility = '/settings/accessibility';
  static const settingsAi = '/settings/ai';
  static const settingsExport = '/settings/export';
  static const settingsHelp = '/settings/help';
  static const settingsAbout = '/settings/about';
  static const settingsDataStorage = '/settings/data-storage';
  static const settingsSecurityPin = '/settings/security-pin';
  static const settingsFeatureFlags = '/settings/more/feature-flags';

  // -- Record --
  static const recordCreate = '/record/create';
  static const recordDetail = '/record'; // /record/:id
  static const recordEdit = '/record'; // /record/:id/edit

  // -- Medicine --
  static const medicineSearch = '/medicine/search';
  static const medicineRiskCheck = '/medicine/risk-check';
  static const medicineRemindersNew = '/medicine/reminders/new';
  static const medicineReminders =
      '/medicine/reminders'; // /medicine/reminders/:medicineId

  // -- Mine --
  static const mineProfileEdit = '/mine/profile/edit';
  static const mineAllergyNew = '/mine/allergy/new';
  static const mineAllergy = '/mine/allergy'; // /mine/allergy/:id/edit
  static const mineConditionNew = '/mine/condition/new';
  static const mineCondition = '/mine/condition'; // /mine/condition/:id/edit
  static const mineMedicineNew = '/mine/medicine/new';
  static const mineMedicine = '/mine/medicine'; // /mine/medicine/:id/edit

  // -- Notifications --
  static const notifications = '/notifications';

  // -- Assistant --
  static const assistant = '/assistant';

  // -- Scan --
  static const scanBarcode = '/scan/barcode';
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
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellPage(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
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
              path: AppRoutes.record,
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
              path: AppRoutes.medicine,
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
              path: AppRoutes.report,
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
              path: AppRoutes.mine,
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
