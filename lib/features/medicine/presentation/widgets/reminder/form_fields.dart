import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
import 'package:luminous/features/medicine/presentation/providers/reminders.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

class FrequencySegments extends StatelessWidget {
  const FrequencySegments({
    super.key,
    required this.frequency,
    required this.onChanged,
  });

  final ReminderFrequency frequency;
  final ValueChanged<ReminderFrequency> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FSelectGroup<ReminderFrequency>(
      control: FMultiValueControl.lifted(
        value: {frequency},
        onChange: (value) => onChanged(value.single),
      ),
      children: [
        FSelectGroupItemMixin.radio(
          value: ReminderFrequency.daily,
          label: Text(l10n.medicineReminderFrequencyDaily),
        ),
        FSelectGroupItemMixin.radio(
          value: ReminderFrequency.weekly,
          label: Text(l10n.medicineReminderFrequencyWeekly),
        ),
        FSelectGroupItemMixin.radio(
          value: ReminderFrequency.custom,
          label: Text(l10n.medicineReminderFrequencyCustom),
        ),
      ],
    );
  }
}

class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker({
    super.key,
    required this.selectedWeekdays,
    required this.onToggled,
  });

  final Set<int> selectedWeekdays;
  final ValueChanged<int> onToggled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = <int, String>{
      1: l10n.recordWeekdayMon,
      2: l10n.recordWeekdayTue,
      3: l10n.recordWeekdayWed,
      4: l10n.recordWeekdayThu,
      5: l10n.recordWeekdayFri,
      6: l10n.recordWeekdaySat,
      0: l10n.recordWeekdaySun,
    };

    return Wrap(
      spacing: Spacing.level2,
      runSpacing: Spacing.level2,
      children: labels.entries
          .map(
            (entry) => FButton(
              key: Key('medicine-reminder-weekday-${entry.key}'),
              onPress: () => onToggled(entry.key),
              variant: FButtonVariant.outline,
              selected: selectedWeekdays.contains(entry.key),
              size: FButtonSizeVariant.xs,
              mainAxisSize: MainAxisSize.min,
              child: Text(entry.value),
            ),
          )
          .toList(growable: false),
    );
  }
}

class TimePickerRow extends StatelessWidget {
  const TimePickerRow({
    super.key,
    required this.times,
    required this.onAddTime,
    required this.onRemoveTime,
  });

  final List<MedicineReminderTimeInput> times;
  final VoidCallback onAddTime;
  final ValueChanged<int> onRemoveTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canRemove = times.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineReminderTimesLabel,
          style: TypographyToken.level5
              .body(context)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Spacing.level3),
        Wrap(
          spacing: Spacing.level2,
          runSpacing: Spacing.level2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var index = 0; index < times.length; index += 1)
              FButton(
                key: Key('medicine-reminder-time-$index'),
                onPress: canRemove ? () => onRemoveTime(index) : null,
                variant: FButtonVariant.outline,
                size: FButtonSizeVariant.xs,
                mainAxisSize: MainAxisSize.min,
                prefix: const Icon(FLucideIcons.clock3, size: 16),
                suffix: canRemove ? const Icon(FLucideIcons.x, size: 16) : null,
                child: Text(
                  formatTimeOfDay(
                    TimeOfDay(
                      hour: times[index].hour,
                      minute: times[index].minute,
                    ),
                    Localizations.localeOf(context),
                  ),
                ),
              ),
            FButton(
              key: const Key('medicine-reminder-add-time'),
              onPress: onAddTime,
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.xs,
              mainAxisSize: MainAxisSize.min,
              prefix: const Icon(FLucideIcons.plus, size: 16),
              child: Text(l10n.medicineReminderAddTimeAction),
            ),
          ],
        ),
      ],
    );
  }
}
