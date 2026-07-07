import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordOccurredAtFields extends StatelessWidget {
  const RecordOccurredAtFields({
    super.key,
    required this.date,
    required this.time,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  final DateTime date;
  final String? time;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<FTime?> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final parsedTime = parseRecordTime(time);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FDateField.calendar(
          key: const Key('record-date-field'),
          label: Text(l10n.recordCreateFieldDate),
          selectionControl: FDateSelectionControl.managedSingle(
            initial: date,
            toggleable: false,
            onChange: (value) {
              if (value != null) onDateChanged(value);
            },
          ),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        FTimeField.picker(
          key: const Key('record-time-field'),
          label: Text(l10n.recordCreateFieldTime),
          control: FTimeFieldControl.lifted(
            time: parsedTime == null
                ? null
                : FTime(parsedTime.hour, parsedTime.minute),
            onChange: onTimeChanged,
          ),
        ),
      ],
    );
  }
}
