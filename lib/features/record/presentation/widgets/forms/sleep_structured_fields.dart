import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/services/sleep_entry.dart';
import 'package:luminous/features/record/presentation/utils/sleep_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SleepStructuredFields extends StatelessWidget {
  const SleepStructuredFields({
    super.key,
    required this.l10n,
    this.bedtime,
    this.wakeTime,
    this.quality,
    this.deepMinutes,
    this.lightMinutes,
    this.remMinutes,
    required this.onBedtimeChanged,
    required this.onWakeTimeChanged,
    required this.onQualityChanged,
    required this.onDeepMinutesChanged,
    required this.onLightMinutesChanged,
    required this.onRemMinutesChanged,
  });

  final AppLocalizations l10n;
  final TimeOfDay? bedtime;
  final TimeOfDay? wakeTime;
  final String? quality;
  final int? deepMinutes;
  final int? lightMinutes;
  final int? remMinutes;

  final ValueChanged<TimeOfDay?> onBedtimeChanged;
  final ValueChanged<TimeOfDay?> onWakeTimeChanged;
  final ValueChanged<String?> onQualityChanged;
  final ValueChanged<int?> onDeepMinutesChanged;
  final ValueChanged<int?> onLightMinutesChanged;
  final ValueChanged<int?> onRemMinutesChanged;

  @override
  Widget build(BuildContext context) {
    final durationMinutes = computeSleepDurationMinutes(bedtime, wakeTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: FTimeField.picker(
                key: const Key('sleep-bedtime-picker'),
                label: Text(l10n.recordSleepBedtimeLabel),
                control: FTimeFieldControl.lifted(
                  time: bedtime?.toFTime(),
                  onChange: (value) => onBedtimeChanged(value?.toTimeOfDay()),
                ),
              ),
            ),
            const SizedBox(width: Spacing.lg),
            Expanded(
              child: FTimeField.picker(
                key: const Key('sleep-waketime-picker'),
                label: Text(l10n.recordSleepWakeTimeLabel),
                control: FTimeFieldControl.lifted(
                  time: wakeTime?.toFTime(),
                  onChange: (value) => onWakeTimeChanged(value?.toTimeOfDay()),
                ),
              ),
            ),
          ],
        ),
        if (durationMinutes != null) ...[
          const SizedBox(height: Spacing.md),
          Text(
            '${l10n.recordSleepDurationLabel}: '
            '${formatSleepDurationLabel(durationMinutes, l10n)}',
            style: context.theme.typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ],
        const SizedBox(height: Spacing.md),
        FSelect<String>.rich(
          key: const Key('sleep-quality-field'),
          label: Text(l10n.recordSleepQualityLabel),
          hint: l10n.recordSleepQualityLabel,
          format: (value) =>
              sleepQualityOptions(l10n).firstWhere((q) => q.key == value).label,
          control: FSelectControl.lifted(
            value: quality,
            onChange: onQualityChanged,
          ),
          children: sleepQualityOptions(l10n)
              .map(
                (option) => FSelectItem.item(
                  title: Text(option.label),
                  value: option.key,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: Spacing.md),
        Row(
          children: [
            Expanded(
              child: _NumberField(
                key: const Key('sleep-deep-minutes-field'),
                label: l10n.recordSleepDeepMinutesLabel,
                value: deepMinutes,
                onChanged: onDeepMinutesChanged,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: _NumberField(
                key: const Key('sleep-light-minutes-field'),
                label: l10n.recordSleepLightMinutesLabel,
                value: lightMinutes,
                onChanged: onLightMinutesChanged,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: _NumberField(
                key: const Key('sleep-rem-minutes-field'),
                label: l10n.recordSleepRemMinutesLabel,
                value: remMinutes,
                onChanged: onRemMinutesChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

extension _SleepTimeOfDay on TimeOfDay {
  FTime toFTime() => FTime(hour, minute);
}

extension _SleepFTime on FTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}

class _NumberField extends HookWidget {
  const _NumberField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: value?.toString() ?? '');

    useEffect(() {
      final newText = value?.toString() ?? '';
      if (controller.text != newText) {
        controller.text = newText;
      }
      return null;
    }, [value]);

    return FTextField(
      control: FTextFieldControl.managed(
        controller: controller,
        onChange: (value) {
          onChanged(int.tryParse(value.text.trim()));
        },
      ),
      label: Text(label),
      keyboardType: TextInputType.number,
    );
  }
}
