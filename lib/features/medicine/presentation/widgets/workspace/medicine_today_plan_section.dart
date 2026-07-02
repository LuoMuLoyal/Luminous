import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/widgets/common/app_status_pill.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_copy.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_workspace_parts.dart';
import 'package:luminous/features/medicine/presentation/widgets/workspace/medicine_workspace_helpers.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineTodayPlanSection extends StatelessWidget {
  const MedicineTodayPlanSection({
    super.key,
    required this.workspace,
    required this.l10n,
    required this.onMarkDose,
  });

  final MedicineWorkspace workspace;
  final AppLocalizations l10n;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context) {
    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Column(
          children: [
            for (var index = 0; index < workspace.plan.items.length; index += 1)
              Padding(
                padding: EdgeInsets.only(
                  bottom: index == workspace.plan.items.length - 1
                      ? 0
                      : AppSpacingTokens.level4,
                ),
                child: _MedicationPlanTile(
                  item: workspace.plan.items[index],
                  l10n: l10n,
                  onMarkDose: onMarkDose,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MedicationPlanTile extends StatelessWidget {
  const _MedicationPlanTile({
    required this.item,
    required this.l10n,
    required this.onMarkDose,
  });

  final MedicinePlanItem item;
  final AppLocalizations l10n;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final nameText = item.rawName ?? medicineCopy(l10n, item.nameKey);
    final dosageText = item.rawDosage ?? medicineCopy(l10n, item.dosageKey);
    final scheduleText =
        item.rawSchedule ?? medicineCopy(l10n, item.scheduleKey);
    final stateText = item.rawState ?? medicineCopy(l10n, item.stateKey);
    final currentMedicineId = item.currentMedicineId;

    return FTappable(
      onPress: () =>
          showPlannedAction(context, nameText, l10n.medicineOpenPlanItemToast),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
          border: Border.all(color: colors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.level4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nameText,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacingTokens.level2),
                        Text(
                          '$dosageText · $scheduleText',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.level3),
                  AppStatusPill(
                    label: stateText,
                    color: item.stateColor,
                    radius: AppRadiusTokens.levelFull,
                    large: true,
                  ),
                ],
              ),
              if (currentMedicineId != null && onMarkDose != null) ...[
                const SizedBox(height: AppSpacingTokens.level3),
                Row(
                  children: [
                    Expanded(
                      child: FButton(
                        variant: FButtonVariant.outline,
                        onPress: () => onMarkDose!(
                          currentMedicineId,
                          MedicineDoseAction.taken,
                        ),
                        prefix: const Icon(FLucideIcons.check, size: 16),
                        child: Text(l10n.medicineDoseActionTaken),
                      ),
                    ),
                    const SizedBox(width: AppSpacingTokens.level3),
                    Expanded(
                      child: FButton(
                        variant: FButtonVariant.outline,
                        onPress: () => onMarkDose!(
                          currentMedicineId,
                          MedicineDoseAction.skipped,
                        ),
                        prefix: const Icon(FLucideIcons.ban, size: 16),
                        child: Text(l10n.medicineDoseActionSkipped),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
