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
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.medicineSafetyEngineTitle,
                style: AppTypographyToken.level7
                    .display(context)
                    .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            FButton(
              variant: FButtonVariant.ghost,
              size: FButtonSizeVariant.xs,
              mainAxisSize: MainAxisSize.min,
              onPress: () => context.push('/medicine/risk-check'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.medicineSafetyAllRecordsAction,
                    style: TextStyle(
                      color: colors.foreground,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: AppSpacingTokens.level1),
                  Icon(
                    FLucideIcons.chevronRight,
                    size: AppSpacingTokens.level4,
                    color: colors.foreground,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        FCard.raw(
          child: Column(
            children: [
              for (var index = 0; index < visibleAlerts.length; index += 1) ...[
                _SafetyAlertRow(alert: visibleAlerts[index], l10n: l10n),
                if (index < visibleAlerts.length - 1) const AppDivider(),
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

    return FTappable(
      onPress: () => context.push('/medicine/risk-check'),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level4,
          vertical: AppSpacingTokens.level3,
        ),
        child: Row(
          children: [
            FAvatar.raw(
              size: AppSpacingTokens.level8,
              child: Icon(
                alert.icon,
                color: alert.color.resolve(colors),
                size: AppSpacingTokens.level5,
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeletonText(
                    text: medicineAlertTitle(l10n, alert),
                    style: AppTypographyToken.level4
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    widthFactor: 0.74,
                  ),
                  const SizedBox(height: AppSpacingTokens.level1),
                  AppSkeletonText(
                    text: medicineAlertBody(l10n, alert),
                    style: AppTypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
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
              child: FBadge.raw(
                builder: (context, style) {
                  final resolvedColor = alert.color.resolve(colors);
                  final foreground = 0.12 > 0.5
                      ? colors.primaryForeground
                      : resolvedColor;
                  return DecoratedBox(
                    decoration: ShapeDecoration(
                      color: resolvedColor.withValues(alpha: 0.12),
                      shape: RoundedSuperellipseBorder(
                        borderRadius: BorderRadius.circular(
                          AppRadiusTokens.level2,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacingTokens.level2,
                        vertical: AppSpacingTokens.level1,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            medicineAlertAction(l10n, alert),
                            style: AppTypographyToken.level3
                                .body(context)
                                .copyWith(
                                  color: foreground,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
