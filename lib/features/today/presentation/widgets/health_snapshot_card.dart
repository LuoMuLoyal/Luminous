part of '../today.dart';

/// 今日健康快照卡片。
///
/// 横向展示心率、血压、睡眠三项健康指标。
class _HealthSnapshotCard extends StatelessWidget {
  const _HealthSnapshotCard({
    required this.heartRate,
    required this.systolic,
    required this.diastolic,
    required this.sleepHours,
  });

  final int heartRate;
  final int systolic;
  final int diastolic;
  final double sleepHours;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppSectionCard(
      accentColor: TodayConstants.heartRateColor,
      padding: const EdgeInsets.all(TodayConstants.cardHorizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodaySectionHeader(title: l10n.todayHealthTitle),
          SizedBox(height: TodayConstants.cardTitleContentSpacing),
          Row(
            children: [
              Expanded(
                child: TodayStatCard(
                  icon: Icons.favorite_rounded,
                  value: '$heartRate',
                  unit: l10n.todayHealthHeartRateUnit,
                  label: l10n.todayHealthHeartRateLabel,
                  accentColor: TodayConstants.heartRateColor,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TodayStatCard(
                  icon: Icons.bloodtype_rounded,
                  value: '$systolic/$diastolic',
                  unit: 'mmHg',
                  label: l10n.todayHealthBloodPressureLabel,
                  accentColor: TodayConstants.bloodPressureColor,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TodayStatCard(
                  icon: Icons.bedtime_rounded,
                  value: '$sleepHours',
                  unit: l10n.todayHealthSleepUnit,
                  label: l10n.todayHealthSleepLabel,
                  accentColor: TodayConstants.sleepColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
