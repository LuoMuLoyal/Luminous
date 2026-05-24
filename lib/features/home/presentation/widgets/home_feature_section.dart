part of '../home.dart';

/// “常用功能”卡片区域。
class HomeFeatureSection extends StatelessWidget {
  const HomeFeatureSection({
    super.key,
    required this.items,
    required this.onTap,
  });

  final List<HomeFeatureItemData> items;
  final ValueChanged<HomeFeatureItemData> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final accent = Color.lerp(scheme.primary, scheme.secondary, 0.35)!;
    final secondary = Color.lerp(scheme.secondary, scheme.tertiary, 0.45)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);
          final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
          final metrics = ResponsiveQuickGridMetrics.fromWidth(
            constraints.maxWidth,
            textScaleFactor: textScaleFactor,
          );

          return AppSectionCard(
            accentColor: accent,
            secondaryColor: secondary,
            ornamentKey: 'home.features',
            padding: EdgeInsets.all(metrics.sectionPadding),
            radius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.homeFeaturesTitle ?? '常用功能',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n?.homeFeaturesSubtitle ?? '快速进入核心健康服务',
                  style: TextStyle(
                    fontSize: 13,
                    color: _homeSecondaryTextColor(context, emphasis: 0.28),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: compact ? 8 : 10),
                ResponsiveQuickWrap(
                  metrics: metrics,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return SharedQuickEntryCard(
                      icon: item.icon,
                      title: item.title,
                      subtitle: item.subtitle,
                      color: item.color,
                      metrics: metrics,
                      onTap: () => onTap(item),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
