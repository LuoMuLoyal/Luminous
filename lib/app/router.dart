import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/features/assistant/presentation/pages/assistant_page.dart';
import 'package:luminous/features/auth/presentation/pages/account_settings_page.dart';
import 'package:luminous/features/auth/presentation/pages/change_email_page.dart';
import 'package:luminous/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:luminous/features/auth/presentation/pages/login_page.dart';
import 'package:luminous/features/auth/presentation/pages/register_page.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_page.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_risk_check_page.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_reminder_pages.dart';
import 'package:luminous/features/scan/presentation/pages/barcode_scanner_page.dart';
import 'package:luminous/features/mine/presentation/pages/allergy_edit.dart';
import 'package:luminous/features/mine/presentation/pages/condition_edit.dart';
import 'package:luminous/features/mine/presentation/pages/current_medicine_edit.dart';
import 'package:luminous/features/mine/presentation/pages/mine_page.dart';
import 'package:luminous/features/mine/presentation/pages/profile_edit.dart';
import 'package:luminous/features/notification/presentation/pages/notification_detail_page.dart';
import 'package:luminous/features/notification/presentation/pages/notification_list_page.dart';
import 'package:luminous/features/record/domain/entities/record_type_mapping.dart';
import 'package:luminous/features/record/presentation/pages/record_create.dart';
import 'package:luminous/features/record/presentation/pages/record_detail.dart';
import 'package:luminous/features/record/presentation/pages/record_edit.dart';
import 'package:luminous/features/record/presentation/pages/record_page.dart';
import 'package:luminous/features/record/presentation/utils/record_date_time_formatters.dart';
import 'package:luminous/features/report/presentation/pages/report_page.dart';
import 'package:luminous/features/search/presentation/pages/search_page.dart';
import 'package:luminous/features/settings/presentation/pages/about_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/advanced_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/ai_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/data_export_page.dart';
import 'package:luminous/features/settings/presentation/pages/help_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/language_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/sleep_reminder_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/theme_settings_page.dart';
import 'package:luminous/features/today/presentation/pages/today_page.dart';
import 'package:luminous/features/shell/presentation/shell_page.dart';

const _authTransitionIn = Duration(milliseconds: 400);
const _authTransitionOut = Duration(milliseconds: 280);
const _crudTransitionIn = Duration(milliseconds: 220);
const _crudTransitionOut = Duration(milliseconds: 150);

CustomTransitionPage<T> _fadePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
    transitionDuration: _authTransitionIn,
    reverseTransitionDuration: _authTransitionOut,
  );
}

