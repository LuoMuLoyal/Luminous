/// 全局字号 token。
///
/// 这些值作为 Material `TextTheme` 之外的补充——
/// 当项目未完整覆盖 TextTheme 全部变体时，优先使用这里的 token。
///
/// 参考 Apple 设计语言：body 17px、负字距、weight 300/400/600。
class AppTypography {
  AppTypography._();

  // ── 基础字号 ──

  /// 10px — 微型法律声明文字。
  static const double micro = 10.0;

  /// 12px — 导航 Tab 标签、脚注。
  static const double tab = 12.0;

  /// 13px — 辅助正文（副标题、chip 文字）。
  static const double caption = 13.0;

  /// 14px — 次要正文（列表项、设置项）。
  static const double bodySmall = 14.0;

  /// 15px — 正文（卡片标题、section header）。
  static const double body = 15.0;

  /// 17px — 主正文（Apple 标准 body，比常规 16px 多 1px）。
  static const double bodyLarge = 17.0;

  /// 18px — 按钮文字。
  static const double button = 18.0;

  /// 21px — 标题副文案。
  static const double tagline = 21.0;

  /// 24px — 大段引导文字。
  static const double lead = 24.0;

  /// 28px — 引导正文。
  static const double leadLarge = 28.0;

  /// 34px — 区块标题。
  static const double display = 34.0;

  /// 40px — 大标题。
  static const double displayLarge = 40.0;

  /// 56px — 全屏 Hero 标题。
  static const double hero = 56.0;

  // ── 语义字号 ──

  /// 卡片产品名 / 药名。
  static const double cardTitle = 13.8;

  /// 卡片副标题行 / 规格信息。
  static const double cardMeta = 12.2;
}
