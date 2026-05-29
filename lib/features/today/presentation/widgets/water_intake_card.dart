part of '../today.dart';

/// 今日喝水追踪卡片。
///
/// 展示圆形进度环、当前次数、目标次数和剩余次数。
class _WaterIntakeCard extends StatelessWidget {
  const _WaterIntakeCard({required this.current, required this.goal});

  final int current;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textMuted = AppUiConstants.TEXT_MUTED;
    final remaining = (goal - current).clamp(0, goal);
    final progress = goal > 0 ? current / goal : 0.0;

    return AppSectionCard(
      accentColor: TodayConstants.waterPrimaryColor,
      padding: const EdgeInsets.all(TodayConstants.cardHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodaySectionHeader(
            title: l10n.todayWaterTitle,
            trailing: l10n.todayWaterGoal(goal),
          ),
          SizedBox(height: TodayConstants.cardTitleContentSpacing),
          Row(
            children: [
              TodayProgressRing(
                progress: progress,
                center: Text(
                  '$current',
                  style: TextStyle(
                    fontSize: AppTypography.titleLg,
                    fontWeight: FontWeight.w700,
                    color: TodayConstants.waterPrimaryColor,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(
                      context,
                      label: l10n.todayWaterDrunk,
                      value: l10n.todayWaterDrunkCount(current),
                      color: TodayConstants.waterPrimaryColor,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildStatRow(
                      context,
                      label: l10n.todayWaterRemaining,
                      value: l10n.todayWaterRemainingCount(remaining),
                      color: textMuted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.bodySmall,
            color: AppUiConstants.TEXT_MUTED,
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: TextStyle(
            fontSize: AppTypography.body,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
