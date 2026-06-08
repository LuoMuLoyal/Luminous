import 'package:flutter/material.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/record_components.dart';
import 'package:luminous/features/record/presentation/widgets/record_overview.dart';
import 'package:luminous/features/record/presentation/widgets/record_copy.dart';
import 'package:luminous/features/record/presentation/widgets/record_sidebar.dart';
import 'package:luminous/features/record/presentation/widgets/record_timeline.dart';
import 'package:luminous/features/record/presentation/widgets/record_trends.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordDashboardView extends StatelessWidget {
  const RecordDashboardView({
    super.key,
    required this.dashboard,
    this.isLoading = false,
    this.onQuickAction,
    this.onFilterSelected,
    this.onDateSelected,
    this.onPickDate,
  });

  final RecordDashboard dashboard;
  final bool isLoading;
  final ValueChanged<RecordQuickAction>? onQuickAction;
  final ValueChanged<RecordEntryType?>? onFilterSelected;
  final ValueChanged<DateTime>? onDateSelected;
  final VoidCallback? onPickDate;

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

    final content = isDesktop
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
            onQuickAction: onQuickAction,
            onFilterSelected: onFilterSelected,
            onDateSelected: onDateSelected,
            onPickDate: onPickDate,
          );

    return AppSkeletonScope(isLoading: isLoading, child: content);
  }
}

