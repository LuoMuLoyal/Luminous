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
            Row(
              children: [
                Container(
                  width: AppSpacingTokens.level7,
                  height: AppSpacingTokens.level7,
                  decoration: BoxDecoration(
                    color: AppColors.primary
                        .resolve(colors)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadiusTokens.level4),
                  ),
                  child: Center(
                    child: Icon(
                      FLucideIcons.briefcaseMedical,
                      color: AppColors.primary.resolve(colors),
                      size: AppSpacingTokens.level5,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.level2),
                Expanded(
                  child: Text(
                    l10n.medicineDrugboxTitle,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.level3),
                FButton(
                  variant: FButtonVariant.ghost,
                  size: FButtonSizeVariant.xs,
                  mainAxisSize: MainAxisSize.min,
                  onPress: () =>
                      pushAuthRequiredRoute(context, '/mine/medicine/new'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.medicineManageMedicinesAction,
                        style: TextStyle(
                          color: colors.foreground,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: AppSpacingTokens.level1),
                      Icon(
                        FLucideIcons.chevronRight,
                        size: AppSpacingTokens.level4,
                        color: colors.foreground,
                      ),
                    ],
                  ),
                ),
              ],
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
                    child: AppDivider(
                      axis: Axis.vertical,
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
                            AppDivider(color: colors.border),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: AppSpacingTokens.level3),
            AppDivider(color: colors.border),
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
                icon: FLucideIcons.clock,
                color: AppColors.primary,
                label: l10n.medicineNextDoseReminderTitle,
                value: value,
                detail: detail,
              ),
            ),
            const _MetricDivider(),
            Expanded(
              child: _DrugBoxMetricItem(
                icon: FLucideIcons.badgeCheck,
                color: AppColors.primary,
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
                color: AppColors.primary,
                filled: true,
                onTap: () =>
                    onMarkDose!(currentMedicineId, MedicineDoseAction.taken),
              ),
              const SizedBox(width: AppSpacingTokens.level3),
              _DoseActionButton(
                key: const Key('medicine-next-dose-action-skipped'),
                label: l10n.medicineDoseActionSkipped,
                icon: FLucideIcons.ban,
                color: AppColors.primary,
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
  final AppColors color;
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
              Icon(
                icon,
                color: color.resolve(colors).withValues(alpha: 0.78),
                size: 16,
              ),
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
              color: color.resolve(colors).withValues(alpha: 0.92),
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
      child: AppDivider(axis: Axis.vertical, color: colors.border),
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
          FAvatar.raw(
            size: AppSpacingTokens.level8,
            child: Icon(
              FLucideIcons.pillBottle,
              color: AppColors.primary.resolve(colors),
              size: AppSpacingTokens.level5,
            ),
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
                        child: FBadge.raw(
                          builder: (context, style) {
                            final resolvedColor = item.stateColor.resolve(
                              colors,
                            );
                            final foreground = 0.12 > 0.5
                                ? colors.primaryForeground
                                : resolvedColor;
                            return DecoratedBox(
                              decoration: ShapeDecoration(
                                color: resolvedColor.withValues(alpha: 0.12),
                                shape: RoundedSuperellipseBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadiusTokens.level2,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacingTokens.level2,
                                  vertical: AppSpacingTokens.level1,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      state,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: foreground,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
