/// Responsive layout breakpoints.
///
/// These are layout helpers, not visual design tokens. They define width
/// thresholds where the page structure (columns, sidebars, max content width)
/// changes; color, spacing, radius, and typography values should come from
/// the current Forui theme or the dedicated token files instead.
///
/// ## 阈值以 Material 3 window size class 为准
///
/// 主分档（[mobile] / [expanded] / [desktop]）与 `fluid_adaptive` 的
/// `ResponsiveBreakpoints.standard` 一致（600 / 840 / 1200），`LayoutScaleResolver`
/// 直接用包的标准断点分档。**新增阈值前先确认包是否已有对应档位**——两套阈值
/// 并存时，布局分档与组件内判断会各说各的。
///
/// 其余常量是结构性辅助：小于主分档的细粒度断点，或宽屏以上的内容上限。
abstract final class Breakpoints {
  /// Very small phones (≤360px). Text may need extra truncation.
  ///
  /// 不是分档边界，只用于「一行放不下就退化为换行/堆叠」这类局部判断。
  static const double compact = 360;

  /// M3 `compact` 上限：`< 600` 是手机，`≥ 600` 进入 `medium`。
  static const double mobile = 600;

  /// M3 `expanded` 起点：`≥ 840` 进入大平板 / 小笔记本。
  ///
  /// 原名 `tablet`（值 960）。改名为 `expanded` 是去掉「平板」这个设备
  /// 意象——同一个宽度在桌面窗口窄化时也会命中，按设备命名会误导判断。
  static const double expanded = 840;

  /// 小桌面过渡区（840–1200）的中段参考值，用于两列网格的少量细粒度判断。
  ///
  /// 不参与 `LayoutScaleResolver` 分档：那层只认 M3 的四档。
  static const double smallDesktop = 1080;

  /// M3 `large` 起点：`≥ 1200` 是桌面窗口。
  static const double desktop = 1200;

  /// 宽屏参考值（≥1400）。用于「是否放宽内容宽度上限」这类局部判断，
  /// 不新增布局档位。
  static const double wide = 1400;

  /// Ultra-wide monitors (≥1920). Content may use 3 columns or wider
  /// max-width.
  static const double ultrawide = 1920;

  /// Fixed max-width for assistant panels and auth forms.
  static const double assistantContent = 560;
}
