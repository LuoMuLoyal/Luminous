import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/presentation/controllers/record_nlp_controller.dart';
import 'package:luminous/features/record/presentation/widgets/forms/daily_record_form_fields.dart';
import 'package:luminous/features/record/presentation/widgets/forms/sleep_structured_fields.dart';
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
      titleController.text = item.title ?? '';
      return null;
    }, [item.title]);
    useEffect(() {
      valueController.text = item.value ?? '';
      return null;
    }, [item.value]);
    useEffect(() {
      noteController.text = item.note ?? '';
      return null;
    }, [item.note]);

    void emit({String? title, String? value, String? unit, String? note}) {
      onChanged(
        item.copyWith(
          title: title ?? item.title,
          value: value ?? item.value,
          unit: unit ?? item.unit,
          note: note ?? item.note,
        ),
      );
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
          const SizedBox(height: AppSpacingTokens.level3),
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
                const SizedBox(width: AppSpacingTokens.level3),
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
          const SizedBox(height: AppSpacingTokens.level3),
        ],
        if (kind == DailyRecordKind.sleep) ...[
          _SleepCandidateFields(
            index: index,
            item: item,
            enabled: enabled,
            onChanged: onChanged,
          ),
          const SizedBox(height: AppSpacingTokens.level3),
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

    return DropdownButtonFormField<String>(
      key: Key('record-nlp-candidate-unit-$index-$normalizedUnit'),
      initialValue: normalizedUnit,
      decoration: InputDecoration(labelText: l10n.recordCreateFieldUnit),
      items: [
        DropdownMenuItem(
          value: dailyRecordWaterDefaultUnit,
          child: Text(l10n.recordWaterUnitMl),
        ),
        DropdownMenuItem(
          value: dailyRecordWaterCupUnit,
          child: Text(l10n.recordWaterUnitCup),
        ),
        DropdownMenuItem(
          value: dailyRecordWaterTimesUnit,
          child: Text(l10n.recordWaterUnitTimes),
        ),
      ],
      onChanged: enabled
          ? (nextValue) => onChanged(nextValue ?? dailyRecordWaterDefaultUnit)
          : null,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: Key('record-nlp-candidate-sleep-duration-$index'),
          enabled: enabled,
          initialValue: _durationValue(payload['durationMinutes']),
          decoration: InputDecoration(labelText: l10n.recordSleepDurationLabel),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final minutes = int.tryParse(value.trim());
            final nextPayload = Map<String, dynamic>.from(payload);
            if (minutes == null || minutes <= 0) {
              nextPayload.remove('durationMinutes');
            } else {
              nextPayload['durationMinutes'] = minutes;
            }
            onChanged(item.copyWith(payload: nextPayload));
          },
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        DropdownButtonFormField<String>(
          key: Key('record-nlp-candidate-sleep-quality-$index'),
          initialValue: quality,
          decoration: InputDecoration(labelText: l10n.recordSleepQualityLabel),
          items: sleepQualityOptions(l10n)
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option.key,
                  child: Text(option.label),
                ),
              )
              .toList(),
          onChanged: enabled
              ? (value) {
                  final nextPayload = Map<String, dynamic>.from(payload);
                  if (value == null || value.isEmpty) {
                    nextPayload.remove('quality');
                  } else {
                    nextPayload['quality'] = value;
                  }
                  onChanged(item.copyWith(payload: nextPayload));
                }
              : null,
        ),
      ],
    );
  }

  String _durationValue(Object? value) {
    if (value is num && value > 0) return value.round().toString();
    return '';
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
