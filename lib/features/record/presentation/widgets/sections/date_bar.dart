import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 日历项星期文字字号（紧凑设计，对应 TypographyToken.level2）。
double _weekdayFontSize(BuildContext context) =>
    TypographyToken.level2.body(context).fontSize!;

/// 日历项日期数字字号（对应 TypographyToken.level3）。
double _dateFontSize(BuildContext context) =>
    TypographyToken.level3.body(context).fontSize!;

class RecordDateBar extends StatelessWidget {
  const RecordDateBar({
    super.key,
    required this.dashboard,
    required this.l10n,
    this.onDateSelected,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final ValueChanged<DateTime>? onDateSelected;

  /// 最早可选日期（2000-01-01）。
  static final DateTime _minDate = DateTime(2000);

  /// 最晚可选日期（当前日期 + 365 天）。
  static final DateTime _maxDate = clock.now().add(const Duration(days: 365));

  /// 日历行高固定值，避免 MediaQuery 在键盘弹出/屏幕旋转时引发重建。
  static const double _calendarItemHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SizedBox(
            height: _calendarItemHeight,
            child: FLineCalendar(
              control: FLineCalendarControl.lifted(
                date: dashboard.selectedDate,
                onChange: (date) {
                  if (date != null) {
                    onDateSelected?.call(_dateOnly(date));
                  }
                },
              ),
              selectable: _isSelectable,
              builder: (context, data, child) =>
                  _CompactCalendarItem(data: data),
            ),
          ),
        ),
        const SizedBox(width: Spacing.level2),
        _CalendarPickerButton(
          selectedDate: dashboard.selectedDate,
          onDateSelected: onDateSelected,
        ),
      ],
    );
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  bool _isSelectable(DateTime date) {
    final value = _dateOnly(date);
    return !value.isBefore(_dateOnly(_minDate)) &&
        !value.isAfter(_dateOnly(_maxDate));
  }
}

class _CompactCalendarItem extends StatelessWidget {
  const _CompactCalendarItem({required this.data});

  final FLineCalendarItemData data;

  @override
  Widget build(BuildContext context) {
    final localizations = FLocalizations.of(context) ?? FDefaultLocalizations();
    final date = data.date;
    final variants = data.variants;
    final style = data.style;
    final isToday = variants.contains(FLineCalendarItemVariant.today);

    return Stack(
      children: [
        SizedBox.expand(
          child: DecoratedBox(
            decoration: style.decoration.resolve(variants),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                spacing: 2,
                children: [
                  DefaultTextStyle.merge(
                    style: style.weekdayTextStyle
                        .resolve(variants)
                        .copyWith(
                          fontSize: _weekdayFontSize(context),
                          height: 1.0,
                        ),
                    child: Text(localizations.shortWeekDays[date.weekday % 7]),
                  ),
                  DefaultTextStyle.merge(
                    style: style.dateTextStyle
                        .resolve(variants)
                        .copyWith(
                          fontSize: _dateFontSize(context),
                          height: 1.0,
                        ),
                    child: Text(
                      DateFormat.d(localizations.localeName).format(date),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isToday)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: style.todayIndicatorColor.resolve(variants),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _CalendarPickerButton extends StatelessWidget {
  const _CalendarPickerButton({
    required this.selectedDate,
    this.onDateSelected,
  });

  final DateTime selectedDate;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  Widget build(BuildContext context) {
    return FButton.icon(
      key: const Key('record-date-picker-action'),
      onPress: onDateSelected == null
          ? null
          : () => _showCalendarPicker(context),
      variant: FButtonVariant.ghost,
      size: FButtonSizeVariant.sm,
      child: const Icon(FLucideIcons.calendarDays),
    );
  }

  Future<void> _showCalendarPicker(BuildContext context) async {
    final picked = await showFDialog<DateTime?>(
      context: context,
      builder: (dialogContext, style, animation) => AppDialogShell(
        maxWidth: LayoutScaleResolver.dialogMaxWidth,
        padding: const EdgeInsets.all(Spacing.level4),
        builder: (_) => SizedBox(
          height: 400,
          child: FCalendar.splitGrid(
            control: FGridSplitCalendarControl(
              start: RecordDateBar._minDate,
              end: RecordDateBar._maxDate,
            ),
            selectionControl: FDateSelectionControl.managedSingle(
              initial: selectedDate,
              onChange: (date) {
                if (date != null) {
                  onDateSelected?.call(_dateOnly(date));
                }
                Navigator.of(dialogContext).pop(date);
              },
            ),
          ),
        ),
      ),
    );
    if (picked != null) {
      onDateSelected?.call(_dateOnly(picked));
    }
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
