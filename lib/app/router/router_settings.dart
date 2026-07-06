import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
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
import 'package:luminous/features/settings/presentation/pages/security_pin_settings_page.dart';

import 'router_helpers.dart';

final settingsRoutes = [
  GoRoute(
    path: AppRoutes.settings,
    pageBuilder: (context, state) =>
        slidePage(key: state.pageKey, child: const SettingsPage()),
    routes: [
      GoRoute(
        path: 'language',
        pageBuilder: (context, state) =>
            slidePage(key: state.pageKey, child: const LanguageSettingsPage()),
      ),
      GoRoute(
        path: 'theme',
        pageBuilder: (context, state) =>
            slidePage(key: state.pageKey, child: const ThemeSettingsPage()),
      ),
      GoRoute(
        path: 'more',
        pageBuilder: (context, state) =>
            slidePage(key: state.pageKey, child: const AdvancedSettingsPage()),
      ),
      GoRoute(
        path: 'notifications',
        pageBuilder: (context, state) => slidePage(
          key: state.pageKey,
          child: const NotificationSettingsPage(),
        ),
        routes: [
          GoRoute(
            path: 'sleep',
            pageBuilder: (context, state) => slidePage(
              key: state.pageKey,
              child: const SleepReminderSettingsPage(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: 'ai',
        pageBuilder: (context, state) =>
            slidePage(key: state.pageKey, child: const AiSettingsPage()),
      ),
      GoRoute(
        path: 'export',
        pageBuilder: (context, state) =>
            slidePage(key: state.pageKey, child: const DataExportPage()),
      ),
      GoRoute(
        path: 'help',
        pageBuilder: (context, state) =>
            slidePage(key: state.pageKey, child: const HelpSettingsPage()),
      ),
      GoRoute(
        path: 'about',
        pageBuilder: (context, state) =>
            slidePage(key: state.pageKey, child: const AboutSettingsPage()),
      ),
      GoRoute(
        path: 'security-pin',
        pageBuilder: (context, state) => slidePage(
          key: state.pageKey,
          child: const SecurityPinSettingsPage(),
        ),
      ),
    ],
  ),
];
