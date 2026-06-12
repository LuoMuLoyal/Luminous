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
    final quickActions = _mobileQuickActions(dashboard.quickActions);
    final timeline = dashboard.timeline.take(7).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MobileRecordDateBar(
          dashboard: dashboard,
          l10n: l10n,
          typography: typography,
          surface: surface,
          onDateSelected: onDateSelected,
          onPickDate: onPickDate,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileAiInputBar(l10n: l10n, typography: typography, surface: surface),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileQuickRecordPanel(
          actions: quickActions,
          l10n: l10n,
          typography: typography,
          surface: surface,
          onQuickAction: onQuickAction,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _MobileOverviewPanels(
          dashboard: dashboard,
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
        _MobileTimelinePanel(
          entries: timeline,
          totalCount: dashboard.timeline.length,
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
    this.onDateSelected,
    this.onPickDate,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<DateTime>? onDateSelected;
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
        _MobileDateStepButton(
          key: const Key('record-date-previous-action'),
          icon: Icons.chevron_left_rounded,
          surface: surface,
          onTap: onDateSelected == null
              ? null
              : () => onDateSelected!(
                  dashboard.selectedDate.subtract(const Duration(days: 1)),
                ),
        ),
        const SizedBox(width: AppSpacingTokens.xs),
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
        const SizedBox(width: AppSpacingTokens.xs),
        _MobileDateStepButton(
          key: const Key('record-date-next-action'),
          icon: Icons.chevron_right_rounded,
          surface: surface,
          onTap: onDateSelected == null
              ? null
              : () => onDateSelected!(
                  dashboard.selectedDate.add(const Duration(days: 1)),
                ),
        ),
      ],
    );
  }
}

class _MobileDateStepButton extends StatelessWidget {
  const _MobileDateStepButton({
    super.key,
    required this.icon,
    required this.surface,
    required this.onTap,
  });

  final IconData icon;
  final AppThemeSurface surface;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
            border: Border.all(color: surface.hairline),
          ),
          child: SizedBox.square(
            dimension: 44,
            child: Icon(icon, color: surface.body, size: AppSpacingTokens.lg),
          ),
        ),
      ),
    );
  }
}

class _RecordIndentedDivider extends StatelessWidget {
  const _RecordIndentedDivider({
    required this.surface,
    required this.indent,
    this.endIndent = 0,
  });

  final AppThemeSurface surface;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
      color: surface.hairline.withValues(alpha: 0.62),
    );
  }
}

class _RecordShortVerticalDivider extends StatelessWidget {
  const _RecordShortVerticalDivider({
    required this.surface,
    required this.height,
  });

