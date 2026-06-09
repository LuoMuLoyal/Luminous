import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_copy.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_mobile_dashboard_view.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_workspace_parts.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineWorkspaceView extends StatelessWidget {
  const MedicineWorkspaceView({
    super.key,
    required this.workspace,
    this.onMarkDose,
  });

  final MedicineWorkspace workspace;
  final void Function(String currentMedicineId, MedicineDoseAction action)?
  onMarkDose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);
    final isDesktop = width >= AppBreakpoints.desktop;

    if (!isDesktop) {
      return MedicineMobileDashboardView(
            workspace: workspace,
            onMarkDose: onMarkDose,
          )
          .animate()
          .fadeIn(duration: 220.ms)
          .slideY(begin: 0.018, end: 0, duration: 240.ms);
    }

    final primaryColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MedicineMetricsPanel(
          key: const Key('medicine-hero'),
          workspace: workspace,
          typography: typography,
          surface: surface,
          l10n: l10n,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _QuickActionSection(
          key: const Key('medicine-quick-actions'),
          workspace: workspace,
          typography: typography,
          surface: surface,
          l10n: l10n,
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _TodayPlanSection(
          key: const Key('medicine-today-plan'),
          workspace: workspace,
          typography: typography,
          surface: surface,
          l10n: l10n,
          onMarkDose: onMarkDose,
        ),
      ],
    );

    final safetyColumn = _SafetyPanel(
      key: const Key('medicine-safety-panel'),
      workspace: workspace,
      typography: typography,
      surface: surface,
      l10n: l10n,
    );

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: primaryColumn),
        const SizedBox(width: AppSpacingTokens.lg),
        Expanded(flex: 3, child: safetyColumn),
      ],
    );

    return content
        .animate()
        .fadeIn(duration: 240.ms)
        .slideY(begin: 0.025, end: 0, duration: 260.ms);
  }
}

class MedicineErrorView extends StatelessWidget {
  const MedicineErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppStateErrorView(
      title: l10n.medicineErrorTitle,
      description: l10n.medicineErrorDescription,
      icon: Icons.medication_liquid_outlined,
      actionLabel: l10n.todayRetryAction,
      onAction: onRetry,
      tone: AppStateTone.warning,
    );
  }
}

