import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/record/domain/entities/daily_record.dart';
import 'package:luminous/l10n/app_localizations.dart';

const dailyRecordWaterDefaultUnit = 'ml';
const dailyRecordWaterCupUnit = 'cup';
const dailyRecordWaterTimesUnit = 'times';

class DailyRecordFormFields extends StatelessWidget {
  const DailyRecordFormFields({
    super.key,
    required this.kind,
    required this.onKindChanged,
    required this.valueController,
    required this.unitController,
    required this.titleController,
    required this.noteController,
    this.showKindField = true,
  });

  final DailyRecordKind kind;
  final ValueChanged<DailyRecordKind> onKindChanged;
  final TextEditingController valueController;
  final TextEditingController unitController;
  final TextEditingController titleController;
  final TextEditingController noteController;
  final bool showKindField;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rules = dailyRecordFormRules(kind);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showKindField) ...[
          FSelect<DailyRecordKind>.rich(
            key: ValueKey('daily-record-kind-${kind.name}'),
            label: Text(l10n.recordCreateFieldKind),
            hint: l10n.recordCreateFieldKind,
            format: (value) => dailyRecordKindLabel(l10n, value),
            control: FSelectControl.lifted(
              value: kind,
              onChange: (value) {
                if (value != null) onKindChanged(value);
              },
            ),
            children: _visibleDailyRecordKinds(kind)
                .map(
                  (k) => FSelectItem.item(
                    title: Text(dailyRecordKindLabel(l10n, k)),
                    value: k,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacingTokens.level3),
        ],
        if (rules.showValue) ...[
          FTextField(
            key: const Key('daily-record-value-field'),
            control: FTextFieldControl.managed(controller: valueController),
            label: Text(dailyRecordValueLabel(l10n, kind)),
          ),
          const SizedBox(height: AppSpacingTokens.level3),
        ],
        if (rules.showUnit) ...[
          if (kind == DailyRecordKind.water)
            FSelect<String>.rich(
              key: const Key('daily-record-unit-field'),
              label: Text(l10n.recordCreateFieldUnit),
              hint: l10n.recordCreateFieldUnit,
              format: (value) => switch (value) {
                dailyRecordWaterCupUnit => l10n.recordWaterUnitCup,
                dailyRecordWaterTimesUnit => l10n.recordWaterUnitTimes,
                _ => l10n.recordWaterUnitMl,
              },
              control: FSelectControl.lifted(
                value: _normalizedWaterUnit(unitController.text),
                onChange: (value) {
                  unitController.text = value ?? dailyRecordWaterDefaultUnit;
                },
              ),
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
            )
          else
            FTextField(
              key: const Key('daily-record-unit-field'),
              control: FTextFieldControl.managed(controller: unitController),
              label: Text(l10n.recordCreateFieldUnit),
            ),
          const SizedBox(height: AppSpacingTokens.level3),
        ],
        if (rules.showTitle) ...[
          FTextField(
            key: const Key('daily-record-title-field'),
            control: FTextFieldControl.managed(controller: titleController),
            label: Text(l10n.recordCreateFieldTitleOptional),
          ),
          const SizedBox(height: AppSpacingTokens.level3),
        ],
        FTextField(
          key: const Key('daily-record-note-field'),
          control: FTextFieldControl.managed(controller: noteController),
          label: Text(l10n.recordCreateFieldNote),
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
    DailyRecordKind.sleep => const DailyRecordFormRules(
      showTitle: false,
      showValue: false,
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
    DailyRecordKind.sleep => l10n.recordTypeSleep,
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
    DailyRecordKind.sleep => l10n.recordCreateValueSleep,
  };
}

const activeDailyRecordKinds = <DailyRecordKind>[
  DailyRecordKind.water,
  DailyRecordKind.meal,
  DailyRecordKind.symptom,
  DailyRecordKind.note,
  DailyRecordKind.sleep,
];

List<DailyRecordKind> _visibleDailyRecordKinds(DailyRecordKind selectedKind) {
  if (activeDailyRecordKinds.contains(selectedKind)) {
    return activeDailyRecordKinds;
  }

  // Deferred by Product_Vision MVP: keep legacy/non-MVP record kinds editable
  // when they already exist, but do not surface them as default create options.
  return <DailyRecordKind>[...activeDailyRecordKinds, selectedKind];
}

String _normalizedWaterUnit(String value) {
  final normalized = value.trim();
  return switch (normalized) {
    dailyRecordWaterCupUnit => dailyRecordWaterCupUnit,
    dailyRecordWaterTimesUnit => dailyRecordWaterTimesUnit,
    _ => dailyRecordWaterDefaultUnit,
  };
}
