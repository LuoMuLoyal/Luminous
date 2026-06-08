import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/l10n/app_localizations.dart';

const dailyRecordWaterDefaultUnit = 'ml';

class DailyRecordFormFields extends StatelessWidget {
  const DailyRecordFormFields({
    super.key,
    required this.kind,
    required this.onKindChanged,
    required this.valueController,
    required this.unitController,
    required this.titleController,
    required this.noteController,
  });

  final DailyRecordKind kind;
  final ValueChanged<DailyRecordKind> onKindChanged;
  final TextEditingController valueController;
  final TextEditingController unitController;
  final TextEditingController titleController;
  final TextEditingController noteController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rules = dailyRecordFormRules(kind);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<DailyRecordKind>(
          key: ValueKey('daily-record-kind-${kind.name}'),
          initialValue: kind,
          decoration: InputDecoration(labelText: l10n.recordCreateFieldKind),
          items: activeDailyRecordKinds
              .map(
                (k) => DropdownMenuItem(
                  value: k,
                  child: Text(dailyRecordKindLabel(l10n, k)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onKindChanged(value);
          },
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        if (rules.showValue) ...[
          TextField(
            key: const Key('daily-record-value-field'),
            controller: valueController,
            decoration: InputDecoration(
              labelText: dailyRecordValueLabel(l10n, kind),
            ),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
        ],
        if (rules.showUnit) ...[
          TextField(
            key: const Key('daily-record-unit-field'),
            controller: unitController,
            decoration: InputDecoration(labelText: l10n.recordCreateFieldUnit),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
        ],
        if (rules.showTitle) ...[
          TextField(
            key: const Key('daily-record-title-field'),
            controller: titleController,
            decoration: InputDecoration(
              labelText: l10n.recordCreateFieldTitleOptional,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
        ],
        TextField(
          key: const Key('daily-record-note-field'),
          controller: noteController,
          decoration: InputDecoration(labelText: l10n.recordCreateFieldNote),
          maxLines: 3,
        ),
      ],
    );
  }
}

class DailyRecordFormRules {
  const DailyRecordFormRules({
    required this.showTitle,
    required this.showValue,
    required this.showUnit,
  });

  final bool showTitle;
  final bool showValue;
  final bool showUnit;
}

DailyRecordFormRules dailyRecordFormRules(DailyRecordKind kind) {
  return switch (kind) {
    DailyRecordKind.water => const DailyRecordFormRules(
      showTitle: false,
      showValue: true,
      showUnit: true,
    ),
    DailyRecordKind.vital => const DailyRecordFormRules(
      showTitle: true,
      showValue: true,
      showUnit: true,
    ),
    DailyRecordKind.symptom => const DailyRecordFormRules(
      showTitle: true,
      showValue: true,
      showUnit: false,
    ),
    DailyRecordKind.note => const DailyRecordFormRules(
      showTitle: true,
      showValue: false,
      showUnit: false,
    ),
    DailyRecordKind.meal => const DailyRecordFormRules(
      showTitle: true,
      showValue: true,
      showUnit: false,
    ),
    DailyRecordKind.mood => const DailyRecordFormRules(
      showTitle: true,
      showValue: false,
      showUnit: false,
    ),
    DailyRecordKind.activity => const DailyRecordFormRules(
      showTitle: true,
      showValue: true,
      showUnit: false,
    ),
  };
}

String dailyRecordKindLabel(AppLocalizations l10n, DailyRecordKind kind) {
  return switch (kind) {
    DailyRecordKind.water => l10n.recordTypeWater,
    DailyRecordKind.meal => l10n.recordTypeMeal,
    DailyRecordKind.vital => l10n.recordTypeVitals,
    DailyRecordKind.mood => l10n.recordTypeMood,
    DailyRecordKind.symptom => l10n.recordTypeSymptom,
    DailyRecordKind.activity => l10n.recordTypeActivity,
    DailyRecordKind.note => l10n.recordCreateKindNote,
  };
}

String dailyRecordValueLabel(AppLocalizations l10n, DailyRecordKind kind) {
  return switch (kind) {
    DailyRecordKind.water => l10n.recordCreateValueWater,
    DailyRecordKind.meal => l10n.recordCreateValueMeal,
    DailyRecordKind.vital => l10n.recordCreateValueVital,
    DailyRecordKind.mood => l10n.recordTypeMood,
    DailyRecordKind.symptom => l10n.recordCreateValueSymptom,
    DailyRecordKind.activity => l10n.recordTypeActivity,
    DailyRecordKind.note => l10n.recordCreateFieldNote,
  };
}

const activeDailyRecordKinds = <DailyRecordKind>[
  DailyRecordKind.water,
  DailyRecordKind.meal,
  DailyRecordKind.vital,
  DailyRecordKind.symptom,
  DailyRecordKind.note,
];
