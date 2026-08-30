import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/record/presentation/widgets/shared/timeline_drag_data.dart';
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
    this.onRecordDropped,
  });

  final List<RecordCalendarDay> days;
  final DateTime selectedDate;
  final AppLocalizations l10n;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<DateTime>? onMonthChanged;

  /// Called when a timeline card is dragged onto a calendar day.
  /// Receives the record ID and the target date.
  /// Only invoked on desktop layouts.
  final void Function(String recordId, DateTime newDate)? onRecordDropped;

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
    final l10n = widget.l10n;
    final viewedDays = _buildViewedDays();

    const weekdayKeys = <RecordCopyKey>[
      RecordCopyKey.weekdaySun,
      RecordCopyKey.weekdayMon,
      RecordCopyKey.weekdayTue,
      RecordCopyKey.weekdayWed,
      RecordCopyKey.weekdayThu,
      RecordCopyKey.weekdayFri,
      RecordCopyKey.weekdaySat,
    ];

    return FCard(
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
                    style: context.theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _CalendarIconActionButton(
                  icon: SemanticIcons.actionPrev,
                  label: l10n.recordPreviousDayAction,
                  onTap: () => _changeMonth(-1),
                ),
                _CalendarIconActionButton(
                  icon: SemanticIcons.actionNext,
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
                        style: context.theme.typography.body.xs.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
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
                childAspectRatio: 0.95,
                mainAxisSpacing: Spacing.level1,
                crossAxisSpacing: Spacing.level1,
              ),
              itemCount: viewedDays.length,
              itemBuilder: (context, index) => _MonthDayCell(
                day: viewedDays[index],
                viewedMonth: _viewedMonth,
                l10n: l10n,
                onTap: widget.onDateSelected,
                onRecordDropped: widget.onRecordDropped,
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
    return FCard(
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
                    style: context.theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
                          SemanticIcons.statusAllDone,
                          size: IconSizeTokens.level2,
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

class _MonthDayCell extends StatefulWidget {
  const _MonthDayCell({
    required this.day,
    required this.viewedMonth,
    required this.l10n,
    this.onTap,
    this.onRecordDropped,
  });

  final RecordCalendarDay day;

  /// The month the user is currently viewing (not necessarily the month of
  /// [day] when [day.inMonth] is false). Used to compute the full [DateTime]
  /// when the cell is tapped.
  final DateTime viewedMonth;
  final AppLocalizations l10n;
  final ValueChanged<DateTime>? onTap;

  /// Called when a timeline card is dragged onto this day cell.
  /// Only invoked on desktop layouts.
  final void Function(String recordId, DateTime newDate)? onRecordDropped;

  @override
  State<_MonthDayCell> createState() => _MonthDayCellState();
}

class _MonthDayCellState extends State<_MonthDayCell> {
  bool _isDragHovering = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;
    final canAcceptDrag =
        isDesktop && widget.onRecordDropped != null && widget.day.inMonth;

    final color = widget.day.inMonth
        ? colors.foreground
        : SemanticColor.neutral.solid(context);
    final markerColors = widget.day.hasAlert
        ? [
            ...widget.day.markers.resolveAll(colors),
            SemanticColor.primary.solid(context),
          ]
        : widget.day.markers.resolveAll(colors);

    final cellContent = FTappable(
      onPress: widget.onTap == null
          ? null
          : () => widget.onTap!(_dateForDay(widget.day, widget.viewedMonth)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: 30,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.day.selected
                    ? colors.foreground
                    : _isDragHovering
                    ? SemanticColor.primary.border(context)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: _isDragHovering && !widget.day.selected
                    ? Border.all(
                        color: SemanticColor.primary.borderStrong(context),
                        width: 1.5,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  '${widget.day.day}',
                  style: context.theme.typography.body.sm.copyWith(
                    color: widget.day.selected
                        ? colors.background
                        : _isDragHovering
                        ? SemanticColor.primary.solid(context)
                        : color,
                    fontWeight: widget.day.selected
                        ? FontWeight.w700
                        : _isDragHovering
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

    if (!canAcceptDrag) {
      return cellContent;
    }

    return DragTarget<TimelineDragData>(
      onWillAcceptWithDetails: (details) {
        // 泛型 DragTarget<TimelineDragData> 已约束数据类型，
        // 此处返回 true 让 DragTarget 接受拖拽；悬停状态由 builder
        // 中 candidateData.isNotEmpty 驱动，避免无条件 setState。
        return true;
      },
      onLeave: (_) {
        setState(() => _isDragHovering = false);
      },
      onAcceptWithDetails: (details) {
        setState(() => _isDragHovering = false);
        final targetDate = _dateForDay(widget.day, widget.viewedMonth);
        widget.onRecordDropped!(details.data.recordId, targetDate);
      },
      builder: (context, candidateData, rejectedData) {
        if (candidateData.isNotEmpty && !_isDragHovering) {
          setState(() => _isDragHovering = true);
        }
        return cellContent;
      },
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
              filter.selected
                  ? SemanticIcons.statusSuccess
                  : SemanticIcons.statusPending,
              color: filter.selected
                  ? SemanticColor.primary.solid(context)
                  : SemanticColor.neutral.solid(context),
              size: IconSizeTokens.level2,
            ),
            const SizedBox(width: Spacing.level3),
            Icon(
              filter.icon,
              color: filter.accent.solid(context),
              size: IconSizeTokens.level2,
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Text(
                label,
                style: context.theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
                    style: context.theme.typography.body.xs.copyWith(
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
    return FTooltip(
      tipBuilder: (context, controller) => Text(label),
      child: FButton.icon(
        onPress: onTap,
        size: FButtonSizeVariant.xs,
        child: Icon(icon, size: IconSizeTokens.level2),
      ),
    );
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
