import 'package:flutter/material.dart';

/// 全局浅色环境背景。
///
/// 不直接给每个组件叠彩色块，而是在页面底层铺一层很淡的环境光，
/// 让页面更柔和、卡片更干净。
class AppCanvas extends StatelessWidget {
  const AppCanvas({
    super.key,
    required this.child,
    required this.accentColor,
    this.secondaryAccentColor = const Color(0xFFDCCEFF),
    this.baseColor,
  });

  final Widget child;
  final Color accentColor;
  final Color secondaryAccentColor;
  final Color? baseColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = baseColor ?? theme.scaffoldBackgroundColor;
    final topTint = Color.alphaBlend(
      accentColor.withValues(alpha: isDark ? 0.10 : 0.06),
      background,
    );
    final bottomTint = Color.alphaBlend(
      secondaryAccentColor.withValues(alpha: isDark ? 0.08 : 0.05),
      background,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topTint, background, bottomTint],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -112,
            right: -88,
            child: _CanvasOrb(
              size: 248,
              colors: [
                accentColor.withValues(alpha: isDark ? 0.12 : 0.14),
                accentColor.withValues(alpha: 0),
              ],
            ),
          ),
          Positioned(
            top: 56,
            left: -76,
            child: _CanvasOrb(
              size: 210,
              colors: [
                const Color(0xFFFDE7A9).withValues(alpha: isDark ? 0.08 : 0.18),
                const Color(0xFFFDE7A9).withValues(alpha: 0),
              ],
            ),
          ),
          Positioned(
            bottom: -138,
            left: -72,
            child: _CanvasOrb(
              size: 292,
              colors: [
                secondaryAccentColor.withValues(alpha: isDark ? 0.10 : 0.16),
                secondaryAccentColor.withValues(alpha: 0),
              ],
            ),
          ),
          Positioned(
            bottom: 84,
            right: -54,
            child: _CanvasOrb(
              size: 156,
              colors: [
                const Color(0xFFFFF6C8).withValues(alpha: isDark ? 0.05 : 0.14),
                const Color(0xFFFFF6C8).withValues(alpha: 0),
              ],
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _CanvasOrb extends StatelessWidget {
  const _CanvasOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
