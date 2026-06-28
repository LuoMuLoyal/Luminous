import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
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
    this.padding = const EdgeInsets.all(AppSpacingTokens.lg),
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
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final accent = _accentFor(surface);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _backgroundFor(surface, accent),
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
        boxShadow: AppShadowTokens.level1,
      ),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacingTokens.md),
                child: Icon(icon, color: accent, size: 28),
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            Text(
              title,
              style: typography.bodyMdStrong.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(
              description,
              style: typography.bodySm.copyWith(color: surface.body),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacingTokens.lg),
              OutlinedButton(
                key: actionKey,
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: accent,
                  side: BorderSide(color: accent.withValues(alpha: 0.45)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _accentFor(AppThemeSurface surface) {
    return switch (tone) {
      AppStateTone.neutral => surface.link,
      AppStateTone.success => surface.accent,
      AppStateTone.warning => surface.warning,
      AppStateTone.danger => surface.error,
    };
  }

  Color _backgroundFor(AppThemeSurface surface, Color accent) {
    if (tone == AppStateTone.neutral) {
      return surface.canvas;
    }
    return Color.alphaBlend(accent.withValues(alpha: 0.08), surface.canvas);
  }
}

class AppStateSkeletonView extends StatelessWidget {
  const AppStateSkeletonView({
    super.key,
    required this.blocks,
    this.padding = const EdgeInsets.all(AppSpacingTokens.md),
  });

  final List<AppStateSkeletonBlock> blocks;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;

    return Shimmer.fromColors(
      baseColor: surface.canvas.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.42 : 1,
      ),
      highlightColor: surface.canvasSoft2,
      child: ListView.separated(
        padding: padding,
        itemBuilder: (context, index) => _SkeletonBlock(data: blocks[index]),
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacingTokens.md),
        itemCount: blocks.length,
      ),
    );
  }
}

class AppInlineSkeleton extends StatelessWidget {
  const AppInlineSkeleton({
    super.key,
    required this.children,
    this.spacing = AppSpacingTokens.sm,
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
    this.radius = AppRadiusTokens.xs,
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
    final surface = theme.extension<AppThemeSurface>()!;

    return Shimmer.fromColors(
      baseColor: surface.canvas.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.42 : 1,
      ),
      highlightColor: surface.canvasSoft2,
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
    this.radius = AppRadiusTokens.lg,
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    final block = DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(color: surface.canvas, shape: BoxShape.circle),
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level1,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
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
    this.radius = AppRadiusTokens.xl,
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return FractionallySizedBox(
      widthFactor: data.widthFactor,
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface.canvas,
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
          ? const EdgeInsets.all(AppSpacingTokens.md)
          : const EdgeInsets.all(AppSpacingTokens.lg),
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
                horizontal: AppSpacingTokens.md,
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
