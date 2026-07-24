/// Centralized SharedPreferences key registry.
///
/// All SharedPreferences keys used across the app are defined here to:
///   - Prevent key collisions between features.
///   - Make it easy to audit what is persisted locally.
///   - Enable centralized key renaming/migration if needed.
///
/// Convention: `domain.subdomain.field` in dot notation.
abstract final class PrefKeys {
  // ── Auth / Session ─────────────────────────────────────────────────────

  static const accessToken = 'lucent_access_token';
  static const refreshToken = 'lucent_refresh_token';

  // ── App ────────────────────────────────────────────────────────────────

  static const appLocale = 'app.locale';

  /// Whether the desktop sidebar is collapsed (icon-only rail mode).
  static const sidebarCollapsed = 'app.sidebar.collapsed';

  // ── Theme ──────────────────────────────────────────────────────────────

  static const themeMode = 'theme.mode';
  static const themeFamily = 'theme.family';

  // ── Accessibility ──────────────────────────────────────────────────────

  static const accessibilityFontSize = 'accessibility.fontSize';
  static const accessibilityReduceAnimations = 'accessibility.reduceAnimations';
  static const accessibilityHighContrast = 'accessibility.highContrast';

  // ── Developer Settings ─────────────────────────────────────────────────

  static const developerApiEndpoint = 'developer.apiEndpoint';
  static const developerCustomApiUrl = 'developer.customApiUrl';
  static const developerLogLevel = 'developer.logLevel';

  // ── Feature Flags ─────────────────────────────────────────────────────

  static const featureFlagsOnDeviceAiRuntime = 'featureFlags.onDeviceAiRuntime';
  static const featureFlagsAiRuntimeProvider = 'featureFlags.aiRuntimeProvider';
  static const featureFlagsGenUiEnabled = 'featureFlags.genUiEnabled';
  static const featureFlagsAssistantStreamMode =
      'featureFlags.assistantStreamMode';
  static const featureFlagsMedicineBarcodeScan =
      'featureFlags.medicineBarcodeScan';
  static const featureFlagsReportExportPdf = 'featureFlags.reportExportPdf';

  // ── Medicine ───────────────────────────────────────────────────────────

  static const medicineReminderSound = 'medicine.reminder.sound';
  static const medicineReminderScheduledNotificationIds =
      'medicine.reminder.scheduledNotificationIds';

  // ── Record ─────────────────────────────────────────────────────────────

  static const recordQuickEntryDynamicSort =
      'record.quickEntry.dynamicSortEnabled';
  static const recordQuickEntryCustomOrder = 'record.quickEntry.customOrder';
  static const recordQuickEntryCollapsed = 'record.quickEntry.collapsed';

  /// Prefix for frequency-count keys: `record.quickEntry.freq.<type>`.
  static const recordQuickEntryFrequencyPrefix = 'record.quickEntry.freq.';

  // ── Settings / Notifications ──────────────────────────────────────────

  static const settingsNotificationsMedicationReminders =
      'settings.notifications.medicationReminders';
  static const settingsNotificationsHealthAlerts =
      'settings.notifications.healthAlerts';
  static const settingsNotificationsWeeklySummary =
      'settings.notifications.weeklySummary';
  static const settingsNotificationsWaterReminders =
      'settings.notifications.waterReminders';
  static const settingsNotificationsSleepReminders =
      'settings.notifications.sleepReminders';
  static const settingsNotificationsSleepReminderEnabled =
      'settings.notifications.sleepReminderEnabled';
  static const settingsNotificationsSleepBedtime =
      'settings.notifications.sleepBedtime';
  static const settingsNotificationsSleepWakeTime =
      'settings.notifications.sleepWakeTime';
  static const settingsNotificationsDndEnabled =
      'settings.notifications.dnd.enabled';
  static const settingsNotificationsDndStartTime =
      'settings.notifications.dnd.startTime';
  static const settingsNotificationsDndEndTime =
      'settings.notifications.dnd.endTime';
  static const settingsNotificationsSoundEnabled =
      'settings.notifications.soundEnabled';
  static const settingsNotificationsVibrationEnabled =
      'settings.notifications.vibrationEnabled';
  static const settingsNotificationsReminderAdvanceMinutes =
      'settings.notifications.reminderAdvanceMinutes';

  // ── Settings / Data Storage ───────────────────────────────────────────

  static const settingsDataStorageRetentionPeriod =
      'settings.dataStorage.retentionPeriod';
  static const settingsDataStorageImageQuality =
      'settings.dataStorage.imageQuality';
  static const settingsDataStorageSyncPreference =
      'settings.dataStorage.syncPreference';
}
