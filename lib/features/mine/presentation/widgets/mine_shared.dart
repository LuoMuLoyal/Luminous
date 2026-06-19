import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
const mineGreen = AppColorTokens.cyanDeep;

class MinePanel extends StatelessWidget {
  const MinePanel({
    super.key,
    required this.child,
    required this.surface,
    this.padding = const EdgeInsets.all(AppSpacingTokens.lg),
  });

  final Widget child;
  final AppThemeSurface surface;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level1,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class MineSectionTitle extends StatelessWidget {
  const MineSectionTitle({super.key, required this.title, required this.typography});

  final String title;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: typography.displaySm.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
    );
  }
}
