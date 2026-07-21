part of '../views/mobile_dashboard_view.dart';

class _DrugBoxSection extends StatelessWidget {
  const _DrugBoxSection({
    required this.workspace,
    required this.l10n,
    required this.onOpenReminder,
  });

  final MedicineWorkspace workspace;
  final AppLocalizations l10n;
  final void Function(String currentMedicineId)? onOpenReminder;

  @override
  Widget build(BuildContext context) {
    final items = workspace.plan.items
        .where((item) => item.currentMedicineId != null)
        .toList(growable: false);

    return Column(
      key: const Key('medicine-current-medications'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineDrugboxTitle,
          style: TypographyToken.level7
              .display(context)
              .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
        ),
        const SizedBox(height: Spacing.level1),
        Text(
          l10n.medicineDrugboxSubtitle,
          style: TypographyToken.level3
              .body(context)
              .copyWith(color: context.theme.colors.mutedForeground),
        ),
        const SizedBox(height: Spacing.level3),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DrugBoxHeader(
                  l10n: l10n,
                  hasMedicines: items.isNotEmpty,
                  count: items.length,
                ),
                const SizedBox(height: Spacing.level4),
                if (items.isEmpty)
                  _DrugBoxEmpty(l10n: l10n)
                else
                  _DrugBoxContent(
                    items: items.take(3).toList(growable: false),
                    totalCount: items.length,
                    l10n: l10n,
                    onOpenReminder: onOpenReminder,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DrugBoxHeader extends StatelessWidget {
  const _DrugBoxHeader({
    required this.l10n,
    required this.hasMedicines,
    required this.count,
  });

  final AppLocalizations l10n;
  final bool hasMedicines;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Row(
      children: [
        Container(
          width: Spacing.level7,
          height: Spacing.level7,
          decoration: BoxDecoration(
            color: SemanticColor.primary.muted(context),
            borderRadius: BorderRadius.circular(RadiusTokens.level4),
          ),
          child: Center(
            child: Icon(
              FLucideIcons.briefcaseMedical,
              color: SemanticColor.primary.solid(context),
              size: Spacing.level5,
            ),
          ),
        ),
        const SizedBox(width: Spacing.level2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.medicineDrugboxTotal(count),
                style: TypographyToken.level5
                    .body(context)
                    .copyWith(fontWeight: FontWeight.w800, letterSpacing: 0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.level1),
              Text(
                l10n.medicineDrugboxTotalPrefix,
                style: TypographyToken.level3
                    .body(context)
                    .copyWith(color: colors.mutedForeground),
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.level3),
        FButton(
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.xs,
          mainAxisSize: MainAxisSize.min,
          onPress: () => pushAuthRequiredRoute(
            context,
            hasMedicines ? AppRoutes.mineMedicineNew : AppRoutes.medicineSearch,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasMedicines
                    ? l10n.medicineManageMedicinesAction
                    : l10n.medicineQuickAddTitle,
                style: TextStyle(
                  color: colors.foreground,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: Spacing.level1),
              Icon(
                FLucideIcons.chevronRight,
                size: Spacing.level4,
                color: colors.foreground,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DrugBoxContent extends StatelessWidget {
  const _DrugBoxContent({
    required this.items,
    required this.totalCount,
    required this.l10n,
    required this.onOpenReminder,
  });

  final List<MedicinePlanItem> items;
  final int totalCount;
  final AppLocalizations l10n;
  final void Function(String currentMedicineId)? onOpenReminder;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DrugBoxCountSummary(count: totalCount, l10n: l10n),
        const SizedBox(width: Spacing.level3),
        const SizedBox(
          height: Spacing.level10,
          child: AppDivider(axis: Axis.vertical),
        ),
        const SizedBox(width: Spacing.level3),
        Expanded(
          child: Column(
            children: [
              for (var index = 0; index < items.length; index += 1) ...[
                _DrugBoxMedicationRow(
                  item: items[index],
                  l10n: l10n,
                  onOpenReminder: onOpenReminder,
                ),
                if (index < items.length - 1) const AppDivider(),
              ],
            ],
          ),
        ),
      ],
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

    return SizedBox(
      width: Spacing.level9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonText(
            text: l10n.medicineDrugboxTotal(count),
            style: TypographyToken.level8
                .display(context)
                .copyWith(fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            widthFactor: 0.72,
          ),
          const SizedBox(height: Spacing.level1),
          Text(
            l10n.medicineDrugboxTotalPrefix,
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: colors.mutedForeground),
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
  final void Function(MedicineDoseMarkRequest request)? onMarkDose;

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
    final takenRequest = item == null
        ? null
        : buildMedicineDoseMarkRequest(
            item: item,
            slot: slot,
            action: MedicineDoseAction.taken,
          );
    final skippedRequest = item == null
        ? null
        : buildMedicineDoseMarkRequest(
            item: item,
            slot: slot,
            action: MedicineDoseAction.skipped,
          );
    final canMark =
        onMarkDose != null && takenRequest != null && skippedRequest != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DrugBoxMetricItem(
                icon: FLucideIcons.clock,
                color: SemanticColor.primary,
                label: l10n.medicineNextDoseReminderTitle,
                value: value,
                detail: detail,
              ),
            ),
            const _MetricDivider(),
            Expanded(
              child: _DrugBoxMetricItem(
                icon: FLucideIcons.badgeCheck,
                color: SemanticColor.primary,
                label: l10n.medicineHeroMetricAdherenceLabel,
                value: workspace.hero.metricAdherence,
                detail: l10n.medicineAdherenceDetail,
              ),
            ),
          ],
        ),
        if (canMark) ...[
          const SizedBox(height: Spacing.level3),
          Row(
            children: [
              _DoseActionButton(
                key: const Key('medicine-next-dose-action-taken'),
                label: l10n.medicineDoseActionTaken,
                icon: FLucideIcons.check,
                color: SemanticColor.primary,
                filled: true,
                onTap: () => onMarkDose!(takenRequest),
              ),
              const SizedBox(width: Spacing.level3),
              _DoseActionButton(
                key: const Key('medicine-next-dose-action-skipped'),
                label: l10n.medicineDoseActionSkipped,
                icon: FLucideIcons.ban,
                color: SemanticColor.neutral,
                onTap: () => onMarkDose!(skippedRequest),
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
  final SemanticColor color;
  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.level1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color.solid(context).withValues(alpha: 0.78),
                size: Spacing.level5,
              ),
              const SizedBox(width: Spacing.level1),
              Expanded(
                child: Text(
                  label,
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.level1),
          AppSkeletonText(
            text: value,
            style: TypographyToken.level5
                .body(context)
                .copyWith(
                  color: color.solid(context).withValues(alpha: 0.92),
                  fontWeight: FontWeight.w800,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            widthFactor: 0.76,
          ),
          const SizedBox(height: Spacing.level1),
          AppSkeletonText(
            text: detail,
            style: TypographyToken.level3
                .body(context)
                .copyWith(color: colors.mutedForeground),
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
    return const SizedBox(
      height: Spacing.level9,
      child: AppDivider(axis: Axis.vertical),
    );
  }
}

class _DrugBoxEmpty extends StatelessWidget {
  const _DrugBoxEmpty({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
      child: Row(
        children: [
          FAvatar.raw(
            size: Spacing.level8,
            child: Icon(
              FLucideIcons.pillBottle,
              color: SemanticColor.primary.solid(context),
              size: Spacing.level5,
            ),
          ),
          const SizedBox(width: Spacing.level4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicineNoMedicineTitle,
                  style: TypographyToken.level4
                      .body(context)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  l10n.medicineNoMedicineBody,
                  style: TypographyToken.level3
                      .body(context)
                      .copyWith(color: colors.mutedForeground),
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
        MedicineReminderDetailRoute(
          medicineId: currentMedicineId,
        ).push(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level2,
          vertical: Spacing.level3,
        ),
        child: Row(
          children: [
            _MedicationAvatar(item: item, size: Spacing.level7),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonText(
                    text: name,
                    style: TypographyToken.level4
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widthFactor: 0.72,
                  ),
                  const SizedBox(height: Spacing.level1),
                  Wrap(
                    spacing: Spacing.level2,
                    runSpacing: Spacing.level1,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppSkeletonText(
                        text: '$dosage · ${_compactRouteOrSchedule(schedule)}',
                        style: TypographyToken.level3
                            .body(context)
                            .copyWith(color: colors.mutedForeground),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        widthFactor: 0.66,
                      ),
                      AppSkeletonSlot(
                        skeleton: const AppInlineSkeletonBlock(
                          height: 22,
                          width: 54,
                          radius: RadiusTokens.levelFull,
                        ),
                        child: TintedStatusBadge(
                          color: item.stateColor,
                          label: state,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.level2),
            Icon(
              FLucideIcons.chevronRight,
              color: colors.mutedForeground,
              size: Spacing.level5,
            ),
          ],
        ),
      ),
    );
  }
}
