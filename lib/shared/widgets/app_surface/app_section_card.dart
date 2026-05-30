part of '../app_surface.dart';

/// 统一的大分区卡片。
///
/// 适合"常用功能""今日提醒"这类整块区域：
/// - 保留表面卡片的干净边界；
/// - 在卡片内部叠一层极浅的区域色；
/// - 只做少量静态装饰，不使用模糊，渲染负担很低。
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.child,
    required this.accentColor,
    this.secondaryColor,
    this.padding = const EdgeInsets.all(14),
    this.radius = 18,
    this.baseColor,
    this.surfaceBorderColor,
  });

  final Widget child;
  final Color accentColor;
  final Color? secondaryColor;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? baseColor;
  final Color? surfaceBorderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final resolvedBaseColor =
        baseColor ?? theme.cardTheme.color ?? theme.colorScheme.surface;
    final startColor = Color.alphaBlend(
      accentColor.withValues(alpha: isDark ? 0.12 : 0.085),
      resolvedBaseColor,
    );
    final endColor = Color.alphaBlend(
      (secondaryColor ?? accentColor).withValues(alpha: isDark ? 0.095 : 0.062),
      resolvedBaseColor,
    );

    return AppSurfaceCard(
      radius: radius,
      color: resolvedBaseColor,
      borderColor: surfaceBorderColor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [startColor, endColor],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.24, 0.74, 1],
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.032 : 0.085),
                        Colors.white.withValues(alpha: isDark ? 0.012 : 0.024),
                        Colors.transparent,
                        Colors.black.withValues(alpha: isDark ? 0.016 : 0.008),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -34,
              right: -12,
              child: IgnorePointer(
                child: Container(
                  width: 132,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accentColor.withValues(alpha: isDark ? 0.08 : 0.11),
                        accentColor.withValues(alpha: 0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: SizedBox(width: double.infinity, child: child),
            ),
          ],
        ),
      ),
    );
  }
}
