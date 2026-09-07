import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/section_label.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// The editable form for a current medicine entry.
///
/// Renders the medicine info, dosage, and timeline sections (display name,
/// strength, dose, route, started-at date, note) plus the save/delete
/// actions. State lives in the owning page; this widget only renders.
class CurrentMedicineForm extends StatelessWidget {
  const CurrentMedicineForm({
    super.key,
    required this.l10n,
    required this.displayNameController,
    required this.strengthTextController,
    required this.doseTextController,
    required this.routeController,
    required this.startedAt,
    required this.onStartedAtChanged,
    required this.noteController,
    required this.onSave,
    required this.onDelete,
    required this.showDelete,
  });

  final AppLocalizations l10n;
  final TextEditingController displayNameController;
  final TextEditingController strengthTextController;
  final TextEditingController doseTextController;
  final TextEditingController routeController;
  final DateTime? startedAt;
  final ValueChanged<DateTime?> onStartedAtChanged;
  final TextEditingController noteController;
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final bool showDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group 1 — 药品信息
        SettingsSectionLabel(label: l10n.mineEditMedicineSectionInfo),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FTextField(
                  key: const Key('medicine-displayname-field'),
                  control: FTextFieldControl.managed(
                    controller: displayNameController,
                  ),
                  label: Text(l10n.mineEditFieldDisplayName),
                ),
                const SizedBox(height: Spacing.level3),
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: strengthTextController,
                  ),
                  label: Text(l10n.mineEditFieldStrengthText),
                  hint: l10n.mineEditFieldStrengthTextHint,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.level5),

        // Group 2 — 用法用量
        SettingsSectionLabel(label: l10n.mineEditMedicineSectionDosage),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: doseTextController,
                  ),
                  label: Text(l10n.mineEditFieldDoseText),
                  hint: l10n.mineEditFieldDoseTextHint,
                ),
                const SizedBox(height: Spacing.level2),
                Wrap(
                  spacing: Spacing.level2,
                  runSpacing: Spacing.level2,
                  children: [
                    for (final v in [
                      l10n.mineEditDoseQuick1Tablet,
                      l10n.mineEditDoseQuick2Tablets,
                      l10n.mineEditDoseQuick5ml,
                      l10n.mineEditDoseQuick10ml,
                    ])
                      QuickSelectChip(
                        label: v,
                        onTap: () => doseTextController.text = v,
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.level3),
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: routeController,
                  ),
                  label: Text(l10n.mineEditFieldRoute),
                  hint: l10n.mineEditFieldRouteHint,
                ),
                const SizedBox(height: Spacing.level2),
                Wrap(
                  spacing: Spacing.level2,
                  runSpacing: Spacing.level2,
                  children: [
                    for (final v in [
                      l10n.mineEditRouteQuickOral,
                      l10n.mineEditRouteQuickTopical,
                      l10n.mineEditRouteQuickInhaled,
                      l10n.mineEditRouteQuickInjection,
                    ])
                      QuickSelectChip(
                        label: v,
                        onTap: () => routeController.text = v,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Spacing.level5),

        // Group 3 — 时间与备注
        SettingsSectionLabel(label: l10n.mineEditMedicineSectionTimeline),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FDateField.calendar(
                  key: const Key('medicine-started-at-field'),
                  label: Text(l10n.mineEditFieldStartedAt),
                  selectionControl: FDateSelectionControl.managedSingle(
                    initial: startedAt,
                    toggleable: true,
                    onChange: onStartedAtChanged,
                  ),
                ),
                const SizedBox(height: Spacing.level3),
                FTextField(
                  control: FTextFieldControl.managed(
                    controller: noteController,
                  ),
                  label: Text(l10n.mineEditFieldNote),
                  maxLines: 3,
                ),
                const SizedBox(height: Spacing.level5),
                FButton(
                  key: const Key('medicine-save-button'),
                  onPress: onSave,
                  child: Text(l10n.mineEditSaveAction),
                ),
                if (showDelete) ...[
                  const SizedBox(height: Spacing.level3),
                  FButton(
                    key: const Key('medicine-delete-button'),
                    variant: FButtonVariant.destructive,
                    onPress: () async {
                      final confirmed = await showDangerConfirmationDialog(
                        context: context,
                        title: l10n.mineEditDeleteConfirmTitle,
                        message: l10n.mineEditDeleteConfirmMessage,
                        confirmLabel: l10n.mineEditDeleteAction,
                      );
                      if (confirmed) onDelete();
                    },
                    child: Text(l10n.mineEditDeleteAction),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A small tappable chip that fills a quick-select value into a text field.
class QuickSelectChip extends StatelessWidget {
  const QuickSelectChip({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FTappable(
      onPress: onTap,
      builder: (context, data, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: SemanticColor.neutral.subtle(context),
          borderRadius: context.theme.style.borderRadius.md,
          border: Border.all(color: SemanticColor.neutral.border(context)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.level3,
            vertical: Spacing.level1,
          ),
          child: Text(
            label,
            style: context.theme.typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ),
      ),
    );
  }
}
