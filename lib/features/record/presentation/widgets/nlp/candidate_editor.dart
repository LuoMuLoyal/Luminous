import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/services/sleep_entry.dart';
import 'package:luminous/features/record/presentation/controllers/nlp.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/utils/sleep_formatters.dart';
import 'package:luminous/features/record/presentation/widgets/forms/form_fields.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordNlpCandidateEditor extends HookWidget {
  const RecordNlpCandidateEditor({
    super.key,
    required this.index,
    required this.item,
    required this.enabled,
    required this.onChanged,
  });

  final int index;
  final RecordNlpCandidateDraft item;
  final bool enabled;
  final ValueChanged<RecordNlpCandidateDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final kind = item.kind;

    final titleController = useTextEditingController(text: item.title ?? '');
    final valueController = useTextEditingController(text: item.value ?? '');
    final noteController = useTextEditingController(text: item.note ?? '');

    // Sync controller text when parent changes the item
    useEffect(() {
      final text = item.title ?? '';
      if (titleController.text != text) {
        unawaited(Future.microtask(() => titleController.text = text));
      }
      return null;
    }, [item.title]);
    useEffect(() {
      final text = item.value ?? '';
      if (valueController.text != text) {
        unawaited(Future.microtask(() => valueController.text = text));
      }
      return null;
    }, [item.value]);
    useEffect(() {
      final text = item.note ?? '';
      if (noteController.text != text) {
        unawaited(Future.microtask(() => noteController.text = text));
      }
      return null;
    }, [item.note]);

    void emit({String? title, String? value, String? unit, String? note}) {
      final next = item.copyWith(
        title: title ?? item.title,
        value: value ?? item.value,
        unit: unit ?? item.unit,
        note: note ?? item.note,
      );
      if (next == item) return;
      onChanged(next);
    }

    bool shouldShowTitle(DailyRecordKind k) {
      return switch (k) {
        DailyRecordKind.water => false,
        DailyRecordKind.sleep => false,
        _ => true,
      };
    }

    bool shouldShowValue(DailyRecordKind k) {
      return switch (k) {
        DailyRecordKind.note => false,
        DailyRecordKind.sleep => false,
        _ => true,
      };
    }

    bool shouldShowUnit(DailyRecordKind k) {
      return k == DailyRecordKind.water;
    }

    bool shouldShowValueOrUnit(DailyRecordKind k) {
      return shouldShowValue(k) || shouldShowUnit(k);
    }

    String valueLabel(AppLocalizations l, DailyRecordKind k) {
      return switch (k) {
        DailyRecordKind.water => l.recordCreateValueWater,
        DailyRecordKind.meal => l.recordCreateValueMeal,
        DailyRecordKind.symptom => l.recordCreateValueSymptom,
        _ => l.recordCreateValueVital,
      };
    }

    String titleLabel(AppLocalizations l, DailyRecordKind k) {
      return switch (k) {
        DailyRecordKind.meal => l.recordNlpMealTitleOptional,
        DailyRecordKind.symptom => l.recordNlpSymptomTitleLabel,
        _ => l.recordCreateFieldTitleOptional,
      };
    }

    String noteLabel(AppLocalizations l, DailyRecordKind k) {
      return switch (k) {
        DailyRecordKind.note => l.recordNlpNoteBodyLabel,
        _ => l.recordNlpDetailsLabel,
      };
    }

    TextInputType? valueKeyboardType(DailyRecordKind k) {
      return switch (k) {
        DailyRecordKind.water => const TextInputType.numberWithOptions(
          decimal: true,
        ),
        _ => null,
      };
    }

    int noteMinLines(DailyRecordKind k) {
      return switch (k) {
        DailyRecordKind.note => 3,
        _ => 2,
      };
    }

    int noteMaxLines(DailyRecordKind k) {
      return switch (k) {
        DailyRecordKind.note => 5,
        _ => 3,
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (shouldShowTitle(kind)) ...[
          FTextField(
            key: Key('record-nlp-candidate-title-$index'),
            control: FTextFieldControl.managed(
              controller: titleController,
              onChange: (value) => emit(title: value.text),
            ),
            enabled: enabled,
            label: Text(titleLabel(l10n, kind)),
          ),
          const SizedBox(height: Spacing.md),
        ],
        if (shouldShowValueOrUnit(kind)) ...[
          Row(
            children: [
              if (shouldShowValue(kind))
                Expanded(
                  child: FTextField(
                    key: Key('record-nlp-candidate-value-$index'),
                    control: FTextFieldControl.managed(
                      controller: valueController,
                      onChange: (value) => emit(value: value.text),
                    ),
                    enabled: enabled,
                    keyboardType: valueKeyboardType(kind),
                    label: Text(valueLabel(l10n, kind)),
                  ),
                ),
              if (shouldShowValue(kind) && shouldShowUnit(kind))
                const SizedBox(width: Spacing.md),
              if (shouldShowUnit(kind))
                Expanded(
                  child: _WaterUnitField(
                    index: index,
                    enabled: enabled,
                    value: item.unit,
                    onChanged: (value) => emit(unit: value),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Spacing.md),
        ],
        if (kind == DailyRecordKind.sleep) ...[
          _SleepCandidateFields(
            index: index,
            item: item,
            enabled: enabled,
            onChanged: onChanged,
          ),
          const SizedBox(height: Spacing.md),
        ],
        FTextField(
          key: Key('record-nlp-candidate-note-$index'),
          control: FTextFieldControl.managed(
            controller: noteController,
            onChange: (value) => emit(note: value.text),
          ),
          enabled: enabled,
          minLines: noteMinLines(kind),
          maxLines: noteMaxLines(kind),
          label: Text(noteLabel(l10n, kind)),
        ),
      ],
    );
  }
}

class _WaterUnitField extends StatelessWidget {
  const _WaterUnitField({
    required this.index,
    required this.enabled,
    required this.value,
    required this.onChanged,
  });

  final int index;
  final bool enabled;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final normalizedUnit = normalizedWaterUnit(value);

    return FSelect<String>.rich(
      key: Key('record-nlp-candidate-unit-$index-$normalizedUnit'),
      label: Text(l10n.recordCreateFieldUnit),
      hint: l10n.recordCreateFieldUnit,
      format: (value) => switch (value) {
        dailyRecordWaterCupUnit => l10n.recordWaterUnitCup,
        dailyRecordWaterTimesUnit => l10n.recordWaterUnitTimes,
        _ => l10n.recordWaterUnitMl,
      },
      control: FSelectControl.lifted(
        value: normalizedUnit,
        onChange: (nextValue) =>
            onChanged(nextValue ?? dailyRecordWaterDefaultUnit),
      ),
      enabled: enabled,
      children: [
        FSelectItem.item(
          title: Text(l10n.recordWaterUnitMl),
          value: dailyRecordWaterDefaultUnit,
        ),
        FSelectItem.item(
          title: Text(l10n.recordWaterUnitCup),
          value: dailyRecordWaterCupUnit,
        ),
        FSelectItem.item(
          title: Text(l10n.recordWaterUnitTimes),
          value: dailyRecordWaterTimesUnit,
        ),
      ],
    );
  }
}

