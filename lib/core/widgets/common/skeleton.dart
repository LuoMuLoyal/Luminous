import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:shimmer/shimmer.dart';

/// 全页骨架屏，展示一组垂直排列的 shimmer 块。
class StateSkeletonView extends StatelessWidget {
  const StateSkeletonView({
    super.key,
    required this.blocks,
    this.padding = const EdgeInsets.all(Spacing.level4),
  });

  final List<StateSkeletonBlock> blocks;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.theme.colors.border,
      highlightColor: context.theme.colors.background,
      child: ListView.separated(
        padding: padding,
        itemBuilder: (context, index) => _SkeletonBlock(data: blocks[index]),
        separatorBuilder: (context, index) =>
            const SizedBox(height: Spacing.level4),
        itemCount: blocks.length,
      ),
    );
  }
}

/// 垂直排列的 inline shimmer 块，自动包裹 [SkeletonShimmer]。
class InlineSkeleton extends StatelessWidget {
  const InlineSkeleton({
    super.key,
    required this.children,
    this.spacing = Spacing.level3,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < children.length; index += 1) ...[
            children[index],
            if (index < children.length - 1) SizedBox(height: spacing),
          ],
        ],
      ),
    );
  }
}

/// 在子树中透传加载状态，配合 [SkeletonSlot] 使用。
class SkeletonScope extends InheritedWidget {
  const SkeletonScope({
    super.key,
    required this.isLoading,
    required super.child,
  });

  final bool isLoading;

  static bool isLoadingOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<SkeletonScope>()
            ?.isLoading ??
        false;
  }

  @override
  bool updateShouldNotify(SkeletonScope oldWidget) {
    return isLoading != oldWidget.isLoading;
  }
}

/// 根据 [isLoading] 或上层 [SkeletonScope] 切换子视图与骨架屏。
class SkeletonSlot extends StatelessWidget {
  const SkeletonSlot({
    super.key,
    required this.child,
    required this.skeleton,
    this.isLoading,
  });

  final Widget child;
  final Widget skeleton;
  final bool? isLoading;

  @override
  Widget build(BuildContext context) {
    final loading = isLoading ?? SkeletonScope.isLoadingOf(context);

    if (!loading) {
      return child;
    }

    return SkeletonShimmer(child: skeleton);
  }
}

/// 将 [text] 在加载态下替换为 shimmer 块的文本占位组件。
class SkeletonText extends StatelessWidget {
  const SkeletonText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.width,
    this.widthFactor = 0.72,
    this.height,
    this.radius = RadiusTokens.level1,
    this.isLoading,
  }) : assert(widthFactor > 0 && widthFactor <= 1);

  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final double? width;
  final double widthFactor;
  final double? height;
  final double radius;
  final bool? isLoading;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
    final resolvedStyle = DefaultTextStyle.of(context).style.merge(style);
    final fontSize = resolvedStyle.fontSize ?? 14;
    final lineHeight = resolvedStyle.height == null
        ? fontSize * 1.18
        : fontSize * resolvedStyle.height!;

    return SkeletonSlot(
      isLoading: isLoading,
      skeleton: InlineSkeletonBlock(
        height: height ?? lineHeight,
        width: width,
        widthFactor: widthFactor,
        radius: radius,
      ),
      child: textWidget,
    );
  }
}

/// 给子树添加 shimmer 效果的包装组件。
class SkeletonShimmer extends StatelessWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.theme.colors.border,
      highlightColor: context.theme.colors.background,
      child: child,
    );
  }
}

/// 矩形 shimmer 占位块。
class InlineSkeletonBlock extends StatelessWidget {
  const InlineSkeletonBlock({
    super.key,
    required this.height,
    this.width,
    this.widthFactor = 1,
    this.radius = RadiusTokens.level4,
    this.fallbackWidth = 96,
  }) : assert(widthFactor > 0 && widthFactor <= 1),
       assert(fallbackWidth > 0);

  final double height;
  final double? width;
  final double widthFactor;
  final double radius;
  final double fallbackWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    final block = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: SizedBox(height: height, width: width),
    );

    if (width != null) {
      return block;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) {
          return SizedBox(width: fallbackWidth * widthFactor, child: block);
        }

        return FractionallySizedBox(
          widthFactor: widthFactor,
          alignment: Alignment.centerLeft,
          child: block,
        );
      },
    );
  }
}

/// 圆形 shimmer 占位块。
///
/// 已自动包裹 [SkeletonShimmer]，可独立使用；若放在已有的 shimmer 作用域内，
/// 外层 shimmer 的视觉效果会覆盖（无负作用）。
class InlineSkeletonCircle extends StatelessWidget {
  const InlineSkeletonCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return SkeletonShimmer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          shape: BoxShape.circle,
        ),
        child: SizedBox.square(dimension: size),
      ),
    );
  }
}

/// 带边框和背景的 shimmer 面板，内部垂直排列 [children]。
class InlineSkeletonSection extends StatelessWidget {
  const InlineSkeletonSection({super.key, required this.children, this.height});

  final List<Widget> children;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(RadiusTokens.level4),
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level5),
        child: SizedBox(
          height: height,
          child: InlineSkeleton(children: children),
        ),
      ),
    );
  }
}

/// 全页骨架屏中单个 shimmer 块的数据描述。
class StateSkeletonBlock {
  const StateSkeletonBlock({
    required this.height,
    this.radius = RadiusTokens.level5,
    this.widthFactor = 1,
  }) : assert(widthFactor > 0 && widthFactor <= 1);

  final double height;
  final double radius;
  final double widthFactor;
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.data});

  final StateSkeletonBlock data;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FractionallySizedBox(
      widthFactor: data.widthFactor,
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(data.radius),
        ),
        child: SizedBox(height: data.height),
      ),
    );
  }
}
