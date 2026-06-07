part of 'medicine_mobile_dashboard_view.dart';

class _NextDoseReminderSection extends StatelessWidget {
  const _NextDoseReminderSection({
    required this.nextDose,
    required this.fallbackTime,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.onMarkDose,
  });

  final _NextDose? nextDose;
  final String fallbackTime;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context) {
    final dose = nextDose;
    final time = dose == null
        ? _cleanMetricTime(fallbackTime)
        : medicineCopy(
            l10n,
            dose.slot?.timeKey ?? MedicineCopyKey.mockTime2000,
          );
    final item = dose?.item;
    final currentMedicineId = item?.currentMedicineId;
    final canMark = currentMedicineId != null && onMarkDose != null;

    return MedicinePanel(
      key: const Key('medicine-next-reminder'),
      color: Color.alphaBlend(
        MedicinePalette.tealSoft.withValues(alpha: 0.16),
        surface.canvas,
      ),
      borderColor: MedicinePalette.teal.withValues(alpha: 0.34),
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const MedicineIconBadge(
            icon: Icons.schedule_rounded,
            color: AppColorTokens.onPrimary,
            backgroundColor: MedicinePalette.teal,
            shape: BoxShape.circle,
            size: AppSpacingTokens.x5l,
            iconSize: AppSpacingTokens.x2l,
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicineNextDoseReminderTitle,
                  style: typography.bodySm.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                AppSkeletonSlot(
                  skeleton: const AppInlineSkeletonBlock(
                    height: 32,
                    width: 132,
                    radius: AppRadiusTokens.sm,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.medicineNextDoseTodayTime(time),
                      style: typography.displayLg.copyWith(
                        color: MedicinePalette.teal,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                AppSkeletonText(
                  text: item == null
                      ? l10n.medicineNoMedicineBody
                      : _doseSummary(l10n, item),
                  style: typography.bodyMd.copyWith(letterSpacing: 0),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  widthFactor: 0.76,
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
                        onTap: () => onMarkDose!(
                          currentMedicineId,
                          MedicineDoseAction.taken,
                        ),
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      _DoseActionButton(
                        label: l10n.medicineDoseActionSkipped,
                        icon: Icons.remove_done_rounded,
                        color: MedicinePalette.orangeDeep,
                        onTap: () => onMarkDose!(
                          currentMedicineId,
                          MedicineDoseAction.skipped,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppSkeletonSlot(
                skeleton: const AppInlineSkeletonBlock(
                  height: 22,
                  width: 56,
                  radius: AppRadiusTokens.pill,
                ),
                child: MedicineStatusPill(
                  label: l10n.medicineDoseDueStatus,
                  color: MedicinePalette.teal,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              if (canMark)
                FilledButton(
                  onPressed: () =>
                      onMarkDose!(currentMedicineId, MedicineDoseAction.taken),
                  style: FilledButton.styleFrom(
                    backgroundColor: MedicinePalette.blue,
                    foregroundColor: AppColorTokens.onPrimary,
                    textStyle: typography.bodyMdStrong.copyWith(
                      letterSpacing: 0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacingTokens.md,
                      vertical: AppSpacingTokens.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadiusTokens.md),
                    ),
                  ),
                  child: Text(l10n.medicineTakeNowAction),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SafetyEngineSection extends StatelessWidget {
  const _SafetyEngineSection({
    required this.alerts,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<MedicineAlert> alerts;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('medicine-safety-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedicineSectionHeader(
          title: l10n.medicineSafetyEngineTitle,
          trailing: MedicineTextAction(
            label: l10n.medicineSafetyAllRecordsAction,
            onTap: () =>
                AppToast.show(context, l10n.medicineSafetyAllRecordsAction),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            const columns = 2;
            final tileWidth =
                (constraints.maxWidth - AppSpacingTokens.sm) / columns;

            return Wrap(
              spacing: AppSpacingTokens.sm,
              runSpacing: AppSpacingTokens.sm,
              children: [
                for (final alert in alerts)
                  SizedBox(
                    width: tileWidth,
                    child: _SafetyAlertCard(
                      alert: alert,
                      l10n: l10n,
                      typography: typography,
                      surface: surface,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SafetyAlertCard extends StatelessWidget {
  const _SafetyAlertCard({
    required this.alert,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final MedicineAlert alert;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            AppToast.show(context, _alertActionResult(alert.actionKey, l10n)),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: MedicinePanel(
          padding: const EdgeInsets.all(AppSpacingTokens.md),
          color: Color.alphaBlend(
            alert.softColor.withValues(alpha: 0.32),
            surface.canvas,
          ),
          borderColor: alert.color.withValues(alpha: 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MedicineIconBadge(
                    icon: alert.icon,
                    color: AppColorTokens.onPrimary,
                    backgroundColor: alert.color,
                    shape: BoxShape.circle,
                    size: AppSpacingTokens.x3l,
                    iconSize: AppSpacingTokens.lg,
                  ),
                  const Spacer(),
                  AppSkeletonSlot(
                    skeleton: const AppInlineSkeletonBlock(
                      height: 22,
                      width: 54,
                      radius: AppRadiusTokens.pill,
                    ),
                    child: MedicineStatusPill(
                      label: medicineCopy(l10n, alert.actionKey),
                      color: alert.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacingTokens.md),
              AppSkeletonText(
                text: medicineCopy(l10n, alert.titleKey),
                style: typography.bodyMdStrong.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                widthFactor: 0.74,
              ),
              const SizedBox(height: AppSpacingTokens.xxs),
              AppSkeletonText(
                text: medicineCopy(l10n, alert.bodyKey),
                style: typography.bodySm.copyWith(
                  color: surface.body,
                  letterSpacing: 0,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                widthFactor: 0.92,
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: surface.mute,
                  size: AppSpacingTokens.lg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickOperationSection extends StatelessWidget {
  const _QuickOperationSection({
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final operations = [
      _QuickOperation(
        icon: Icons.add_rounded,
        color: MedicinePalette.teal,
        title: l10n.medicineQuickAddTitle,
        subtitle: l10n.medicineQuickAddSubtitle,
        onTap: () => context.push('/medicine/search'),
      ),
      _QuickOperation(
        icon: Icons.qr_code_scanner_rounded,
        color: MedicinePalette.blue,
        title: l10n.medicineQuickScanTitle,
        subtitle: l10n.medicineQuickScanSubtitle,
        onTap: () => AppToast.show(context, l10n.medicineSearchScanHint),
      ),
      _QuickOperation(
        icon: Icons.fact_check_rounded,
        color: MedicinePalette.violet,
        title: l10n.medicineQuickRecordTitle,
        subtitle: l10n.medicineQuickRecordSubtitle,
        onTap: () => AppToast.show(context, l10n.medicineQuickRecordToast),
      ),
      _QuickOperation(
        icon: Icons.bar_chart_rounded,
        color: MedicinePalette.teal,
        title: l10n.medicineQuickReportTitle,
        subtitle: l10n.medicineQuickReportSubtitle,
        onTap: () => AppToast.show(context, l10n.medicineQuickReportToast),
      ),
    ];

    return MedicinePanel(
      key: const Key('medicine-quick-actions'),
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicineSectionHeader(title: l10n.medicineQuickOperationTitle),
          const SizedBox(height: AppSpacingTokens.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < operations.length; index += 1) ...[
                Expanded(
                  child: _QuickOperationTile(
                    operation: operations[index],
                    typography: typography,
                    surface: surface,
                  ),
                ),
                if (index < operations.length - 1)
                  const SizedBox(width: AppSpacingTokens.sm),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickOperationTile extends StatelessWidget {
  const _QuickOperationTile({
    required this.operation,
    required this.typography,
    required this.surface,
  });

  final _QuickOperation operation;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: operation.onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.xs),
          child: Column(
            children: [
              MedicineIconBadge(
                icon: operation.icon,
                color: AppColorTokens.onPrimary,
                backgroundColor: operation.color,
                shape: BoxShape.circle,
                size: AppSpacingTokens.x4l,
                iconSize: AppSpacingTokens.xl,
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                operation.title,
                style: typography.bodySmStrong.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacingTokens.xxs),
              Text(
                operation.subtitle,
                style: typography.caption.copyWith(
                  color: surface.body,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicineRecordsSection extends StatelessWidget {
  const _MedicineRecordsSection({
    required this.items,
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.onMarkDose,
  });

  final List<MedicinePlanItem> items;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context) {
    final rows = _recordRowsFor(l10n, items).take(4).toList(growable: false);

    return MedicinePanel(
      key: const Key('medicine-today-plan'),
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedicineSectionHeader(
            title: l10n.medicineRecordsTitle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FilterText(label: l10n.medicineAllMedicinesFilter),
                const SizedBox(width: AppSpacingTokens.sm),
                _FilterText(label: l10n.medicineLastSevenDaysFilter),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          if (rows.isEmpty)
            _DrugBoxEmpty(l10n: l10n, typography: typography, surface: surface)
          else
            MedicinePanel(
              padding: EdgeInsets.zero,
              shadow: const <BoxShadow>[],
              borderColor: surface.hairline,
              child: Column(
                children: [
                  for (var index = 0; index < rows.length; index += 1) ...[
                    _MedicineRecordRow(
                      row: rows[index],
                      isLast: index == rows.length - 1,
                      typography: typography,
                      surface: surface,
                      l10n: l10n,
                      onMarkDose: onMarkDose,
                    ),
                    if (index < rows.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: AppSpacingTokens.x6l + AppSpacingTokens.sm,
                        color: surface.hairline,
                      ),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacingTokens.md,
                    ),
                    child: Center(
                      child: MedicineTextAction(
                        label: l10n.medicineViewMoreRecordsAction,
                        color: MedicinePalette.blue,
                        onTap: () =>
                            AppToast.show(context, l10n.medicineViewPlanToast),
                      ),
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

class _MedicineRecordRow extends StatelessWidget {
  const _MedicineRecordRow({
    required this.row,
    required this.isLast,
    required this.typography,
    required this.surface,
    required this.l10n,
    required this.onMarkDose,
  });

  final _RecordRow row;
  final bool isLast;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context) {
    final canMark = row.item.currentMedicineId != null && onMarkDose != null;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: AppSpacingTokens.x3l,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonText(
                  text: row.date,
                  style: typography.bodySm.copyWith(letterSpacing: 0),
                  width: 34,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                AppSkeletonText(
                  text: row.time,
                  style: typography.bodySm.copyWith(letterSpacing: 0),
                  width: 32,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.xs),
          SizedBox(
            width: AppSpacingTokens.lg,
            child: Column(
              children: [
                MedicineIconBadge(
                  icon: row.statusIcon,
                  color: row.statusColor,
                  backgroundColor: row.statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  size: AppSpacingTokens.lg,
                  iconSize: AppSpacingTokens.md,
                ),
                if (!isLast)
                  SizedBox(
                    height: AppSpacingTokens.x4l,
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: surface.hairline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          _MedicationAvatar(item: row.item, size: AppSpacingTokens.x3l),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonText(
                  text: row.name,
                  style: typography.bodyMdStrong.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  widthFactor: 0.66,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Wrap(
                  spacing: AppSpacingTokens.xs,
                  runSpacing: AppSpacingTokens.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppSkeletonText(
                      text: row.detail,
                      style: typography.bodySm.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                      width: 94,
                    ),
                    AppSkeletonSlot(
                      skeleton: const AppInlineSkeletonBlock(
                        height: 22,
                        width: 44,
                        radius: AppRadiusTokens.pill,
                      ),
                      child: MedicineStatusPill(
                        label: row.statusLabel,
                        color: row.statusColor,
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
                        onTap: () => onMarkDose!(
                          row.item.currentMedicineId!,
                          MedicineDoseAction.taken,
                        ),
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      _DoseActionButton(
                        label: l10n.medicineDoseActionSkipped,
                        icon: Icons.remove_done_rounded,
                        color: MedicinePalette.orangeDeep,
                        onTap: () => onMarkDose!(
                          row.item.currentMedicineId!,
                          MedicineDoseAction.skipped,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.xs),
          Icon(
            Icons.event_note_outlined,
            color: surface.body,
            size: AppSpacingTokens.lg,
          ),
        ],
      ),
    );
  }
}

class _ReferenceNotice extends StatelessWidget {
  const _ReferenceNotice({
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
      color: Color.alphaBlend(
        MedicinePalette.orangeSoft.withValues(alpha: 0.44),
        surface.canvas,
      ),
      borderColor: MedicinePalette.orange.withValues(alpha: 0.24),
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: MedicinePalette.orange,
            size: AppSpacingTokens.xl,
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicineReferenceNoticeTitle,
                  style: typography.bodyMdStrong.copyWith(
                    color: MedicinePalette.orangeDeep,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  l10n.medicineReferenceNoticeBody,
                  style: typography.bodySm.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: MedicinePalette.orangeDeep,
            size: AppSpacingTokens.lg,
          ),
        ],
      ),
    );
  }
}

class _SafetyTipsSection extends StatelessWidget {
  const _SafetyTipsSection({
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final tips = [
      _SafetyTip(
        icon: Icons.local_drink_outlined,
        color: MedicinePalette.blue,
        text: l10n.medicineSafetyTipSpacing,
      ),
      _SafetyTip(
        icon: Icons.coffee_rounded,
        color: MedicinePalette.orangeDeep,
        text: l10n.medicineSafetyTipCoffee,
      ),
      _SafetyTip(
        icon: Icons.schedule_rounded,
        color: MedicinePalette.blue,
        text: l10n.medicineSafetyTipTiming,
      ),
      _SafetyTip(
        icon: Icons.inventory_2_outlined,
        color: MedicinePalette.teal,
        text: l10n.medicineSafetyTipStorage,
      ),
    ];

    return Column(
      key: const Key('medicine-safety-tips'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedicineSectionHeader(
          title: l10n.medicineSafetyTipsTitle,
          leading: const Icon(
            Icons.lightbulb_outline_rounded,
            color: MedicinePalette.orange,
            size: AppSpacingTokens.lg,
          ),
          compact: true,
          trailing: MedicineTextAction(
            label: l10n.medicineSafetyTipsRefreshAction,
            icon: Icons.refresh_rounded,
            color: MedicinePalette.blue,
            onTap: () =>
                AppToast.show(context, l10n.medicineSafetyTipsRefreshAction),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        MedicinePanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < tips.length; index += 1) ...[
                _SafetyTipRow(
                  tip: tips[index],
                  typography: typography,
                  surface: surface,
                ),
                if (index < tips.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: AppSpacingTokens.x4l,
                    color: surface.hairline,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SafetyTipRow extends StatelessWidget {
  const _SafetyTipRow({
    required this.tip,
    required this.typography,
    required this.surface,
  });

  final _SafetyTip tip;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          MedicineIconBadge(
            icon: tip.icon,
            color: tip.color,
            backgroundColor: tip.color.withValues(alpha: 0.08),
            size: AppSpacingTokens.x3l,
            iconSize: AppSpacingTokens.lg,
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Text(
              tip.text,
              style: typography.bodySm.copyWith(
                color: surface.body,
                letterSpacing: 0,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: surface.mute,
            size: AppSpacingTokens.lg,
          ),
        ],
      ),
    );
  }
}
