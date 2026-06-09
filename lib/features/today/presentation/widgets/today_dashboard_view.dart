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
      _TodoSection(dashboard: dashboard),
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
                  _TodoSection(dashboard: dashboard),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.lg),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _RecommendationSection(dashboard: dashboard, compact: true),
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
        AppSpacingTokens.sm,
        AppSpacingTokens.sm,
        AppSpacingTokens.sm,
        AppSpacingTokens.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TodaySectionHeader(
            title: l10n.todayHealthSummaryCardTitle,
            leading: const Icon(
              Icons.check_circle_outline_rounded,
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
          const SizedBox(height: AppSpacingTokens.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < items.length; index += 1) ...[
                Expanded(child: _OverviewMetric(item: items[index])),
                if (index < items.length - 1)
                  const _VerticalMetricDivider(
                    height: AppSpacingTokens.x4l + AppSpacingTokens.xs,
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
          Icon(item.icon, color: item.color, size: AppSpacingTokens.lg),
          const SizedBox(height: AppSpacingTokens.xs),
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
          const SizedBox(height: AppSpacingTokens.xxs),
          AppSkeletonSlot(
            skeleton: const AppInlineSkeletonBlock(
              height: 20,
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
          const SizedBox(height: AppSpacingTokens.xxs),
          AppSkeletonSlot(
            skeleton: const AppInlineSkeletonBlock(
              height: 20,
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
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return _TodaySection(
      title: l10n.todayPrioritySectionTitle,
      actionLabel: l10n.todayManageAction,
      onAction: () => AppToast.show(context, l10n.todayManageAction),
      child: TodayPanel(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var index = 0; index < items.length; index += 1) ...[
              _PriorityRow(item: items[index]),
              if (index < items.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: AppSpacingTokens.x5l,
                  color: surface.hairline.withValues(alpha: 0.62),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  const _PriorityRow({required this.item});

  final _PriorityItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

    return Material(
      key: item.key,
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AppToast.show(context, item.action),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.md,
            vertical: AppSpacingTokens.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TodayGlyphTile(
                icon: item.icon,
                color: item.color,
                size: AppSpacingTokens.x2l,
                radius: AppRadiusTokens.md,
                gradient: false,
              ),
              const SizedBox(width: AppSpacingTokens.sm),
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
                    if (item.progress != null) ...[
                      const SizedBox(height: AppSpacingTokens.xs),
                      TodayLinearProgress(
                        progress: item.progress!,
                        color: item.color,
                        height: 5,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              SizedBox(
                width: 82,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppSkeletonText(
                      text: item.detail,
                      style: typography.bodySmStrong.copyWith(
                        color: surface.body,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widthFactor: 0.76,
                    ),
                    const SizedBox(height: AppSpacingTokens.xs),
                    _PriorityActionPill(item: item),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityActionPill extends StatelessWidget {
  const _PriorityActionPill({required this.item});

  final _PriorityItem item;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypographyTokens.mobile(
      Theme.of(context).colorScheme.onSurface,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AppToast.show(context, item.action),
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.sm,
              vertical: AppSpacingTokens.xs,
            ),
            child: Text(
              item.action,
              style: typography.bodySmStrong.copyWith(
                color: AppColorTokens.onPrimary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
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

class _TodoSection extends StatelessWidget {
  const _TodoSection({required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final items = _todoItems(l10n, dashboard);

    return _TodaySection(
      title: l10n.todayTodoSectionTitle,
      actionLabel: l10n.todayTodoAddAction,
      onAction: () => AppToast.show(context, l10n.todayTodoAddAction),
      child: TodayPanel(
        key: const Key('today-todo-card'),
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            for (var index = 0; index < items.length; index += 1) ...[
              _TodoRow(item: items[index]),
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

class _TodoRow extends StatelessWidget {
  const _TodoRow({required this.item});

  final _TodoItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final statusIcon = DecoratedBox(
      decoration: BoxDecoration(
        color: item.completed
            ? item.color.withValues(alpha: 0.12)
            : surface.canvasSoft,
        border: Border.all(color: item.color.withValues(alpha: 0.24)),
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(
        dimension: AppSpacingTokens.x2l,
        child: Center(
          child: Icon(
            item.completed
                ? Icons.check_rounded
                : Icons.radio_button_unchecked_rounded,
            color: item.color,
            size: AppSpacingTokens.lg,
          ),
        ),
      ),
    );

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
              AppSkeletonSlot(
                isLoading: item.statusIsDynamic ? null : false,
                skeleton: const AppInlineSkeletonCircle(
                  size: AppSpacingTokens.x2l,
                ),
                child: statusIcon,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacingTokens.xxs),
                    AppSkeletonText(
                      text: item.subtitle,
                      style: typography.bodySm.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widthFactor: 0.84,
                      isLoading: item.subtitleIsDynamic ? null : false,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                  border: Border.all(color: item.color.withValues(alpha: 0.12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.sm,
                    vertical: AppSpacingTokens.xxs,
                  ),
                  child: Text(
                    item.source,
                    style: typography.caption.copyWith(
                      color: item.color,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
  final medicationDone = dashboard.medication.medicineCount == 0
      ? 0
      : dashboard.medication.medicineCount - dashboard.medication.pendingCount;
  final safeMedicationDone = medicationDone < 0 ? 0 : medicationDone;

  return [
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
      icon: Icons.water_drop_rounded,
      label: l10n.todayHydrationOverviewLabel,
      value: l10n.todayWaterOverviewCount(
        dashboard.water.completedCount,
        dashboard.water.targetCount,
      ),
      status: dashboard.water.progress >= 0.75
          ? l10n.todayVitalStatusGood
          : l10n.todayStatusNeedsImprovement,
      color: TodayPalette.teal,
      statusColor: dashboard.water.progress >= 0.75
          ? TodayPalette.teal
          : TodayPalette.amber,
    ),
    _OverviewItem(
      icon: Icons.bedtime_rounded,
      label: l10n.todayVitalSleepLabel,
      value: '$sleep ${l10n.todayVitalSleepUnit}',
      status: l10n.todayVitalStatusGood,
      color: TodayPalette.blue,
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
  final sourceItems = dashboard.priorityItems.isEmpty
      ? _fallbackPriorityItems(dashboard)
      : dashboard.priorityItems;

  return [
    for (final item in sourceItems)
      switch (item.type) {
        TodayPriorityItemType.medication => _PriorityItem(
          key: const Key('today-medication-card'),
          icon: Icons.medication_rounded,
          color: TodayPalette.blue,
          title: l10n.todayMedicationCardTitle,
          subtitle: l10n.todayMedicationPrioritySubtitle(
            item.count ?? dashboard.medication.pendingCount,
          ),
          detail: l10n.todayMedicationPriorityDetail(
            item.timeLabel ?? dashboard.medication.nextDoseTimeLabel,
            item.medicineName ?? nextMedicineName,
          ),
          action: l10n.todayMedicationTakeAction,
        ),
        TodayPriorityItemType.water => _PriorityItem(
          key: const Key('today-water-card'),
          icon: Icons.local_drink_rounded,
          color: TodayPalette.teal,
          title: l10n.todayWaterPriorityTitle,
          subtitle: l10n.todayWaterGoalCount(
            item.targetCount ?? dashboard.water.targetCount,
          ),
          detail: l10n.todayWaterCount(
            item.count ?? dashboard.water.completedCount,
          ),
          action: l10n.todayDrinkWaterAction,
          progress: item.progress ?? dashboard.water.progress,
        ),
      },
  ];
}

List<TodayPriorityItem> _fallbackPriorityItems(TodayDashboard dashboard) {
  return [
    TodayPriorityItem(
      id: 'medication',
      type: TodayPriorityItemType.medication,
      count: dashboard.medication.pendingCount,
      timeLabel: dashboard.medication.nextDoseTimeLabel,
      medicineName: dashboard.medication.nextMedicineName,
    ),
    TodayPriorityItem(
      id: 'water',
      type: TodayPriorityItemType.water,
      count: dashboard.water.completedCount,
      targetCount: dashboard.water.targetCount,
      progress: dashboard.water.progress,
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
  ];
}

List<_TodoItem> _todoItems(AppLocalizations l10n, TodayDashboard dashboard) {
  final nextMedicineName =
      dashboard.medication.nextMedicineName ??
      _medicationName(l10n, dashboard.medication.nextMedicine);
  final waterProgressPercent = (dashboard.water.progress * 100).round();

  return [
    _TodoItem(
      title: l10n.todayTodoMedicationTitle,
      subtitle: l10n.todayTodoMedicationSubtitle(
        dashboard.medication.nextDoseTimeLabel,
        nextMedicineName,
      ),
      source: l10n.todayTodoSourceSystem,
      action: dashboard.medication.pendingCount == 0
          ? l10n.todayStatusCompleted
          : l10n.todayMedicationTakeAction,
      color: TodayPalette.blue,
      completed: dashboard.medication.pendingCount == 0,
      statusIsDynamic: true,
      subtitleIsDynamic: true,
    ),
    _TodoItem(
      title: l10n.todayTodoWaterTitle,
      subtitle: l10n.todayTodoWaterSubtitle(waterProgressPercent),
      source: l10n.todayTodoSourceSystem,
      action: dashboard.water.progress >= 1
          ? l10n.todayStatusCompleted
          : l10n.todayDrinkWaterAction,
      color: TodayPalette.teal,
      completed: dashboard.water.progress >= 1,
      statusIsDynamic: true,
      subtitleIsDynamic: true,
    ),
    _TodoItem(
      title: l10n.todayTodoCustomTitle,
      subtitle: l10n.todayTodoCustomSubtitle,
      source: l10n.todayTodoSourceUser,
      action: l10n.todayTodoAddAction,
      color: TodayPalette.amber,
      completed: false,
      statusIsDynamic: false,
      subtitleIsDynamic: false,
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

class _TodoItem {
  const _TodoItem({
    required this.title,
    required this.subtitle,
    required this.source,
    required this.action,
    required this.color,
    required this.completed,
    required this.statusIsDynamic,
    required this.subtitleIsDynamic,
  });

  final String title;
  final String subtitle;
  final String source;
  final String action;
  final Color color;
  final bool completed;
  final bool statusIsDynamic;
  final bool subtitleIsDynamic;
}