class _MedicineMetricsPanel extends StatelessWidget {
  const _MedicineMetricsPanel({
    super.key,
    required this.workspace,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MedicineWorkspace workspace;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return MedicineSectionSurface(
      title: '',
      typography: typography,
      surface: surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.lg,
        vertical: AppSpacingTokens.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricBlock(
              label: l10n.medicineHeroMetricTodayCountLabel,
              value: workspace.hero.metricDosesToday,
              typography: typography,
              surface: surface,
              suffix: l10n.medicineHeroMetricTodayCountUnit,
            ),
          ),
          Container(width: 1, height: 70, color: surface.hairline),
          Expanded(
            child: _MetricBlock(
              label: l10n.medicineHeroMetricAdherenceLabel,
              value: workspace.hero.metricAdherence.replaceAll('%', ''),
              typography: typography,
              surface: surface,
              suffix: l10n.medicineHeroMetricAdherenceUnit,
              showInfo: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({
    required this.label,
    required this.value,
    required this.typography,
    required this.surface,
    required this.suffix,
    this.showInfo = false,
  });

  final String label;
  final String value;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final String suffix;
  final bool showInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  label,
                  style: typography.bodySm.copyWith(color: surface.body),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showInfo) ...[
                const SizedBox(width: AppSpacingTokens.xxs),
                Icon(Icons.info_outline_rounded, size: 14, color: surface.mute),
              ],
            ],
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          RichText(
            text: TextSpan(
              style: typography.displayXl.copyWith(
                color: _MedicinePalette.green,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: suffix,
                  style: typography.bodySmStrong.copyWith(
                    color: _MedicinePalette.green,
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

class _QuickActionSection extends StatelessWidget {
  const _QuickActionSection({
    super.key,
    required this.workspace,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MedicineWorkspace workspace;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return MedicineSectionSurface(
      title: l10n.medicineQuickActionSectionTitle,
      typography: typography,
      surface: surface,
      child: Row(
        children: [
          for (var index = 0; index < workspace.quickActions.length; index += 1)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == workspace.quickActions.length - 1
                      ? 0
                      : AppSpacingTokens.sm,
                ),
                child: _QuickActionTile(
                  action: workspace.quickActions[index],
                  typography: typography,
                  surface: surface,
                  l10n: l10n,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.action,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MedicineQuickAction action;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPlannedAction(
          context,
          medicineCopy(l10n, action.titleKey),
          _quickActionResult(action.titleKey, l10n),
        ),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: action.accent.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
                  border: Border.all(
                    color: action.accent.withValues(alpha: 0.12),
                  ),
                ),
                child: Icon(action.icon, color: action.accent, size: 32),
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              Text(
                medicineCopy(l10n, action.titleKey),
                style: typography.bodySmStrong,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayPlanSection extends StatelessWidget {
  const _TodayPlanSection({
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
    return MedicineSectionSurface(
      title: l10n.medicineTodayPlanTitle,
      trailing: _SectionTextAction(
        label:
            '${l10n.medicineTodayPlanInspectAction}(${workspace.plan.items.length})',
        typography: typography,
        surface: surface,
        onTap: () => _showPlannedAction(
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
        onTap: () => _showPlannedAction(
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
                    _StatusBadge(
                      label: stateText,
                      color: item.stateColor,
                      typography: typography,
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
                          color: _MedicinePalette.green,
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
                          color: _MedicinePalette.orange,
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
    final color = isTaken ? _MedicinePalette.green : _MedicinePalette.orange;
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
                  _slotTimeLabel(l10n, slot),
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
            color: _MedicinePalette.orange,
            size: 20,
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Text(
              l10n.medicineRecordScheduledStatus,
              style: typography.bodySm.copyWith(color: _MedicinePalette.orange),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyPanel extends StatelessWidget {
  const _SafetyPanel({
    super.key,
    required this.workspace,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MedicineWorkspace workspace;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MedicineSectionSurface(
          title: l10n.medicineSafetyPanelTitle,
          typography: typography,
          surface: surface,
          child: Column(
            children: [
              for (var index = 0; index < workspace.alerts.length; index += 1)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: index == workspace.alerts.length - 1
                        ? 0
                        : AppSpacingTokens.md,
                  ),
                  child: _AlertTile(
                    alert: workspace.alerts[index],
                    typography: typography,
                    surface: surface,
                    l10n: l10n,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacingTokens.md),
        _PromisePanel(
          workspace: workspace,
          typography: typography,
          surface: surface,
          l10n: l10n,
        ),
      ],
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({
    required this.alert,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MedicineAlert alert;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: alert.softColor.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        border: Border.all(color: alert.color.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _alertIconBackground(context),
                    borderRadius: BorderRadius.circular(AppRadiusTokens.md),
                  ),
                  child: Icon(alert.icon, color: alert.color, size: 18),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                Expanded(
                  child: Text(
                    medicineCopy(l10n, alert.titleKey),
                    style: typography.bodySmStrong.copyWith(color: alert.color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            Text(
              medicineCopy(l10n, alert.bodyKey),
              style: typography.bodyMdStrong,
            ),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(
              medicineCopy(l10n, alert.detailKey),
              style: typography.bodySm.copyWith(color: surface.body),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            Align(
              alignment: Alignment.centerLeft,
              child: _AlertActionButton(
                label: medicineCopy(l10n, alert.actionKey),
                color: alert.color,
                typography: typography,
                emphasized: false,
                onTap: () => _showPlannedAction(
                  context,
                  medicineCopy(l10n, alert.titleKey),
                  _alertActionResult(alert.actionKey, l10n),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _alertIconBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.black.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.78);
  }
}

class _AlertActionButton extends StatelessWidget {
  const _AlertActionButton({
    required this.label,
    required this.color,
    required this.typography,
    required this.emphasized,
    required this.onTap,
  });

  final String label;
  final Color color;
  final AppTypographyScale typography;
  final bool emphasized;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: emphasized
                ? _MedicinePalette.green
                : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
            border: Border.all(
              color: emphasized
                  ? _MedicinePalette.green
                  : color.withValues(alpha: 0.28),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.md,
              vertical: AppSpacingTokens.sm,
            ),
            child: Text(
              label,
              style: typography.bodySmStrong.copyWith(
                color: emphasized ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PromisePanel extends StatelessWidget {
  const _PromisePanel({
    required this.workspace,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MedicineWorkspace workspace;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPlannedAction(
          context,
          l10n.medicinePromiseTitle,
          l10n.medicineOpenPromiseToast,
        ),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _MedicinePalette.greenSoft,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: _MedicinePalette.greenLine),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.gpp_good_outlined,
                      color: _MedicinePalette.green,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacingTokens.sm),
                    Expanded(
                      child: Text(
                        l10n.medicinePromiseTitle,
                        style: typography.bodyMdStrong.copyWith(
                          color: _MedicinePalette.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacingTokens.md),
                ...workspace.promisePoints.map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacingTokens.md),
                    child: _PromisePoint(
                      label: medicineCopy(l10n, point.copyKey),
                      typography: typography,
                      surface: surface,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xs),
                Row(
                  children: [
                    Text(
                      l10n.medicinePromiseAction,
                      style: typography.bodySmStrong.copyWith(
                        color: _MedicinePalette.green,
                      ),
                    ),
                    const SizedBox(width: AppSpacingTokens.xs),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _MedicinePalette.green,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PromisePoint extends StatelessWidget {
  const _PromisePoint({
    required this.label,
    required this.typography,
    required this.surface,
  });

  final String label;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          color: _MedicinePalette.green,
          size: 18,
        ),
        const SizedBox(width: AppSpacingTokens.sm),
        Expanded(
          child: Text(
            label,
            style: typography.bodySm.copyWith(color: surface.body),
          ),
        ),
      ],
    );
  }
}

class _SectionTextAction extends StatelessWidget {
  const _SectionTextAction({
    required this.label,
    required this.typography,
    required this.surface,
    required this.onTap,
  });

  final String label;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.xs,
            vertical: AppSpacingTokens.xs,
          ),
          child: Text(
            label,
            style: typography.bodySm.copyWith(color: surface.body),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.typography,
  });

  final String label;
  final Color color;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.sm,
          vertical: AppSpacingTokens.xs,
        ),
        child: Text(
          label,
          style: typography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

String _quickActionResult(MedicineCopyKey key, AppLocalizations l10n) {
  return switch (key) {
    MedicineCopyKey.quickActionCameraTitle =>
      l10n.medicineQuickActionCameraToast,
    MedicineCopyKey.quickActionBarcodeTitle =>
      l10n.medicineQuickActionBarcodeToast,
    MedicineCopyKey.quickActionPrescriptionTitle =>
      l10n.medicineQuickActionPrescriptionToast,
    _ => l10n.todayRetryAction,
  };
}

String _slotTimeLabel(AppLocalizations l10n, MedicineDoseSlot slot) {
  final raw = slot.rawTime?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  final key = slot.timeKey;
  return key == null ? l10n.medicineScheduleNotSet : medicineCopy(l10n, key);
}

String _alertActionResult(MedicineCopyKey key, AppLocalizations l10n) {
  return switch (key) {
    MedicineCopyKey.alertInteractionAction =>
      l10n.medicineAlertInteractionToast,
    MedicineCopyKey.alertOtherAction => l10n.medicineAlertOtherToast,
    MedicineCopyKey.alertAlcoholRiskStatus =>
      l10n.medicineAlertAlcoholRiskToast,
    MedicineCopyKey.alertCoffeeReminderStatus =>
      l10n.medicineAlertCoffeeReminderToast,
    MedicineCopyKey.alertDuplicateCheckStatus =>
      l10n.medicineAlertDuplicateCheckToast,
    MedicineCopyKey.alertSpecialGroupSafetyStatus =>
      l10n.medicineAlertSpecialGroupSafetyToast,
    _ => l10n.todayRetryAction,
  };
}

void _showPlannedAction(BuildContext context, String title, String message) {
  AppToast.show(context, '$title: $message');
}

abstract final class _MedicinePalette {
  static const Color green = AppColorTokens.cyanDeep;
  static const Color greenSoft = AppColorTokens.cyanSoft;
  static const Color greenLine = AppColorTokens.cyanSoft;
  static const Color orange = AppColorTokens.warning;
}