  final AppThemeSurface surface;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: height,
        child: VerticalDivider(
          width: 1,
          thickness: 1,
          color: surface.hairline.withValues(alpha: 0.62),
        ),
      ),
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
    final rows = <List<RecordQuickAction>>[];
    for (var index = 0; index < actions.length; index += 5) {
      rows.add(actions.skip(index).take(5).toList(growable: false));
    }

    return Column(
      key: const Key('record-quick-actions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recordQuickSectionTitle, style: typography.displaySm),
        const SizedBox(height: AppSpacingTokens.sm),
        RecordSectionSurface(
          typography: typography,
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var rowIndex = 0; rowIndex < rows.length; rowIndex += 1) ...[
                SizedBox(
                  height: 92,
                  child: Row(
                    children: [
                      for (
                        var index = 0;
                        index < rows[rowIndex].length;
                        index += 1
                      ) ...[
                        Expanded(
                          child: _MobileQuickRecordTile(
                            action: rows[rowIndex][index],
                            l10n: l10n,
                            typography: typography,
                            surface: surface,
                            onQuickAction: onQuickAction,
                          ),
                        ),
                        if (index < rows[rowIndex].length - 1)
                          _RecordShortVerticalDivider(
                            surface: surface,
                            height: AppSpacingTokens.x4l,
                          ),
                      ],
                      for (
                        var filler = rows[rowIndex].length;
                        filler < 5;
                        filler += 1
                      )
                        const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ),
                if (rowIndex < rows.length - 1)
                  _RecordIndentedDivider(
                    surface: surface,
                    indent: AppSpacingTokens.md,
                    endIndent: AppSpacingTokens.md,
                  ),
              ],
            ],
          ),
        ),
      ],
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
    final actionLabel = _quickRecordLabel(l10n, action);
    final displayLabel = recordCopy(l10n, action.titleKey);
    final isLocked = action.locked;

    return Material(
      key: Key('record-quick-${action.type.name}'),
      color: Colors.transparent,
      child: InkWell(
        onTap: onQuickAction == null
            ? () => showRecordToast(context, actionLabel)
            : () => onQuickAction!(action),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: Semantics(
          button: true,
          label: isLocked
              ? '$actionLabel ${l10n.recordNotEnabledLabel}'
              : actionLabel,
          child: Opacity(
            opacity: isLocked ? 0.76 : 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacingTokens.xxs,
                vertical: AppSpacingTokens.xxs,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RecordIconBadge(
                    icon: action.icon,
                    color: action.accent,
                    backgroundColor: action.softColor,
                    size: AppSpacingTokens.xl,
                    iconSize: AppSpacingTokens.md,
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    displayLabel,
                    style: typography.bodySmStrong.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isLocked) ...[
                    const SizedBox(height: 2),
                    Text(
                      l10n.recordNotEnabledLabel,
                      style: typography.caption.copyWith(
                        color: surface.mute,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
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
    return Column(
      key: const Key('record-timeline'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordTodayEntriesTitle(totalCount),
          style: typography.displaySm,
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        RecordSectionSurface(
          typography: typography,
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < entries.length; index += 1) ...[
                _MobileTimelineRow(
                  entry: entries[index],
                  l10n: l10n,
                  typography: typography,
                  surface: surface,
                  isLast: index == entries.length - 1,
                ),
                if (index < entries.length - 1)
                  _RecordIndentedDivider(
                    surface: surface,
                    indent: AppSpacingTokens.x6l + AppSpacingTokens.md,
                    endIndent: AppSpacingTokens.md,
                  ),
              ],
            ],
          ),
        ),
      ],
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
            border: Border.all(
              color: AppColorTokens.cyanDeep.withValues(alpha: 0.32),
            ),
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
              locked: false,
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
                locked: filter.locked,
                typography: typography,
                surface: surface,
                onTap: filter.locked || onFilterSelected == null
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
    required this.locked,
    required this.typography,
    required this.surface,
    required this.onTap,
  });

  final Key chipKey;
  final String label;
  final Color color;
  final bool selected;
  final bool locked;
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: typography.bodySmStrong.copyWith(color: foreground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (locked) ...[
                  const SizedBox(width: AppSpacingTokens.xs),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: surface.canvasSoft2,
                      borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacingTokens.xs,
                        vertical: 2,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.recordNotEnabledLabel,
                        style: typography.caption.copyWith(color: surface.body),
                      ),
                    ),
                  ),
                ],
              ],
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
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return _MobileTodayOverviewPanel(
      items: _mobileOverviewItems(l10n, dashboard),
      l10n: l10n,
      typography: typography,
      surface: surface,
    );
  }
}

