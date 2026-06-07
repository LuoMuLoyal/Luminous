part of 'medicine_mobile_dashboard_view.dart';

class _DrugBoxSection extends StatelessWidget {
  const _DrugBoxSection({
    required this.workspace,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final MedicineWorkspace workspace;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final items = workspace.plan.items.take(2).toList(growable: false);

    return MedicinePanel(
      key: const Key('medicine-hero'),
      color: Color.alphaBlend(
        MedicinePalette.tealSoft.withValues(alpha: 0.16),
        surface.canvas,
      ),
      borderColor: MedicinePalette.teal.withValues(alpha: 0.28),
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicineSectionHeader(
            title: l10n.medicineDrugboxTitle,
            compact: true,
            leading: const MedicineIconBadge(
              icon: Icons.medical_services_rounded,
              color: AppColorTokens.onPrimary,
              backgroundColor: MedicinePalette.teal,
              size: AppSpacingTokens.x2l,
              iconSize: AppSpacingTokens.lg,
            ),
            trailing: MedicineTextAction(
              label: l10n.medicineManageMedicinesAction,
              onTap: () =>
                  AppToast.show(context, l10n.medicineManageMedicinesAction),
            ),
          ),
          const SizedBox(height: AppSpacingTokens.xxs),
          Text(
            l10n.medicineDrugboxSubtitle,
            style: typography.bodySm.copyWith(
              color: surface.body,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          if (items.isEmpty)
            _DrugBoxEmpty(l10n: l10n, typography: typography, surface: surface)
          else
            Column(
              children: [
                for (var index = 0; index < items.length; index += 1) ...[
                  _DrugBoxMedicationRow(
                    item: items[index],
                    l10n: l10n,
                    typography: typography,
                    surface: surface,
                  ),
                  if (index < items.length - 1)
                    const SizedBox(height: AppSpacingTokens.sm),
                ],
              ],
            ),
          const SizedBox(height: AppSpacingTokens.md),
          Row(
            children: [
              Text(
                l10n.medicineDrugboxTotalPrefix,
                style: typography.bodySm.copyWith(
                  color: surface.body,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: AppSpacingTokens.xs),
              Text(
                l10n.medicineDrugboxTotal(workspace.plan.items.length),
                style: typography.bodySmStrong.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.check_circle_outline_rounded,
                color: MedicinePalette.teal,
                size: AppSpacingTokens.md,
              ),
              const SizedBox(width: AppSpacingTokens.xxs),
              Flexible(
                child: Text(
                  l10n.medicineExpiredReminderEnabled,
                  style: typography.bodySm.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: surface.mute,
                size: AppSpacingTokens.lg,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrugBoxEmpty extends StatelessWidget {
  const _DrugBoxEmpty({
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return MedicinePanel(
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      shadow: const <BoxShadow>[],
      borderColor: surface.hairline,
      child: Row(
        children: [
          const MedicineIconBadge(
            icon: Icons.medication_outlined,
            color: MedicinePalette.teal,
            shape: BoxShape.circle,
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicineNoMedicineTitle,
                  style: typography.bodyMdStrong,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  l10n.medicineNoMedicineBody,
                  style: typography.bodySm.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrugBoxMedicationRow extends StatelessWidget {
  const _DrugBoxMedicationRow({
    required this.item,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final MedicinePlanItem item;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final name = _itemName(l10n, item);
    final dosage = _itemDosage(l10n, item);
    final schedule = _itemSchedule(l10n, item);
    final state = _itemState(l10n, item);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AppToast.show(context, l10n.medicineOpenPlanItemToast),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: MedicinePanel(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.md,
            vertical: AppSpacingTokens.sm,
          ),
          shadow: const <BoxShadow>[],
          borderColor: surface.hairline,
          child: Row(
            children: [
              _MedicationAvatar(item: item, size: AppSpacingTokens.x4l),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonText(
                      text: name,
                      style: typography.displaySm.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widthFactor: 0.72,
                    ),
                    const SizedBox(height: AppSpacingTokens.xs),
                    Wrap(
                      spacing: AppSpacingTokens.xs,
                      runSpacing: AppSpacingTokens.xxs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        AppSkeletonText(
                          text: _compactRouteOrSchedule(schedule),
                          style: typography.bodySm.copyWith(
                            color: surface.body,
                            letterSpacing: 0,
                          ),
                          widthFactor: 0.58,
                        ),
                        AppSkeletonSlot(
                          skeleton: const AppInlineSkeletonBlock(
                            height: 22,
                            width: 54,
                            radius: AppRadiusTokens.pill,
                          ),
                          child: MedicineStatusPill(
                            label: state,
                            color: item.stateColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppSkeletonText(
                    text: dosage,
                    style: typography.displaySm.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    widthFactor: 0.66,
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  AppSkeletonText(
                    text: schedule,
                    style: typography.bodySm.copyWith(
                      color: surface.body,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    widthFactor: 0.84,
                  ),
                ],
              ),
              const SizedBox(width: AppSpacingTokens.xs),
              Icon(
                Icons.chevron_right_rounded,
                color: surface.mute,
                size: AppSpacingTokens.lg,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
