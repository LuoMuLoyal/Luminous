/// 应用路由路径常量表。
///
/// 放在 `lib/core/router/` 而不是 `lib/app/router.dart`：这张常量表被
/// `core/` 与各 feature 广泛引用，若定义在组合根里会让 `core → app` 形成
/// 依赖环（arch_guard）。`lib/app/router.dart` 只负责装配 `GoRouter`，
/// 并 re-export 本文件以保持既有 `Routes.*` 调用点可用。
///
/// 注意与同目录的 `routes.dart`（`CoreRoutes`，core 的极简镜像）区分：
/// 那份只服务 core 的跨层工具，这份是应用全量路由表。
library;

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

  /// 编排页前缀；具体 location 由 `CustomizeRoute(surface: …).location` 生成。
  static const customize = '/customize';

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
