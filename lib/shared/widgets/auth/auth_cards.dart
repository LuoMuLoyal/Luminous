part of 'auth.dart';

/// 认证页面中用于承载表单的浅色装饰卡片。
class AuthSurfaceCard extends StatelessWidget {
  const AuthSurfaceCard({super.key, required this.child, this.radius = 18});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = Color.lerp(scheme.primary, scheme.secondary, 0.30)!;
    final baseColor = scheme.surface.withValues(alpha: isDark ? 0.40 : 0.76);
    final borderColor = appTintedBorder(
      context,
      accentColor,
      lightAlpha: 0.16,
      darkAlpha: 0.22,
    );

    return AppSurfaceCard(
      radius: radius,
      color: baseColor,
      borderColor: borderColor,
      child: child,
    );
  }
}

/// 登录/注册页顶部的 Hero 卡片。
///
/// 用于统一展示页面 icon、标题和副标题。
class AuthHeroCard extends StatelessWidget {
  /// 创建一个 Hero 卡片组件。
  const AuthHeroCard({
    super.key,
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  /// Hero 卡片使用的浅色横幅配色。
  final SoftBannerPalette palette;

  /// Hero 左侧图标。
  final IconData icon;

  /// Hero 主标题。
  final String title;

  /// Hero 副标题。
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SoftBannerCard(
      palette: palette,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      borderRadius: BorderRadius.circular(18),
      builder: (context, theme) {
        return Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.borderColor),
              ),
              child: Icon(icon, color: theme.accentColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.secondaryTextColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
