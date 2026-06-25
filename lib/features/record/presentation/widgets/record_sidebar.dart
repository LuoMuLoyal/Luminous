import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_text_action.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/record_components.dart';
import 'package:luminous/features/record/presentation/widgets/record_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordMonthCalendarPanel extends StatelessWidget {
  const RecordMonthCalendarPanel({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onDateSelected,
    this.onMonthChanged,
  });

  final List<RecordCalendarDay> days;
  final DateTime selectedDate;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onMonthChanged;

  void _changeMonth(int delta) {
    if (onMonthChanged == null) return;
    final base = DateTime(selectedDate.year, selectedDate.month, 1);
    final shifted = DateTime(base.year, base.month + delta, 1);
    onMonthChanged!(shifted);
  }

  @override
  Widget build(BuildContext context) {
    final weekdayKeys = const <RecordCopyKey>[
      RecordCopyKey.weekdaySun,
      RecordCopyKey.weekdayMon,
      RecordCopyKey.weekdayTue,
      RecordCopyKey.weekdayWed,
      RecordCopyKey.weekdayThu,
      RecordCopyKey.weekdayFri,
      RecordCopyKey.weekdaySat,
    ];

    return AppSectionSurface(
      key: const Key('record-calendar-panel'),
      typography: typography,
      surface: surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.recordMonthLabel,
                  style: typography.bodyMdStrong,
                ),
              ),
              _CalendarIconButton(
                icon: Icons.chevron_left_rounded,
                label: l10n.recordPreviousDayAction,
                onTap: () => _changeMonth(-1),
              ),
              _CalendarIconButton(
                icon: Icons.chevron_right_rounded,
                label: l10n.recordNextDayAction,
                onTap: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Row(
            children: weekdayKeys
                .map(
                  (key) => Expanded(
                    child: Text(
                      recordCopy(l10n, key),
                      textAlign: TextAlign.center,
                      style: typography.caption.copyWith(color: surface.body),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.86,
              mainAxisSpacing: AppSpacingTokens.xs,
              crossAxisSpacing: AppSpacingTokens.xs,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) => _MonthDayCell(
              day: days[index],
              selectedDate: selectedDate,
              typography: typography,
              surface: surface,
              l10n: l10n,
              onTap: onDateSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class RecordFilterPanel extends StatelessWidget {
  const RecordFilterPanel({
    super.key,
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
    return AppSectionSurface(
      key: const Key('record-filter-panel'),
      title: l10n.recordFilterSectionTitle,
      trailing: AppTextAction(
        label: l10n.recordFilterSelectAll,
        icon: null,
        onTap: () {
          final handler = onFilterSelected;
          if (handler == null) {
            showRecordToast(context, l10n.recordFilterSelectAll);
            return;
          }
          handler(null);
        },
      ),
      typography: typography,
      surface: surface,
      child: Column(
        children: filters
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
                child: _FilterRow(
                  filter: filter,
                  l10n: l10n,
                  typography: typography,
                  surface: surface,
                  onTap: onFilterSelected == null
                      ? null
                      : () => onFilterSelected!(filter.type),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MonthDayCell extends StatelessWidget {
  const _MonthDayCell({
    required this.day,
    required this.selectedDate,
    required this.typography,
    required this.surface,
    required this.l10n,
    this.onTap,
  });

  final RecordCalendarDay day;
  final DateTime selectedDate;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;
  final ValueChanged<DateTime>? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = surface.accent;
    final color = day.inMonth
        ? Theme.of(context).colorScheme.onSurface
        : surface.mute;
    final markerColors = day.hasAlert
        ? [...day.markers, const Color(0xFFFF4D57)]
        : day.markers;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final handler = onTap;
          if (handler == null) {
            showRecordToast(context, '${l10n.recordOpenDateAction} ${day.day}');
            return;
          }
          handler(_dateForDay(day, selectedDate));
        },
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.square(
              dimension: 24,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: day.selected ? accent : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: typography.caption.copyWith(
                      color: day.selected
                          ? Theme.of(context).colorScheme.onPrimary
                          : color,
                      fontWeight: day.selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: markerColors
                      .take(3)
                      .map(
                        (marker) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: marker,
                              shape: BoxShape.circle,
                            ),
                            child: const SizedBox.square(dimension: 3),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filter,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onTap,
  });

  final RecordFilter filter;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = recordCopy(l10n, filter.titleKey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => showRecordToast(context, label),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.xs),
          child: Row(
            children: [
              Icon(
                filter.selected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: filter.selected ? surface.accent : surface.mute,
                size: 18,
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Icon(filter.icon, color: filter.accent, size: 18),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Text(
                  label,
                  style: typography.bodySmStrong,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (filter.locked)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: surface.canvasSoft2,
                    borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacingTokens.sm,
                      vertical: AppSpacingTokens.xs,
                    ),
                    child: Text(
                      l10n.recordNotEnabledLabel,
                      style: typography.caption.copyWith(color: surface.body),
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

class _CalendarIconButton extends StatelessWidget {
  const _CalendarIconButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      visualDensity: VisualDensity.compact,
      onPressed: onTap ?? () => showRecordToast(context, label),
      icon: Icon(icon, size: 18),
    );
  }
}

DateTime _dateForDay(RecordCalendarDay day, DateTime selectedDate) {
  final monthStart = DateTime(selectedDate.year, selectedDate.month, 1);
  DateTime candidate;
  if (day.inMonth) {
    candidate = DateTime(monthStart.year, monthStart.month, day.day);
  } else if (day.day > 20) {
    // Belongs to the previous month shown at the start of the grid.
    candidate = DateTime(
      monthStart.year,
      monthStart.month,
      1,
    ).subtract(const Duration(days: 1));
    candidate = DateTime(candidate.year, candidate.month, day.day);
  } else {
    // Belongs to the next month shown at the end of the grid.
    candidate = DateTime(monthStart.year, monthStart.month + 1, 1);
    candidate = DateTime(candidate.year, candidate.month, day.day);
  }
  return candidate;
}
