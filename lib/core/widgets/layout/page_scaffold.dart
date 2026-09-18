import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/widgets/common/control/back_button.dart';

/// Unified sub-page scaffold.
///
/// Encapsulates the most common Forui sub-page structure:
/// - [FScaffold] with default [FScaffold.childPad] disabled; body manages its own padding.
/// - [FHeader.nested] as the top title bar, centered title, [AppBackButton] on the left by default.
/// - [SafeArea] disabled at the top of body to avoid duplicate calculation with header's SafeArea.
///
/// Visual boundary: header and body share the same background; no extra bottom divider or
/// background color. For a divider, wrap [header] at the call site or set [FScaffold]'s headerDecoration.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    this.title,
    this.titleWidget,
    this.centerTitle = true,
    this.leading = const AppBackButton(),
    this.actions = const [],
    required this.child,
    this.resizeToAvoidBottomInset = true,
    this.useSafeArea = true,
    this.headerStyle = const FHeaderStyleDelta.context(),
  }) : assert(
         title != null || titleWidget != null,
         'title or titleWidget must be provided',
       );

  /// 页面标题，会包装为 [Text]。
  ///
  /// 与 [titleWidget] 互斥，优先使用 [titleWidget]。
  final String? title;

  /// 自定义标题 widget。
  ///
  /// 传入时优先于 [title]。
  final Widget? titleWidget;

  /// 标题是否居中。默认为 `true`；设为 `false` 时标题左对齐。
  final bool centerTitle;

  /// 左侧操作按钮。默认为 [AppBackButton]，传 `null` 表示不显示返回按钮。
  final Widget? leading;

  /// 右侧操作按钮列表。
  final List<Widget> actions;

  /// 页面主体内容。
  final Widget child;

  /// 是否根据键盘高度调整 body 大小。
  final bool resizeToAvoidBottomInset;

  /// 是否在 body 顶部关闭 [SafeArea]。默认为 `true`。
  ///
  /// 全屏页面（如扫码）可设为 `false`，让 child 自行处理安全区域。
  final bool useSafeArea;

  /// 自定义 header 样式。默认为 Forui 上下文样式。
  final FHeaderStyleDelta headerStyle;

  @override
  Widget build(BuildContext context) {
    final content = useSafeArea ? SafeArea(top: false, child: child) : child;

    // Forui 的 `_RenderScaffold.performLayout` 为 footer 预留
    // `max(insets.bottom, footerHeight)`,即底部 inset 已在 scaffold 层被计入
    // 一次;但它不像 Material `Scaffold` 那样对主体 `removeViewInsets`。于是
    // 主体内再消费一次底部 inset 的组件(AI chat 的 composer 会给自身加底部
    // 内边距)会把同一份 inset 算两遍,视口被压到不足 inset + 输入区高度时
    // 即产生溢出。这里去掉底部 inset(正是 Forui 缺失、Material 具备的语义),
    // 布局收缩本身仍由 FScaffold 负责。
    // `resizeToAvoidBottomInset: false` 时 scaffold 未消费 inset,保留给主体自行处理。
    return FScaffold(
      childPad: false,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      header: FHeader.nested(
        title: titleWidget ?? Text(title!),
        titleAlignment: centerTitle ? Alignment.center : Alignment.centerLeft,
        prefixes: leading == null ? const [] : [leading!],
        suffixes: actions,
        style: headerStyle,
      ),
      child: resizeToAvoidBottomInset
          ? MediaQuery.removeViewInsets(
              context: context,
              removeBottom: true,
              child: content,
            )
          : content,
    );
  }
}
