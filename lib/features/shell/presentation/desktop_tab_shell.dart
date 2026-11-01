import 'dart:ui' show ImageFilter;

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
/// - Content area rendered flat on the scaffold surface; the sidebar/canvas/card
///   hierarchy comes from `SurfaceTokens` color steps, never from wrapping the
///   page in another card
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
          if (showHeader) _GlassHeader(child: _buildHeader()),
          // 内容区
          Expanded(child: _buildContent(layout)),
        ],
      ),
    );

    // 内容区平铺，不切成圆角白卡。
    //
    // 层次靠**色差**而不是容器：侧边栏（sidebarBackground，最深）
    // 与内容区（scaffoldBackground，居中）本身就是两层；卡片再往上一层。
    // 三层亮度差已经把结构说清楚了，内容区再包一层白底 + 圆角，
    // 卡片就成了「卡片套卡片」——白卡上的白卡只能靠边框才看得见，
    // 反而把层次加了回去。
    //
    // 这里只做两件事：铺内容区底色、给 header 与内容共享的水平约束。
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

  Widget _buildHeader() {
    return FHeader.nested(
      title: titleSurface == null
          ? Text(title)
          : SurfaceTitleEntry(surface: titleSurface!, title: title),
      suffixes: suffixes,
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

/// 顶栏的「玻璃」层：半透明底色 + 背景模糊 + 底部细分隔线。
///
/// 目的不是特效，而是**让滚动关系可见**：内容从顶栏下方经过时，若顶栏是一块
/// 不透明的色块，用户看不出自己还能往上滚；半透明加模糊既压住文字保证了标题
/// 可读，又留下「下面还有内容」的线索。
///
/// 为什么用 `BackdropFilter` 而不是简单给一层 `color.withOpacity`：二者都不
/// 挡文字，但纯半透明会让下方文字以全饱和度透出来，标题与内容互相干扰；
/// 模糊把穿过的内容压成一层灰面，标题才稳。
///
/// `ClipRect` 是必须的——`BackdropFilter` 若不被裁剪，模糊会溢出到顶栏之外
/// （模糊半径以内的一切都会被采样并重绘）。
class _GlassHeader extends StatelessWidget {
  const _GlassHeader({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    // 背景色带 alpha 再模糊：alpha 太高会变成实心块，玻璃就失效了；
    // 太低则下方内容透出过强。0.72 在亮暗两端都验证过可读。
    final tint = colors.background.withValues(alpha: 0.72);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tint,
            border: Border(bottom: BorderSide(color: colors.border, width: 1)),
          ),
          child: child,
        ),
      ),
    );
  }
}
