import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_copy.dart';
import 'package:luminous/features/medicine/presentation/widgets/workspace/medicine_workspace_helpers.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineSafetyPanel extends StatelessWidget {
  const MedicineSafetyPanel({
    super.key,
    required this.workspace,
    required this.alerts,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MedicineWorkspace workspace;
  final List<MedicineAlert> alerts;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSectionSurface(
          title: l10n.medicineSafetyPanelTitle,
          typography: typography,
          surface: surface,
          child: Column(
            children: [
              for (var index = 0; index < alerts.length; index += 1)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: index == alerts.length - 1
                        ? 0
                        : AppSpacingTokens.md,
                  ),
                  child: _AlertTile(
                    alert: alerts[index],
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
                    medicineAlertTitle(l10n, alert),
                    style: typography.bodySmStrong.copyWith(color: alert.color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            Text(
              medicineAlertBody(l10n, alert),
              style: typography.bodyMdStrong,
            ),
            const SizedBox(height: AppSpacingTokens.xs),
            Text(
              medicineAlertDetail(l10n, alert),
              style: typography.bodySm.copyWith(color: surface.body),
            ),
            const SizedBox(height: AppSpacingTokens.md),
            Align(
              alignment: Alignment.centerLeft,
              child: _AlertActionButton(
                label: medicineAlertAction(l10n, alert),
                color: alert.color,
                typography: typography,
                emphasized: false,
                onTap: () => context.push('/medicine/risk-check'),
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
                ? MedicineWorkspacePalette.green
                : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
            border: Border.all(
              color: emphasized
                  ? MedicineWorkspacePalette.green
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
        onTap: () => showPlannedAction(
          context,
          l10n.medicinePromiseTitle,
          l10n.medicineOpenPromiseToast,
        ),
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: MedicineWorkspacePalette.greenSoft,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: MedicineWorkspacePalette.greenLine),
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
                      color: MedicineWorkspacePalette.green,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacingTokens.sm),
                    Expanded(
                      child: Text(
                        l10n.medicinePromiseTitle,
                        style: typography.bodyMdStrong.copyWith(
                          color: MedicineWorkspacePalette.green,
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
                        color: MedicineWorkspacePalette.green,
                      ),
                    ),
                    const SizedBox(width: AppSpacingTokens.xs),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: MedicineWorkspacePalette.green,
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
          color: MedicineWorkspacePalette.green,
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
