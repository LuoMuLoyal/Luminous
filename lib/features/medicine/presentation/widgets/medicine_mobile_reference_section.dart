part of 'medicine_mobile_dashboard_view.dart';

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
    return AppSectionSurface(
      color: Color.alphaBlend(
        surface.warningSoft.withValues(alpha: 0.44),
        surface.canvas,
      ),
      borderColor: surface.warning.withValues(alpha: 0.24),
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: surface.warning,
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
                    color: surface.warningDeep,
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
            color: surface.warningDeep,
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
        color: surface.link,
        text: l10n.medicineSafetyTipSpacing,
      ),
      _SafetyTip(
        icon: Icons.coffee_rounded,
        color: surface.warningDeep,
        text: l10n.medicineSafetyTipCoffee,
      ),
      _SafetyTip(
        icon: Icons.schedule_rounded,
        color: surface.link,
        text: l10n.medicineSafetyTipTiming,
      ),
      _SafetyTip(
        icon: Icons.thermostat_rounded,
        color: surface.teal,
        text: l10n.medicineSafetyTipStorage,
      ),
    ];

    return Column(
      key: const Key('medicine-safety-tips'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: l10n.medicineSafetyTipsTitle,
          leading: Icon(
            Icons.lightbulb_outline_rounded,
            color: surface.warning,
            size: AppSpacingTokens.lg,
          ),
          compact: true,
          trailing: AppTextAction(
            label: l10n.medicineSafetyTipsRefreshAction,
            icon: Icons.refresh_rounded,
            color: surface.link,
            onTap: () =>
                AppToast.show(context, l10n.medicineSafetyTipsRefreshAction),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        AppSectionSurface(
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
                    indent:
                        AppSpacingTokens.md +
                        AppSpacingTokens.x3l +
                        AppSpacingTokens.md,
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
          AppIconBadge(
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
