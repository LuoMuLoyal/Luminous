import 'package:flutter/material.dart';

import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/top_bar.dart';

/// 桌面端 Tab 页面统一外壳。
///
/// 由 [ShellPage] 在桌面端使用，为所有 Tab 页面提供统一的：
/// - AppTopBar（标题 + trailing actions + 可选 bottom）
/// - 内容区最大宽度约束（TopBar 与内容区共享同一约束，水平对齐）
/// - 内容区背景色（muted，与侧边栏区分）
/// - 统一 padding
/// - 可选下拉刷新（onRefresh）和滚动位置保持（scrollStorageKey）
class DesktopTabShell extends StatelessWidget {
  const DesktopTabShell({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing = const [],
    this.bottom,
    required this.child,
    this.scrollable = true,
    this.onRefresh,
    this.scrollStorageKey,
    this.showHeader = true,
  });

  /// 主标题，显示在 AppTopBar 中。
  final String title;

  /// 副标题，位于主标题下方。
  final Widget? subtitle;

  /// 右侧操作按钮列表。
  final List<Widget> trailing;

  /// 标题行下方的额外内容（如报告页的操作按钮区）。
  final Widget? bottom;

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

  /// 是否渲染外壳的 AppTopBar。默认 true。
  ///
  /// 某些页面（如 Today）在内容区自带顶栏（含标题 + trailing 按钮），
  /// 设为 false 可避免桌面端出现双重标题。
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final layout = LayoutScaleResolver.resolve(width);

    // TopBar 与内容区共享同一个 maxWidth 约束，确保水平对齐
    final constrained = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: layout.maxContentWidth),
      child: Column(
        children: [
          if (showHeader)
            // AppTopBar 内部已自带 SafeArea(bottom: false)
            AppTopBar(
              title: title,
              subtitle: subtitle,
              trailing: trailing,
              bottom: bottom,
            ),
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
