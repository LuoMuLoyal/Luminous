import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/review/presentation/providers/clinic_summary.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Per-field privacy toggles: 事件概况 / 症状变化 / 用药槽位 / 饮水 / 睡眠 /
/// 备注. The free-text notes field defaults to off; the last remaining
/// selected field cannot be toggled off (an empty selection is impossible).
class ClinicSummaryFieldSelectionPanel extends StatelessWidget {
  const ClinicSummaryFieldSelectionPanel({
    super.key,
    required this.selectedFields,
    required this.enabled,
    required this.onChanged,
  });

  final List<PreviewClinicSummaryRequestSelectedFieldsEnum> selectedFields;

  /// Whether the toggles can be changed. Disabled once the share link is
  /// created/revoked, so the preview cannot silently change behind the
  /// shown link.
  final bool enabled;

  final ValueChanged<List<PreviewClinicSummaryRequestSelectedFieldsEnum>>
  onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviewClinicSummaryFieldSectionTitle,
          style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: Spacing.level2),
        for (final field in kClinicSummaryAllFields) ...[
          ClinicSummaryFieldToggle(
            key: Key('clinic-summary-field-${field.value}'),
            label: _fieldLabel(l10n, field),
            selected: selectedFields.contains(field),
            // The last remaining selection cannot be disabled — an empty
            // field selection is rejected by the server.
            enabled:
                enabled &&
                (selectedFields.contains(field)
                    ? selectedFields.length > 1
                    : true),
            onChanged: (value) => onChanged(
              value
                  ? [...selectedFields, field]
                  : ([...selectedFields]..remove(field)),
            ),
          ),
          if (field != kClinicSummaryAllFields.last)
            const SizedBox(height: Spacing.level1),
        ],
        const SizedBox(height: Spacing.level2),
        Text(
          l10n.reviewClinicSummaryFieldPrivacyHint,
          style: typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
      ],
    );
  }

  String _fieldLabel(
    AppLocalizations l10n,
    PreviewClinicSummaryRequestSelectedFieldsEnum field,
  ) {
    return switch (field) {
      PreviewClinicSummaryRequestSelectedFieldsEnum.eventOverview =>
        l10n.reviewClinicSummaryFieldEventOverview,
      PreviewClinicSummaryRequestSelectedFieldsEnum.symptomChanges =>
        l10n.reviewClinicSummaryFieldSymptomChanges,
      PreviewClinicSummaryRequestSelectedFieldsEnum.medicationSlots =>
        l10n.reviewClinicSummaryFieldMedicationSlots,
      PreviewClinicSummaryRequestSelectedFieldsEnum.water =>
        l10n.reviewClinicSummaryFieldWater,
      PreviewClinicSummaryRequestSelectedFieldsEnum.sleep =>
        l10n.reviewClinicSummaryFieldSleep,
      PreviewClinicSummaryRequestSelectedFieldsEnum.notes =>
        l10n.reviewClinicSummaryFieldNotes,
      PreviewClinicSummaryRequestSelectedFieldsEnum.unknownDefaultOpenApi =>
        field.value,
    };
  }
}

class ClinicSummaryFieldToggle extends StatelessWidget {
  const ClinicSummaryFieldToggle({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FCheckbox(
          value: selected,
          enabled: enabled,
          // The visible label is a separate Text in the row — expose it to
          // screen readers via the checkbox semantics (register.dart
          // pattern).
          semanticsLabel: label,
          onChange: enabled ? onChanged : null,
        ),
        const SizedBox(width: Spacing.level3),
        Expanded(child: Text(label, style: context.theme.typography.body.sm)),
      ],
    );
  }
}
