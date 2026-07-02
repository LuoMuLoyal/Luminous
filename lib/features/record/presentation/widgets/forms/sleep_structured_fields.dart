import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SleepQuality {
  const SleepQuality(this.key, this.label);

  final String key;
  final String label;
}

List<SleepQuality> sleepQualityOptions(AppLocalizations l10n) => [
  SleepQuality('poor', l10n.recordSleepQualityPoor),
  SleepQuality('fair', l10n.recordSleepQualityFair),
  SleepQuality('good', l10n.recordSleepQualityGood),
  SleepQuality('excellent', l10n.recordSleepQualityExcellent),
];

class SleepStructuredFields extends StatelessWidget {
  /// When true, the time picker opens in input mode instead of dial mode.
  /// Intended for integration tests that need to interact with TextFields.
  /// Tests must reset this to false in `addTearDown`.
  static bool forceInputTimePicker = false;

  /// Optional test-only override queue for deterministic picked times without
  /// opening the platform time-picker dialog.
  /// Tests must clear this in `addTearDown`.
  static final List<TimeOfDay> forcedPickedTimes = <TimeOfDay>[];

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
              child: _TimePickerField(
                key: const Key('sleep-bedtime-picker'),
                label: l10n.recordSleepBedtimeLabel,
                time: bedtime,
                onPicked: onBedtimeChanged,
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level4),
            Expanded(
              child: _TimePickerField(
                key: const Key('sleep-waketime-picker'),
                label: l10n.recordSleepWakeTimeLabel,
                time: wakeTime,
                onPicked: onWakeTimeChanged,
              ),
            ),
          ],
        ),
        if (durationMinutes != null) ...[
          const SizedBox(height: AppSpacingTokens.level3),
          Text(
            '${l10n.recordSleepDurationLabel}: ${_formatDuration(durationMinutes, l10n)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: AppSpacingTokens.level3),
        DropdownButtonFormField<String>(
          key: const Key('sleep-quality-field'),
          initialValue: quality,
          decoration: InputDecoration(labelText: l10n.recordSleepQualityLabel),
          items: sleepQualityOptions(l10n)
              .map((q) => DropdownMenuItem(value: q.key, child: Text(q.label)))
              .toList(),
          onChanged: onQualityChanged,
        ),
        const SizedBox(height: AppSpacingTokens.level3),
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
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: _NumberField(
                key: const Key('sleep-light-minutes-field'),
                label: l10n.recordSleepLightMinutesLabel,
                value: lightMinutes,
                onChanged: onLightMinutesChanged,
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
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

int? computeSleepDurationMinutes(TimeOfDay? bedtime, TimeOfDay? wakeTime) {
  if (bedtime == null || wakeTime == null) return null;
  final bedMinutes = bedtime.hour * 60 + bedtime.minute;
  final wakeMinutes = wakeTime.hour * 60 + wakeTime.minute;
  var diff = wakeMinutes - bedMinutes;
  if (diff < 0) diff += 24 * 60;
  // Same bedtime and wake time is ambiguous — treat as invalid rather
  // than a full 24-hour sleep.
  if (diff == 0) return null;
  return diff;
}

String _formatDuration(int minutes, AppLocalizations l10n) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (m == 0) return '$h${l10n.todayVitalSleepUnit}';
  return '$h${l10n.todayVitalSleepUnit} $m${l10n.recordSleepMinutesUnit}';
}

String? formatSleepTimeRange(TimeOfDay? bedtime, TimeOfDay? wakeTime) {
  if (bedtime == null || wakeTime == null) return null;
  return '${_fmt(bedtime)} – ${_fmt(wakeTime)}';
}

String _fmt(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    super.key,
    required this.label,
    required this.time,
    required this.onPicked,
  });

  final String label;
  final TimeOfDay? time;
  final ValueChanged<TimeOfDay?> onPicked;

  @override
  Widget build(BuildContext context) {
    final text = time == null ? null : _fmt(time!);

    return FTappable(
      onPress: () async {
        if (SleepStructuredFields.forcedPickedTimes.isNotEmpty) {
          onPicked(SleepStructuredFields.forcedPickedTimes.removeAt(0));
          return;
        }
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? const TimeOfDay(hour: 23, minute: 0),
          initialEntryMode: SleepStructuredFields.forceInputTimePicker
              ? TimePickerEntryMode.input
              : TimePickerEntryMode.dial,
        );
        onPicked(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(text ?? '', style: const TextStyle(fontSize: 14)),
      ),
    );
  }
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
