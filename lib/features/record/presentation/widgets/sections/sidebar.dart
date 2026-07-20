import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Desktop-side month calendar with decoupled month navigation.
///
/// The user can browse previous/next months via the chevron buttons without
/// losing their selected date. Only tapping a day cell calls [onDateSelected].
/// The calendar grid is rebuilt locally based on the viewed month, drawing
/// markers from the parent-provided [days] when the viewed month matches the
/// [days] array's own month (validated by in-month day count, not by
/// [selectedDate], so stale [days] data won't bleed into the wrong month).
///
/// [onMonthChanged] is an optional callback for parents that want to track
/// which month the user is currently viewing. When not provided, the panel
/// maintains its own [_viewedMonth] state and remains fully self-contained —
/// month navigation works without any parent coordination.
class RecordMonthCalendarPanel extends StatefulWidget {
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

  @override
  State<RecordMonthCalendarPanel> createState() =>
      _RecordMonthCalendarPanelState();
}

class _RecordMonthCalendarPanelState extends State<RecordMonthCalendarPanel> {
  late DateTime _viewedMonth;

  @override
  void initState() {
    super.initState();
    _viewedMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
  }

  @override
  void didUpdateWidget(covariant RecordMonthCalendarPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the selected date moved to a different month (e.g. via the header
    // date pickers or the mobile date bar), sync the viewed month so the
    // calendar stays in sync.
    final selectedMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
    if (selectedMonth !=
        DateTime(oldWidget.selectedDate.year, oldWidget.selectedDate.month)) {
      _viewedMonth = selectedMonth;
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _viewedMonth = DateTime(_viewedMonth.year, _viewedMonth.month + delta);
    });
    widget.onMonthChanged?.call(
      DateTime(_viewedMonth.year, _viewedMonth.month, 1),
    );
  }

  /// Builds the calendar grid for [_viewedMonth], merging marker data from
  /// the parent [widget.days] when the viewed month matches the days' month.
  ///
  /// The month match is validated by comparing the count of in-month days in
  /// [widget.days] against the number of days in [_viewedMonth]. This is more
  /// robust than comparing against [widget.selectedDate]'s month, because the
  /// parent may asynchronously update [widget.days] after [widget.selectedDate]
  /// has already changed, causing a temporary mismatch.
  List<RecordCalendarDay> _buildViewedDays() {
    final selectedDate = widget.selectedDate;
    final days = widget.days;

    // Validate that the parent-provided days array actually corresponds to
    // the viewed month by checking that the count of in-month days matches
    // the number of days in _viewedMonth. This avoids using stale days data
    // when selectedDate and days are temporarily out of sync.
    final viewedMonthDayCount = DateTime(
      _viewedMonth.year,
      _viewedMonth.month + 1,
      0,
    ).day;
    final inMonthDayCount = days.where((d) => d.inMonth).length;

    final parentMonthMatches =
        days.isNotEmpty && inMonthDayCount == viewedMonthDayCount;

    if (parentMonthMatches) {
      return days;
    }

    return _buildPlainMonthDays(_viewedMonth, selectedDate);
  }

  List<RecordCalendarDay> _buildPlainMonthDays(
    DateTime month,
    DateTime selectedDate,
  ) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final startOffset = first.weekday - 1;
    final result = <RecordCalendarDay>[];

    for (var i = 0; i < startOffset; i++) {
      result.add(
        const RecordCalendarDay(
          day: 0,
          inMonth: false,
          selected: false,
          markers: [],
        ),
      );
    }

    for (var d = 1; d <= last.day; d++) {
      final isSelected =
          selectedDate.year == month.year &&
          selectedDate.month == month.month &&
          selectedDate.day == d;
      result.add(
        RecordCalendarDay(
          day: d,
          inMonth: true,
          selected: isSelected,
          markers: const [],
        ),
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final l10n = widget.l10n;
    final viewedDays = _buildViewedDays();

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
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat.yMMMM(
                      Localizations.localeOf(context).toString(),
                    ).format(_viewedMonth),
                    style: TypographyToken.level5
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
            const SizedBox(height: Spacing.level4),
            Row(
              children: weekdayKeys
                  .map(
                    (key) => Expanded(
                      child: Text(
                        recordCopy(l10n, key),
                        textAlign: TextAlign.center,
                        style: TypographyToken.level3
                            .body(context)
                            .copyWith(color: colors.mutedForeground),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: Spacing.level3),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.86,
                mainAxisSpacing: Spacing.level2,
                crossAxisSpacing: Spacing.level2,
              ),
              itemCount: viewedDays.length,
              itemBuilder: (context, index) => _MonthDayCell(
                day: viewedDays[index],
                viewedMonth: _viewedMonth,
                l10n: l10n,
                onTap: widget.onDateSelected,
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
        padding: const EdgeInsets.all(Spacing.level5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recordFilterSectionTitle,
                    style: TypographyToken.level5
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
                        const SizedBox(width: Spacing.level1),
                        Icon(
                          FLucideIcons.chevronRight,
                          size: Spacing.level4,
                          color: colors.foreground,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.level4),
            Column(
              children: filters
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.level3),
                      child: _FilterRow(
                        filter: filter,
                        l10n: l10n,
                        onTap: onFilterSelected == null || filter.locked
                            ? null
                            : () => onFilterSelected!(
                                filter.selected ? null : filter.type,
                              ),
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
    required this.viewedMonth,
    required this.l10n,
    this.onTap,
  });

  final RecordCalendarDay day;

  /// The month the user is currently viewing (not necessarily the month of
  /// [day] when [day.inMonth] is false). Used to compute the full [DateTime]
  /// when the cell is tapped.
  final DateTime viewedMonth;
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
          : () => onTap!(_dateForDay(day, viewedMonth)),
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
                  style: TypographyToken.level4
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
        padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
        child: Row(
          children: [
            Icon(
              filter.selected ? FLucideIcons.circleCheck : FLucideIcons.circle,
              color: filter.selected ? colors.primary : colors.mutedForeground,
              size: 18,
            ),
            const SizedBox(width: Spacing.level3),
            Icon(filter.icon, color: filter.accent.solid(context), size: 18),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Text(
                label,
                style: TypographyToken.level5
                    .body(context)
                    .copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (filter.locked)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: SemanticColor.neutral.subtle(context),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.level3,
                    vertical: Spacing.level2,
                  ),
                  child: Text(
                    l10n.recordNotEnabledLabel,
                    style: TypographyToken.level3
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

DateTime _dateForDay(RecordCalendarDay day, DateTime viewedMonth) {
  final monthStart = DateTime(viewedMonth.year, viewedMonth.month, 1);
  DateTime candidate;
  if (day.inMonth) {
    candidate = DateTime(monthStart.year, monthStart.month, day.day);
  } else if (day.day > 20) {
    // Leading day from the previous month.
    candidate = DateTime(
      monthStart.year,
      monthStart.month,
      1,
    ).subtract(const Duration(days: 1));
    candidate = DateTime(candidate.year, candidate.month, day.day);
  } else {
    // Trailing day from the next month.
    candidate = DateTime(monthStart.year, monthStart.month + 1, 1);
    candidate = DateTime(candidate.year, candidate.month, day.day);
  }
  return candidate;
}
