import 'package:flutter/material.dart';

import 'package:forui/forui.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/surface_title_button.dart';
import 'package:luminous/core/widgets/common/feedback/refresh_indicator.dart';

/// Desktop tab page unified shell.
///
/// Used by [ShellPage] on desktop, providing all tab pages with:
/// - FHeader.nested (title + suffixes)
/// - Content area max-width constraint (shared with header for horizontal alignment)
/// - Content area background color (scaffold background, to distinguish from sidebar)
/// - Unified padding
/// - Optional pull-to-refresh (onRefresh) and scroll position preservation (scrollStorageKey)
class DesktopTabShell extends StatelessWidget {
  const DesktopTabShell({
    super.key,
    required this.title,
    this.titleSurface,
    this.suffixes = const [],
    required this.child,
    this.scrollable = true,
    this.onRefresh,
    this.scrollStorageKey,
    this.showHeader = true,
  });

  /// 主标题，显示在 FHeader 中。
  final String title;

  /// 该标题对应的 surface：传入时标题变成按钮，点一下进入这页的编排页。
  ///
  /// 默认 `null` 保持纯文本标题——编排入口是 tab 根页的能力，不是所有
  /// 复用这个外壳的页面的能力。
  final SurfaceId? titleSurface;

  /// 右侧操作按钮列表（FHeader.suffixes）。
  final List<Widget> suffixes;

  /// 内容 Widget。
  final Widget child;

  /// 是否使用滚动容器包裹内容。默认 true。
  /// 某些页面（如 Today）可能自行管理滚动，设为 false。
  final bool scrollable;

  /// 下拉刷新回调。不为 null 时用 [ForuiRefreshIndicator] 包裹滚动容器。
  /// Report 和 Mine 页面需要此功能。
  final Future<void> Function()? onRefresh;

  /// 滚动位置保持 key。传入时赋给 SingleChildScrollView 的 key，
  /// 确保 Tab 切换后滚动位置不丢失。
  final String? scrollStorageKey;

  /// 是否渲染外壳的 FHeader。默认 true。
  ///
  /// 某些页面（如 Today）在内容区自带顶栏（含标题 + trailing 按钮），
  /// 设为 false 可避免桌面端出现双重标题。
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final layout = LayoutScaleResolver.resolve(width);

    // Header 与内容区共享同一个 maxWidth 约束，确保水平对齐
    final constrained = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
      child: Column(
        children: [
          if (showHeader)
            FHeader.nested(
              title: titleSurface == null
                  ? Text(title)
                  : SurfaceTitleEntry(surface: titleSurface!, title: title),
              suffixes: suffixes,
            ),
          // 内容区
          Expanded(child: _buildContent(layout)),
        ],
      ),
    );

    // Content area background uses the scaffold's background color (light grey)
    // to match the FScaffold — no need for a separate tint.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.theme.scaffoldStyle.backgroundColor,
      ),
      // showHeader=false 时顶部 SafeArea 由内容区自行处理
      child: SafeArea(
        top: !showHeader,
        child: Center(child: constrained),
      ),
    );
  }

  Widget _buildContent(LayoutScale layout) {
    final padding = EdgeInsets.symmetric(
      horizontal: layout.pageHorizontalPadding,
      vertical: Spacing.xl,
    );

    if (!scrollable) {
      return Padding(padding: padding, child: child);
    }

    final scrollView = SingleChildScrollView(
      key: scrollStorageKey != null
          ? PageStorageKey<String>(scrollStorageKey!)
          : null,
      padding: padding,
      child: child,
    );

    if (onRefresh != null) {
      return ForuiRefreshIndicator(onRefresh: onRefresh!, child: scrollView);
    }

    return scrollView;
  }
}
