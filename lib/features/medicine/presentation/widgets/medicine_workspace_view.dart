import 'package:flutter/material.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_copy.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_workspace_parts.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineWorkspaceView extends StatelessWidget {
  const MedicineWorkspaceView({super.key, required this.workspace});

  final MedicineWorkspace workspace;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surface = theme.extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final layout = AppLayoutTokens.resolve(width);
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);
    final isDesktop = width >= AppBreakpoints.desktop;

    final content = isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MedicineHero(
                      key: const Key('medicine-hero'),
                      workspace: workspace,
                      typography: typography,
                      surface: surface,
                      l10n: l10n,
                    ),
                    const SizedBox(height: AppSpacingTokens.lg),
                    _QuickActionSection(
                      key: const Key('medicine-quick-actions'),
                      workspace: workspace,
                      typography: typography,
                      surface: surface,
                      l10n: l10n,
                    ),
                    const SizedBox(height: AppSpacingTokens.lg),
                    _TodayPlanSection(
                      key: const Key('medicine-today-plan'),
                      workspace: workspace,
                      typography: typography,
                      surface: surface,
                      l10n: l10n,
                    ),
                  ],
                ),
              ),
              SizedBox(width: layout.componentGap * 2),
              Expanded(
                flex: 5,
                child: _SafetyPanel(
                  key: const Key('medicine-safety-panel'),
                  workspace: workspace,
                  typography: typography,
                  surface: surface,
                  l10n: l10n,
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MedicineHero(
                key: const Key('medicine-hero'),
                workspace: workspace,
                typography: typography,
                surface: surface,
                l10n: l10n,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              _QuickActionSection(
                key: const Key('medicine-quick-actions'),
                workspace: workspace,
                typography: typography,
                surface: surface,
                l10n: l10n,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              _TodayPlanSection(
                key: const Key('medicine-today-plan'),
                workspace: workspace,
                typography: typography,
                surface: surface,
                l10n: l10n,
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              _SafetyPanel(
                key: const Key('medicine-safety-panel'),
                workspace: workspace,
                typography: typography,
                surface: surface,
                l10n: l10n,
              ),
            ],
          );

    return content;
  }
}

class MedicineLoadingView extends StatelessWidget {
  const MedicineLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonBlock(height: 220, color: surface.canvas),
        const SizedBox(height: AppSpacingTokens.lg),
        _SkeletonBlock(height: 148, color: surface.canvas),
        const SizedBox(height: AppSpacingTokens.lg),
        _SkeletonBlock(height: 260, color: surface.canvas),
      ],
    );
  }
}

class MedicineErrorView extends StatelessWidget {
  const MedicineErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(scheme.onSurface);

    return MedicineSectionSurface(
      title: l10n.medicineTodayPlanTitle,
      typography: typography,
      surface: surface,
      child: Align(
        alignment: Alignment.centerLeft,
        child: OutlinedButton(
          onPressed: onRetry,
          child: Text(l10n.todayRetryAction),
        ),
      ),
    );
  }
}

class _MedicineHero extends StatelessWidget {
  const _MedicineHero({
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
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl + 4),
        color: surface.canvas,
        border: Border.all(color: surface.hairline.withValues(alpha: 0.82)),
        boxShadow: AppShadowTokens.level2,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: _HeroMetric(
                      data: _HeroMetricData(
                        value: workspace.hero.metricDosesToday,
                        label: l10n.medicineHeroMetricTodayCountLabel,
                      ),
                      typography: typography,
                      surface: surface,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.lg,
                  ),
                  child: Container(
                    width: 1,
                    height: 72,
                    color: surface.hairlineStrong.withValues(alpha: 0.38),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: _HeroMetric(
                      data: _HeroMetricData(
                        value: workspace.hero.metricAdherence,
                        label: l10n.medicineHeroMetricAdherenceLabel,
                      ),
                      typography: typography,
                      surface: surface,
                      emphasized: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < AppBreakpoints.tablet;

    return MedicineSectionSurface(
      title: l10n.medicineQuickActionSectionTitle,
      typography: typography,
      surface: surface,
      child: Row(
        children: workspace.quickActions
            .map(
              (action) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: action == workspace.quickActions.last
                        ? 0
                        : (isCompact
                              ? AppSpacingTokens.sm
                              : AppSpacingTokens.md),
                  ),
                  child: _QuickActionTile(
                    action: action,
                    typography: typography,
                    surface: surface,
                    l10n: l10n,
                  ),
                ),
              ),
            )
            .toList(),
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
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacingTokens.sm,
              horizontal: AppSpacingTokens.sm,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action.icon, color: action.accent, size: 22),
                const SizedBox(height: AppSpacingTokens.sm),
                Text(
                  medicineCopy(l10n, action.titleKey),
                  style: typography.bodySmStrong,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
  });

