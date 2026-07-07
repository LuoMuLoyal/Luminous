import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_colors.dart';
import 'package:luminous/core/design/app_design.dart';

enum MedicineDoseAction { taken, skipped }

/// 彩色文字 + 同色浅底的状态徽标，用于用药状态、配送状态等。
///
/// 文字颜色为 [color] 全不透明，背景为 [color] 的 12% 透明度。
class TintedStatusBadge extends StatelessWidget {
  const TintedStatusBadge({
    super.key,
    required this.color,
    required this.label,
  });

  final AppColors color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final resolvedColor = color.resolve(colors);

    return FBadge.raw(
      builder: (context, style) => DecoratedBox(
        decoration: ShapeDecoration(
          color: resolvedColor.withValues(alpha: 0.12),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(AppRadiusTokens.level2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.level2,
            vertical: AppSpacingTokens.level1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypographyToken.level3
                    .body(context)
                    .copyWith(
                      color: resolvedColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MedicineHeaderActionChip extends StatelessWidget {
  const MedicineHeaderActionChip({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.emphasized = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return FButton(
      onPress: onTap,
      variant: emphasized ? FButtonVariant.primary : FButtonVariant.outline,
      mainAxisSize: MainAxisSize.min,
      style: const .delta(
        contentStyle: .delta(
          padding: .value(
            EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.level4,
              vertical: AppSpacingTokens.level3,
            ),
          ),
        ),
      ),
      prefix: Icon(icon, size: 18),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
