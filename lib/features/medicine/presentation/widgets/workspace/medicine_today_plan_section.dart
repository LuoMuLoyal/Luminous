import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/widgets/app_status_pill.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_copy.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_workspace_parts.dart';
import 'package:luminous/features/medicine/presentation/widgets/workspace/medicine_workspace_helpers.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineTodayPlanSection extends StatelessWidget {
  const MedicineTodayPlanSection({
    super.key,
    required this.workspace,
    required this.typography,
    required this.surface,
    required this.l10n,
    required this.onMarkDose,
  });

  final MedicineWorkspace workspace;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context) {
    return AppSectionSurface(
      title: l10n.medicineTodayPlanTitle,
      trailing: SectionTextAction(
        label:
            '${l10n.medicineTodayPlanInspectAction}(${workspace.plan.items.length})',
        typography: typography,
        surface: surface,
        onTap: () => showPlannedAction(
          context,
          l10n.medicineTodayPlanInspectAction,
          l10n.medicineViewPlanToast,
        ),
      ),
      typography: typography,
      surface: surface,
      child: Column(
        children: [
          for (var index = 0; index < workspace.plan.items.length; index += 1)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == workspace.plan.items.length - 1
                    ? 0
                    : AppSpacingTokens.md,
              ),
              child: _MedicationPlanTile(
                item: workspace.plan.items[index],
                typography: typography,
                surface: surface,
                l10n: l10n,
                onMarkDose: onMarkDose,
              ),
            ),
        ],
      ),
    );
  }
}

class _MedicationPlanTile extends StatelessWidget {
  const _MedicationPlanTile({
    required this.item,
    required this.typography,
    required this.surface,
    required this.l10n,
    required this.onMarkDose,
  });

  final MedicinePlanItem item;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context) {
    final nameText = item.rawName ?? medicineCopy(l10n, item.nameKey);
    final dosageText = item.rawDosage ?? medicineCopy(l10n, item.dosageKey);
    final scheduleText =
        item.rawSchedule ?? medicineCopy(l10n, item.scheduleKey);
    final stateText = item.rawState ?? medicineCopy(l10n, item.stateKey);
    final currentMedicineId = item.currentMedicineId;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showPlannedAction(
          context,
          nameText,
          l10n.medicineOpenPlanItemToast,
        ),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
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
                            style: typography.bodyMdStrong.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppSpacingTokens.xs),
                          Text(
                            '$dosageText · $scheduleText',
                            style: typography.bodySm.copyWith(
                              color: surface.body,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacingTokens.sm),
                    AppStatusPill(
                      label: stateText,
                      color: item.stateColor,
                      typography: typography,
                      radius: AppRadiusTokens.pill,
                      large: true,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.md),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: surface.canvasSoft,
                    borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
                    border: Border.all(color: surface.hairline),
                  ),
                  child: Column(
                    children: [
                      if (item.slots.isEmpty)
                        _DosePlaceholderRow(typography: typography, l10n: l10n)
                      else
                        for (
                          var index = 0;
                          index < item.slots.length;
                          index += 1
                        )
                          _DoseSlotRow(
                            slot: item.slots[index],
                            typography: typography,
                            surface: surface,
                            l10n: l10n,
                            showDivider: index < item.slots.length - 1,
                          ),
                    ],
                  ),
                ),
                if (currentMedicineId != null && onMarkDose != null) ...[
                  const SizedBox(height: AppSpacingTokens.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _DoseActionButton(
                          label: l10n.medicineDoseActionTaken,
                          icon: Icons.check_rounded,
                          color: MedicineWorkspacePalette.green,
                          typography: typography,
                          onTap: () => onMarkDose!(
                            currentMedicineId,
                            MedicineDoseAction.taken,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      Expanded(
                        child: _DoseActionButton(
                          label: l10n.medicineDoseActionSkipped,
                          icon: Icons.remove_done_rounded,
                          color: MedicineWorkspacePalette.orange,
                          typography: typography,
                          onTap: () => onMarkDose!(
                            currentMedicineId,
                            MedicineDoseAction.skipped,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoseActionButton extends StatelessWidget {
  const _DoseActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.typography,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final AppTypographyScale typography;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        textStyle: typography.bodySmStrong,
        side: BorderSide(color: color.withValues(alpha: 0.34)),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.sm,
          vertical: AppSpacingTokens.sm,
        ),
      ),
    );
  }
}

class _DoseSlotRow extends StatelessWidget {
  const _DoseSlotRow({
    required this.slot,
    required this.typography,
    required this.surface,
    required this.l10n,
    required this.showDivider,
  });

  final MedicineDoseSlot slot;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final isTaken = slot.status == MedicineDoseStatus.taken;
    final color = isTaken
        ? MedicineWorkspacePalette.green
        : MedicineWorkspacePalette.orange;
    final icon = isTaken ? Icons.check_circle_rounded : Icons.schedule_rounded;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.md,
            vertical: AppSpacingTokens.sm,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                child: Text(
                  slotTimeLabel(l10n, slot),
                  style: typography.bodySmStrong,
                ),
              ),
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Text(
                  medicineCopy(l10n, slot.statusKey),
                  style: typography.bodySm.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacingTokens.md,
              right: AppSpacingTokens.md,
            ),
            child: Divider(height: 1, color: surface.hairline),
          ),
      ],
    );
  }
}

class _DosePlaceholderRow extends StatelessWidget {
  const _DosePlaceholderRow({required this.typography, required this.l10n});

  final AppTypographyScale typography;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              l10n.medicineScheduleNotSet,
              style: typography.bodySmStrong,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(
            Icons.schedule_rounded,
            color: MedicineWorkspacePalette.orange,
            size: 20,
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Text(
              l10n.medicineRecordScheduledStatus,
              style: typography.bodySm.copyWith(
                color: MedicineWorkspacePalette.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
