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
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSectionHeader(
              title: l10n.medicineDrugboxTitle,
              compact: true,
              leading: AppIconBadge(
                icon: FLucideIcons.briefcaseMedical,
                color: Color(0xFF0F766E),
                backgroundColor: Color(0xFF0F766E).withValues(alpha: 0.12),
                size: AppSpacingTokens.level7,
                iconSize: AppSpacingTokens.level5,
              ),
              trailing: AppTextAction(
                label: l10n.medicineManageMedicinesAction,
                onTap: () =>
                    pushAuthRequiredRoute(context, '/mine/medicine/new'),
              ),
            ),
            const SizedBox(height: AppSpacingTokens.level1),
            Text(
              l10n.medicineDrugboxSubtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacingTokens.level4),
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
                  const SizedBox(width: AppSpacingTokens.level3),
                  SizedBox(
                    height: AppSpacingTokens.level10,
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: colors.border,
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.level3),
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
                                  AppSpacingTokens.level7 + AppSpacingTokens.level3,
                              color: colors.border,
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacingTokens.level3),
            Divider(height: 1, thickness: 1, color: colors.border),
            const SizedBox(height: AppSpacingTokens.level3),
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
      width: AppSpacingTokens.level9,
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
          const SizedBox(height: AppSpacingTokens.level1),
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
                color: Color(0xFF0F766E),
                label: l10n.medicineNextDoseReminderTitle,
                value: value,
                detail: detail,
              ),
            ),
            const _MetricDivider(),
            Expanded(
              child: _DrugBoxMetricItem(
                icon: FLucideIcons.badgeCheck,
                color: Color(0xFF0F766E),
                label: l10n.medicineHeroMetricAdherenceLabel,
                value: workspace.hero.metricAdherence,
                detail: l10n.medicineDoseDueStatus,
              ),
            ),
          ],
        ),
        if (canMark) ...[
          const SizedBox(height: AppSpacingTokens.level3),
          Row(
            children: [
              _DoseActionButton(
                key: const Key('medicine-next-dose-action-taken'),
                label: l10n.medicineDoseActionTaken,
                icon: FLucideIcons.check,
                color: Color(0xFF0F766E),
                filled: true,
                onTap: () =>
                    onMarkDose!(currentMedicineId, MedicineDoseAction.taken),
              ),
              const SizedBox(width: AppSpacingTokens.level3),
              _DoseActionButton(
                key: const Key('medicine-next-dose-action-skipped'),
                label: l10n.medicineDoseActionSkipped,
                icon: FLucideIcons.ban,
                color: Color(0xFFB45309),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.level1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color.withValues(alpha: 0.78), size: 16),
              const SizedBox(width: AppSpacingTokens.level1),
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
          const SizedBox(height: AppSpacingTokens.level1),
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
          const SizedBox(height: AppSpacingTokens.level1),
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
      height: AppSpacingTokens.level9,
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.level2),
      child: Row(
        children: [
          AppIconBadge(
            icon: FLucideIcons.pillBottle,
            color: Color(0xFF0F766E),
            backgroundColor: Color(0xFF0F766E).withValues(alpha: 0.12),
            shape: BoxShape.circle,
            size: AppSpacingTokens.level8,
            iconSize: AppSpacingTokens.level5,
          ),
          const SizedBox(width: AppSpacingTokens.level4),
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
                const SizedBox(height: AppSpacingTokens.level1),
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

    return FTappable(
      onPress: () {
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
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level2,
          vertical: AppSpacingTokens.level3,
        ),
        child: Row(
          children: [
            _MedicationAvatar(item: item, size: AppSpacingTokens.level7),
            const SizedBox(width: AppSpacingTokens.level3),
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
                  const SizedBox(height: AppSpacingTokens.level1),
                  Wrap(
                    spacing: AppSpacingTokens.level2,
                    runSpacing: AppSpacingTokens.level1,
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
                          radius: AppRadiusTokens.levelFull,
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
            const SizedBox(width: AppSpacingTokens.level2),
            Icon(
              FLucideIcons.chevronRight,
              color: colors.mutedForeground,
              size: AppSpacingTokens.level5,
            ),
          ],
        ),
      ),
    );
  }
}