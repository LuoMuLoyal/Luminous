import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router/helpers.dart';
import 'package:luminous/features/settings/presentation/pages/about_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/accessibility_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/advanced_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/ai_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/data_export_page.dart';
import 'package:luminous/features/settings/presentation/pages/data_storage_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/dnd_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/feature_flags_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/help_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/language_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/page.dart';
import 'package:luminous/features/settings/presentation/pages/security_pin_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/sleep_reminder_settings_page.dart';
import 'package:luminous/features/settings/presentation/pages/theme_settings_page.dart';

part 'routes.g.dart';

@TypedGoRoute<SettingsRoute>(
  path: '/settings',
  routes: [
    TypedGoRoute<SettingsLanguageRoute>(path: 'language'),
    TypedGoRoute<SettingsThemeRoute>(path: 'theme'),
    TypedGoRoute<SettingsMoreRoute>(
      path: 'more',
      routes: [TypedGoRoute<SettingsFeatureFlagsRoute>(path: 'feature-flags')],
    ),
    TypedGoRoute<SettingsNotificationsRoute>(
      path: 'notifications',
      routes: [
        TypedGoRoute<SettingsNotificationsSleepRoute>(path: 'sleep'),
        TypedGoRoute<SettingsNotificationsDndRoute>(path: 'dnd'),
      ],
    ),
    TypedGoRoute<SettingsAccessibilityRoute>(path: 'accessibility'),
    TypedGoRoute<SettingsAiRoute>(path: 'ai'),
    TypedGoRoute<SettingsExportRoute>(path: 'export'),
    TypedGoRoute<SettingsHelpRoute>(path: 'help'),
    TypedGoRoute<SettingsAboutRoute>(path: 'about'),
    TypedGoRoute<SettingsDataStorageRoute>(path: 'data-storage'),
    TypedGoRoute<SettingsSecurityPinRoute>(path: 'security-pin'),
  ],
)
class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const SettingsPage());
  }
}

class SettingsLanguageRoute extends GoRouteData with $SettingsLanguageRoute {
  const SettingsLanguageRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const LanguageSettingsPage());
  }
}

class SettingsThemeRoute extends GoRouteData with $SettingsThemeRoute {
  const SettingsThemeRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const ThemeSettingsPage());
  }
}

class SettingsMoreRoute extends GoRouteData with $SettingsMoreRoute {
  const SettingsMoreRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const AdvancedSettingsPage());
  }
}

class SettingsFeatureFlagsRoute extends GoRouteData
    with $SettingsFeatureFlagsRoute {
  const SettingsFeatureFlagsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: const FeatureFlagsSettingsPage(),
    );
  }
}

class SettingsNotificationsRoute extends GoRouteData
    with $SettingsNotificationsRoute {
  const SettingsNotificationsRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: const NotificationSettingsPage(),
    );
  }
}

class SettingsNotificationsSleepRoute extends GoRouteData
    with $SettingsNotificationsSleepRoute {
  const SettingsNotificationsSleepRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: const SleepReminderSettingsPage(),
    );
  }
}

class SettingsNotificationsDndRoute extends GoRouteData
    with $SettingsNotificationsDndRoute {
  const SettingsNotificationsDndRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const DndSettingsPage());
  }
}

class SettingsAccessibilityRoute extends GoRouteData
    with $SettingsAccessibilityRoute {
  const SettingsAccessibilityRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: const AccessibilitySettingsPage(),
    );
  }
}

class SettingsAiRoute extends GoRouteData with $SettingsAiRoute {
  const SettingsAiRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const AiSettingsPage());
  }
}

class SettingsExportRoute extends GoRouteData with $SettingsExportRoute {
  const SettingsExportRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const DataExportPage());
  }
}

class SettingsHelpRoute extends GoRouteData with $SettingsHelpRoute {
  const SettingsHelpRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const HelpSettingsPage());
  }
}

class SettingsAboutRoute extends GoRouteData with $SettingsAboutRoute {
  const SettingsAboutRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(key: state.pageKey, child: const AboutSettingsPage());
  }
}

class SettingsDataStorageRoute extends GoRouteData
    with $SettingsDataStorageRoute {
  const SettingsDataStorageRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: const DataStorageSettingsPage(),
    );
  }
}

class SettingsSecurityPinRoute extends GoRouteData
    with $SettingsSecurityPinRoute {
  const SettingsSecurityPinRoute();

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return slidePage(
      key: state.pageKey,
      child: const SecurityPinSettingsPage(),
    );
  }
}
