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
    this.tone = AppStateTone.neutral,
    this.padding = const EdgeInsets.all(AppSpacingTokens.lg),
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
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
        boxShadow: AppShadowTokens.level2,
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
      AppStateTone.success => const Color(0xFF159B55),
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
