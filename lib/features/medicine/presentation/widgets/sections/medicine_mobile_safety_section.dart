part of '../views/medicine_mobile_dashboard_view.dart';

class _SafetyEngineSection extends StatelessWidget {
  const _SafetyEngineSection({required this.alerts, required this.l10n});

  final List<MedicineAlert> alerts;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final visibleAlerts = alerts.take(3).toList(growable: false);

    return Column(
      key: const Key('medicine-safety-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: l10n.medicineSafetyEngineTitle,
          trailing: AppTextAction(
            label: l10n.medicineSafetyAllRecordsAction,
            onTap: () => context.push('/medicine/risk-check'),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        FCard.raw(
          child: Column(
            children: [
              for (var index = 0; index < visibleAlerts.length; index += 1) ...[
                _SafetyAlertRow(alert: visibleAlerts[index], l10n: l10n),
                if (index < visibleAlerts.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent:
                        AppSpacingTokens.level4 +
                        AppSpacingTokens.level8 +
                        AppSpacingTokens.level3,
                    color: colors.border,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SafetyAlertRow extends StatelessWidget {
  const _SafetyAlertRow({required this.alert, required this.l10n});

  final MedicineAlert alert;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    return AppInkWell(
      onTap: () => context.push('/medicine/risk-check'),
      borderRadius: BorderRadius.circular(AppRadiusTokens.level3),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level4,
          vertical: AppSpacingTokens.level3,
        ),
        child: Row(
          children: [
            AppIconBadge(
              icon: alert.icon,
              color: alert.color,
              backgroundColor: Color.alphaBlend(
                alert.softColor.withValues(alpha: 0.18),
                colors.background,
              ),
              shape: BoxShape.circle,
              size: AppSpacingTokens.level8,
              iconSize: AppSpacingTokens.level5,
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonText(
                    text: medicineAlertTitle(l10n, alert),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widthFactor: 0.74,
                  ),
                  const SizedBox(height: AppSpacingTokens.level1),
                  AppSkeletonText(
                    text: medicineAlertBody(l10n, alert),
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widthFactor: 0.92,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            AppSkeletonSlot(
              skeleton: const AppInlineSkeletonBlock(
                height: 22,
                width: 54,
                radius: AppRadiusTokens.levelFull,
              ),
              child: AppStatusPill(
                label: medicineAlertAction(l10n, alert),
                color: alert.color,
              ),
            ),
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
