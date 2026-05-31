import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

abstract final class TodayPalette {
  static const Color brand = Color(0xFF139F5A);
  static const Color brandDeep = Color(0xFF087A45);
  static const Color brandSoft = Color(0xFFEAF8EE);
  static const Color brandSoftLine = Color(0xFFC7EBD3);
  static const Color mintSoft = Color(0xFFEAF8E8);
  static const Color coralStrong = Color(0xFFFF4D4F);
  static const Color coralSoft = Color(0xFFFFEDEC);
  static const Color violetStrong = Color(0xFF7D67E8);
  static const Color violetSoft = Color(0xFFF0ECFF);
  static const Color amber = Color(0xFFFF8A00);
  static const Color amberSoft = Color(0xFFFFF2DD);
  static const Color waterTop = Color(0xFF96E8B5);
  static const Color waterBottom = Color(0xFF19A75D);
}

class TodayPanel extends StatelessWidget {
  const TodayPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacingTokens.lg),
    this.color,
    this.radius = AppRadiusTokens.lg,
    this.shadow = AppShadowTokens.level2,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? surface.canvas,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: surface.hairline),
        boxShadow: shadow,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class TodaySectionHeader extends StatelessWidget {
  const TodaySectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.compact = false,
  });

  final String title;
  final Widget? trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < 600
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: (compact ? typography.bodyMdStrong : typography.displaySm)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class TodayTextAction extends StatelessWidget {
  const TodayTextAction({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final foreground = emphasized ? TodayPalette.brand : surface.body;
    final borderColor = emphasized
        ? TodayPalette.brand.withValues(alpha: 0.55)
        : surface.hairline;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: emphasized ? TodayPalette.brandSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
            border: Border.all(color: borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.md,
              vertical: AppSpacingTokens.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: typography.buttonMd.copyWith(color: foreground),
                ),
                if (icon != null) ...[
                  const SizedBox(width: AppSpacingTokens.xxs),
                  Icon(icon, size: 16, color: foreground),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TodayStatusDot extends StatelessWidget {
  const TodayStatusDot({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: TodayPalette.coralStrong,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: 16,
        height: 16,
        child: Center(
          child: Text(
            '1',
            style: AppTypographyTokens.mobile(
              Colors.white,
            ).caption.copyWith(fontWeight: FontWeight.w600, height: 1),
          ),
        ),
      ),
    );
  }
}

class TodayWaterArc extends StatelessWidget {
  const TodayWaterArc({
    super.key,
    required this.completedCount,
    required this.targetCount,
    this.size = 128,
  });

  final int completedCount;
  final int targetCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final progress = (completedCount / targetCount).clamp(0, 1).toDouble();

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(progress: progress),
          ),
          const TodayWaterCup(width: 42, height: 54, filled: true),
        ],
      ),
    );
  }
}

class TodayWaterCup extends StatelessWidget {
  const TodayWaterCup({
    super.key,
    required this.width,
    required this.height,
    required this.filled,
  });

  final double width;
  final double height;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: filled
            ? TodayPalette.brandSoft.withValues(alpha: 0.72)
            : surface.canvas.withValues(alpha: 0.74),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(width * 0.2),
          bottom: Radius.circular(width * 0.32),
        ),
        border: Border.all(
          color: filled
              ? TodayPalette.brand.withValues(alpha: 0.35)
              : surface.hairlineStrong.withValues(alpha: 0.28),
        ),
      ),
      child: SizedBox(
        width: width,
        height: height,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            width * 0.18,
            height * 0.22,
            width * 0.18,
            height * 0.12,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: filled
                      ? const [TodayPalette.waterTop, TodayPalette.waterBottom]
                      : [surface.canvasSoft2, surface.canvasSoft2],
                ),
                borderRadius: BorderRadius.circular(width),
              ),
              child: SizedBox(
                width: double.infinity,
                height: filled ? height * 0.42 : height * 0.08,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TodayImagePlaceholder extends StatelessWidget {
  const TodayImagePlaceholder({
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
        color: surface.canvas.withValues(alpha: 0.62),
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

class TodaySignalPill extends StatelessWidget {
  const TodaySignalPill({
    super.key,
    required this.icon,
    required this.label,
    required this.level,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadiusTokens.md),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacingTokens.xs),
              child: Icon(icon, size: 18, color: color),
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Text(
              label,
              style: typography.bodySmStrong,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(level, style: typography.bodySmStrong.copyWith(color: color)),
        ],
      ),
    );
  }
}

class TodayHealthMetricTile extends StatelessWidget {
  const TodayHealthMetricTile({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.unit,
    this.status,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? unit;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < 600
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: AppSpacingTokens.xs),
              Expanded(
                child: Text(
                  label,
                  style: typography.bodySm.copyWith(color: surface.body),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          RichText(
            text: TextSpan(
              style: typography.displaySm.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(text: value),
                if (unit != null)
                  TextSpan(
                    text: ' $unit',
                    style: typography.caption.copyWith(color: surface.body),
                  ),
              ],
            ),
          ),
          if (status != null) ...[
            const SizedBox(height: AppSpacingTokens.xxs),
            Text(
              status!,
              style: typography.caption.copyWith(
                color: TodayPalette.brand,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TodayMetricDivider extends StatelessWidget {
  const TodayMetricDivider({super.key, this.height = 64});

  final double height;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return SizedBox(
      height: height,
      child: VerticalDivider(width: 1, thickness: 1, color: surface.hairline),
    );
  }
}

class TodayMetricList extends StatelessWidget {
  const TodayMetricList({
    super.key,
    required this.children,
    this.desktop = false,
  });

  final List<Widget> children;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < children.length; index += 1) ...[
          Expanded(child: children[index]),
          if (index < children.length - 1)
            TodayMetricDivider(height: desktop ? 76 : 64),
        ],
      ],
    );
  }
}

class TodaySignalList extends StatelessWidget {
  const TodaySignalList({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < children.length; index += 1) ...[
          Expanded(child: children[index]),
          if (index < children.length - 1) const TodayMetricDivider(height: 44),
        ],
      ],
    );
  }
}

class TodayLumiAvatarPlaceholder extends StatelessWidget {
  const TodayLumiAvatarPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: TodayPalette.brand.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const SizedBox.square(
        dimension: 46,
        child: Icon(
          Icons.auto_awesome_outlined,
          color: TodayPalette.brand,
          size: 22,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final basePaint = Paint()
      ..color = TodayPalette.brandSoft
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          TodayPalette.waterBottom,
          Color(0xFF72D68E),
          TodayPalette.waterBottom,
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawArc(
      rect,
      math.pi * 0.8,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
