import 'package:flutter/material.dart';

import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';

/// Desktop tab page unified shell.
///
/// Used by [ShellPage] on desktop, providing all tab pages with:
/// - FHeader.nested (title + suffixes)
/// - Content area max-width constraint (shared with header for horizontal alignment)
/// - Content area background color (muted, to distinguish from sidebar)
/// - Unified padding
/// - Optional pull-to-refresh (onRefresh) and scroll position preservation (scrollStorageKey)
class DesktopTabShell extends StatelessWidget {
  const DesktopTabShell({
    super.key,
    required this.title,
    this.suffixes = const [],
    required this.child,
    this.scrollable = true,
    this.onRefresh,
    this.scrollStorageKey,
    this.showHeader = true,
  });

  /// 主标题，显示在 FHeader 中。
  final String title;

  /// 右侧操作按钮列表（FHeader.suffixes）。
  final List<Widget> suffixes;

  /// 内容 Widget。
  final Widget child;

  /// 是否使用滚动容器包裹内容。默认 true。
  /// 某些页面（如 Today）可能自行管理滚动，设为 false。
  final bool scrollable;

  /// 下拉刷新回调。不为 null 时用 RefreshIndicator 包裹滚动容器。
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
            FHeader.nested(title: Text(title), suffixes: suffixes),
          // 内容区
          Expanded(child: _buildContent(layout)),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SemanticColor.neutral.muted(context).withValues(alpha: 0.32),
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
      vertical: Spacing.level5,
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
      return RefreshIndicator(onRefresh: onRefresh!, child: scrollView);
    }

    return scrollView;
  }
}
