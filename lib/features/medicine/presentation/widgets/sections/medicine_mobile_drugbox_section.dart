part of '../views/medicine_mobile_dashboard_view.dart';

class _DrugBoxSection extends StatelessWidget {
  const _DrugBoxSection({
    required this.workspace,
    required this.nextDose,
    required this.l10n,
    required this.onMarkDose,
    required this.onOpenReminder,
  });

  final MedicineWorkspace workspace;
  final _NextDose? nextDose;
  final AppLocalizations l10n;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;
  final void Function(String currentMedicineId)? onOpenReminder;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final items = workspace.plan.items
        .where((item) => item.currentMedicineId != null)
        .take(2)
        .toList(growable: false);

    return FCard.raw(
      key: const Key('medicine-hero'),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: l10n.medicineDrugboxTitle,
              compact: true,
              leading: AppIconBadge(
                icon: FLucideIcons.briefcaseMedical,
                color: AppColorTokens.cyanDeep,
                backgroundColor: AppColorTokens.cyanDeep.withValues(
                  alpha: 0.12,
                ),
                size: AppSpacingTokens.x2l,
                iconSize: AppSpacingTokens.lg,
              ),
              trailing: AppTextAction(
                label: l10n.medicineManageMedicinesAction,
                onTap: () =>
                    pushAuthRequiredRoute(context, '/mine/medicine/new'),
              ),
            ),
            const SizedBox(height: AppSpacingTokens.xxs),
            Text(
              l10n.medicineDrugboxSubtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            if (items.isEmpty)
              _DrugBoxEmpty(l10n: l10n)
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DrugBoxCountSummary(
                    count: workspace.plan.items.length,
                    l10n: l10n,
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  SizedBox(
                    height: AppSpacingTokens.x5l,
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: colors.border,
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Expanded(
                    child: Column(
                      children: [
                        for (
                          var index = 0;
                          index < items.length;
                          index += 1
                        ) ...[
                          _DrugBoxMedicationRow(
                            item: items[index],
                            l10n: l10n,
                            onOpenReminder: onOpenReminder,
                          ),
                          if (index < items.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent:
                                  AppSpacingTokens.x2l + AppSpacingTokens.sm,
                              color: colors.border,
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacingTokens.sm),
            Divider(height: 1, thickness: 1, color: colors.border),
            const SizedBox(height: AppSpacingTokens.sm),
            _DrugBoxReminderStrip(
              key: const Key('medicine-next-reminder'),
              workspace: workspace,
              nextDose: nextDose,
              l10n: l10n,
              onMarkDose: onMarkDose,
            ),
          ],
        ),
      ),
    );
  }
}

class _DrugBoxCountSummary extends StatelessWidget {
  const _DrugBoxCountSummary({required this.count, required this.l10n});

  final int count;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: AppSpacingTokens.x4l,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonText(
            text: l10n.medicineDrugboxTotal(count),
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            widthFactor: 0.72,
          ),
          const SizedBox(height: AppSpacingTokens.xxs),
          Text(
            l10n.medicineDrugboxTotalPrefix,
            style: textTheme.bodySmall?.copyWith(color: colors.mutedForeground),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DrugBoxReminderStrip extends StatelessWidget {
  const _DrugBoxReminderStrip({
    super.key,
    required this.workspace,
    required this.nextDose,
    required this.l10n,
    required this.onMarkDose,
  });

  final MedicineWorkspace workspace;
  final _NextDose? nextDose;
  final AppLocalizations l10n;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context) {
    final dose = nextDose;
    final item = dose?.item;
    final hasAnyMedicine = workspace.plan.items.isNotEmpty;
    final slot = dose?.slot;
    final value = item == null
        ? (hasAnyMedicine
              ? l10n.medicineNoPendingDose
              : l10n.medicineScheduleNotSet)
        : slot == null
        ? l10n.medicineScheduleNotSet
        : l10n.medicineNextDoseTodayTime(_slotTimeLabel(l10n, slot));
    final detail = item == null
        ? (hasAnyMedicine
              ? l10n.medicineNoPendingDoseDetail
              : l10n.medicineNoMedicineBody)
        : _doseSummary(l10n, item);
    final currentMedicineId = item?.currentMedicineId;
    final canMark =
        currentMedicineId != null &&
        onMarkDose != null &&
        item?.todayStatus == MedicineDoseStatus.pending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DrugBoxMetricItem(
                icon: Icons.schedule_rounded,
                color: AppColorTokens.cyanDeep,
                label: l10n.medicineNextDoseReminderTitle,
                value: value,
                detail: detail,
              ),
            ),
            const _MetricDivider(),
            Expanded(
              child: _DrugBoxMetricItem(
                icon: FLucideIcons.badgeCheck,
                color: AppColorTokens.cyanDeep,
                label: l10n.medicineHeroMetricAdherenceLabel,
                value: workspace.hero.metricAdherence,
                detail: l10n.medicineDoseDueStatus,
              ),
            ),
          ],
        ),
        if (canMark) ...[
          const SizedBox(height: AppSpacingTokens.sm),
          Row(
            children: [
              _DoseActionButton(
                key: const Key('medicine-next-dose-action-taken'),
                label: l10n.medicineDoseActionTaken,
                icon: FLucideIcons.check,
                color: AppColorTokens.cyanDeep,
                filled: true,
                onTap: () =>
                    onMarkDose!(currentMedicineId, MedicineDoseAction.taken),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              _DoseActionButton(
                key: const Key('medicine-next-dose-action-skipped'),
                label: l10n.medicineDoseActionSkipped,
                icon: FLucideIcons.ban,
                color: AppColorTokens.warningDeep,
                onTap: () =>
                    onMarkDose!(currentMedicineId, MedicineDoseAction.skipped),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DrugBoxMetricItem extends StatelessWidget {
  const _DrugBoxMetricItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.detail,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color.withValues(alpha: 0.78), size: 16),
              const SizedBox(width: AppSpacingTokens.xxs),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.mutedForeground,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.xxs),
          AppSkeletonText(
            text: value,
            style: textTheme.titleMedium?.copyWith(
              color: color.withValues(alpha: 0.92),
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            widthFactor: 0.76,
          ),
          const SizedBox(height: AppSpacingTokens.xxs),
          AppSkeletonText(
            text: detail,
            style: textTheme.labelSmall?.copyWith(
              color: colors.mutedForeground,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            widthFactor: 0.88,
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return SizedBox(
      height: AppSpacingTokens.x4l,
      child: VerticalDivider(width: 1, thickness: 1, color: colors.border),
    );
  }
}

class _DrugBoxEmpty extends StatelessWidget {
  const _DrugBoxEmpty({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.xs),
      child: Row(
        children: [
          AppIconBadge(
            icon: FLucideIcons.pillBottle,
            color: AppColorTokens.cyanDeep,
            backgroundColor: AppColorTokens.cyanDeep.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            size: AppSpacingTokens.x3l,
            iconSize: AppSpacingTokens.lg,
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicineNoMedicineTitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  l10n.medicineNoMedicineBody,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.mutedForeground,
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
    required this.onOpenReminder,
  });

  final MedicinePlanItem item;
  final AppLocalizations l10n;
  final void Function(String currentMedicineId)? onOpenReminder;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final name = _itemName(l10n, item);
    final dosage = _itemDosage(l10n, item);
    final schedule = _itemSchedule(l10n, item);
    final state = _itemState(l10n, item);
    final currentMedicineId = item.currentMedicineId;

    return AppInkWell(
      onTap: () {
        if (currentMedicineId == null) {
          AppToast.show(context, l10n.medicineOpenPlanItemToast);
          return;
        }
        if (onOpenReminder != null) {
          onOpenReminder!(currentMedicineId);
          return;
        }
        context.push(
          '/medicine/reminders/${Uri.encodeComponent(currentMedicineId)}',
        );
      },
      borderRadius: BorderRadius.circular(AppRadiusTokens.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.xs,
          vertical: AppSpacingTokens.sm,
        ),
        child: Row(
          children: [
            _MedicationAvatar(item: item, size: AppSpacingTokens.x2l),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonText(
                    text: name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widthFactor: 0.72,
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Wrap(
                    spacing: AppSpacingTokens.xs,
                    runSpacing: AppSpacingTokens.xxs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppSkeletonText(
                        text: '$dosage · ${_compactRouteOrSchedule(schedule)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.mutedForeground,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        widthFactor: 0.66,
                      ),
                      AppSkeletonSlot(
                        skeleton: const AppInlineSkeletonBlock(
                          height: 22,
                          width: 54,
                          radius: AppRadiusTokens.pill,
                        ),
                        child: AppStatusPill(
                          label: state,
                          color: item.stateColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.xs),
            Icon(
              FLucideIcons.chevronRight,
              color: colors.mutedForeground,
              size: AppSpacingTokens.lg,
            ),
          ],
        ),
      ),
    );
  }
}
