import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_reminder_providers.dart';
import 'package:luminous/features/medicine/presentation/utils/medicine_reminder_formatters.dart';
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

    return SegmentedButton<ReminderFrequency>(
      segments: [
        ButtonSegment(
          value: ReminderFrequency.daily,
          label: Text(l10n.medicineReminderFrequencyDaily),
        ),
        ButtonSegment(
          value: ReminderFrequency.weekly,
          label: Text(l10n.medicineReminderFrequencyWeekly),
        ),
        ButtonSegment(
          value: ReminderFrequency.custom,
          label: Text(l10n.medicineReminderFrequencyCustom),
        ),
      ],
      selected: {frequency},
      showSelectedIcon: false,
      onSelectionChanged: (value) => onChanged(value.single),
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
      spacing: AppSpacingTokens.xs,
      runSpacing: AppSpacingTokens.xs,
      children: labels.entries
          .map(
            (entry) => FilterChip(
              label: Text(entry.value),
              selected: selectedWeekdays.contains(entry.key),
              onSelected: (_) => onToggled(entry.key),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineReminderTimesLabel,
          style: AppTypographyTokens.mobile(
            Theme.of(context).colorScheme.onSurface,
          ).bodySmStrong.copyWith(letterSpacing: 0),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        Wrap(
          spacing: AppSpacingTokens.xs,
          runSpacing: AppSpacingTokens.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var index = 0; index < times.length; index += 1)
              InputChip(
                key: Key('medicine-reminder-time-$index'),
                label: Text(times[index].label),
                avatar: const Icon(Icons.schedule_rounded, size: 16),
                onDeleted: times.length > 1 ? () => onRemoveTime(index) : null,
              ),
            ActionChip(
              key: const Key('medicine-reminder-add-time'),
              avatar: const Icon(Icons.add_rounded, size: 16),
              label: Text(l10n.medicineReminderAddTimeAction),
              onPressed: onAddTime,
            ),
          ],
        ),
      ],
    );
  }
}
