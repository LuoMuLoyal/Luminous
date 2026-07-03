import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/widgets/common/app_back_button.dart';

/// 统一子页 scaffold。
///
/// 封装了 Forui 子页最常见的结构：
/// - [FScaffold] 关闭默认的 [FScaffold.childPad]，由 body 自行决定内边距。
/// - [FHeader.nested] 作为顶部标题栏，标题居中，左侧默认 [AppBackButton]。
/// - body 顶部关闭 [SafeArea]，避免与 header 的 SafeArea 重复计算。
///
/// 视觉边界：header 与 body 共享同一背景，不额外添加底部分割线或背景色。
/// 如需分割线在调用处自行包装 [header] 或在 [FScaffold] 的 headerDecoration 中设置。
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    this.centerTitle = true,
    this.leading = const AppBackButton(),
    this.actions = const [],
    required this.child,
    this.resizeToAvoidBottomInset = true,
    this.useSafeArea = true,
  });

  /// 页面标题，会包装为 [Text]。
  final String title;

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

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      childPad: false,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      header: FHeader.nested(
        title: Text(title),
        titleAlignment: centerTitle ? Alignment.center : Alignment.centerLeft,
        prefixes: leading == null ? const [] : [leading!],
        suffixes: actions,
      ),
      child: useSafeArea ? SafeArea(top: false, child: child) : child,
    );
  }
}