  final MedicineWorkspace workspace;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return MedicineSectionSurface(
      title: l10n.medicineTodayPlanTitle,
      trailing: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPlannedAction(
            context,
            l10n.medicineTodayPlanInspectAction,
            '会打开完整的今日用药列表与历史记录。',
          ),
          borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.xs,
              vertical: AppSpacingTokens.xs,
            ),
            child: Text(
              l10n.medicineTodayPlanInspectAction,
              style: typography.bodySmStrong.copyWith(color: surface.link),
            ),
          ),
        ),
      ),
      typography: typography,
      surface: surface,
      child: Column(
        children: workspace.plan.items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacingTokens.md),
                child: _MedicationPlanTile(
                  item: item,
                  typography: typography,
                  surface: surface,
                  l10n: l10n,
                ),
              ),
            )
            .toList(),
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
  });

  final MedicinePlanItem item;
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
          medicineCopy(l10n, item.nameKey),
          '会打开药品详情、提醒设置和历史服用记录。',
        ),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface.canvasSoft,
            borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
            border: Border.all(color: surface.hairline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
                  ),
                  child: Icon(
                    Icons.medication_outlined,
                    color: item.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.md),
                Expanded(
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
                                  medicineCopy(l10n, item.nameKey),
                                  style: typography.bodyMdStrong,
                                ),
                                const SizedBox(height: AppSpacingTokens.xs),
                                Text(
                                  '${medicineCopy(l10n, item.dosageKey)}  ·  ${medicineCopy(l10n, item.scheduleKey)}',
                                  style: typography.bodySm.copyWith(
                                    color: surface.body,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacingTokens.sm),
                          Text(
                            medicineCopy(l10n, item.stockKey),
                            style: typography.caption.copyWith(
                              color: surface.mute,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacingTokens.md),
                      Wrap(
                        spacing: AppSpacingTokens.sm,
                        runSpacing: AppSpacingTokens.sm,
                        children: [
                          MedicinePlanPill(
                            label: medicineCopy(l10n, item.nextSlotKey),
                            color: item.color,
                            typography: typography,
                          ),
                          MedicinePlanPill(
                            label: medicineCopy(l10n, item.laterSlotKey),
                            color: surface.hairlineStrong,
                            typography: typography,
                          ),
                          MedicinePlanPill(
                            label: medicineCopy(l10n, item.stateKey),
                            color: item.stateColor,
                            typography: typography,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
    return MedicineSectionSurface(
      title: l10n.medicineSafetyPanelTitle,
      typography: typography,
      surface: surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...workspace.alerts.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacingTokens.md),
              child: _AlertTile(
                alert: alert,
                typography: typography,
                surface: surface,
                l10n: l10n,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showPlannedAction(
                context,
                l10n.medicinePromiseTitle,
                '会打开安全边界、特殊人群提示和隐私处理说明。',
              ),
              borderRadius: BorderRadius.circular(AppRadiusTokens.md),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: surface.canvasSoft,
                  borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
                  border: Border.all(color: surface.hairline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: surface.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                AppRadiusTokens.md,
                              ),
                            ),
                            child: Icon(
                              Icons.verified_user_outlined,
                              color: surface.success,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacingTokens.sm),
                          Expanded(
                            child: Text(
                              l10n.medicinePromiseTitle,
                              style: typography.bodyMdStrong,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: surface.mute,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacingTokens.md),
                      ...workspace.promisePoints.map(
                        (point) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacingTokens.sm,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Icon(
                                  Icons.circle,
                                  size: 7,
                                  color: surface.success,
                                ),
                              ),
                              const SizedBox(width: AppSpacingTokens.sm),
                              Expanded(
                                child: Text(
                                  medicineCopy(l10n, point.copyKey),
                                  style: typography.bodySm.copyWith(
                                    color: surface.body,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
        border: Border.all(color: alert.color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
              ),
              child: Icon(alert.icon, color: alert.color, size: 20),
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicineCopy(l10n, alert.titleKey),
                    style: typography.bodyMdStrong,
                  ),
                  const SizedBox(height: AppSpacingTokens.xs),
                  Text(
                    medicineCopy(l10n, alert.bodyKey),
                    style: typography.bodySm.copyWith(color: surface.body),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            SizedBox(
              height: 36,
              child: TextButton(
                onPressed: () => _showPlannedAction(
                  context,
                  medicineCopy(l10n, alert.titleKey),
                  _alertActionResult(alert.actionKey, l10n),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: alert.color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.sm,
                  ),
                ),
                child: Text(medicineCopy(l10n, alert.actionKey)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.data,
    required this.typography,
    required this.surface,
    this.emphasized = false,
  });

  final _HeroMetricData data;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.xs,
          vertical: AppSpacingTokens.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              data.label,
              style: typography.bodySm.copyWith(color: surface.body),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(
              data.value,
              style: emphasized ? typography.displayLg : typography.displayMd,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroMetricData {
  const _HeroMetricData({required this.value, required this.label});

  final String value;
  final String label;
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      ),
    );
  }
}

String _quickActionResult(MedicineCopyKey key, AppLocalizations l10n) {
  return switch (key) {
    MedicineCopyKey.quickActionCameraTitle => '会调用相机拍摄药盒、药板或标签并开始识别。',
    MedicineCopyKey.quickActionBarcodeTitle => '会打开扫码流程，识别条形码并补齐药品信息。',
    MedicineCopyKey.quickActionPrescriptionTitle => '会打开图片导入与处方识别流程。',
    _ => l10n.todayRetryAction,
  };
}

String _alertActionResult(MedicineCopyKey key, AppLocalizations l10n) {
  return switch (key) {
    MedicineCopyKey.alertRefillAction => '会打开补药与库存详情。',
    MedicineCopyKey.alertInteractionAction => '会打开相互作用详情与风险说明。',
    _ => l10n.todayRetryAction,
  };
}

void _showPlannedAction(BuildContext context, String title, String message) {
  AppToast.show(context, '$title: $message');
}
