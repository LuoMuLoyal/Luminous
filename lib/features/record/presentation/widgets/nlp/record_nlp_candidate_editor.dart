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
      final text = item.title ?? '';
      if (titleController.text != text) {
        titleController.text = text;
      }
      return null;
    }, [item.title]);
    useEffect(() {
      final text = item.value ?? '';
      if (valueController.text != text) {
        valueController.text = text;
      }
      return null;
    }, [item.value]);
    useEffect(() {
      final text = item.note ?? '';
      if (noteController.text != text) {
        noteController.text = text;
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
        onChange: (nextValue) => onChanged(nextValue ?? dailyRecordWaterDefaultUnit),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FTextField(
          key: Key('record-nlp-candidate-sleep-duration-$index'),
          control: FTextFieldControl.managed(
            initial: TextEditingValue(
              text: _durationValue(payload['durationMinutes']),
            ),
            onChange: (value) {
              final minutes = int.tryParse(value.text.trim());
              final nextPayload = Map<String, dynamic>.from(payload);
              if (minutes == null || minutes <= 0) {
                nextPayload.remove('durationMinutes');
              } else {
                nextPayload['durationMinutes'] = minutes;
              }
              onChanged(item.copyWith(payload: nextPayload));
            },
          ),
          enabled: enabled,
          label: Text(l10n.recordSleepDurationLabel),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        FSelect<String>.rich(
          key: Key('record-nlp-candidate-sleep-quality-$index'),
          label: Text(l10n.recordSleepQualityLabel),
          hint: l10n.recordSleepQualityLabel,
          format: (value) => sleepQualityOptions(l10n)
              .firstWhere((q) => q.key == value)
              .label,
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