CustomTransitionPage<T> _slidePage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(animation),
            child: child,
          ),
        ),
    transitionDuration: _crudTransitionIn,
    reverseTransitionDuration: _crudTransitionOut,
  );
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
    // -- settings (top-level full-screen) --
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) =>
          _slidePage(key: state.pageKey, child: const SettingsPage()),
      routes: [
        GoRoute(
          path: 'language',
          pageBuilder: (context, state) => _slidePage(
            key: state.pageKey,
            child: const LanguageSettingsPage(),
          ),
        ),
        GoRoute(
          path: 'theme',
          pageBuilder: (context, state) =>
              _slidePage(key: state.pageKey, child: const ThemeSettingsPage()),
        ),
        GoRoute(
          path: 'more',
          pageBuilder: (context, state) => _slidePage(
            key: state.pageKey,
            child: const AdvancedSettingsPage(),
          ),
        ),
        GoRoute(
          path: 'notifications',
          pageBuilder: (context, state) => _slidePage(
            key: state.pageKey,
            child: const NotificationSettingsPage(),
          ),
          routes: [
            GoRoute(
              path: 'sleep',
              pageBuilder: (context, state) => _slidePage(
                key: state.pageKey,
                child: const SleepReminderSettingsPage(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'ai',
          pageBuilder: (context, state) =>
              _slidePage(key: state.pageKey, child: const AiSettingsPage()),
        ),
        GoRoute(
          path: 'export',
          pageBuilder: (context, state) =>
              _slidePage(key: state.pageKey, child: const DataExportPage()),
        ),
        GoRoute(
          path: 'help',
          pageBuilder: (context, state) =>
              _slidePage(key: state.pageKey, child: const HelpSettingsPage()),
        ),
        GoRoute(
          path: 'about',
          pageBuilder: (context, state) =>
              _slidePage(key: state.pageKey, child: const AboutSettingsPage()),
        ),
      ],
    ),
    // -- assistant (top-level full-screen) --
    GoRoute(
      path: '/assistant',
      pageBuilder: (context, state) =>
          _slidePage(key: state.pageKey, child: const AssistantPage()),
    ),
    // -- notifications inbox (top-level full-screen) --
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) =>
          _slidePage(key: state.pageKey, child: const NotificationListPage()),
      routes: [
        GoRoute(
          path: ':id',
          pageBuilder: (context, state) => _slidePage(
            key: state.pageKey,
            child: NotificationDetailPage(
              notificationId: state.pathParameters['id']!,
            ),
          ),
        ),
      ],
    ),
    // -- record sub-pages (top-level full-screen) --
    GoRoute(
      path: '/record/create',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: RecordCreatePage(
          initialKind: dailyRecordKindFromName(
            state.uri.queryParameters['kind'],
          ),
          initialDate: parseRecordDate(state.uri.queryParameters['date']),
          initialTime: state.uri.queryParameters['time'],
        ),
      ),
    ),
    GoRoute(
      path: '/record/:id',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: RecordDetailPage(recordId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/record/:id/edit',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: RecordEditPage(recordId: state.pathParameters['id']!),
      ),
    ),
    // -- medicine sub-pages (top-level full-screen) --
    GoRoute(
      path: '/medicine/search',
      pageBuilder: (context, state) =>
          _slidePage(key: state.pageKey, child: const SearchPage()),
    ),
    GoRoute(
      path: '/medicine/risk-check',
      pageBuilder: (context, state) =>
          _slidePage(key: state.pageKey, child: const MedicineRiskCheckPage()),
    ),
    GoRoute(
      path: '/medicine/reminders/new',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: MedicineReminderEditPage(
          initialMedicineId: state.uri.queryParameters['medicineId'],
        ),
      ),
    ),
    GoRoute(
      path: '/medicine/reminders/:medicineId',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: MedicineReminderDetailPage(
          currentMedicineId: state.pathParameters['medicineId']!,
        ),
      ),
    ),
    GoRoute(
      path: '/medicine/reminders/:medicineId/edit',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: MedicineReminderEditPage(
          currentMedicineId: state.pathParameters['medicineId'],
        ),
      ),
    ),
    // -- mine sub-pages (top-level full-screen) --
    GoRoute(
      path: '/mine/profile/edit',
      pageBuilder: (context, state) =>
          _slidePage(key: state.pageKey, child: const ProfileEditPage()),
    ),
    GoRoute(
      path: '/mine/allergy/new',
      pageBuilder: (context, state) =>
          _slidePage(key: state.pageKey, child: const AllergyEditPage()),
    ),
    GoRoute(
      path: '/mine/allergy/:id/edit',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: AllergyEditPage(allergyId: state.pathParameters['id']),
      ),
    ),
    GoRoute(
      path: '/mine/condition/new',
      pageBuilder: (context, state) =>
          _slidePage(key: state.pageKey, child: const ConditionEditPage()),
    ),
    GoRoute(
      path: '/mine/condition/:id/edit',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: ConditionEditPage(conditionId: state.pathParameters['id']),
      ),
    ),
    GoRoute(
      path: '/mine/medicine/new',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: const CurrentMedicineEditPage(),
      ),
    ),
    GoRoute(
      path: '/mine/medicine/:id/edit',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: CurrentMedicineEditPage(medicineId: state.pathParameters['id']),
      ),
    ),
    // -- auth (fade) --
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _fadePage(
        key: state.pageKey,
        child: LoginPage(returnTo: state.uri.queryParameters['returnTo']),
      ),
    ),
    GoRoute(
      path: '/login/oauth/wechat',
      pageBuilder: (context, state) => _fadePage(
        key: state.pageKey,
        child: LoginPage(
          wechatCode: state.uri.queryParameters['code'],
          wechatState: state.uri.queryParameters['state'],
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
    ),
    GoRoute(
      path: '/login/oauth/qq',
      pageBuilder: (context, state) => _fadePage(
        key: state.pageKey,
        child: LoginPage(
          qqCode: state.uri.queryParameters['code'],
          qqState: state.uri.queryParameters['state'],
          returnTo: state.uri.queryParameters['returnTo'],
        ),
      ),
    ),
    GoRoute(
      path: '/forgot-password',
      pageBuilder: (context, state) =>
          _fadePage(key: state.pageKey, child: const ForgotPasswordPage()),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) =>
          _fadePage(key: state.pageKey, child: const RegisterPage()),
    ),
    // -- account management (slide, full-screen) --
    GoRoute(
      path: '/account',
      pageBuilder: (context, state) =>
          _slidePage(key: state.pageKey, child: const AccountSettingsPage()),
    ),
    GoRoute(
      path: '/account/oauth/wechat',
      pageBuilder: (context, state) => _slidePage(
        key: state.pageKey,
        child: AccountSettingsPage(
          wechatCode: state.uri.queryParameters['code'],
          wechatState: state.uri.queryParameters['state'],
        ),
      ),
    ),
    GoRoute(
      path: '/account/change-email',
      pageBuilder: (context, state) =>
          _slidePage(key: state.pageKey, child: const ChangeEmailPage()),
    ),
    // -- scan --
    GoRoute(
      path: '/scan/barcode',
      pageBuilder: (context, state) =>
          _slidePage(key: state.pageKey, child: const BarcodeScannerPage()),
    ),
  ],
);
