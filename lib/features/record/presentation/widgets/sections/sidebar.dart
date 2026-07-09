import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
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
                    style: AppTypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                _CalendarIconActionButton(
                  icon: FLucideIcons.chevronLeft,
                  label: l10n.recordPreviousDayAction,
                  onTap: () => _changeMonth(-1),
                ),
                _CalendarIconActionButton(
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
                        style: AppTypographyToken.level3
                            .body(context)
                            .copyWith(color: colors.mutedForeground),
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
    final colors = context.theme.colors;
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
                    style: AppTypographyToken.level5
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                if (onFilterSelected != null)
                  FButton(
                    variant: FButtonVariant.ghost,
                    size: FButtonSizeVariant.xs,
                    mainAxisSize: MainAxisSize.min,
                    onPress: () => onFilterSelected!(null),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.recordFilterSelectAll,
                          style: TextStyle(
                            color: colors.foreground,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: AppSpacingTokens.level1),
                        Icon(
                          FLucideIcons.chevronRight,
                          size: AppSpacingTokens.level4,
                          color: colors.foreground,
                        ),
                      ],
                    ),
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

    final color = day.inMonth ? colors.foreground : colors.mutedForeground;
    final markerColors = day.hasAlert
        ? [...day.markers.resolveAll(colors), colors.primary]
        : day.markers.resolveAll(colors);

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
                  style: AppTypographyToken.level4
                      .body(context)
                      .copyWith(
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
            Icon(filter.icon, color: filter.accent.resolve(colors), size: 18),
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: Text(
                label,
                style: AppTypographyToken.level5
                    .body(context)
                    .copyWith(fontWeight: FontWeight.w600),
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
                    style: AppTypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.foreground),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CalendarIconActionButton extends StatelessWidget {
  const _CalendarIconActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FButton.icon(onPress: onTap, child: Icon(icon, size: 18));
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
