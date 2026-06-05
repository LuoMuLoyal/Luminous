import 'package:flutter/material.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/presentation/widgets/today_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class TodayDashboardView extends StatelessWidget {
  const TodayDashboardView({
    super.key,
    required this.dashboard,
    this.isLoading = false,
  });

  final TodayDashboard dashboard;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= AppBreakpoints.desktop;
    final content = isDesktop
        ? _DesktopTodayDashboard(dashboard: dashboard, isLoading: isLoading)
        : _MobileTodayDashboard(dashboard: dashboard, isLoading: isLoading);

    return content;
  }
}

class TodayErrorView extends StatelessWidget {
  const TodayErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppStateErrorView(
      title: l10n.todayErrorTitle,
      description: l10n.todayErrorDescription,
      icon: Icons.question_mark_rounded,
      actionLabel: l10n.todayRetryAction,
      onAction: onRetry,
      tone: AppStateTone.danger,
    );
  }
}

class TodayEmptyView extends StatelessWidget {
  const TodayEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: AppStateMessageView(
          title: l10n.todayEmptyTitle,
          description: l10n.todayEmptyDescription,
          icon: Icons.medical_information_outlined,
          actionLabel: l10n.todayEmptyAction,
          onAction: () {},
          tone: AppStateTone.success,
        ),
      ),
    );
  }
}

class _MobileTodayDashboard extends StatelessWidget {
  const _MobileTodayDashboard({
    required this.dashboard,
    required this.isLoading,
  });

  final TodayDashboard dashboard;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      _TodayTopBar(
        hasUnreadNotifications: dashboard.user.hasUnreadNotifications,
      ),
      _TodayHero(moment: dashboard.user.moment),
      _TodayWaterCard(water: dashboard.water, isLoading: isLoading),
      _TodayMedicationCard(
        medication: dashboard.medication,
        isLoading: isLoading,
      ),
      _TodayHealthSummaryCard(vitals: dashboard.vitals, isLoading: isLoading),
      _TodayMealSuggestionCard(mealSuggestion: dashboard.mealSuggestion),
      _TodayEnvironmentCard(
        environment: dashboard.environment,
        isLoading: isLoading,
      ),
      _TodayLumiCard(suggestion: dashboard.lumiSuggestion),
    ];

    return ListView.separated(
      key: const PageStorageKey<String>('today-dashboard-scroll'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacingTokens.md,
        AppSpacingTokens.sm,
        AppSpacingTokens.md,
        AppSpacingTokens.xl,
      ),
      itemBuilder: (context, index) => sections[index],
      separatorBuilder: (context, index) => SizedBox(
        height: index == 0 ? AppSpacingTokens.md : AppSpacingTokens.sm,
      ),
      itemCount: sections.length,
    );
  }
}

class _DesktopTodayDashboard extends StatelessWidget {
  const _DesktopTodayDashboard({
    required this.dashboard,
    required this.isLoading,
  });