class _SleepCandidateFields extends StatelessWidget {
  const _SleepCandidateFields({
    required this.index,
    required this.item,
    required this.enabled,
    required this.onChanged,
  });

  final int index;
  final RecordNlpCandidateDraft item;
  final bool enabled;
  final ValueChanged<RecordNlpCandidateDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final payload = Map<String, dynamic>.from(
      item.payload ?? const <String, dynamic>{},
    );
    final quality = payload['quality'] as String?;

    // Extract bedtime/wakeTime from the canonical payload instants.
    final bedtime = _extractTimeOfDay(payload['startedAt']);
    final wakeTime = _extractTimeOfDay(payload['endedAt']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: FTimeField.picker(
                key: Key('record-nlp-candidate-sleep-bedtime-$index'),
                label: Text(l10n.recordSleepBedtimeLabel),
                control: FTimeFieldControl.lifted(
                  time: bedtime?.toFTime(),
                  onChange: (value) {
                    onChanged(
                      item.copyWith(
                        payload: _withSleepTimes(
                          payload,
                          bedtime: value?.toTimeOfDay(),
                          wakeTime: wakeTime,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: Spacing.lg),
            Expanded(
              child: FTimeField.picker(
                key: Key('record-nlp-candidate-sleep-waketime-$index'),
                label: Text(l10n.recordSleepWakeTimeLabel),
                control: FTimeFieldControl.lifted(
                  time: wakeTime?.toFTime(),
                  onChange: (value) {
                    onChanged(
                      item.copyWith(
                        payload: _withSleepTimes(
                          payload,
                          bedtime: bedtime,
                          wakeTime: value?.toTimeOfDay(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        if (bedtime != null && wakeTime != null) ...[
          const SizedBox(height: Spacing.md),
          Text(
            '${l10n.recordSleepDurationLabel}: '
            '${formatSleepDurationLabel(computeSleepDurationMinutes(bedtime, wakeTime) ?? 0, l10n)}',
            style: context.theme.typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ],
        const SizedBox(height: Spacing.md),
        FSelect<String>.rich(
          key: Key('record-nlp-candidate-sleep-quality-$index'),
          label: Text(l10n.recordSleepQualityLabel),
          hint: l10n.recordSleepQualityLabel,
          format: (value) =>
              sleepQualityOptions(l10n).firstWhere((q) => q.key == value).label,
          control: FSelectControl.lifted(
            value: quality,
            onChange: (value) {
              final nextPayload = Map<String, dynamic>.from(payload);
              if (value == null || value.isEmpty) {
                nextPayload.remove('quality');
              } else {
                nextPayload['quality'] = value;
              }
              onChanged(item.copyWith(payload: nextPayload));
            },
          ),
          enabled: enabled,
          children: sleepQualityOptions(l10n)
              .map(
                (option) => FSelectItem.item(
                  title: Text(option.label),
                  value: option.key,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  /// Extracts a [TimeOfDay] from a canonical ISO instant payload value.
  TimeOfDay? _extractTimeOfDay(Object? value) {
    if (value is! String) return null;
    final dt = DateTime.tryParse(value);
    if (dt == null) return null;
    final local = dt.toLocal();
    return TimeOfDay(hour: local.hour, minute: local.minute);
  }

  /// Rewrites the canonical sleep keys (`startedAt`/`endedAt`/`durationMinutes`)
  /// from the edited clock times, resolved against the candidate's wake date.
  Map<String, dynamic> _withSleepTimes(
    Map<String, dynamic> payload, {
    required TimeOfDay? bedtime,
    required TimeOfDay? wakeTime,
  }) {
    final next = Map<String, dynamic>.from(payload)
      ..remove('startedAt')
      ..remove('endedAt')
      ..remove('durationMinutes');

    final recordDate = parseRecordDate(item.occurredAt);
    if (bedtime == null || wakeTime == null || recordDate == null) return next;

    final window = resolveSleepWindow(
      recordDate: recordDate,
      bedtime: bedtime,
      wakeTime: wakeTime,
      kind: SleepEntryKind.fromPayload(payload['sleepType']),
    );
    if (window == null) return next;

    next['startedAt'] = window.startedAt.toUtc().toIso8601String();
    next['endedAt'] = window.endedAt.toUtc().toIso8601String();
    next['durationMinutes'] = window.durationMinutes;
    return next;
  }
}

String normalizedWaterUnit(String? value) {
  final normalized = value?.trim();
  return switch (normalized) {
    dailyRecordWaterCupUnit => dailyRecordWaterCupUnit,
    dailyRecordWaterTimesUnit => dailyRecordWaterTimesUnit,
    _ => dailyRecordWaterDefaultUnit,
  };
}

extension _NlpTimeOfDay on TimeOfDay {
  FTime toFTime() => FTime(hour, minute);
}

extension _NlpFTime on FTime {
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);
}
