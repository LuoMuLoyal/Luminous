part of '../today.dart';

/// 今日用药提醒卡片。
///
/// 展示待服药品数量、下次服药时间和药品列表摘要。
class _MedicationReminderCard extends StatelessWidget {
  const _MedicationReminderCard({
    required this.totalCount,
    required this.pendingCount,
    required this.nextTime,
    required this.nextMedicationName,
  });

  final int totalCount;
  final int pendingCount;
  final String nextTime;
  final String nextMedicationName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppUiConstants.TEXT_PRIMARY_DARK
        : AppUiConstants.TEXT_PRIMARY;

    return AppSectionCard(
      accentColor: TodayConstants.medicationColor,
      padding: const EdgeInsets.all(TodayConstants.cardHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodaySectionHeader(
            title: l10n.todayMedicationTitle,
            trailing: l10n.todayMedicationView,
          ),
          SizedBox(height: TodayConstants.cardTitleContentSpacing),
          Row(
            children: [
              _buildStatBadge(
                context,
                value: '$totalCount',
                label: l10n.todayMedicationTypeCount(totalCount),
              ),
              SizedBox(width: AppSpacing.sm),
              Container(width: 1, height: 24, color: AppUiConstants.DIVIDER),
              SizedBox(width: AppSpacing.sm),
              _buildStatBadge(
                context,
                value: '$pendingCount',
                label: l10n.todayMedicationPendingCount(pendingCount),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: TodayConstants.medicationColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: TodayConstants.medicationColor,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      l10n.todayMedicationNextTime(nextTime),
                      style: TextStyle(
                        fontSize: AppTypography.tab,
                        fontWeight: FontWeight.w600,
                        color: TodayConstants.medicationColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: TodayConstants.medicationColor.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Icon(
                    Icons.medication_rounded,
                    size: 18,
                    color: TodayConstants.medicationColor,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    nextMedicationName,
                    style: TextStyle(
                      fontSize: AppTypography.body,
                      fontWeight: FontWeight.w500,
                      color: textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppUiConstants.TEXT_MUTED,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: AppTypography.titleLg,
            fontWeight: FontWeight.w700,
            color: TodayConstants.medicationColor,
            height: 1,
          ),
        ),
        SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTypography.bodySmall,
            color: AppUiConstants.TEXT_MUTED,
          ),
        ),
      ],
    );
  }
}
