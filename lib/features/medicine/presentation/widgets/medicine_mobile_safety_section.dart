part of 'medicine_mobile_dashboard_view.dart';

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
    final visibleAlerts = alerts.take(3).toList(growable: false);

    return Column(
      key: const Key('medicine-safety-panel'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedicineSectionHeader(
          title: l10n.medicineSafetyEngineTitle,
          trailing: MedicineTextAction(
            label: l10n.medicineSafetyAllRecordsAction,
            onTap: () => context.push('/medicine/risk-check'),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        MedicinePanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < visibleAlerts.length; index += 1) ...[
                _SafetyAlertRow(
                  alert: visibleAlerts[index],
                  l10n: l10n,
                  typography: typography,
                  surface: surface,
                ),
                if (index < visibleAlerts.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent:
                        AppSpacingTokens.md +
                        AppSpacingTokens.x3l +
                        AppSpacingTokens.sm,
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

class _SafetyAlertRow extends StatelessWidget {
  const _SafetyAlertRow({
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
        onTap: () => context.push('/medicine/risk-check'),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.md,
            vertical: AppSpacingTokens.sm,
          ),
          child: Row(
            children: [
              MedicineIconBadge(
                icon: alert.icon,
                color: alert.color,
                backgroundColor: Color.alphaBlend(
                  alert.softColor.withValues(alpha: 0.18),
                  surface.canvas,
                ),
                shape: BoxShape.circle,
                size: AppSpacingTokens.x3l,
                iconSize: AppSpacingTokens.lg,
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeletonText(
                      text: medicineAlertTitle(l10n, alert),
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
                      text: medicineAlertBody(l10n, alert),
                      style: typography.bodySm.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widthFactor: 0.92,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              AppSkeletonSlot(
                skeleton: const AppInlineSkeletonBlock(
                  height: 22,
                  width: 54,
                  radius: AppRadiusTokens.pill,
                ),
                child: MedicineStatusPill(
                  label: medicineAlertAction(l10n, alert),
                  color: alert.color,
                ),
              ),
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
