part of '../today.dart';

/// 今日环境提醒卡片。
///
/// 展示花粉、紫外线等环境指标，使用 Chip 标签展示等级。
class _EnvironmentAlertCard extends StatelessWidget {
  const _EnvironmentAlertCard({
    required this.pollenLevel,
    required this.uvLevel,
  });

  final String pollenLevel;
  final String uvLevel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppSectionCard(
      accentColor: TodayConstants.pollenColor,
      padding: const EdgeInsets.all(TodayConstants.cardHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodaySectionHeader(title: l10n.todayEnvironmentTitle),
          SizedBox(height: TodayConstants.cardTitleContentSpacing),
          Row(
            children: [
              TodayEnvChip(
                icon: Icons.grass_rounded,
                label: l10n.todayEnvironmentPollen,
                level: pollenLevel,
                accentColor: TodayConstants.pollenColor,
              ),
              SizedBox(width: AppSpacing.md),
              TodayEnvChip(
                icon: Icons.wb_sunny_rounded,
                label: l10n.todayEnvironmentUv,
                level: uvLevel,
                accentColor: TodayConstants.uvColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
