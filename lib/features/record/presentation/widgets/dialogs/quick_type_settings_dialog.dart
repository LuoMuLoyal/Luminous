import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/constants/fast_entry_choices.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/water_custom_amount_dialog.dart';
import 'package:luminous/features/record/presentation/widgets/shared/copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Long-press dialog for a quick-entry tile (Forui [FDialog]).
///
/// Per the quick-entry UX spec, long press is a shortcut to the type-specific
/// "more/settings" surface:
/// - water: water default amount + badge display settings;
/// - other grid types: the type's current rule description.
///
/// Meal is handled separately (manual no-photo entry dialog).
class QuickEntryTypeSettingsDialog extends ConsumerWidget {
  const QuickEntryTypeSettingsDialog({
    super.key,
    required this.action,
    required this.l10n,
  });

  final RecordQuickAction action;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs =
        ref.watch(quickEntryPreferencesProvider).asData?.value ??
        const QuickEntryPreferences();
    final label = recordCopy(l10n, action.titleKey);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: TypographyToken.level6.body(context)),
        const SizedBox(height: Spacing.level4),
        if (action.type == RecordEntryType.water)
          _WaterSettings(
            prefs: prefs,
            controller: ref.read(quickEntryPreferencesProvider.notifier),
            l10n: l10n,
          )
        else if (action.type == RecordEntryType.symptom)
          _SymptomSettings(
            prefs: prefs,
            controller: ref.read(quickEntryPreferencesProvider.notifier),
            l10n: l10n,
          )
        else
          Text(
            _ruleText(l10n, action.type),
            style: TypographyToken.level4.body(context),
          ),
        const SizedBox(height: Spacing.level5),
        Align(
          alignment: Alignment.centerRight,
          child: FButton(
            variant: FButtonVariant.ghost,
            onPress: () => Navigator.of(context).pop(),
            child: Text(l10n.commonConfirm),
          ),
        ),
      ],
    );
  }

  String _ruleText(AppLocalizations l10n, RecordEntryType type) {
    return switch (type) {
      RecordEntryType.medication => l10n.recordQuickSettingsMedicationRule,
      RecordEntryType.symptom => l10n.recordQuickSettingsSymptomRule,
      RecordEntryType.mood => l10n.recordQuickSettingsMoodRule,
      RecordEntryType.sleep => l10n.recordQuickSettingsSleepRule,
      RecordEntryType.water => l10n.recordQuickSettingsWaterDefault,
      _ => l10n.recordQuickSettingsMealRule,
    };
  }
}

class _SymptomSettings extends StatelessWidget {
  const _SymptomSettings({
    required this.prefs,
    required this.controller,
    required this.l10n,
  });

  final QuickEntryPreferences prefs;
  final QuickEntryPreferencesController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final severityOptions = _symptomSeverityOptions(l10n);
    final allChoices = recordFastEntryChoicesFor(DailyRecordKind.symptom, l10n);
    final enabledSet = prefs.symptomEnabledChoices.toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FSelect<String>.rich(
          key: const Key('quick-type-symptom-severity'),
          label: Text(l10n.recordQuickSettingsSymptomDefaultSeverity),
          format: (value) => _severityLabel(l10n, value),
          control: FSelectControl.lifted(
            value: prefs.symptomDefaultSeverity,
            onChange: (value) {
              if (value != null) {
                unawaited(controller.setSymptomDefaultSeverity(value));
              }
            },
          ),
          children: [
            for (final option in severityOptions)
              FSelectItem.item(
                title: Text(_severityLabel(l10n, option)),
                value: option,
              ),
          ],
        ),
        const SizedBox(height: Spacing.level3),
        Text(
          l10n.recordQuickSettingsSymptomChoices,
          style: TypographyToken.level4.body(context),
        ),
        const SizedBox(height: Spacing.level2),
        Wrap(
          spacing: Spacing.level2,
          runSpacing: Spacing.level2,
          children: [
            for (final choice in allChoices)
              FilterChip(
                label: Text(choice.label),
                selected:
                    enabledSet.isEmpty || enabledSet.contains(choice.title),
                onSelected: (selected) {
                  final current = Set<String>.from(
                    prefs.symptomEnabledChoices.isEmpty
                        ? allChoices.map((c) => c.title ?? c.label)
                        : prefs.symptomEnabledChoices,
                  );
                  if (selected) {
                    current.add(choice.title ?? choice.label);
                  } else {
                    current.remove(choice.title ?? choice.label);
                  }
                  unawaited(
                    controller.setSymptomEnabledChoices(current.toList()),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  List<String> _symptomSeverityOptions(AppLocalizations l10n) => [
    'mild',
    'moderate',
    'severe',
  ];

  String _severityLabel(AppLocalizations l10n, String value) {
    return switch (value) {
      'moderate' => l10n.recordFastChoiceSeverityModerate,
      'severe' => l10n.recordFastChoiceSeveritySevere,
      _ => l10n.recordFastChoiceSeverityMild,
    };
  }
}

class _WaterSettings extends StatelessWidget {
  const _WaterSettings({
    required this.prefs,
    required this.controller,
    required this.l10n,
  });

  final QuickEntryPreferences prefs;
  final QuickEntryPreferencesController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FSelect<QuickEntryWaterDefault>.rich(
          key: const Key('quick-type-water-default'),
          label: Text(l10n.recordQuickSettingsWaterDefault),
          format: (value) => waterDefaultOptionLabel(
            l10n,
            value,
            customMl: prefs.waterCustomMl,
          ),
          control: FSelectControl.lifted(
            value: prefs.waterDefault,
            onChange: (value) {
              if (value != null) {
                unawaited(
                  handleWaterDefaultSelect(
                    context,
                    value: value,
                    prefs: prefs,
                    controller: controller,
                  ),
                );
              }
            },
          ),
          children: [
            for (final option in QuickEntryWaterDefault.values)
              FSelectItem.item(
                title: Text(
                  waterDefaultOptionLabel(
                    l10n,
                    option,
                    customMl: prefs.waterCustomMl,
                  ),
                ),
                value: option,
              ),
          ],
        ),
        const SizedBox(height: Spacing.level3),
        FSelect<QuickEntryWaterBadgeMode>.rich(
          key: const Key('quick-type-water-badge'),
          label: Text(l10n.recordQuickSettingsWaterBadge),
          format: (value) => waterBadgeLabel(l10n, value),
          control: FSelectControl.lifted(
            value: prefs.waterBadgeMode,
            onChange: (value) {
              if (value != null) {
                unawaited(controller.setWaterBadgeMode(value));
              }
            },
          ),
          children: [
            for (final mode in QuickEntryWaterBadgeMode.values)
              FSelectItem.item(
                title: Text(waterBadgeLabel(l10n, mode)),
                value: mode,
              ),
          ],
        ),
      ],
    );
  }
}
