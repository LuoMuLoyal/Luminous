import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/features/record/presentation/controllers/record_nlp_controller.dart';
import 'package:luminous/features/record/presentation/widgets/daily_record_form_fields.dart';
import 'package:luminous/features/record/presentation/widgets/sleep_structured_fields.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordNlpCandidateEditor extends StatefulWidget {
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
  State<RecordNlpCandidateEditor> createState() =>
      _RecordNlpCandidateEditorState();
}

class _RecordNlpCandidateEditorState extends State<RecordNlpCandidateEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _valueController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title ?? '');
    _valueController = TextEditingController(text: widget.item.value ?? '');
    _noteController = TextEditingController(text: widget.item.note ?? '');
  }

  @override
  void didUpdateWidget(covariant RecordNlpCandidateEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.title != widget.item.title) {
      _titleController.text = widget.item.title ?? '';
    }
    if (oldWidget.item.value != widget.item.value) {
      _valueController.text = widget.item.value ?? '';
    }
    if (oldWidget.item.note != widget.item.note) {
      _noteController.text = widget.item.note ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final kind = widget.item.kind;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_shouldShowTitle(kind)) ...[
          TextField(
            key: Key('record-nlp-candidate-title-${widget.index}'),
            controller: _titleController,
            enabled: widget.enabled,
            decoration: InputDecoration(labelText: _titleLabel(l10n, kind)),
            onChanged: (value) => _emit(title: value),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
        ],
        if (_shouldShowValueOrUnit(kind)) ...[
          Row(
            children: [
              if (_shouldShowValue(kind))
                Expanded(
                  child: TextField(
                    key: Key('record-nlp-candidate-value-${widget.index}'),
                    controller: _valueController,
                    enabled: widget.enabled,
                    keyboardType: _valueKeyboardType(kind),
                    decoration: InputDecoration(
                      labelText: _valueLabel(l10n, kind),
                    ),
                    onChanged: (value) => _emit(value: value),
                  ),
                ),
              if (_shouldShowValue(kind) && _shouldShowUnit(kind))
                const SizedBox(width: AppSpacingTokens.sm),
              if (_shouldShowUnit(kind))
                Expanded(
                  child: _WaterUnitField(
                    index: widget.index,
                    enabled: widget.enabled,
                    value: widget.item.unit,
                    onChanged: (value) => _emit(unit: value),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.sm),
        ],
        if (kind == DailyRecordKind.sleep) ...[
          _SleepCandidateFields(
            index: widget.index,
            item: widget.item,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
          ),
          const SizedBox(height: AppSpacingTokens.sm),
        ],
        TextField(
          key: Key('record-nlp-candidate-note-${widget.index}'),
          controller: _noteController,
          enabled: widget.enabled,
          minLines: _noteMinLines(kind),
          maxLines: _noteMaxLines(kind),
          decoration: InputDecoration(labelText: _noteLabel(l10n, kind)),
          onChanged: (value) => _emit(note: value),
        ),
      ],
    );
  }

  bool _shouldShowTitle(DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water => false,
      DailyRecordKind.sleep => false,
      _ => true,
    };
  }

  bool _shouldShowValue(DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.note => false,
      DailyRecordKind.sleep => false,
      _ => true,
    };
  }

  bool _shouldShowUnit(DailyRecordKind kind) {
    return kind == DailyRecordKind.water;
  }

  bool _shouldShowValueOrUnit(DailyRecordKind kind) {
    return _shouldShowValue(kind) || _shouldShowUnit(kind);
  }

  String _valueLabel(AppLocalizations l10n, DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water => l10n.recordCreateValueWater,
      DailyRecordKind.meal => l10n.recordCreateValueMeal,
      DailyRecordKind.symptom => l10n.recordCreateValueSymptom,
      _ => l10n.recordCreateValueVital,
    };
  }

  String _titleLabel(AppLocalizations l10n, DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.meal => l10n.recordNlpMealTitleOptional,
      DailyRecordKind.symptom => l10n.recordNlpSymptomTitleLabel,
      _ => l10n.recordCreateFieldTitleOptional,
    };
  }

  String _noteLabel(AppLocalizations l10n, DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.note => l10n.recordNlpNoteBodyLabel,
      _ => l10n.recordNlpDetailsLabel,
    };
  }

  TextInputType? _valueKeyboardType(DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.water => const TextInputType.numberWithOptions(
        decimal: true,
      ),
      _ => null,
    };
  }

  int _noteMinLines(DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.note => 3,
      _ => 2,
    };
  }

  int _noteMaxLines(DailyRecordKind kind) {
    return switch (kind) {
      DailyRecordKind.note => 5,
      _ => 3,
    };
  }

  void _emit({String? title, String? value, String? unit, String? note}) {
    widget.onChanged(
      widget.item.copyWith(
        title: title ?? widget.item.title,
        value: value ?? widget.item.value,
        unit: unit ?? widget.item.unit,
        note: note ?? widget.item.note,
      ),
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
          decoration: InputDecoration(
            labelText: l10n.recordSleepDurationLabel,
          ),
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
        const SizedBox(height: AppSpacingTokens.sm),
        DropdownButtonFormField<String>(
          key: Key('record-nlp-candidate-sleep-quality-$index'),
          initialValue: quality,
          decoration: InputDecoration(
            labelText: l10n.recordSleepQualityLabel,
          ),
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
