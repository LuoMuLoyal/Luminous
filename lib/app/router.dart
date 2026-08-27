import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router/helpers.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/assistant/presentation/routes.dart'
    as assistant_routes;
import 'package:luminous/features/auth/presentation/routes.dart' as auth_routes;
import 'package:luminous/features/health_data/presentation/routes.dart'
    as health_data_routes;
import 'package:luminous/features/legal/presentation/routes.dart'
    as legal_routes;
import 'package:luminous/features/medicine/presentation/pages/page.dart';
import 'package:luminous/features/medicine/presentation/routes.dart'
    as medicine_routes;
import 'package:luminous/features/mine/presentation/pages/page.dart';
import 'package:luminous/features/mine/presentation/routes.dart' as mine_routes;
import 'package:luminous/features/notification/presentation/routes.dart'
    as notification_routes;
import 'package:luminous/features/record/presentation/pages/page.dart';
import 'package:luminous/features/record/presentation/routes.dart'
    as record_routes;
import 'package:luminous/features/review/presentation/pages/clinic_summary_shared.dart';
import 'package:luminous/features/review/presentation/pages/legacy_dashboard_compat.dart';
import 'package:luminous/features/review/presentation/pages/page.dart';
import 'package:luminous/features/review/presentation/pages/review_detail.dart';
import 'package:luminous/features/scan/presentation/routes.dart' as scan_routes;
import 'package:luminous/features/settings/presentation/routes.dart'
    as settings_routes;
import 'package:luminous/features/shell/presentation/page.dart';
import 'package:luminous/features/today/presentation/pages/page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

part 'router.g.dart';

/// Named route constants used throughout the codebase.
///
/// Prefer these over hardcoded path strings to avoid typos and make
/// route changes easier to audit.
///
/// For routes with path parameters (e.g. `/record/:id`), use the typed
/// route class (e.g. `RecordDetailRoute(id: id).push(context)`) instead
/// of interpolating path strings.
class Routes {
  const Routes._();

  // -- Shell tabs (kept for tab switching via context.go) --
  static const home = '/';
  static const record = '/record';
  static const medicine = '/medicine';

  /// Fifth tab route (Review / 回顾).
  static const review = '/review';
  static const mine = '/mine';

  // -- Non-navigation path references (deep link validation, OAuth URIs) --
  static const login = '/login';
  static const loginOauthWechat = '/login/oauth/wechat';
  static const loginOauthQq = '/login/oauth/qq';
  static const loginOauthWeibo = '/login/oauth/weibo';
  static const loginOauthGoogle = '/login/oauth/google';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const register = '/register';

  static const account = '/account';
  static const accountOauthWechat = '/account/oauth/wechat';
  static const accountChangeEmail = '/account/change-email';
  static const accountSessions = '/account/sessions';

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
  static const settingsFeatureFlags = '/settings/more/feature-flags';

  static const recordCreate = '/record/create';
  static const recordQuickEntrySettings = '/record/quick-entry-settings';
  static const recordQuickEntryReorder = '/record/quick-entry-settings/reorder';

  static const medicineSearch = '/medicine/search';
  static const medicineDetail = '/medicine/detail';
  static const medicineRiskCheck = '/medicine/risk-check';
  static const medicineRemindersNew = '/medicine/reminders/new';

  static const mineProfileEdit = '/mine/profile/edit';
  static const mineAllergyNew = '/mine/allergy/new';
  static const mineConditionNew = '/mine/condition/new';
  static const mineMedicineNew = '/mine/medicine/new';

  static const notifications = '/notifications';

  static const assistant = '/assistant';

  static const scanBarcode = '/scan/barcode';

  static const healthSync = '/health-sync';

  static const legal = '/legal';
  static const legalDetail = '/legal/:docType';

  static const reviewClinicSummaryShared = '/review/clinic-summary/:token';

  /// Legacy dashboard 兼容页（Task 8）：从 Review 页 More sheet 的
  /// 「历史报告」入口进入，重建旧 dashboard 装配（7/30 天切换、导出卡）。
  static const reviewLegacyDashboard = '/review/legacy';

  /// 单个历史事件的完整回顾详情页（改造项 2 H-6）：从 Review 页历史行
  /// 点入，复用事件头部 + 四段渲染。
  static const reviewDetail = '/review/review/:eventId';
}

/// Route prefixes that are publicly accessible without authentication.
///
/// Auth routes (`/login`, `/register`, `/forgot-password`) are handled
/// separately in the redirect guard. Add new public route prefixes here
/// when introducing pages that should be viewable while signed out
/// (e.g. shared clinic summaries, legal documents).
const _publicRoutePrefixes = <String>[
  '/legal',
  '/medicine/detail',
  '/review/clinic-summary',
  // Legacy dashboard 兼容页沿用 `/review` 的公开预览语义（未登录显示
  // preview 内容 + 登录引导，不重定向到 /login）。
  '/review/legacy',
];

