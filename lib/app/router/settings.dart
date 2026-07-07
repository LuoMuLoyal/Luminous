import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/settings/presentation/pages/about_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/accessibility_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/advanced_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/ai_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/data_export_page.dart';
import 'package:luminous/features/settings/presentation/pages/data_storage_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/dnd_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/help_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/language_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/page.dart';
import 'package:luminous/features/settings/presentation/pages/sleep_reminder_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/theme_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/feature_flags_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/security_pin_settings_page.dart';

import 'helpers.dart';

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
        routes: [
          GoRoute(
            path: 'feature-flags',
            pageBuilder: (context, state) => slidePage(
              key: state.pageKey,
              child: const FeatureFlagsSettingsPage(),
            ),
          ),
        ],
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
          GoRoute(
            path: 'dnd',
            pageBuilder: (context, state) =>
                slidePage(key: state.pageKey, child: const DndSettingsPage()),
          ),
        ],
      ),
      GoRoute(
        path: 'accessibility',
        pageBuilder: (context, state) => slidePage(
          key: state.pageKey,
          child: const AccessibilitySettingsPage(),
        ),
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
        path: 'data-storage',
        pageBuilder: (context, state) => slidePage(
          key: state.pageKey,
          child: const DataStorageSettingsPage(),
        ),
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
