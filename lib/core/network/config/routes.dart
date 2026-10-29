/// Route paths as plain string constants.
///
/// Paths are part of the app's public navigation surface and are read by
/// non-UI code too (deep-link validation, archive row targets in the mine
/// data layer), so they live in a dependency-free file. `lib/app/router.dart`
/// re-exports them.
library;

/// Route paths as plain string constants.
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
  static const loginOauthGoogle = '/login/oauth/google';
  static const forgotPassword = '/forgot-password';
  static const register = '/register';

  static const account = '/account';
  static const accountOauthWechat = '/account/oauth/wechat';
  static const accountChangeEmail = '/account/change-email';
  static const accountSessions = '/account/sessions';
  static const accountSecurityCenter = '/account/security-center';

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

  static const profile = '/profile';

  static const recordCreate = '/record/create';
  static const recordQuickEntrySettings = '/record/quick-entry-settings';
  static const recordQuickEntryReorder = '/record/quick-entry-settings/reorder';

  static const medicineSearch = '/medicine/search';
  static const medicineDetail = '/medicine/detail';
  static const medicineRiskCheck = '/medicine/risk-check';
  static const medicineRemindersNew = '/medicine/reminders/new';

  static const mineAllergyNew = '/mine/allergy/new';
  static const mineConditionNew = '/mine/condition/new';
  static const mineMedicineNew = '/mine/medicine/new';
  static const mineSyncFailures = '/mine/sync/failures';

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
