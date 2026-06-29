import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

class AppImagePlaceholder extends StatelessWidget {
  const AppImagePlaceholder({
    super.key,
    required this.label,
    this.width,
    this.height,
    this.icon = Icons.image_outlined,
  });

  final String label;
  final double? width;
  final double? height;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvasSoft2.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.sm,
              vertical: AppSpacingTokens.xs,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: surface.mute),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  label,
                  style: typography.caption.copyWith(color: surface.body),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
