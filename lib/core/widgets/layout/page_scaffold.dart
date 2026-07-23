import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/widgets/common/back_button.dart';

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
      child: useSafeArea ? SafeArea(top: false, child: child) : child,
    );
  }
}
