/// 全局字号 token。
///
/// 这些值作为 Material `TextTheme` 之外的补充——
/// 当项目未完整覆盖 TextTheme 全部变体时，优先使用这里的 token。
///
/// 基于 DESIGN.md（Airbnb 设计语言）更新：
/// 字重适度，display 以 500–600 为主，仅 hero rating 使用 700。
class AppTypography {
  AppTypography._();

  // ── 基础字号 ──

  /// 8px — 微型标签（uppercase-tag / "NEW" badge）。
  static const double microTag = 8.0;

  /// 11px — 徽章文字（guest-favorite-badge）。
  static const double badge = 11.0;

  /// 12px — 导航 Tab 标签、脚注、micro-label。
  static const double tab = 12.0;

  /// 13px — 辅助正文（caption-sm、副标题、chip 文字）。
  static const double caption = 13.0;

  /// 14px — 次要正文（body-sm、列表项、设置项）。
  static const double bodySmall = 14.0;

  /// 16px — 正文（body-md、button-md、title-md，Airbnb 标准 body）。
  static const double body = 16.0;

  /// 17px — 主正文（Apple body，比常规 16px 多 1px）。
  static const double bodyLarge = 17.0;

  /// 18px — 按钮文字。
  static const double button = 18.0;

  /// 20px — 子区块标题（display-sm）。
  static const double titleLg = 20.0;

  /// 21px — 标题副文案 / section header（display-md / tagline）。
  static const double tagline = 21.0;

  /// 22px — 列表详情标题（display-lg）。
  static const double display = 22.0;

  /// 24px — 大段引导文字。
  static const double lead = 24.0;

  /// 28px — 首页大标题（display-xl）。
  static const double displayLarge = 28.0;

  /// 64px — 评分展示（rating-display，系统最大字号）。
  static const double hero = 64.0;

  // ── 语义字号 ──

  /// 卡片产品名 / 药名。
  static const double cardTitle = 13.8;

  /// 卡片副标题行 / 规格信息。
  static const double cardMeta = 12.2;
}
