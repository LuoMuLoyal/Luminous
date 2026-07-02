import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:shimmer/shimmer.dart';

enum AppStateTone { neutral, success, warning, danger }

class AppStateMessageView extends StatelessWidget {
  const AppStateMessageView({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.actionKey,
    this.tone = AppStateTone.neutral,
    this.padding = const EdgeInsets.all(AppSpacingTokens.level5),
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Key? actionKey;
  final AppStateTone tone;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = context.theme.colors;
    final accent = _accentFor(colors);

    return FCard.raw(
      child: Padding(
        padding: padding,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.level4),
                  child: Icon(icon, color: accent, size: 28),
                ),
              ),
              const SizedBox(height: AppSpacingTokens.level4),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacingTokens.level2),
              Text(
                description,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacingTokens.level5),
                FButton(
                  key: actionKey,
                  onPress: onAction,
                  variant: FButtonVariant.outline,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _accentFor(FColors colors) {
    return switch (tone) {
      AppStateTone.neutral => colors.primary,
      AppStateTone.success => const Color(0xFF16A34A),
      AppStateTone.warning => const Color(0xFFF59E0B),
      AppStateTone.danger => colors.destructive,
    };
  }
}

class AppStateSkeletonView extends StatelessWidget {
  const AppStateSkeletonView({
    super.key,
    required this.blocks,
    this.padding = const EdgeInsets.all(AppSpacingTokens.level4),
  });

  final List<AppStateSkeletonBlock> blocks;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.theme.colors;

    return Shimmer.fromColors(
      baseColor: colors.background.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.42 : 1,
      ),
      highlightColor: colors.secondary.withValues(alpha: 0.55),
      child: ListView.separated(
        padding: padding,
        itemBuilder: (context, index) => _SkeletonBlock(data: blocks[index]),
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacingTokens.level4),
        itemCount: blocks.length,
      ),
    );
  }
}

class AppInlineSkeleton extends StatelessWidget {
  const AppInlineSkeleton({
    super.key,
    required this.children,
    this.spacing = AppSpacingTokens.level3,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
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

class AppSkeletonScope extends InheritedWidget {
  const AppSkeletonScope({
    super.key,
    required this.isLoading,
    required super.child,
  });

  final bool isLoading;

  static bool isLoadingOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<AppSkeletonScope>()
            ?.isLoading ??
        false;
  }

  @override
  bool updateShouldNotify(AppSkeletonScope oldWidget) {
    return isLoading != oldWidget.isLoading;
  }
}

class AppSkeletonSlot extends StatelessWidget {
  const AppSkeletonSlot({
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
    final loading = isLoading ?? AppSkeletonScope.isLoadingOf(context);

    if (!loading) {
      return child;
    }

    return AppSkeletonShimmer(child: skeleton);
  }
}

class AppSkeletonText extends StatelessWidget {
  const AppSkeletonText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.width,
    this.widthFactor = 0.72,
    this.height,
    this.radius = AppRadiusTokens.level1,
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

    return AppSkeletonSlot(
      isLoading: isLoading,
      skeleton: AppInlineSkeletonBlock(
        height: height ?? lineHeight,
        width: width,
        widthFactor: widthFactor,
        radius: radius,
      ),
      child: textWidget,
    );
  }
}

class AppSkeletonShimmer extends StatelessWidget {
  const AppSkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.theme.colors;

    return Shimmer.fromColors(
      baseColor: colors.background.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.42 : 1,
      ),
      highlightColor: colors.secondary.withValues(alpha: 0.55),
      child: child,
    );
  }
}

class AppInlineSkeletonBlock extends StatelessWidget {
  const AppInlineSkeletonBlock({
    super.key,
    required this.height,
    this.width,
    this.widthFactor = 1,
    this.radius = AppRadiusTokens.level4,
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

class AppInlineSkeletonCircle extends StatelessWidget {
  const AppInlineSkeletonCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(dimension: size),
    );
  }
}

class AppInlineSkeletonSection extends StatelessWidget {
  const AppInlineSkeletonSection({
    super.key,
    required this.children,
    this.height,
  });

  final List<Widget> children;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
        border: Border.all(color: colors.border),
        boxShadow: AppShadowTokens.level1,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level5),
        child: SizedBox(
          height: height,
          child: AppInlineSkeleton(children: children),
        ),
      ),
    );
  }
}

class AppStateSkeletonBlock {
  const AppStateSkeletonBlock({
    required this.height,
    this.radius = AppRadiusTokens.level5,
    this.widthFactor = 1,
  }) : assert(widthFactor > 0 && widthFactor <= 1);

  final double height;
  final double radius;
  final double widthFactor;
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.data});

  final AppStateSkeletonBlock data;

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

/// Full-page error view that wraps [AppStateMessageView] with centered layout.
/// Use this for page-level error states (skeleton timeout, network failure).
class AppStateErrorView extends StatelessWidget {
  const AppStateErrorView({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.tone = AppStateTone.neutral,
    this.compact = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final AppStateTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final message = AppStateMessageView(
      title: title,
      description: description,
      icon: icon,
      actionLabel: actionLabel,
      onAction: onAction,
      tone: tone,
      padding: compact
          ? const EdgeInsets.all(AppSpacingTokens.level4)
          : const EdgeInsets.all(AppSpacingTokens.level5),
    );

    if (compact) {
      return message;
    }

    // Use LayoutBuilder so the view works both in finite-height parents
    // (e.g. the body of a non-scrollable Scaffold) and inside scrollables
    // where the incoming max height is unbounded.
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 320.0;
        return SizedBox(
          height: height,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.level4,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: message,
              ),
            ),
          ),
        );
      },
    );
  }
}
