part of '../today.dart';

/// 今日页。
///
/// 作为应用一级入口的「今日」Tab，整合喝水追踪、用药提醒、
/// 健康快照、饮食建议、环境提醒和 Lumi AI 建议。
///
/// 当前使用 Mock 数据，后续接入真实 API。
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              // TODO: 接入真实数据刷新。
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _GreetingHeader(
                    greeting: l10n.todayGreeting,
                    subtitle: l10n.todayGreetingSubtitle,
                    onNotificationTap: () {},
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                  ),
                  sliver: SliverList.list(
                    children: [
                      _WaterIntakeCard(
                        current: TodayConstants.mockWaterIntake,
                        goal: TodayConstants.defaultWaterGoal,
                      ),
                      SizedBox(height: TodayConstants.cardVerticalSpacing),
                      _MedicationReminderCard(
                        totalCount: TodayConstants.mockTotalMedications,
                        pendingCount: TodayConstants.mockPendingMedications,
                        nextTime: TodayConstants.mockNextMedicationTime,
                        nextMedicationName:
                            TodayConstants.mockNextMedicationName,
                      ),
                      SizedBox(height: TodayConstants.cardVerticalSpacing),
                      _HealthSnapshotCard(
                        heartRate: TodayConstants.mockHeartRate,
                        systolic: TodayConstants.mockSystolic,
                        diastolic: TodayConstants.mockDiastolic,
                        sleepHours: TodayConstants.mockSleepHours,
                      ),
                      SizedBox(height: TodayConstants.cardVerticalSpacing),
                      _DietSuggestionCard(
                        title: TodayConstants.mockDietTitle,
                        description: TodayConstants.mockDietDescription,
                        imageUrl: null,
                      ),
                      SizedBox(height: TodayConstants.cardVerticalSpacing),
                      _EnvironmentAlertCard(
                        pollenLevel: TodayConstants.mockPollenLevel,
                        uvLevel: TodayConstants.mockUvLevel,
                      ),
                      SizedBox(height: TodayConstants.cardVerticalSpacing),
                      _LumiAdviceCard(advice: TodayConstants.mockLumiAdvice),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
