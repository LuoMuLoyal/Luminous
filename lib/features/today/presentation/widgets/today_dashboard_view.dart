import 'package:flutter/material.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
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
        ? _DesktopTodayDashboard(dashboard: dashboard)
        : _MobileTodayDashboard(dashboard: dashboard);

    return AppSkeletonScope(isLoading: isLoading, child: content);
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
  const _MobileTodayDashboard({required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      _TodayTopBar(
        moment: dashboard.user.moment,
        hasUnreadNotifications: dashboard.user.hasUnreadNotifications,
      ),
      _HealthOverviewCard(dashboard: dashboard),
      _PrioritySection(dashboard: dashboard),
      _RecommendationSection(dashboard: dashboard),
      _TrendSection(dashboard: dashboard),
      const _QuickRecordSection(),
    ];

    return ListView.separated(
      key: const PageStorageKey<String>('today-dashboard-scroll'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacingTokens.md,
        AppSpacingTokens.md,
        AppSpacingTokens.md,
        AppSpacingTokens.x5l + AppSpacingTokens.xs,
      ),
      itemBuilder: (context, index) => sections[index],
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacingTokens.lg),
      itemCount: sections.length,
    );
  }
}

class _DesktopTodayDashboard extends StatelessWidget {
  const _DesktopTodayDashboard({required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey<String>('today-dashboard-desktop-scroll'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacingTokens.xl,
        AppSpacingTokens.xl,
        AppSpacingTokens.xl,
        AppSpacingTokens.xl,
      ),
      children: [
        _TodayTopBar(
          moment: dashboard.user.moment,
          hasUnreadNotifications: dashboard.user.hasUnreadNotifications,
        ),
        const SizedBox(height: AppSpacingTokens.lg),
        _HealthOverviewCard(dashboard: dashboard),
        const SizedBox(height: AppSpacingTokens.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  _PrioritySection(dashboard: dashboard),
                  const SizedBox(height: AppSpacingTokens.lg),
                  _TrendSection(dashboard: dashboard),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.lg),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _RecommendationSection(dashboard: dashboard, compact: true),
                  const SizedBox(height: AppSpacingTokens.lg),
                  const _QuickRecordSection(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TodayTopBar extends StatelessWidget {
  const _TodayTopBar({
    required this.moment,
    required this.hasUnreadNotifications,
  });

  final TodayDayMoment moment;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.todayHeroTitle,
                style: typography.displayXl.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.xxs),
              AppSkeletonText(
                text: _greetingSubtitle(l10n, moment),
                style: typography.bodyMd.copyWith(
                  color: Theme.of(context).extension<AppThemeSurface>()!.body,
                  letterSpacing: 0,
                ),
                widthFactor: 0.64,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.md),
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
    final theme = Theme.of(context);

    return Tooltip(
      message: l10n.todayNotificationsTooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            onPressed: () =>
                AppToast.show(context, l10n.todayNotificationsTooltip),
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: AppSpacingTokens.lg + AppSpacingTokens.xxs,
            ),
            color: theme.colorScheme.onSurface,
            visualDensity: VisualDensity.compact,
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          if (hasUnread)
            Positioned(
              right: AppSpacingTokens.sm,
              top: AppSpacingTokens.xs,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.square(dimension: AppSpacingTokens.xs),
              ),
            ),
        ],
      ),
    );
  }
}

