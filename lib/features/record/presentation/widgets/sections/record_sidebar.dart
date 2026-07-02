import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_text_action.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordMonthCalendarPanel extends StatelessWidget {
  const RecordMonthCalendarPanel({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.l10n,
    this.onDateSelected,
    this.onMonthChanged,
  });

  final List<RecordCalendarDay> days;
  final DateTime selectedDate;
  final AppLocalizations l10n;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onMonthChanged;

  void _changeMonth(int delta) {
    if (onMonthChanged == null) return;
    final base = DateTime(selectedDate.year, selectedDate.month, 1);
    onMonthChanged!(DateTime(base.year, base.month + delta, 1));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final weekdayKeys = const <RecordCopyKey>[
      RecordCopyKey.weekdaySun,
      RecordCopyKey.weekdayMon,
      RecordCopyKey.weekdayTue,
      RecordCopyKey.weekdayWed,
      RecordCopyKey.weekdayThu,
      RecordCopyKey.weekdayFri,
      RecordCopyKey.weekdaySat,
    ];

    return FCard.raw(
      key: const Key('record-calendar-panel'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level5),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recordMonthLabel,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _CalendarIconButton(
                  icon: FLucideIcons.chevronLeft,
                  label: l10n.recordPreviousDayAction,
                  onTap: () => _changeMonth(-1),
                ),
                _CalendarIconButton(
                  icon: FLucideIcons.chevronRight,
                  label: l10n.recordNextDayAction,
                  onTap: () => _changeMonth(1),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.level4),
            Row(
              children: weekdayKeys
                  .map(
                    (key) => Expanded(
                      child: Text(
                        recordCopy(l10n, key),
                        textAlign: TextAlign.center,
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.mutedForeground,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpacingTokens.level3),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.86,
                mainAxisSpacing: AppSpacingTokens.level2,
                crossAxisSpacing: AppSpacingTokens.level2,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) => _MonthDayCell(
                day: days[index],
                selectedDate: selectedDate,
                l10n: l10n,
                onTap: onDateSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordFilterPanel extends StatelessWidget {
  const RecordFilterPanel({
    super.key,
    required this.filters,
    required this.l10n,
    this.onFilterSelected,
  });

  final List<RecordFilter> filters;
  final AppLocalizations l10n;
  final ValueChanged<RecordEntryType?>? onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return FCard.raw(
      key: const Key('record-filter-panel'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recordFilterSectionTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onFilterSelected != null)
                  AppTextAction(
                    label: l10n.recordFilterSelectAll,
                    onTap: () => onFilterSelected!(null),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.level4),
            Column(
              children: filters
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacingTokens.level3,
                      ),
                      child: _FilterRow(
                        filter: filter,
                        l10n: l10n,
                        onTap: onFilterSelected == null
                            ? null
                            : () => onFilterSelected!(filter.type),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthDayCell extends StatelessWidget {
  const _MonthDayCell({
    required this.day,
    required this.selectedDate,
    required this.l10n,
    this.onTap,
  });

  final RecordCalendarDay day;
  final DateTime selectedDate;
  final AppLocalizations l10n;
  final ValueChanged<DateTime>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final color = day.inMonth ? colors.foreground : colors.mutedForeground;
    final markerColors = day.hasAlert
        ? [...day.markers, const Color(0xFFFF4D57)]
        : day.markers;

    return FTappable(
      onPress: onTap == null
          ? null
          : () => onTap!(_dateForDay(day, selectedDate)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: 30,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: day.selected ? colors.foreground : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: textTheme.labelMedium?.copyWith(
                    color: day.selected ? colors.background : color,
                    fontWeight: day.selected
                        ? FontWeight.w700
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
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.filter, required this.l10n, this.onTap});

  final RecordFilter filter;
  final AppLocalizations l10n;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final label = recordCopy(l10n, filter.titleKey);

    return FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.level2),
        child: Row(
          children: [
            Icon(
              filter.selected
                  ? FLucideIcons.squareCheckBig
                  : FLucideIcons.square,
              color: filter.selected
                  ? colors.foreground
                  : colors.mutedForeground,
              size: 18,
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Icon(filter.icon, color: filter.accent, size: 18),
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (filter.locked)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.secondary.withValues(alpha: 0.22),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.level3,
                    vertical: AppSpacingTokens.level2,
                  ),
                  child: Text(
                    l10n.recordNotEnabledLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.foreground,
                    ),
                  ),
                ),
              ),
          ],
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
      onPressed: onTap,
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
    candidate = DateTime(
      monthStart.year,
      monthStart.month,
      1,
    ).subtract(const Duration(days: 1));
    candidate = DateTime(candidate.year, candidate.month, day.day);
  } else {
    candidate = DateTime(monthStart.year, monthStart.month + 1, 1);
    candidate = DateTime(candidate.year, candidate.month, day.day);
  }
  return candidate;
}
