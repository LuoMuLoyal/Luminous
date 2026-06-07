import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/record_components.dart';
import 'package:luminous/features/record/presentation/widgets/record_overview.dart';
import 'package:luminous/features/record/presentation/widgets/record_copy.dart';
import 'package:luminous/features/record/presentation/widgets/record_sidebar.dart';
import 'package:luminous/features/record/presentation/widgets/record_timeline.dart';
import 'package:luminous/features/record/presentation/widgets/record_trends.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordDashboardView extends StatelessWidget {
  const RecordDashboardView({super.key, required this.dashboard});

  final RecordDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);
    final isDesktop = width >= AppBreakpoints.desktop;

    return isDesktop
        ? _DesktopRecordDashboard(
            dashboard: dashboard,
            l10n: l10n,
            typography: typography,
            surface: surface,
          )
        : _MobileRecordDashboard(
            dashboard: dashboard,
            l10n: l10n,
            typography: typography,
            surface: surface,
          );
  }
}

class _MobileRecordDashboard extends StatelessWidget {
  const _MobileRecordDashboard({
    required this.dashboard,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final quickActions = _mobileQuickActions(dashboard.quickActions);
    final timeline = dashboard.timeline.take(4).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MobileRecordDateBar(
          dashboard: dashboard,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileQuickRecordPanel(
          actions: quickActions,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileTimelinePanel(
          entries: timeline,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileSymptomPanel(
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileMoodTrendPanel(
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileCycleDietPanel(
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileSpecialistPackPanel(
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
      ],
    );
  }
}

class _MobileRecordDateBar extends StatelessWidget {
  const _MobileRecordDateBar({
    required this.dashboard,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final dateLabel = l10n.recordDatePillLabel(
      dashboard.selectedDate.month,
      dashboard.selectedDate.day,
      recordCopy(l10n, _weekdayKeyFromDate(dashboard.selectedDate)),
    );

    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => showRecordToast(context, l10n.recordPickDateAction),
              borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: surface.canvas,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                  border: Border.all(color: surface.hairline),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.md,
                    vertical: AppSpacingTokens.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        color: surface.body,
                        size: AppSpacingTokens.lg,
                      ),
                      const SizedBox(width: AppSpacingTokens.xs),
                      Expanded(
                        child: Text(
                          dateLabel,
                          style: typography.bodyMdStrong.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacingTokens.xs),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: surface.mute,
                        size: AppSpacingTokens.lg,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.sm),
        RecordTextAction(
          label: l10n.recordSwitchDateAction,
          icon: Icons.calendar_today_outlined,
          typography: typography,
          surface: surface,
          onTap: () => showRecordToast(context, l10n.recordSwitchDateAction),
        ),
      ],
    );
  }
}

class _MobileQuickRecordPanel extends StatelessWidget {
  const _MobileQuickRecordPanel({
    required this.actions,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return RecordSectionSurface(
      key: const Key('record-quick-actions'),
      title: l10n.recordQuickSectionTitle,
      typography: typography,
      surface: surface,
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const columns = 3;
          final tileWidth =
              (constraints.maxWidth - AppSpacingTokens.sm * (columns - 1)) /
              columns;

          return Wrap(
            spacing: AppSpacingTokens.sm,
            runSpacing: AppSpacingTokens.sm,
            children: [
              for (final action in actions)
                SizedBox(
                  width: tileWidth,
                  child: _MobileQuickRecordTile(
                    action: action,
                    l10n: l10n,
                    typography: typography,
                    surface: surface,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MobileQuickRecordTile extends StatelessWidget {
  const _MobileQuickRecordTile({
    required this.action,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final label = _quickRecordLabel(l10n, action);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showRecordToast(context, label),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              action.softColor.withValues(alpha: 0.46),
              surface.canvas,
            ),
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: action.accent.withValues(alpha: 0.16)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.xs,
              vertical: AppSpacingTokens.md,
            ),
            child: Column(
              children: [
                RecordIconBadge(
                  icon: action.icon,
                  color: AppColorTokens.onPrimary,
                  backgroundColor: action.accent,
                  size: AppSpacingTokens.x3l,
                  iconSize: AppSpacingTokens.lg,
                ),
                const SizedBox(height: AppSpacingTokens.sm),
                Text(
                  label,
                  style: typography.bodyMdStrong.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileTimelinePanel extends StatelessWidget {
  const _MobileTimelinePanel({
    required this.entries,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<RecordTimelineEntry> entries;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return RecordSectionSurface(
      key: const Key('record-timeline'),
      title: l10n.recordTodayEntriesTitle(entries.length),
      typography: typography,
      surface: surface,
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface.canvas,
          borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
          border: Border.all(color: surface.hairline),
        ),
        child: Column(
          children: [
            for (var index = 0; index < entries.length; index += 1)
              _MobileTimelineRow(
                entry: entries[index],
                l10n: l10n,
                typography: typography,
                surface: surface,
                isLast: index == entries.length - 1,
              ),
          ],
        ),
      ),
    );
  }
}

class _MobileTimelineRow extends StatelessWidget {
  const _MobileTimelineRow({
    required this.entry,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.isLast,
  });

  final RecordTimelineEntry entry;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final label = entry.rawTitle ?? recordCopy(l10n, entry.titleKey);
    final value = entry.valueKey == null
        ? entry.value
        : recordCopy(l10n, entry.valueKey!);
    final unit = entry.unitKey == null
        ? null
        : recordCopy(l10n, entry.unitKey!);
    final detail = entry.detailKey == null
        ? null
        : recordCopy(l10n, entry.detailKey!);
    final subtitle = [
      if (value != null && value.isNotEmpty)
        unit == null ? value : '$value $unit',
      if (detail != null && detail.isNotEmpty) detail,
    ].join(' · ');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (entry.recordId != null) {
            context.push('/record/${entry.recordId}');
          } else {
            showRecordToast(context, label);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.md,
            vertical: AppSpacingTokens.sm,
          ),
          child: Row(
            children: [
              SizedBox(
                width: AppSpacingTokens.x3l,
                child: Text(
                  entry.time,
                  style: typography.bodySm.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(
                width: AppSpacingTokens.lg,
                child: Column(
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: entry.accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: surface.canvas,
                          width: AppSpacingTokens.xxs,
                        ),
                      ),
                      child: const SizedBox.square(
                        dimension: AppSpacingTokens.sm,
                      ),
                    ),
                    if (!isLast)
                      SizedBox(
                        height: AppSpacingTokens.x3l,
                        child: VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: surface.hairline,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              RecordIconBadge(
                icon: entry.icon,
                color: entry.accent,
                backgroundColor: entry.softColor,
                size: AppSpacingTokens.x3l,
                iconSize: AppSpacingTokens.lg,
              ),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: typography.bodyMdStrong.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: AppSpacingTokens.xxs),
                      Text(
                        subtitle,
                        style: typography.bodySm.copyWith(color: surface.body),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (entry.badgeKey != null) ...[
                const SizedBox(width: AppSpacingTokens.xs),
                RecordPill(
                  label: recordCopy(l10n, entry.badgeKey!),
                  color: entry.accent,
                  typography: typography,
                ),
              ],
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

class _MobileSymptomPanel extends StatelessWidget {
  const _MobileSymptomPanel({
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return RecordSectionSurface(
      key: const Key('record-summary'),
      title: l10n.recordSymptomTrackingSectionTitle,
      typography: typography,
      surface: surface,
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            AppColorTokens.warningSoft.withValues(alpha: 0.42),
            surface.canvas,
          ),
          borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
          border: Border.all(
            color: AppColorTokens.warning.withValues(alpha: 0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  RecordIconBadge(
                    icon: Icons.psychology_alt_outlined,
                    color: AppColorTokens.warning,
                    backgroundColor: AppColorTokens.warningSoft,
                    size: AppSpacingTokens.x3l,
                    iconSize: AppSpacingTokens.lg,
                  ),
                  const SizedBox(width: AppSpacingTokens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.recordSymptomHeadache,
                          style: typography.bodyMdStrong.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacingTokens.xxs),
                        Text(
                          l10n.recordSymptomLoggedAt('08:20'),
                          style: typography.caption.copyWith(
                            color: surface.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.md),
              _InfoLine(
                label: l10n.recordBodyPartLabel,
                value: l10n.recordBodyPartForehead,
                typography: typography,
                surface: surface,
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                l10n.recordAccompanyingSymptomsLabel,
                style: typography.bodySm.copyWith(color: surface.body),
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              Wrap(
                spacing: AppSpacingTokens.xs,
                runSpacing: AppSpacingTokens.xs,
                children: [
                  RecordPill(
                    label: l10n.recordSymptomNausea,
                    color: AppColorTokens.warning,
                    typography: typography,
                  ),
                  RecordPill(
                    label: l10n.recordSymptomLightSensitive,
                    color: AppColorTokens.warning,
                    typography: typography,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.recordPainRatingLabel,
                          style: typography.caption.copyWith(
                            color: surface.body,
                          ),
                        ),
                        const SizedBox(height: AppSpacingTokens.xxs),
                        Text.rich(
                          TextSpan(
                            style: typography.displaySm.copyWith(
                              color: AppColorTokens.warning,
                              fontWeight: FontWeight.w800,
                            ),
                            children: [
                              const TextSpan(text: '4'),
                              TextSpan(
                                text: '/10',
                                style: typography.caption.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacingTokens.xxs),
                        Text(
                          l10n.recordPainModerate,
                          style: typography.bodySmStrong,
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () =>
                        showRecordToast(context, l10n.recordViewTrendAction),
                    child: Text(l10n.recordViewTrendAction),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileMoodTrendPanel extends StatelessWidget {
  const _MobileMoodTrendPanel({
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        date: '5/17',
        icon: Icons.sentiment_neutral_rounded,
        label: l10n.recordMoodAverage,
        color: AppColorTokens.warning,
      ),
      (
        date: '5/18',
        icon: Icons.sentiment_satisfied_rounded,
        label: l10n.recordMoodGood,
        color: AppColorTokens.cyanDeep,
      ),
      (
        date: '5/19',
        icon: Icons.sentiment_dissatisfied_rounded,
        label: l10n.recordMoodPoor,
        color: AppColorTokens.error,
      ),
      (
        date: '5/20',
        icon: Icons.sentiment_satisfied_rounded,
        label: l10n.recordMoodGood,
        color: AppColorTokens.cyanDeep,
      ),
      (
        date: l10n.recordTodayAction,
        icon: Icons.sentiment_satisfied_alt_rounded,
        label: l10n.recordMoodStable,
        color: AppColorTokens.violet,
      ),
    ];

    return RecordSectionSurface(
      key: const Key('record-trends'),
      title: l10n.recordMoodTrendSectionTitle,
      typography: typography,
      surface: surface,
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index += 1) ...[
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: index == items.length - 1
                      ? AppColorTokens.violetSoft.withValues(alpha: 0.36)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                  border: index == items.length - 1
                      ? Border.all(color: AppColorTokens.violet)
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacingTokens.sm,
                  ),
                  child: Column(
                    children: [
                      Text(
                        items[index].date,
                        style: typography.caption.copyWith(color: surface.body),
                      ),
                      const SizedBox(height: AppSpacingTokens.xs),
                      Icon(
                        items[index].icon,
                        color: items[index].color,
                        size: AppSpacingTokens.xl,
                      ),
                      const SizedBox(height: AppSpacingTokens.xxs),
                      Text(
                        items[index].label,
                        style: typography.caption.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (index < items.length - 1)
              const SizedBox(width: AppSpacingTokens.xs),
          ],
        ],
      ),
    );
  }
}

class _MobileCycleDietPanel extends StatelessWidget {
  const _MobileCycleDietPanel({
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return RecordSectionSurface(
      title: l10n.recordCycleDietSectionTitle,
      typography: typography,
      surface: surface,
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _MiniActionCard(
              icon: Icons.calendar_month_rounded,
              color: AppColorTokens.highlightMagenta,
              title: l10n.recordPeriodTitle,
              primary: l10n.recordPeriodDayValue(2),
              secondary: l10n.recordPeriodEndsIn(5),
              action: l10n.recordPeriodRecordAction,
              typography: typography,
              surface: surface,
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: _MiniActionCard(
              icon: Icons.ramen_dining_rounded,
              color: AppColorTokens.cyanDeep,
              title: l10n.recordDietTitle,
              primary: l10n.recordMealCountValue(2),
              secondary: l10n.recordMealLogging,
              action: l10n.recordDietRecordAction,
              typography: typography,
              surface: surface,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileSpecialistPackPanel extends StatelessWidget {
  const _MobileSpecialistPackPanel({
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: Icons.health_and_safety_outlined,
        color: AppColorTokens.link,
        title: l10n.recordDentalRecordTitle,
      ),
      (
        icon: Icons.visibility_outlined,
        color: AppColorTokens.cyanDeep,
        title: l10n.recordEyeRecordTitle,
      ),
      (
        icon: Icons.hearing_outlined,
        color: AppColorTokens.warning,
        title: l10n.recordHearingRecordTitle,
      ),
    ];

    return RecordSectionSurface(
      key: const Key('record-health-bag'),
      title: l10n.recordSpecialistPackTitle,
      subtitle: l10n.recordSpecialistPackSubtitle,
      typography: typography,
      surface: surface,
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index += 1) ...[
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: items[index].color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                  border: Border.all(
                    color: items[index].color.withValues(alpha: 0.18),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.sm),
                  child: Row(
                    children: [
                      Icon(
                        items[index].icon,
                        color: items[index].color,
                        size: AppSpacingTokens.xl,
                      ),
                      const SizedBox(width: AppSpacingTokens.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[index].title,
                              style: typography.bodySmStrong,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              l10n.recordZeroCountLabel,
                              style: typography.caption.copyWith(
                                color: surface.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (index < items.length - 1)
              const SizedBox(width: AppSpacingTokens.sm),
          ],
        ],
      ),
    );
  }
}

class _MiniActionCard extends StatelessWidget {
  const _MiniActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.primary,
    required this.secondary,
    required this.action,
    required this.typography,
    required this.surface,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String primary;
  final String secondary;
  final String action;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: AppSpacingTokens.xl),
            const SizedBox(height: AppSpacingTokens.sm),
            Text(title, style: typography.bodySm.copyWith(color: surface.body)),
            const SizedBox(height: AppSpacingTokens.xxs),
            Text(
              primary,
              style: typography.bodyMdStrong.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacingTokens.xs),
            LinearProgressIndicator(
              value: 0.62,
              color: color,
              backgroundColor: surface.hairline,
              minHeight: AppSpacingTokens.xxs,
              borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
            ),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(
              secondary,
              style: typography.caption.copyWith(color: surface.body),
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            FilledButton(
              onPressed: () => showRecordToast(context, action),
              style: FilledButton.styleFrom(backgroundColor: color),
              child: Text(action),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    required this.typography,
    required this.surface,
  });

  final String label;
  final String value;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: typography.bodySm.copyWith(color: surface.body)),
        const SizedBox(height: AppSpacingTokens.xxs),
        Text(value, style: typography.bodyMdStrong),
      ],
    );
  }
}

List<RecordQuickAction> _mobileQuickActions(List<RecordQuickAction> actions) {
  const preferredTypes = <RecordEntryType>[
    RecordEntryType.symptom,
    RecordEntryType.medication,
    RecordEntryType.mood,
    RecordEntryType.meal,
    RecordEntryType.water,
    RecordEntryType.womenHealth,
  ];
  final byType = {for (final action in actions) action.type: action};
  final ordered = <RecordQuickAction>[
    for (final type in preferredTypes)
      if (byType[type] != null) byType[type]!,
  ];
  for (final action in actions) {
    if (!ordered.contains(action)) ordered.add(action);
  }
  return ordered.take(6).toList(growable: false);
}

RecordCopyKey _weekdayKeyFromDate(DateTime date) {
  return switch (date.weekday) {
    DateTime.monday => RecordCopyKey.weekdayMon,
    DateTime.tuesday => RecordCopyKey.weekdayTue,
    DateTime.wednesday => RecordCopyKey.weekdayWed,
    DateTime.thursday => RecordCopyKey.weekdayThu,
    DateTime.friday => RecordCopyKey.weekdayFri,
    DateTime.saturday => RecordCopyKey.weekdaySat,
    _ => RecordCopyKey.weekdaySun,
  };
}

String _quickRecordLabel(AppLocalizations l10n, RecordQuickAction action) {
  if (action.type == RecordEntryType.womenHealth) {
    return l10n.recordQuickPeriodAction;
  }
  return l10n.recordQuickActionLabel(recordCopy(l10n, action.titleKey));
}

class _DesktopRecordDashboard extends StatelessWidget {
  const _DesktopRecordDashboard({
    required this.dashboard,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 300,
          child: Column(
            children: [
              RecordMonthCalendarPanel(
                days: dashboard.monthDays,
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              RecordFilterPanel(
                filters: dashboard.filters,
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              RecordHealthBagPanel(
                healthBag: dashboard.healthBag,
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.lg),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              RecordSummaryGrid(
                summary: dashboard.summary,
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              RecordTimelinePanel(
                entries: dashboard.timeline,
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacingTokens.lg),
        SizedBox(
          width: 330,
          child: Column(
            children: [
              RecordTrendsPanel(
                trends: dashboard.trends,
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
              const SizedBox(height: AppSpacingTokens.md),
              RecordNewEntryPanel(
                actions: dashboard.quickActions,
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
