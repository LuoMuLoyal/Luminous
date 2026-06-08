part of 'medicine_mobile_dashboard_view.dart';

class _DrugBoxSection extends StatelessWidget {
  const _DrugBoxSection({
    required this.workspace,
    required this.nextDose,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.onMarkDose,
  });

  final MedicineWorkspace workspace;
  final _NextDose? nextDose;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context) {
    final items = workspace.plan.items.take(2).toList(growable: false);

    return MedicinePanel(
      key: const Key('medicine-hero'),
      color: Color.alphaBlend(
        MedicinePalette.tealSoft.withValues(alpha: 0.08),
        surface.canvas,
      ),
      borderColor: MedicinePalette.teal.withValues(alpha: 0.14),
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      shadow: const <BoxShadow>[],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicineSectionHeader(
            title: l10n.medicineDrugboxTitle,
            compact: true,
            leading: MedicineIconBadge(
              icon: Icons.medical_services_rounded,
              color: MedicinePalette.teal,
              backgroundColor: Color.alphaBlend(
                MedicinePalette.tealSoft.withValues(alpha: 0.28),
                surface.canvas,
              ),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DrugBoxCountSummary(
                  count: workspace.plan.items.length,
                  l10n: l10n,
                  typography: typography,
                  surface: surface,
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                SizedBox(
                  height: AppSpacingTokens.x5l,
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: surface.hairline,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: Column(
                    children: [
                      for (var index = 0; index < items.length; index += 1) ...[
                        _DrugBoxMedicationRow(
                          item: items[index],
                          l10n: l10n,
                          typography: typography,
                          surface: surface,
                        ),
                        if (index < items.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            indent: AppSpacingTokens.x2l + AppSpacingTokens.sm,
                            color: surface.hairline,
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacingTokens.sm),
          Divider(height: 1, thickness: 1, color: surface.hairline),
          const SizedBox(height: AppSpacingTokens.sm),
          _DrugBoxReminderStrip(
            key: const Key('medicine-next-reminder'),
            workspace: workspace,
            nextDose: nextDose,
            l10n: l10n,
            typography: typography,
            surface: surface,
            onMarkDose: onMarkDose,
          ),
        ],
      ),
    );
  }
}

class _DrugBoxCountSummary extends StatelessWidget {
  const _DrugBoxCountSummary({
    required this.count,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final int count;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacingTokens.x4l,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonText(
            text: l10n.medicineDrugboxTotal(count),
            style: typography.displayLg.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            widthFactor: 0.72,
          ),
          const SizedBox(height: AppSpacingTokens.xxs),
          Text(
            l10n.medicineDrugboxTotalPrefix,
            style: typography.bodySm.copyWith(
              color: surface.body,
              letterSpacing: 0,
            ),
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
    required this.typography,
    required this.surface,
    required this.onMarkDose,
  });

  final MedicineWorkspace workspace;
  final _NextDose? nextDose;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
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
        : l10n.medicineNextDoseTodayTime(medicineCopy(l10n, slot.timeKey));
    final detail = item == null
        ? (hasAnyMedicine
              ? l10n.medicineNoPendingDoseDetail
              : l10n.medicineNoMedicineBody)
        : _doseSummary(l10n, item);
    final refillItem = _refillCandidate(workspace.plan.items);
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
                color: MedicinePalette.teal,
                label: l10n.medicineNextDoseReminderTitle,
                value: value,
                detail: detail,
                typography: typography,
                surface: surface,
              ),
            ),
            _MetricDivider(surface: surface),
            Expanded(
              child: _DrugBoxMetricItem(
                icon: Icons.check_circle_rounded,
                color: MedicinePalette.teal,
                label: l10n.medicineHeroMetricAdherenceLabel,
                value: workspace.hero.metricAdherence,
                detail: l10n.medicineDoseDueStatus,
                typography: typography,
                surface: surface,
              ),
            ),
            _MetricDivider(surface: surface),
            Expanded(
              child: _DrugBoxMetricItem(
                icon: Icons.inventory_2_outlined,
                color: MedicinePalette.orangeDeep,
                label: l10n.medicineAlertRefillTitle,
                value: refillItem == null
                    ? l10n.medicineExpiredReminderEnabled
                    : _itemName(l10n, refillItem),
                detail: _refillDetail(l10n, refillItem),
                typography: typography,
                surface: surface,
              ),
            ),
          ],
        ),
        if (canMark) ...[
          const SizedBox(height: AppSpacingTokens.sm),
          Row(
            children: [
              _DoseActionButton(
                label: l10n.medicineDoseActionTaken,
                icon: Icons.check_rounded,
                color: MedicinePalette.teal,
                filled: true,
                onTap: () =>
                    onMarkDose!(currentMedicineId, MedicineDoseAction.taken),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              _DoseActionButton(
                label: l10n.medicineDoseActionSkipped,
                icon: Icons.remove_done_rounded,
                color: MedicinePalette.orangeDeep,
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
    required this.typography,
    required this.surface,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String detail;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
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
                  style: typography.caption.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
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
            style: typography.bodyMdStrong.copyWith(
              color: color.withValues(alpha: 0.92),
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            widthFactor: 0.76,
          ),
          const SizedBox(height: AppSpacingTokens.xxs),
          AppSkeletonText(
            text: detail,
            style: typography.caption.copyWith(
              color: surface.body,
              letterSpacing: 0,
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
  const _MetricDivider({required this.surface});

  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacingTokens.x4l,
      child: VerticalDivider(width: 1, thickness: 1, color: surface.hairline),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.xs),
      child: Row(
        children: [
          MedicineIconBadge(
            icon: Icons.medication_outlined,
            color: MedicinePalette.teal,
            backgroundColor: Color.alphaBlend(
              MedicinePalette.tealSoft.withValues(alpha: 0.28),
              surface.canvas,
            ),
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
                      style: typography.bodyMdStrong.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
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
                          text:
                              '$dosage · ${_compactRouteOrSchedule(schedule)}',
                          style: typography.bodySm.copyWith(
                            color: surface.body,
                            letterSpacing: 0,
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

MedicinePlanItem? _refillCandidate(List<MedicinePlanItem> items) {
  for (final item in items) {
    if (item.stockWarningKey != null) return item;
  }
  if (items.isEmpty) return null;
  return items.last;
}

String _refillDetail(AppLocalizations l10n, MedicinePlanItem? item) {
  if (item == null) return l10n.medicineExpiredReminderEnabled;
  final warningKey = item.stockWarningKey;
  if (warningKey != null) return medicineCopy(l10n, warningKey);
  final raw = item.rawStock;
  if (raw != null) {
    final trimmed = raw.trim();
    return trimmed.isEmpty ? l10n.medicineStockNotTracked : trimmed;
  }
  return medicineCopy(l10n, item.stockKey);
}