  final TodayDashboard dashboard;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey<String>('today-dashboard-desktop-scroll'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacingTokens.md,
        AppSpacingTokens.xl,
        AppSpacingTokens.md,
        AppSpacingTokens.xl,
      ),
      children: [
        _TodayHero(moment: dashboard.user.moment, desktop: true),
        const SizedBox(height: AppSpacingTokens.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: _TodayWaterCard(
                water: dashboard.water,
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: AppSpacingTokens.md),
            Expanded(
              flex: 5,
              child: _TodayMedicationCard(
                medication: dashboard.medication,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _TodayHealthSummaryCard(
          vitals: dashboard.vitals,
          desktop: true,
          isLoading: isLoading,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _TodayMealSuggestionCard(
          mealSuggestion: dashboard.mealSuggestion,
          desktop: true,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _TodayEnvironmentCard(
                environment: dashboard.environment,
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: AppSpacingTokens.md),
            Expanded(
              child: _TodayLumiCard(
                suggestion: dashboard.lumiSuggestion,
                desktop: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TodayTopBar extends StatelessWidget {
  const _TodayTopBar({required this.hasUnreadNotifications});

  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Row(
      children: [
        Text(
          l10n.appTitle,
          style: typography.displaySm.copyWith(
            color: TodayPalette.brand,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        _NotificationButton(hasUnread: hasUnreadNotifications),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.hasUnread});

  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return Tooltip(
      message: l10n.todayNotificationsTooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: surface.canvas.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(AppRadiusTokens.pillSm),
              border: Border.all(color: surface.hairline),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications_none_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              visualDensity: VisualDensity.compact,
              style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          if (hasUnread)
            const Positioned(
              right: 10,
              top: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: TodayPalette.coralStrong,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(dimension: 8),
              ),
            ),
        ],
      ),
    );
  }
}

class _TodayHero extends StatelessWidget {
  const _TodayHero({required this.moment, this.desktop = false});

  final TodayDayMoment moment;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = desktop
        ? AppTypographyTokens.desktop(theme.colorScheme.onSurface)
        : AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TodayPalette.mintSoft,
            surface.canvas.withValues(alpha: 0.94),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level1,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: Stack(
          children: [
            Positioned(
              right: desktop ? AppSpacingTokens.xl : AppSpacingTokens.md,
              bottom: desktop ? AppSpacingTokens.md : AppSpacingTokens.sm,
              top: desktop ? AppSpacingTokens.md : AppSpacingTokens.sm,
              child: TodayImagePlaceholder(
                label: l10n.todayHeroImagePlaceholder,
                width: desktop ? 230 : 104,
                icon: Icons.image_outlined,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                desktop ? AppSpacingTokens.xl : AppSpacingTokens.md,
                desktop ? AppSpacingTokens.lg : AppSpacingTokens.md,
                desktop ? 286 : 126,
                desktop ? AppSpacingTokens.lg : AppSpacingTokens.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greetingTitle(l10n, moment),
                    style:
                        (desktop ? typography.displayLg : typography.displayMd)
                            .copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Text(
                    _greetingSubtitle(l10n, moment),
                    style: typography.bodyMd.copyWith(color: surface.body),
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    l10n.todayHeroCareLine,
                    style: typography.bodyMd.copyWith(color: surface.body),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayWaterCard extends StatelessWidget {
  const _TodayWaterCard({required this.water, required this.isLoading});

  final TodayWaterSummary water;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return TodayPanel(
      key: const Key('today-water-card'),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TodaySectionHeader(
                title: l10n.todayWaterCardTitle,
                compact: true,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              if (isLoading)
                Row(
                  children: [
                    AppInlineSkeletonCircle(size: compact ? 112 : 128),
                    const SizedBox(width: AppSpacingTokens.lg),
                    const Expanded(
                      child: AppInlineSkeleton(
                        children: [
                          AppInlineSkeletonBlock(height: 28, widthFactor: 0.45),
                          AppInlineSkeletonBlock(height: 16, widthFactor: 0.8),
                          AppInlineSkeletonBlock(height: 18, widthFactor: 0.62),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    TodayWaterArc(
                      completedCount: water.completedCount,
                      targetCount: water.targetCount,
                      size: compact ? 112 : 128,
                    ),
                    const SizedBox(width: AppSpacingTokens.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: typography.displayMd.copyWith(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                              children: [
                                TextSpan(text: '${water.completedCount}'),
                                TextSpan(
                                  text: ' ${l10n.todayWaterUnit}',
                                  style: typography.bodyMd.copyWith(
                                    color: surface.body,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacingTokens.xs),
                          Text(
                            l10n.todayWaterGoalCount(water.targetCount),
                            style: typography.bodySm.copyWith(
                              color: surface.body,
                            ),
                          ),
                          const SizedBox(height: AppSpacingTokens.md),
                          Text(
                            l10n.todayWaterRemainingCount(water.remainingCount),
                            style: typography.bodyMdStrong.copyWith(
                              color: TodayPalette.brand,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TodayMedicationCard extends StatelessWidget {
  const _TodayMedicationCard({
    required this.medication,
    required this.isLoading,
  });

  final TodayMedicationSummary medication;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return TodayPanel(
      key: const Key('today-medication-card'),
      color: Color.alphaBlend(
        TodayPalette.amberSoft.withValues(alpha: 0.38),
        surface.canvas,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodaySectionHeader(
            title: l10n.todayMedicationCardTitle,
            compact: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TodayStatusDot(),
                const SizedBox(width: AppSpacingTokens.sm),
                TodayTextAction(
                  label: l10n.todayMedicationAction,
                  emphasized: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          if (isLoading)
            const AppInlineSkeleton(
              children: [
                AppInlineSkeletonBlock(height: 20, widthFactor: 0.72),
                AppInlineSkeletonBlock(height: 16, widthFactor: 0.86),
              ],
            )
          else
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: TodayPalette.amberSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacingTokens.md),
                    child: Icon(
                      Icons.medication_rounded,
                      color: TodayPalette.amber,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.todayMedicationSummary(
                          medication.medicineCount,
                          medication.pendingCount,
                        ),
                        style: typography.bodyMdStrong,
                      ),
                      const SizedBox(height: AppSpacingTokens.xs),
                      Text(
                        l10n.todayMedicationNextDose(
                          medication.nextDoseTimeLabel,
                          medication.nextMedicineName ??
                              _medicationName(l10n, medication.nextMedicine),
                        ),
                        style: typography.bodySm.copyWith(color: surface.body),
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
}

class _TodayHealthSummaryCard extends StatelessWidget {
  const _TodayHealthSummaryCard({
    required this.vitals,
    required this.isLoading,
    this.desktop = false,
  });

  final List<TodayVitalSummary> vitals;
  final bool isLoading;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final metricTiles = [
      TodayHealthMetricTile(
        icon: Icons.favorite_rounded,
        color: TodayPalette.coralStrong,
        label: l10n.todayVitalHeartRateLabel,
        value: _vitalValue(TodayVitalType.heartRate),
        unit: l10n.todayVitalHeartRateUnit,
        status: l10n.todayVitalStatusNormal,
      ),
      TodayHealthMetricTile(
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF428BFF),
        label: l10n.todayVitalBloodPressureLabel,
        value: _vitalValue(TodayVitalType.bloodPressure),
        status: l10n.todayVitalStatusNormal,
      ),
      TodayHealthMetricTile(
        icon: Icons.bedtime_rounded,
        color: TodayPalette.violetStrong,
        label: l10n.todayVitalSleepLabel,
        value: _vitalValue(TodayVitalType.sleep),
        unit: l10n.todayVitalSleepUnit,
        status: l10n.todayVitalStatusGood,
      ),
    ];

    return TodayPanel(
      key: const Key('today-health-summary-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodaySectionHeader(
            title: l10n.todayHealthSummaryCardTitle,
            trailing: TodayTextAction(
              label: l10n.todayMoreAction,
              icon: Icons.chevron_right_rounded,
              onTap: () {},
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          if (isLoading)
            const AppInlineSkeleton(
              children: [
                AppInlineSkeletonBlock(height: 18, widthFactor: 0.42),
                AppInlineSkeletonBlock(height: 34),
                AppInlineSkeletonBlock(height: 18, widthFactor: 0.72),
              ],
            )
          else
            TodayMetricList(desktop: desktop, children: metricTiles),
        ],
      ),
    );
  }

  String _vitalValue(TodayVitalType type) {
    for (final vital in vitals) {
      if (vital.type == type) return vital.valueLabel;
    }
    return '--';
  }
}

class _TodayMealSuggestionCard extends StatelessWidget {
  const _TodayMealSuggestionCard({
    required this.mealSuggestion,
    this.desktop = false,
  });

  final TodayMealSuggestion mealSuggestion;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = desktop
        ? AppTypographyTokens.desktop(theme.colorScheme.onSurface)
        : AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return TodayPanel(
      key: const Key('today-meal-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodaySectionHeader(
            title: l10n.todayMealCardTitle,
            trailing: TodayTextAction(
              label: l10n.todayMealRefreshAction,
              icon: Icons.refresh_rounded,
              onTap: () {},
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = constraints.maxWidth >= 420;

              final image = TodayImagePlaceholder(
                label: l10n.todayMealImagePlaceholder,
                width: horizontal ? 136 : 116,
                height: horizontal ? 94 : 82,
                icon: Icons.restaurant_outlined,
              );
              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _mealTitle(l10n, mealSuggestion.type),
                    style: typography.bodyMdStrong.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xs),
                  Text(
                    _mealDescription(l10n, mealSuggestion.type),
                    style: typography.bodySm.copyWith(color: surface.body),
                  ),
                  const SizedBox(height: AppSpacingTokens.xs),
                  Text(
                    l10n.todayMealEnergyHint,
                    style: typography.bodySm.copyWith(color: surface.body),
                  ),
                ],
              );

              if (!horizontal) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    image,
                    const SizedBox(height: AppSpacingTokens.sm),
                    copy,
                  ],
                );
              }

              return Row(
                children: [
                  image,
                  const SizedBox(width: AppSpacingTokens.lg),
                  Expanded(child: copy),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TodayEnvironmentCard extends StatelessWidget {
  const _TodayEnvironmentCard({
    required this.environment,
    required this.isLoading,
  });

  final TodayEnvironmentSummary environment;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chips = environment.signals
        .map(
          (signal) => TodaySignalPill(
            icon: _environmentIcon(signal.type),
            label: _environmentLabel(l10n, signal.type),
            level: _environmentLevelLabel(l10n, signal.level),
            color: _environmentAccent(signal.type),
          ),
        )
        .toList(growable: false);

    return TodayPanel(
      key: const Key('today-environment-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodaySectionHeader(
            title: l10n.todayEnvironmentCardTitle,
            trailing: TodayTextAction(
              label: l10n.todayViewDetailsAction,
              icon: Icons.chevron_right_rounded,
              onTap: () {},
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          if (isLoading)
            const AppInlineSkeleton(
              children: [
                AppInlineSkeletonBlock(height: 18, widthFactor: 0.46),
                AppInlineSkeletonBlock(height: 32),
              ],
            )
          else
            TodaySignalList(children: chips),
        ],
      ),
    );
  }
}

class _TodayLumiCard extends StatelessWidget {
  const _TodayLumiCard({required this.suggestion, this.desktop = false});

  final TodayLumiSuggestion suggestion;
  final bool desktop;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = desktop
        ? AppTypographyTokens.desktop(theme.colorScheme.onSurface)
        : AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return TodayPanel(
      key: const Key('today-lumi-card'),
      color: TodayPalette.brandSoft,
      shadow: AppShadowTokens.level1,
      child: Row(
        children: [
          const TodayLumiAvatarPlaceholder(),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.todayLumiCardTitle, style: typography.bodyMdStrong),
                const SizedBox(height: AppSpacingTokens.xs),
                Text(
                  _lumiBody(l10n, suggestion.type),
                  style: typography.bodySm.copyWith(color: surface.body),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          const Icon(
            Icons.chevron_right_rounded,
            color: TodayPalette.brand,
            size: 22,
          ),
        ],
      ),
    );
  }
}

String _greetingTitle(AppLocalizations l10n, TodayDayMoment moment) {
  return switch (moment) {
    TodayDayMoment.morning => l10n.todayGreetingTitleMorning,
    TodayDayMoment.afternoon => l10n.todayGreetingTitleAfternoon,
    TodayDayMoment.evening => l10n.todayGreetingTitleEvening,
  };
}

String _greetingSubtitle(AppLocalizations l10n, TodayDayMoment moment) {
  return switch (moment) {
    TodayDayMoment.morning => l10n.todayGreetingSubtitleMorning,
    TodayDayMoment.afternoon => l10n.todayGreetingSubtitleAfternoon,
    TodayDayMoment.evening => l10n.todayGreetingSubtitleEvening,
  };
}

String _medicationName(AppLocalizations l10n, TodayMedicationKind kind) {
  return switch (kind) {
    TodayMedicationKind.atorvastatin => l10n.todayMedicationNameAtorvastatin,
  };
}

String _mealTitle(AppLocalizations l10n, TodayMealSuggestionType type) {
  return switch (type) {
    TodayMealSuggestionType.highProteinBalancedLunch =>
      l10n.todayMealHighProteinBalancedTitle,
  };
}

String _mealDescription(AppLocalizations l10n, TodayMealSuggestionType type) {
  return switch (type) {
    TodayMealSuggestionType.highProteinBalancedLunch =>
      l10n.todayMealHighProteinBalancedDescription,
  };
}

String _environmentLabel(
  AppLocalizations l10n,
  TodayEnvironmentSignalType type,
) {
  return switch (type) {
    TodayEnvironmentSignalType.pollen => l10n.todayEnvironmentPollenLabel,
    TodayEnvironmentSignalType.uv => l10n.todayEnvironmentUvLabel,
  };
}

String _environmentLevelLabel(
  AppLocalizations l10n,
  TodayEnvironmentLevel level,
) {
  return switch (level) {
    TodayEnvironmentLevel.low => l10n.todayEnvironmentLevelLow,
    TodayEnvironmentLevel.medium => l10n.todayEnvironmentLevelMedium,
    TodayEnvironmentLevel.high => l10n.todayEnvironmentLevelHigh,
  };
}

IconData _environmentIcon(TodayEnvironmentSignalType type) {
  return switch (type) {
    TodayEnvironmentSignalType.pollen => Icons.eco_rounded,
    TodayEnvironmentSignalType.uv => Icons.wb_sunny_outlined,
  };
}

Color _environmentAccent(TodayEnvironmentSignalType type) {
  return switch (type) {
    TodayEnvironmentSignalType.pollen => TodayPalette.brand,
    TodayEnvironmentSignalType.uv => TodayPalette.amber,
  };
}

String _lumiBody(AppLocalizations l10n, TodayLumiSuggestionType type) {
  return switch (type) {
    TodayLumiSuggestionType.pollenProtection =>
      l10n.todayLumiPollenProtectionBody,
  };
}