/// Top-level routes that can be visited while signed out so the user can
/// preview the app before deciding to sign in.
///
/// These include the five main shell tabs plus standalone pages that already
/// render their own sign-in prompts when needed. Any other route requires
/// authentication.
const _publicRootRoutes = <String>[
  Routes.home,
  Routes.record,
  Routes.medicine,
  Routes.review,
  Routes.mine,
  Routes.settings,
  Routes.assistant,
];

/// The main application router.
///
/// The five main tabs live inside a [StatefulShellRoute.indexedStack] so that
/// the desktop sidebar / mobile bottom navigation stays visible while
/// navigating between Tab roots.
///
/// All sub-pages are top-level full-screen routes (generated by
/// `go_router_builder`) so they hide the tab chrome and can be pushed
/// and popped naturally.
///
/// The `redirect` guard sends authenticated users away from auth pages and
/// requires authentication for any route that is not explicitly public.
/// Unauthenticated users can still browse the public preview routes (main
/// tabs, settings, assistant, etc.) and decide when to sign in.
/// Call `appRouterProvider`'s `refresh()` (e.g. from an auth session
/// listener) to re-evaluate the redirect after authentication state changes.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) => GoRouter(
  initialLocation: Routes.home,
  // Starts a Sentry route transaction per navigation; dio requests then
  // become child spans carrying the same traceId (Sentry NavigatorObserver
  // is a no-op when Sentry is not initialized, e.g. in tests).
  observers: [SentryNavigatorObserver()],
  redirect: (context, state) {
    final session = ref.read(authSessionProvider);

    // Don't redirect while session is being restored (prevents flicker).
    if (session.isRestoring) return null;

    final location = state.matchedLocation;
    final isAuthRoute =
        location.startsWith('/login') ||
        location.startsWith('/register') ||
        location.startsWith('/forgot-password') ||
        location.startsWith('/reset-password');
    final isPublicRoute =
        _publicRoutePrefixes.any((prefix) => location.startsWith(prefix)) ||
        _publicRootRoutes.contains(location);

    // Public routes (including the main shell tabs) are accessible without
    // signing in so the app opens in preview mode. All other routes require
    // authentication.
    if (!session.isAuthenticated && !isAuthRoute && !isPublicRoute) {
      return Routes.login;
    }
    // Authenticated users have no reason to stay on auth pages.
    if (session.isAuthenticated && isAuthRoute) {
      return Routes.home;
    }
    return null;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellPage(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home,
              pageBuilder: (context, state) =>
                  tabFadePage(key: state.pageKey, child: const TodayPage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.record,
              pageBuilder: (context, state) =>
                  tabFadePage(key: state.pageKey, child: const RecordPage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.medicine,
              pageBuilder: (context, state) =>
                  tabFadePage(key: state.pageKey, child: const MedicinePage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.review,
              pageBuilder: (context, state) =>
                  tabFadePage(key: state.pageKey, child: const ReviewPage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.mine,
              pageBuilder: (context, state) =>
                  tabFadePage(key: state.pageKey, child: const MinePage()),
            ),
          ],
        ),
      ],
    ),
    // -- full-screen routes (hide tab chrome) --
    // Generated by go_router_builder from each feature's presentation/routes.dart
    ...auth_routes.$appRoutes,
    ...record_routes.$appRoutes,
    ...medicine_routes.$appRoutes,
    ...mine_routes.$appRoutes,
    ...settings_routes.$appRoutes,
    ...notification_routes.$appRoutes,
    ...assistant_routes.$appRoutes,
    ...scan_routes.$appRoutes,
    ...health_data_routes.$appRoutes,
    ...legal_routes.$appRoutes,
    // -- public shared clinic summary (deep link, no auth required) --
    GoRoute(
      path: Routes.reviewClinicSummaryShared,
      pageBuilder: (context, state) {
        final token = state.pathParameters['token'];
        if (token == null) {
          return slidePage(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(child: Text('Invalid link: missing token.')),
            ),
          );
        }
        return slidePage(
          key: state.pageKey,
          child: ClinicSummarySharedPage(token: token),
        );
      },
    ),
    // -- legacy dashboard compatibility page (Review More sheet entry) --
    GoRoute(
      path: Routes.reviewLegacyDashboard,
      pageBuilder: (context, state) => slidePage(
        key: state.pageKey,
        child: const LegacyDashboardCompatPage(),
      ),
    ),
    // -- event review detail page (history row tap, requires auth) --
    GoRoute(
      path: Routes.reviewDetail,
      pageBuilder: (context, state) {
        final eventId = state.pathParameters['eventId'];
        if (eventId == null) {
          return slidePage(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(child: Text('Invalid link: missing event ID.')),
            ),
          );
        }
        return slidePage(
          key: state.pageKey,
          child: ReviewDetailPage(eventId: eventId),
        );
      },
    ),
  ],
);