class _HealthOverviewCard extends StatelessWidget {
  const _HealthOverviewCard({required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = _overviewItems(l10n, dashboard);

    return TodayPanel(
      key: const Key('today-health-summary-card'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacingTokens.md,
        AppSpacingTokens.md,
        AppSpacingTokens.md,
        AppSpacingTokens.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodaySectionHeader(
            title: l10n.todayHealthSummaryCardTitle,
            leading: const Icon(
              Icons.health_and_safety_outlined,
              color: TodayPalette.teal,
              size: AppSpacingTokens.lg,
            ),
            compact: true,
            trailing: AppSkeletonSlot(
              skeleton: const AppInlineSkeletonBlock(
                height: 22,
                width: 96,
                radius: AppRadiusTokens.pill,
              ),
              child: TodayTextAction(
                label: l10n.todayUpdatedAt(dashboard.user.updatedAtLabel),
                icon: Icons.refresh_rounded,
                onTap: () => AppToast.show(
                  context,
                  l10n.todayUpdatedAt(dashboard.user.updatedAtLabel),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < items.length; index += 1) ...[
                Expanded(child: _OverviewMetric(item: items[index])),
                if (index < items.length - 1)
                  const _VerticalMetricDivider(
                    height: AppSpacingTokens.x5l + AppSpacingTokens.md,
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({required this.item});

  final _OverviewItem item;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xxs),
      child: Column(
        children: [
          Icon(item.icon, color: item.color, size: AppSpacingTokens.xl),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            item.label,
            style: typography.bodyMd.copyWith(
              color: Theme.of(context).extension<AppThemeSurface>()!.body,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          AppSkeletonSlot(
            skeleton: const AppInlineSkeletonBlock(
              height: 22,
              width: 44,
              radius: AppRadiusTokens.sm,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                item.value,
                style: typography.bodyLg.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
                maxLines: 1,
              ),
            ),
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          AppSkeletonSlot(
            skeleton: const AppInlineSkeletonBlock(
              height: 22,
              width: 48,
              radius: AppRadiusTokens.pill,
            ),
            child: TodayStatusPill(
              label: item.status,
              color: item.statusColor ?? item.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrioritySection extends StatelessWidget {
  const _PrioritySection({required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = _priorityItems(l10n, dashboard);

    return _TodaySection(
      title: l10n.todayPrioritySectionTitle,
      actionLabel: l10n.todayManageAction,
      onAction: () => AppToast.show(context, l10n.todayManageAction),
      child: _ResponsiveCardGrid(
        minTileWidth: AppSpacingTokens.x6l + AppSpacingTokens.xl,
        spacing: AppSpacingTokens.md,
        children: [for (final item in items) _PriorityCard(item: item)],
      ),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  const _PriorityCard({required this.item});

  final _PriorityItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return TodayPanel(
      key: item.key,
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      color: Color.alphaBlend(
        item.color.withValues(alpha: 0.035),
        surface.canvas,
      ),
      borderColor: item.color.withValues(alpha: 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TodayGlyphTile(icon: item.icon, color: item.color),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: typography.displaySm.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacingTokens.xxs),
                    Text(
                      item.subtitle,
                      style: typography.bodySm.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          if (item.progress != null) ...[
            AppSkeletonSlot(
              skeleton: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppInlineSkeletonBlock(
                    height: 8,
                    radius: AppRadiusTokens.pill,
                  ),
                  SizedBox(height: AppSpacingTokens.sm),
                  Center(
                    child: AppInlineSkeletonBlock(
                      height: 18,
                      width: 42,
                      radius: AppRadiusTokens.sm,
                    ),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TodayLinearProgress(
                    progress: item.progress!,
                    color: item.color,
                  ),
                  const SizedBox(height: AppSpacingTokens.sm),
                  Center(
                    child: Text(
                      item.detail,
                      style: typography.displaySm.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            AppSkeletonText(
              text: item.detail,
              style: typography.bodyMd.copyWith(
                color: surface.body,
                letterSpacing: 0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              widthFactor: 0.74,
            ),
          const SizedBox(height: AppSpacingTokens.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => AppToast.show(context, item.action),
              style: FilledButton.styleFrom(
                backgroundColor: item.color,
                foregroundColor: AppColorTokens.onPrimary,
                minimumSize: const Size.fromHeight(
                  AppSpacingTokens.x2l + AppSpacingTokens.xxs,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadiusTokens.md),
                ),
                textStyle: typography.buttonLg.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              child: Text(item.action),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationSection extends StatelessWidget {
  const _RecommendationSection({required this.dashboard, this.compact = false});

  final TodayDashboard dashboard;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final items = _recommendationItems(l10n, dashboard);

    return _TodaySection(
      title: l10n.todayRecommendationSectionTitle,
      actionLabel: l10n.todayViewMoreAction,
      onAction: () => AppToast.show(context, l10n.todayViewMoreAction),
      child: TodayPanel(
        key: const Key('today-recommendation-card'),
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var index = 0; index < items.length; index += 1) ...[
              _RecommendationRow(item: items[index], compact: compact),
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: AppSpacingTokens.x4l + AppSpacingTokens.xs,
                  color: surface.hairline.withValues(alpha: 0.62),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  const _RecommendationRow({required this.item, required this.compact});

  final _RecommendationItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AppToast.show(context, item.action),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.md,
            vertical: AppSpacingTokens.sm,
          ),
          child: Row(
            children: [
              TodayGlyphTile(
                icon: item.icon,
                color: item.color,
                size: AppSpacingTokens.x2l + AppSpacingTokens.xxs,
                radius: AppRadiusTokens.md,
                gradient: false,
              ),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: typography.bodyMdStrong.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacingTokens.xxs),
                    Text(
                      item.subtitle,
                      style: typography.bodySm.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: TodayPalette.tealSoft,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                  border: Border.all(
                    color: TodayPalette.teal.withValues(alpha: 0.16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.sm,
                    vertical: AppSpacingTokens.xxs,
                  ),
                  child: Text(
                    item.action,
                    style: typography.caption.copyWith(
                      color: TodayPalette.tealDeep,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacingTokens.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: surface.mute,
                size: AppSpacingTokens.lg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendSection extends StatelessWidget {
  const _TrendSection({required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = _trendItems(l10n, dashboard);

    return _TodaySection(
      title: l10n.todayTrendSectionTitle,
      actionLabel: l10n.todayTrendAnalysisAction,
      onAction: () => AppToast.show(context, l10n.todayTrendAnalysisAction),
      child: _ResponsiveCardGrid(
        minTileWidth: AppSpacingTokens.x5l + AppSpacingTokens.sm,
        spacing: AppSpacingTokens.sm,
        children: [for (final item in items) _TrendCard(item: item)],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.item});

  final _TrendItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return TodayPanel(
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: typography.bodySmStrong.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          AppSkeletonText(
            text: item.value,
            style: typography.displaySm.copyWith(
              color: item.color,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
            widthFactor: 0.48,
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          AppSkeletonSlot(
            skeleton: const AppInlineSkeletonBlock(
              height: 42,
              radius: AppRadiusTokens.md,
            ),
            child: TodayMiniTrendChart(points: item.points, color: item.color),
          ),
          const SizedBox(height: AppSpacingTokens.xxs),
          _WeekLabels(color: item.color),
        ],
      ),
    );
  }
}

class _WeekLabels extends StatelessWidget {
  const _WeekLabels({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );
    final labels = [
      l10n.recordWeekdayMon,
      l10n.recordWeekdayTue,
      l10n.recordWeekdayWed,
      l10n.recordWeekdayThu,
      l10n.recordWeekdayFri,
      l10n.recordWeekdaySat,
      l10n.recordWeekdaySun,
    ];

    return Row(
      children: [
        for (final label in labels)
          Expanded(
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: label == l10n.recordWeekdayThu
                      ? color
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: AppSpacingTokens.md + AppSpacingTokens.xxs,
                  child: Center(
                    child: Text(
                      label.isEmpty ? '' : label.substring(0, 1),
                      style: typography.caption.copyWith(
                        color: label == l10n.recordWeekdayThu
                            ? AppColorTokens.onPrimary
                            : TodayPalette.mute,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _QuickRecordSection extends StatelessWidget {
  const _QuickRecordSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      _QuickRecordItem(
        icon: Icons.medication_rounded,
        label: l10n.todayQuickMedication,
        color: TodayPalette.blue,
      ),
      _QuickRecordItem(
        icon: Icons.fact_check_rounded,
        label: l10n.todayQuickSymptom,
        color: TodayPalette.teal,
      ),
      _QuickRecordItem(
        icon: Icons.sentiment_satisfied_alt_rounded,
        label: l10n.todayQuickMood,
        color: TodayPalette.violet,
      ),
      _QuickRecordItem(
        icon: Icons.local_drink_rounded,
        label: l10n.todayQuickWater,
        color: TodayPalette.teal,
      ),
    ];

    return _TodaySection(
      title: l10n.todayQuickRecordSectionTitle,
      child: _ResponsiveCardGrid(
        minTileWidth: AppSpacingTokens.x4l + AppSpacingTokens.md,
        spacing: AppSpacingTokens.sm,
        children: [for (final item in items) _QuickRecordCard(item: item)],
      ),
    );
  }
}

class _QuickRecordCard extends StatelessWidget {
  const _QuickRecordCard({required this.item});

  final _QuickRecordItem item;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );

    return TodayPanel(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.sm,
        vertical: AppSpacingTokens.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AppToast.show(context, item.label),
          borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: item.color, size: AppSpacingTokens.xl),
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                item.label,
                style: typography.bodySmStrong.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodaySection extends StatelessWidget {
  const _TodaySection({
    required this.title,
    required this.child,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TodaySectionHeader(
          title: title,
          trailing: actionLabel == null
              ? null
              : TodayTextAction(label: actionLabel!, onTap: onAction ?? () {}),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        child,
      ],
    );
  }
}

class _ResponsiveCardGrid extends StatelessWidget {
  const _ResponsiveCardGrid({
    required this.children,
    required this.minTileWidth,
    required this.spacing,
  });

  final List<Widget> children;
  final double minTileWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minTileWidth)
            .floor()
            .clamp(1, children.length)
            .toInt();
        final rows = <Widget>[];

        for (var index = 0; index < children.length; index += columns) {
          final rowChildren = children.skip(index).take(columns).toList();
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (
                  var childIndex = 0;
                  childIndex < rowChildren.length;
                  childIndex += 1
                ) ...[
                  Expanded(child: rowChildren[childIndex]),
                  if (childIndex < rowChildren.length - 1)
                    SizedBox(width: spacing),
                ],
                if (rowChildren.length < columns)
                  for (
                    var filler = rowChildren.length;
                    filler < columns;
                    filler += 1
                  ) ...[
                    SizedBox(width: spacing),
                    const Expanded(child: SizedBox.shrink()),
                  ],
              ],
            ),
          );
        }

        return Column(
          children: [
            for (var index = 0; index < rows.length; index += 1) ...[
              rows[index],
              if (index < rows.length - 1) SizedBox(height: spacing),
            ],
          ],
        );
      },
    );
  }
}

class _VerticalMetricDivider extends StatelessWidget {
  const _VerticalMetricDivider({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return SizedBox(
      height: height,
      child: VerticalDivider(width: 1, thickness: 1, color: surface.hairline),
    );
  }
}

List<_OverviewItem> _overviewItems(
  AppLocalizations l10n,
  TodayDashboard dashboard,
) {
  final sleep = _vitalValue(
    dashboard.vitals,
    TodayVitalType.sleep,
    fallback: l10n.todaySleepFallbackValue,
  );
  final mood = _vitalValue(
    dashboard.vitals,
    TodayVitalType.mood,
    fallback: l10n.todayMoodStableValue,
  );
  final medicationDone = dashboard.medication.medicineCount == 0
      ? 0
      : dashboard.medication.medicineCount - dashboard.medication.pendingCount;
  final safeMedicationDone = medicationDone < 0 ? 0 : medicationDone;

  return [
    _OverviewItem(
      icon: Icons.bedtime_rounded,
      label: l10n.todayVitalSleepLabel,
      value: '$sleep ${l10n.todayVitalSleepUnit}',
      status: l10n.todayVitalStatusGood,
      color: TodayPalette.blue,
    ),
    _OverviewItem(
      icon: Icons.water_drop_rounded,
      label: l10n.todayHydrationOverviewLabel,
      value: '${(dashboard.water.progress * 100).round()}%',
      status: dashboard.water.progress >= 0.75
          ? l10n.todayVitalStatusGood
          : l10n.todayStatusNeedsImprovement,
      color: TodayPalette.teal,
      statusColor: dashboard.water.progress >= 0.75
          ? TodayPalette.teal
          : TodayPalette.amber,
    ),
    _OverviewItem(
      icon: Icons.sentiment_satisfied_alt_rounded,
      label: l10n.todayMoodOverviewLabel,
      value: mood,
      status: l10n.todayVitalStatusGood,
      color: TodayPalette.violet,
    ),
    _OverviewItem(
      icon: Icons.medication_rounded,
      label: l10n.todayMedicationOverviewLabel,
      value: '$safeMedicationDone/${dashboard.medication.medicineCount}',
      status: dashboard.medication.pendingCount == 0
          ? l10n.todayStatusCompleted
          : l10n.todayMedicationPendingStatus,
      color: TodayPalette.green,
    ),
    _OverviewItem(
      icon: Icons.calendar_month_rounded,
      label: l10n.todayPeriodOverviewLabel,
      value: l10n.todayPeriodDayValue(dashboard.period.day),
      status: l10n.todayPeriodStatus,
      color: TodayPalette.pink,
    ),
  ];
}

List<_PriorityItem> _priorityItems(
  AppLocalizations l10n,
  TodayDashboard dashboard,
) {
  final nextMedicineName =
      dashboard.medication.nextMedicineName ??
      _medicationName(l10n, dashboard.medication.nextMedicine);
  final pending = dashboard.medication.pendingCount;
  final waterProgress = dashboard.water.progress;

  return [
    _PriorityItem(
      key: const Key('today-medication-card'),
      icon: Icons.medication_rounded,
      color: TodayPalette.blue,
      title: l10n.todayMedicationCardTitle,
      subtitle: l10n.todayMedicationPrioritySubtitle(pending),
      detail: l10n.todayMedicationPriorityDetail(
        dashboard.medication.nextDoseTimeLabel,
        nextMedicineName,
      ),
      action: l10n.todayMedicationTakeAction,
    ),
    _PriorityItem(
      key: const Key('today-water-card'),
      icon: Icons.local_drink_rounded,
      color: TodayPalette.teal,
      title: l10n.todayWaterPriorityTitle,
      subtitle: l10n.todayWaterGoalMl,
      detail: '${(waterProgress * 100).round()}%',
      action: l10n.todayDrinkWaterAction,
      progress: waterProgress,
    ),
    _PriorityItem(
      key: const Key('today-mood-card'),
      icon: Icons.sentiment_satisfied_alt_rounded,
      color: TodayPalette.violet,
      title: l10n.todayMoodCheckinTitle,
      subtitle: l10n.todayMoodCheckinSubtitle,
      detail: _vitalValue(
        dashboard.vitals,
        TodayVitalType.mood,
        fallback: l10n.todayMoodNoRecord,
      ),
      action: l10n.todayMoodCheckinAction,
    ),
    _PriorityItem(
      key: const Key('today-campus-card'),
      icon: Icons.local_hospital_rounded,
      color: TodayPalette.blue,
      title: l10n.todayCampusGuideTitle,
      subtitle: l10n.todayCampusGuideSubtitle,
      detail: l10n.todayCampusGuideDetail,
      action: l10n.todayViewAction,
    ),
  ];
}

List<_RecommendationItem> _recommendationItems(
  AppLocalizations l10n,
  TodayDashboard dashboard,
) {
  return [
    _RecommendationItem(
      icon: Icons.health_and_safety_outlined,
      color: TodayPalette.teal,
      title: l10n.todayRecommendationMedicineSafetyTitle,
      subtitle: l10n.todayRecommendationMedicineSafetyBody,
      action: l10n.todayLearnMoreAction,
    ),
    _RecommendationItem(
      icon: Icons.bedtime_rounded,
      color: TodayPalette.blue,
      title: l10n.todayRecommendationSleepTitle,
      subtitle: l10n.todayRecommendationSleepBody,
      action: l10n.todayLearnMoreAction,
    ),
    _RecommendationItem(
      icon: Icons.water_drop_rounded,
      color: TodayPalette.teal,
      title: l10n.todayRecommendationWaterTitle,
      subtitle: l10n.todayRecommendationWaterBody,
      action: dashboard.water.progress >= 1
          ? l10n.todayStatusCompleted
          : l10n.todayCompleteAction,
    ),
    _RecommendationItem(
      icon: Icons.coffee_rounded,
      color: TodayPalette.blue,
      title: l10n.todayRecommendationCoffeeTitle,
      subtitle: l10n.todayRecommendationCoffeeBody,
      action: l10n.todayLearnMoreAction,
    ),
  ];
}

List<_TrendItem> _trendItems(AppLocalizations l10n, TodayDashboard dashboard) {
  final sleep = _vitalValue(
    dashboard.vitals,
    TodayVitalType.sleep,
    fallback: l10n.todaySleepFallbackValue,
  );
  final mood = _vitalValue(
    dashboard.vitals,
    TodayVitalType.mood,
    fallback: l10n.todayMoodStableValue,
  );

  return [
    _TrendItem(
      title: l10n.todayTrendSleepTitle,
      value: '$sleep ${l10n.todayVitalSleepUnit}',
      color: TodayPalette.blue,
      points: const [6.8, 7.0, 7.2, 6.9, 7.1, 7.4, 7.8],
    ),
    _TrendItem(
      title: l10n.todayTrendWaterTitle,
      value: '${(dashboard.water.progress * 100).round()}%',
      color: TodayPalette.teal,
      points: const [62, 58, 54, 48, 57, 65, 74],
    ),
    _TrendItem(
      title: l10n.todayTrendMoodTitle,
      value: mood,
      color: TodayPalette.violet,
      points: const [3, 3.4, 3.9, 3.2, 2.6, 3.4, 4.0],
    ),
  ];
}

String _vitalValue(
  List<TodayVitalSummary> vitals,
  TodayVitalType type, {
  required String fallback,
}) {
  for (final vital in vitals) {
    if (vital.type == type) {
      final value = vital.valueLabel.trim();
      if (value.isNotEmpty && value != '--') return value;
    }
  }
  return fallback;
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
    TodayMedicationKind.vitaminBComplex =>
      l10n.todayMedicationNameVitaminBComplex,
  };
}

class _OverviewItem {
  const _OverviewItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
    required this.color,
    this.statusColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String status;
  final Color color;
  final Color? statusColor;
}

class _PriorityItem {
  const _PriorityItem({
    required this.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.action,
    this.progress,
  });

  final Key key;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String detail;
  final String action;
  final double? progress;
}

class _RecommendationItem {
  const _RecommendationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String action;
}

class _TrendItem {
  const _TrendItem({
    required this.title,
    required this.value,
    required this.color,
    required this.points,
  });

  final String title;
  final String value;
  final Color color;
  final List<double> points;
}

class _QuickRecordItem {
  const _QuickRecordItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}
