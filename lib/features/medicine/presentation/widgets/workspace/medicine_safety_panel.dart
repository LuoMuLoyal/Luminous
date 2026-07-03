import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_colors.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_copy.dart';
import 'package:luminous/features/medicine/presentation/widgets/workspace/medicine_workspace_helpers.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineSafetyPanel extends StatelessWidget {
  const MedicineSafetyPanel({
    super.key,
    required this.workspace,
    required this.alerts,
    required this.l10n,
  });

  final MedicineWorkspace workspace;
  final List<MedicineAlert> alerts;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FCard.raw(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacingTokens.level4),
            child: Column(
              children: [
                for (var index = 0; index < alerts.length; index += 1)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: index == alerts.length - 1
                          ? 0
                          : AppSpacingTokens.level4,
                    ),
                    child: _AlertTile(alert: alerts[index], l10n: l10n),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.level4),
        _PromisePanel(workspace: workspace, l10n: l10n),
      ],
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.l10n});

  final MedicineAlert alert;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    return FCard.raw(
      style: .delta(
        decoration: .shapeDelta(
          color: alert.softColor.resolve(colors).withValues(alpha: 0.42),
          shape: RoundedSuperellipseBorder(
            side: BorderSide(
              color: alert.color.resolve(colors).withValues(alpha: 0.18),
            ),
            borderRadius: context.theme.style.borderRadius.lg,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medicineAlertTitle(l10n, alert),
              style: textTheme.labelLarge?.copyWith(
                color: alert.color.resolve(colors),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacingTokens.level3),
            Text(medicineAlertBody(l10n, alert), style: textTheme.bodyMedium),
            const SizedBox(height: AppSpacingTokens.level2),
            Text(
              medicineAlertDetail(l10n, alert),
              style: textTheme.bodySmall?.copyWith(
                color: colors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacingTokens.level4),
            Align(
              alignment: Alignment.centerLeft,
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: () => context.push('/medicine/risk-check'),
                child: Text(medicineAlertAction(l10n, alert)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromisePanel extends StatelessWidget {
  const _PromisePanel({required this.workspace, required this.l10n});

  final MedicineWorkspace workspace;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    return FTappable(
      onPress: () => showPlannedAction(
        context,
        l10n.medicinePromiseTitle,
        l10n.medicineOpenPromiseToast,
      ),
      child: FCard.raw(
        style: .delta(
          decoration: .shapeDelta(
            color: colors.primary,
            shape: RoundedSuperellipseBorder(
              side: BorderSide(color: colors.primary.withValues(alpha: 0.2)),
              borderRadius: context.theme.style.borderRadius.lg,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacingTokens.level5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.medicinePromiseTitle,
                style: textTheme.titleSmall?.copyWith(
                  color: context.theme.colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.level4),
              ...workspace.promisePoints.map(
                (point) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacingTokens.level4,
                  ),
                  child: Text(
                    medicineCopy(l10n, point.copyKey),
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