class _MobileRecordDashboard extends StatelessWidget {
  const _MobileRecordDashboard({
    required this.dashboard,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onQuickAction,
    this.onFilterSelected,
    this.onDateSelected,
    this.onPickDate,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<RecordQuickAction>? onQuickAction;
  final ValueChanged<RecordEntryType?>? onFilterSelected;
  final ValueChanged<DateTime>? onDateSelected;
  final VoidCallback? onPickDate;

  @override
  Widget build(BuildContext context) {
    final quickActions = _mobileQuickActions(
      dashboard.quickActions,
    );
    final timeline = dashboard.timeline.take(7).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MobileRecordDateBar(
          dashboard: dashboard,
          l10n: l10n,
          typography: typography,
          surface: surface,
          onPickDate: onPickDate,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileQuickRecordPanel(
          actions: quickActions,
          l10n: l10n,
          typography: typography,
          surface: surface,
          onQuickAction: onQuickAction,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileAiInputBar(l10n: l10n, typography: typography, surface: surface),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileTimelinePanel(
          entries: timeline,
          totalCount: dashboard.timeline.length,
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileFilterChipsPanel(
          filters: _mobileFilters(dashboard.filters),
          l10n: l10n,
          typography: typography,
          surface: surface,
          onFilterSelected: onFilterSelected,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileOverviewPanels(
          dashboard: dashboard,
          l10n: l10n,
          typography: typography,
          surface: surface,
          onDateSelected: onDateSelected,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileQuickOperationPanel(
          l10n: l10n,
          typography: typography,
          surface: surface,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileRecordGuideRow(
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
    this.onPickDate,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback? onPickDate;

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
              onTap:
                  onPickDate ??
                  () => showRecordToast(context, l10n.recordPickDateAction),
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
          onTap:
              onPickDate ??
              () => showRecordToast(context, l10n.recordSwitchDateAction),
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
    this.onQuickAction,
  });

  final List<RecordQuickAction> actions;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<RecordQuickAction>? onQuickAction;

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
          const columns = 4;
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
                    onQuickAction: onQuickAction,
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
    this.onQuickAction,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<RecordQuickAction>? onQuickAction;

  @override
  Widget build(BuildContext context) {
    final label = _quickRecordLabel(l10n, action);

    return Material(
      key: Key('record-quick-${action.type.name}'),
      color: Colors.transparent,
      child: InkWell(
        onTap: onQuickAction == null
            ? () => showRecordToast(context, label)
            : () => onQuickAction!(action),
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
                  maxLines: 2,
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
    required this.totalCount,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<RecordTimelineEntry> entries;
  final int totalCount;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return RecordSectionSurface(
      key: const Key('record-timeline'),
      title: l10n.recordTodayEntriesTitle(totalCount),
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
            pushAuthRequiredRoute(context, '/record/${entry.recordId}');
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
                child: AppSkeletonText(
                  text: entry.time,
                  style: typography.bodySm.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  widthFactor: 0.68,
                  maxLines: 1,
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
                    AppSkeletonText(
                      text: label,
                      style: typography.bodyMdStrong.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widthFactor: 0.64,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: AppSpacingTokens.xxs),
                      AppSkeletonText(
                        text: subtitle,
                        style: typography.bodySm.copyWith(color: surface.body),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        widthFactor: 0.78,
                      ),
                    ],
                  ],
                ),
              ),
              if (entry.badgeKey != null) ...[
                const SizedBox(width: AppSpacingTokens.xs),
                AppSkeletonSlot(
                  skeleton: const AppInlineSkeletonBlock(
                    height: 22,
                    width: 44,
                    radius: AppRadiusTokens.sm,
                  ),
                  child: RecordPill(
                    label: recordCopy(l10n, entry.badgeKey!),
                    color: entry.accent,
                    typography: typography,
                  ),
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

class _MobileAiInputBar extends StatelessWidget {
  const _MobileAiInputBar({
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('record-ai-input'),
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showRecordToast(context, l10n.recordAiInputHint),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: AppColorTokens.cyanDeep),
            boxShadow: AppShadowTokens.level1,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.md,
              vertical: AppSpacingTokens.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColorTokens.gradientPreviewStart,
                  size: AppSpacingTokens.xl,
                ),
                const SizedBox(width: AppSpacingTokens.md),
                Expanded(
                  child: Text(
                    l10n.recordAiInputHint,
                    style: typography.bodyMd.copyWith(color: surface.mute),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColorTokens.cyanDeep.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacingTokens.sm,
                      vertical: AppSpacingTokens.xxs,
                    ),
                    child: Text(
                      l10n.recordAiBadge,
                      style: typography.caption.copyWith(
                        color: AppColorTokens.cyanDeep,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Tooltip(
                  message: l10n.recordVoiceInputTitle,
                  child: Icon(
                    Icons.mic_none_rounded,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: AppSpacingTokens.lg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileFilterChipsPanel extends StatelessWidget {
  const _MobileFilterChipsPanel({
    required this.filters,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onFilterSelected,
  });

  final List<RecordFilter> filters;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<RecordEntryType?>? onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final allSelected = filters.every((filter) => filter.selected);

    return Column(
      key: const Key('record-filter-chips'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recordFilterMobileTitle, style: typography.displaySm),
        const SizedBox(height: AppSpacingTokens.sm),
        Wrap(
          spacing: AppSpacingTokens.xs,
          runSpacing: AppSpacingTokens.xs,
          children: [
            _MobileFilterChip(
              chipKey: const Key('record-filter-all'),
              label: l10n.recordFilterAllAction,
              color: AppColorTokens.cyanDeep,
              selected: allSelected,
              typography: typography,
              surface: surface,
              onTap: onFilterSelected == null
                  ? () => showRecordToast(context, l10n.recordFilterAllAction)
                  : () => onFilterSelected!(null),
            ),
            for (final filter in filters)
              _MobileFilterChip(
                chipKey: Key('record-filter-${filter.type.name}'),
                label: _mobileFilterLabel(l10n, filter),
                color: filter.accent,
                selected: filter.selected,
                typography: typography,
                surface: surface,
                onTap: onFilterSelected == null
                    ? () => showRecordToast(
                        context,
                        _mobileFilterLabel(l10n, filter),
                      )
                    : () => onFilterSelected!(filter.type),
              ),
          ],
        ),
      ],
    );
  }
}

class _MobileFilterChip extends StatelessWidget {
  const _MobileFilterChip({
    required this.chipKey,
    required this.label,
    required this.color,
    required this.selected,
    required this.typography,
    required this.surface,
    required this.onTap,
  });

  final Key chipKey;
  final String label;
  final Color color;
  final bool selected;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? color : surface.body;

    return Material(
      key: chipKey,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.1) : surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
            border: Border.all(color: selected ? color : surface.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.md,
              vertical: AppSpacingTokens.xs,
            ),
            child: Text(
              label,
              style: typography.bodySmStrong.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileOverviewPanels extends StatelessWidget {
  const _MobileOverviewPanels({
    required this.dashboard,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onDateSelected,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: _MobileCalendarOverviewPanel(
            days: dashboard.weekDays,
            l10n: l10n,
            typography: typography,
            surface: surface,
            onDateSelected: onDateSelected,
          ),
        ),
        const SizedBox(width: AppSpacingTokens.sm),
        Expanded(
          flex: 5,
          child: _MobileTodayOverviewPanel(
            eventCount: dashboard.timeline.length,
            l10n: l10n,
            typography: typography,
            surface: surface,
          ),
        ),
      ],
    );
  }
}

class _MobileCalendarOverviewPanel extends StatelessWidget {
  const _MobileCalendarOverviewPanel({
    required this.days,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onDateSelected,
  });

  final List<RecordWeekDay> days;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  Widget build(BuildContext context) {
    return RecordSectionSurface(
      key: const Key('record-calendar-overview'),
      title: l10n.recordCalendarOverviewTitle,
      typography: typography,
      surface: surface,
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Column(
        children: [
          Row(
            children: [
              for (final day in days)
                Expanded(
                  child: Text(
                    recordCopy(l10n, day.weekdayKey),
                    textAlign: TextAlign.center,
                    style: typography.caption.copyWith(color: surface.body),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          Row(
            children: [
              for (final day in days)
                Expanded(
                  child: _MobileCalendarDay(
                    day: day,
                    l10n: l10n,
                    typography: typography,
                    surface: surface,
                    onDateSelected: onDateSelected,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileCalendarDay extends StatelessWidget {
  const _MobileCalendarDay({
    required this.day,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onDateSelected,
  });

  final RecordWeekDay day;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  Widget build(BuildContext context) {
    final foreground = day.selected
        ? AppColorTokens.cyanDeep
        : Theme.of(context).colorScheme.onSurface;
    final markerColors = day.hasAlert
        ? [...day.markers, AppColorTokens.highlightMagenta]
        : day.markers;

    return Material(
      key: Key('record-weekday-${_formatDateKey(day.date)}'),
      color: Colors.transparent,
      child: InkWell(
        onTap: onDateSelected == null
            ? () => showRecordToast(
                context,
                '${l10n.recordOpenDateAction} ${day.day}',
              )
            : () => onDateSelected!(day.date),
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.xxs),
          child: Column(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: day.selected
                      ? AppColorTokens.cyanDeep.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
                  border: day.selected
                      ? Border.all(color: AppColorTokens.cyanDeep)
                      : null,
                ),
                child: SizedBox(
                  height: AppSpacingTokens.x3l,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${day.day}',
                        style: typography.bodySmStrong.copyWith(
                          color: foreground,
                        ),
                      ),
                      const SizedBox(height: AppSpacingTokens.xxs),
                      SizedBox(
                        height: 6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final marker in markerColors.take(2))
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 1.2,
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: marker,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const SizedBox.square(dimension: 4),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileTodayOverviewPanel extends StatelessWidget {
  const _MobileTodayOverviewPanel({
    required this.eventCount,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final int eventCount;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return RecordSectionSurface(
      key: const Key('record-today-overview'),
      title: l10n.recordTodayOverviewTitle,
      typography: typography,
      surface: surface,
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Column(
        children: [
          _MobileOverviewLine(
            icon: Icons.event_note_outlined,
            color: AppColorTokens.link,
            label: l10n.recordTodayOverviewEvents,
            value: l10n.recordTodayOverviewEventCount(eventCount),
            typography: typography,
            surface: surface,
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          _MobileOverviewLine(
            icon: Icons.local_drink_rounded,
            color: AppColorTokens.link,
            label: l10n.recordTodayOverviewWater,
            value: l10n.recordTodayOverviewWaterValue('2.5'),
            typography: typography,
            surface: surface,
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          _MobileOverviewLine(
            icon: Icons.dark_mode_rounded,
            color: AppColorTokens.violet,
            label: l10n.recordTodayOverviewSleep,
            value: l10n.recordTodayOverviewSleepValue('7.0'),
            typography: typography,
            surface: surface,
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          _MobileOverviewLine(
            icon: Icons.sentiment_satisfied_rounded,
            color: AppColorTokens.warning,
            label: l10n.recordTodayOverviewMoodAverage,
            value: l10n.recordTodayOverviewMoodValue('3.0'),
            typography: typography,
            surface: surface,
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => showRecordToast(
                context,
                l10n.recordTodayOverviewReportAction,
              ),
              borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacingTokens.xs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.recordTodayOverviewReportAction,
                        style: typography.bodySmStrong.copyWith(
                          color: AppColorTokens.link,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: surface.body,
                      size: AppSpacingTokens.lg,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileOverviewLine extends StatelessWidget {
  const _MobileOverviewLine({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.typography,
    required this.surface,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: AppSpacingTokens.md),
        const SizedBox(width: AppSpacingTokens.xs),
        Expanded(
          child: Text(
            label,
            style: typography.caption.copyWith(color: surface.body),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacingTokens.xs),
        AppSkeletonText(
          text: value,
          style: typography.bodySmStrong,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          width: 38,
        ),
      ],
    );
  }
}

class _MobileQuickOperationPanel extends StatelessWidget {
  const _MobileQuickOperationPanel({
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
        icon: Icons.mic_rounded,
        color: AppColorTokens.cyanDeep,
        title: l10n.recordVoiceInputTitle,
        subtitle: l10n.recordVoiceInputSubtitle,
      ),
      (
        icon: Icons.photo_camera_rounded,
        color: AppColorTokens.link,
        title: l10n.recordPhotoRecordTitle,
        subtitle: l10n.recordPhotoRecordSubtitle,
      ),
      (
        icon: Icons.fact_check_outlined,
        color: AppColorTokens.linkDeep,
        title: l10n.recordTemplateRecordTitle,
        subtitle: l10n.recordTemplateRecordSubtitle,
      ),
    ];

    return Column(
      key: const Key('record-quick-operations'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recordQuickOperationTitle, style: typography.displaySm),
        const SizedBox(height: AppSpacingTokens.sm),
        Row(
          children: [
            for (var index = 0; index < items.length; index += 1) ...[
              Expanded(
                child: _MobileQuickOperationCard(
                  icon: items[index].icon,
                  color: items[index].color,
                  title: items[index].title,
                  subtitle: items[index].subtitle,
                  typography: typography,
                  surface: surface,
                ),
              ),
              if (index < items.length - 1)
                const SizedBox(width: AppSpacingTokens.sm),
            ],
          ],
        ),
      ],
    );
  }
}

class _MobileQuickOperationCard extends StatelessWidget {
  const _MobileQuickOperationCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.typography,
    required this.surface,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showRecordToast(context, title),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
            boxShadow: AppShadowTokens.level1,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RecordIconBadge(
                  icon: icon,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.12),
                  size: AppSpacingTokens.x2l,
                  iconSize: AppSpacingTokens.lg,
                ),
                const SizedBox(height: AppSpacingTokens.xs),
                Text(
                  title,
                  style: typography.bodySmStrong,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  subtitle,
                  style: typography.caption.copyWith(color: surface.body),
                  textAlign: TextAlign.center,
                  maxLines: 2,
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

class _MobileRecordGuideRow extends StatelessWidget {
  const _MobileRecordGuideRow({
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('record-guide-row'),
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showRecordToast(context, l10n.recordGuideAction),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
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
                  Icons.lightbulb_outline_rounded,
                  color: AppColorTokens.warning,
                  size: AppSpacingTokens.lg,
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: Text(
                    l10n.recordGuideHint,
                    style: typography.bodySm.copyWith(color: surface.body),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Text(
                  l10n.recordGuideAction,
                  style: typography.bodySmStrong.copyWith(
                    color: AppColorTokens.link,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColorTokens.link,
                  size: AppSpacingTokens.lg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<RecordQuickAction> _mobileQuickActions(List<RecordQuickAction> actions) {
  final preferredTypes = <RecordEntryType>[
    RecordEntryType.medication,
    RecordEntryType.symptom,
    RecordEntryType.water,
    RecordEntryType.meal,
    RecordEntryType.vitals,
  ];
  final byType = {for (final action in actions) action.type: action};
  final ordered = <RecordQuickAction>[
    for (final type in preferredTypes)
      if (byType[type] != null) byType[type]!,
  ];
  for (final action in actions) {
    if (!ordered.contains(action)) ordered.add(action);
  }
  return ordered.take(8).toList(growable: false);
}

List<RecordFilter> _mobileFilters(List<RecordFilter> filters) {
  const preferredTypes = <RecordEntryType>[
    RecordEntryType.medication,
    RecordEntryType.symptom,
    RecordEntryType.water,
    RecordEntryType.meal,
    RecordEntryType.vitals,
  ];
  final byType = {for (final filter in filters) filter.type: filter};
  final ordered = <RecordFilter>[
    for (final type in preferredTypes)
      if (byType[type] != null) byType[type]!,
  ];
  for (final filter in filters) {
    if (!ordered.contains(filter)) ordered.add(filter);
  }
  return ordered.toList(growable: false);
}

String _mobileFilterLabel(AppLocalizations l10n, RecordFilter filter) {
  return recordCopy(l10n, filter.titleKey);
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
  return l10n.recordQuickActionLabel(recordCopy(l10n, action.titleKey));
}

String _formatDateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
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