class _MobileTodayOverviewPanel extends StatelessWidget {
  const _MobileTodayOverviewPanel({
    required this.items,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<_MobileOverviewItem> items;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final rows = <List<_MobileOverviewItem>>[];
    for (var index = 0; index < items.length; index += 2) {
      rows.add(items.skip(index).take(2).toList(growable: false));
    }

    return Column(
      key: const Key('record-today-overview'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recordTodayOverviewTitle, style: typography.displaySm),
        const SizedBox(height: AppSpacingTokens.sm),
        RecordSectionSurface(
          typography: typography,
          surface: surface,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var rowIndex = 0; rowIndex < rows.length; rowIndex += 1) ...[
                SizedBox(
                  height: 72,
                  child: Row(
                    children: [
                      Expanded(
                        child: _MobileOverviewTile(
                          item: rows[rowIndex][0],
                          typography: typography,
                          surface: surface,
                        ),
                      ),
                      if (rows[rowIndex].length > 1) ...[
                        _RecordShortVerticalDivider(
                          surface: surface,
                          height: AppSpacingTokens.x4l,
                        ),
                        Expanded(
                          child: _MobileOverviewTile(
                            item: rows[rowIndex][1],
                            typography: typography,
                            surface: surface,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (rowIndex < rows.length - 1)
                  _RecordIndentedDivider(
                    surface: surface,
                    indent: AppSpacingTokens.md,
                    endIndent: AppSpacingTokens.md,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MobileOverviewTile extends StatelessWidget {
  const _MobileOverviewTile({
    required this.item,
    required this.typography,
    required this.surface,
  });

  final _MobileOverviewItem item;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.sm,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          Icon(item.icon, color: item.color, size: AppSpacingTokens.lg),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: typography.caption.copyWith(color: surface.body),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                AppSkeletonText(
                  text: item.value,
                  style: typography.bodyMdStrong.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  widthFactor: 0.74,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileOverviewItem {
  const _MobileOverviewItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
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
    return RecordSectionSurface(
      key: const Key('record-guide-row'),
      typography: typography,
      surface: surface,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showRecordToast(context, l10n.recordGuideAction),
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
    RecordEntryType.symptom,
    RecordEntryType.water,
    RecordEntryType.meal,
    RecordEntryType.sleep,
    RecordEntryType.medication,
    RecordEntryType.note,
  ];
  final byType = {for (final action in actions) action.type: action};
  final ordered = <RecordQuickAction>[
    for (final type in preferredTypes)
      if (byType[type] != null) byType[type]!,
  ];
  for (final action in actions) {
    if (!ordered.contains(action)) ordered.add(action);
  }
  return ordered.toList(growable: false);
}

List<RecordFilter> _mobileFilters(List<RecordFilter> filters) {
  const preferredTypes = <RecordEntryType>[
    RecordEntryType.symptom,
    RecordEntryType.water,
    RecordEntryType.meal,
    RecordEntryType.sleep,
    RecordEntryType.medication,
    RecordEntryType.note,
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

List<_MobileOverviewItem> _mobileOverviewItems(
  AppLocalizations l10n,
  RecordDashboard dashboard,
) {
  final activeSummaryItems = dashboard.summary.items
      .where((item) => _isActiveMobileOverviewType(item.type))
      .toList(growable: false);
  final summaryByType = {
    for (final item in activeSummaryItems) item.type: item,
  };
  final countsByType = <RecordEntryType, int>{};
  for (final entry in dashboard.timeline) {
    if (!_isActiveMobileOverviewType(entry.type)) continue;
    countsByType.update(entry.type, (value) => value + 1, ifAbsent: () => 1);
  }

  final items = <_MobileOverviewItem>[
    _MobileOverviewItem(
      icon: Icons.event_note_outlined,
      color: AppColorTokens.link,
      label: l10n.recordTodayOverviewEvents,
      value: l10n.recordTodayOverviewEventCount(dashboard.timeline.length),
    ),
  ];

  for (final type in _mobileOverviewTypeOrder) {
    final summary = summaryByType[type];
    final count = countsByType[type] ?? 0;
    if (summary == null && count == 0) continue;
    items.add(_overviewItemFor(l10n, type, summary, count));
  }

  return items;
}

_MobileOverviewItem _overviewItemFor(
  AppLocalizations l10n,
  RecordEntryType type,
  RecordSummaryItem? summary,
  int count,
) {
  final label = summary == null
      ? _overviewFallbackLabel(l10n, type)
      : recordCopy(l10n, summary.titleKey);
  final value = summary == null
      ? l10n.recordTodayOverviewEventCount(count)
      : _summaryValue(l10n, summary);

  return _MobileOverviewItem(
    icon: summary?.icon ?? _overviewFallbackIcon(type),
    color: summary?.accent ?? _overviewFallbackColor(type),
    label: label,
    value: value,
  );
}

String _summaryValue(AppLocalizations l10n, RecordSummaryItem item) {
  final value = item.value.trim();
  final unit = item.unitKey == null ? null : recordCopy(l10n, item.unitKey!);
  final detail = item.detailKey == null
      ? null
      : recordCopy(l10n, item.detailKey!);
  if (value.isNotEmpty) return unit == null ? value : '$value $unit';
  if (detail != null && detail.isNotEmpty) return detail;
  return l10n.recordTodayOverviewEventCount(0);
}

String _overviewFallbackLabel(AppLocalizations l10n, RecordEntryType type) {
  return switch (type) {
    RecordEntryType.medication => l10n.recordTypeMedication,
    RecordEntryType.symptom => l10n.recordTypeSymptom,
    RecordEntryType.water => l10n.recordTypeWater,
    RecordEntryType.meal => l10n.recordTypeMeal,
    RecordEntryType.vitals => l10n.recordTypeVitals,
    RecordEntryType.mood => l10n.recordTypeMood,
    RecordEntryType.activity => l10n.recordTypeActivity,
    RecordEntryType.sleep => l10n.recordTypeSleep,
    RecordEntryType.heartRate => l10n.recordTypeHeartRate,
    RecordEntryType.weight => l10n.recordTypeWeight,
    RecordEntryType.note => l10n.recordCreateKindNote,
  };
}

IconData _overviewFallbackIcon(RecordEntryType type) {
  return switch (type) {
    RecordEntryType.medication => Icons.medication_rounded,
    RecordEntryType.symptom => Icons.sick_outlined,
    RecordEntryType.water => Icons.local_drink_rounded,
    RecordEntryType.meal => Icons.restaurant_menu_rounded,
    RecordEntryType.vitals => Icons.favorite_rounded,
    RecordEntryType.mood => Icons.mood_rounded,
    RecordEntryType.activity => Icons.directions_run_rounded,
    RecordEntryType.sleep => Icons.dark_mode_rounded,
    RecordEntryType.heartRate => Icons.monitor_heart_outlined,
    RecordEntryType.weight => Icons.monitor_weight_outlined,
    RecordEntryType.note => Icons.notes_rounded,
  };
}

Color _overviewFallbackColor(RecordEntryType type) {
  return switch (type) {
    RecordEntryType.medication => AppColorTokens.cyanDeep,
    RecordEntryType.symptom => AppColorTokens.warning,
    RecordEntryType.water => AppColorTokens.link,
    RecordEntryType.meal => AppColorTokens.cyanDeep,
    RecordEntryType.vitals => AppColorTokens.error,
    RecordEntryType.mood => AppColorTokens.violet,
    RecordEntryType.activity => AppColorTokens.gradientDevelopStart,
    RecordEntryType.sleep => AppColorTokens.violet,
    RecordEntryType.heartRate => AppColorTokens.error,
    RecordEntryType.weight => AppColorTokens.linkDeep,
    RecordEntryType.note => AppColorTokens.link,
  };
}

bool _isActiveMobileOverviewType(RecordEntryType type) {
  return _mobileOverviewTypeOrder.contains(type);
}

const _mobileOverviewTypeOrder = <RecordEntryType>[
  RecordEntryType.symptom,
  RecordEntryType.water,
  RecordEntryType.meal,
  RecordEntryType.sleep,
  RecordEntryType.medication,
  RecordEntryType.note,
];

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
