part of '../views/mobile_dashboard_view.dart';

/// Maximum drugbox rows rendered before collapsing the rest into the
/// "more" footer.
const _maxVisibleDrugboxItems = 3;

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
    final typography = context.theme.typography;

    return Column(
      key: const Key('medicine-current-medications'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineDrugboxTitle,
          style: typography.display.xl.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          l10n.medicineDrugboxSubtitle,
          style: typography.body.xs.copyWith(
            color: SemanticColor.neutral.solid(context),
          ),
        ),
        const SizedBox(height: Spacing.md),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DrugBoxHeader(
                  l10n: l10n,
                  hasMedicines: items.isNotEmpty,
                  count: items.length,
                ),
                const SizedBox(height: Spacing.lg),
                if (items.isEmpty)
                  _DrugBoxEmpty(l10n: l10n)
                else ...[
                  _DrugBoxContent(
                    items: items
                        .take(_maxVisibleDrugboxItems)
                        .toList(growable: false),
                    l10n: l10n,
                    onOpenReminder: onOpenReminder,
                  ),
                  if (items.length > _maxVisibleDrugboxItems) ...[
                    const SizedBox(height: Spacing.sm),
                    _TruncatedFooter(
                      label: l10n.medicineDrugboxMoreCount(
                        items.length - _maxVisibleDrugboxItems,
                      ),
                      onTap: () => pushAuthRequiredRoute(
                        context,
                        Routes.mineMedicineNew,
                      ),
                    ),
                  ],
                ],
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
    final typography = context.theme.typography;

    return Row(
      children: [
        Container(
          width: Spacing.xl3,
          height: Spacing.xl3,
          decoration: BoxDecoration(
            color: SemanticColor.primary.muted(context),
            borderRadius: context.theme.style.borderRadius.md,
          ),
          child: Center(
            child: Icon(
              SemanticIcons.medicineKit,
              color: SemanticColor.primary.solid(context),
              size: Spacing.xl,
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.medicineDrugboxTotal(count),
                style: typography.body.md.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                l10n.medicineDrugboxTotalPrefix,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.md),
        FButton(
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.xs,
          mainAxisSize: MainAxisSize.min,
          onPress: () => pushAuthRequiredRoute(
            context,
            hasMedicines ? Routes.mineMedicineNew : Routes.medicineSearch,
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
              const SizedBox(width: Spacing.xs),
              Icon(
                SemanticIcons.actionNext,
                size: Spacing.lg,
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
    required this.l10n,
    required this.onOpenReminder,
  });

  final List<MedicinePlanItem> items;
  final AppLocalizations l10n;
  final void Function(String currentMedicineId)? onOpenReminder;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class _DrugBoxReminderStrip extends StatelessWidget {
  const _DrugBoxReminderStrip({
    super.key,
    required this.workspace,
    required this.nextDose,
    required this.l10n,
  });

  final MedicineWorkspace workspace;
  final _NextDose? nextDose;
  final AppLocalizations l10n;

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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _DrugBoxMetricItem(
            icon: SemanticIcons.doseSlot,
            color: SemanticColor.primary,
            label: l10n.medicineNextDoseReminderTitle,
            value: value,
            detail: detail,
          ),
        ),
        const _MetricDivider(),
        Expanded(
          child: _DrugBoxMetricItem(
            icon: SemanticIcons.reportAdherence,
            color: SemanticColor.primary,
            label: l10n.medicineHeroMetricAdherenceLabel,
            value: workspace.hero.metricAdherence,
            detail: l10n.medicineAdherenceDetail,
          ),
        ),
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
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color.solid(context).withValues(alpha: 0.78),
                size: Spacing.xl,
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          SkeletonText(
            text: value,
            style: typography.body.md.copyWith(
              color: color.fillStrong(context),
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            widthFactor: 0.76,
          ),
          const SizedBox(height: Spacing.xs),
          SkeletonText(
            text: detail,
            style: typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
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
    return const SizedBox(
      height: Spacing.xl5,
      child: AppDivider(axis: Axis.vertical),
    );
  }
}

class _DrugBoxEmpty extends StatelessWidget {
  const _DrugBoxEmpty({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          FAvatar.raw(
            size: Spacing.xl4,
            child: Icon(
              SemanticIcons.medicineBottle,
              color: SemanticColor.primary.solid(context),
              size: Spacing.xl,
            ),
          ),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicineNoMedicineTitle,
                  style: typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  l10n.medicineNoMedicineBody,
                  style: typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
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
    final name = _itemName(l10n, item);
    final dosage = _itemDosage(l10n, item);
    final schedule = _itemSchedule(l10n, item);
    final state = _itemState(l10n, item);
    final currentMedicineId = item.currentMedicineId;
    final source = item.source;
    final sourceRefId = item.sourceRefId;
    final typography = context.theme.typography;

    return FTappable(
      onPress: () {
        if (currentMedicineId == null) {
          unawaited(Toast.show(context, l10n.medicineOpenPlanItemToast));
          return;
        }
        // Default: open medicine detail page when source + sourceRefId are
        // available; otherwise fall back to the reminder detail page.
        if (source != null &&
            sourceRefId != null &&
            (source == 'cn' || source == 'drugbank')) {
          unawaited(
            MedicineDetailRoute(source: source, id: sourceRefId).push(context),
          );
          return;
        }
        if (onOpenReminder != null) {
          onOpenReminder!(currentMedicineId);
          return;
        }
        unawaited(
          MedicineReminderDetailRoute(
            medicineId: currentMedicineId,
          ).push(context),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.md,
        ),
        child: Row(
          children: [
            _MedicationAvatar(item: item, size: Spacing.xl3),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonText(
                    text: name,
                    style: typography.body.sm.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widthFactor: 0.72,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SkeletonText(
                        text: '$dosage · ${_compactRouteOrSchedule(schedule)}',
                        style: typography.body.xs.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        widthFactor: 0.66,
                      ),
                      SkeletonSlot(
                        skeleton: InlineSkeletonBlock(
                          height: 22,
                          width: 54,
                          radius:
                              context.theme.style.borderRadius.pill.topLeft.x,
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
            const SizedBox(width: Spacing.sm),
            Icon(
              SemanticIcons.actionNext,
              color: SemanticColor.neutral.solid(context),
              size: Spacing.xl,
            ),
          ],
        ),
      ),
    );
  }
}

class _TruncatedFooter extends StatelessWidget {
  const _TruncatedFooter({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FTappable(
      onPress: onTap,
      builder: (context, data, _) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          child: Text(
            label,
            style: context.theme.typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
