part of 'medicine_mobile_dashboard_view.dart';

class _QuickOperationSection extends StatelessWidget {
  const _QuickOperationSection({
    required this.l10n,
    required this.typography,
    required this.surface,
    required this.onCreateReminder,
  });

  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback? onCreateReminder;

  @override
  Widget build(BuildContext context) {
    final operations = [
      _QuickOperation(
        icon: Icons.add_rounded,
        color: surface.teal,
        title: l10n.medicineQuickAddTitle,
        subtitle: l10n.medicineQuickAddSubtitle,
        onTap: () => context.push('/medicine/search'),
      ),
      _QuickOperation(
        icon: Icons.fact_check_rounded,
        color: surface.violet,
        title: l10n.medicineQuickRecordTitle,
        subtitle: l10n.medicineQuickRecordSubtitle,
        onTap: () => AppToast.show(context, l10n.medicineQuickRecordToast),
      ),
      _QuickOperation(
        icon: Icons.notifications_none_rounded,
        color: surface.link,
        title: l10n.medicineReminderQuickTitle,
        subtitle: l10n.medicineReminderQuickSubtitle,
        onTap:
            onCreateReminder ??
            () => AppToast.show(context, l10n.medicineNotificationsTooltip),
      ),
      _QuickOperation(
        icon: Icons.health_and_safety_rounded,
        color: surface.warningDeep,
        title: l10n.medicineQuickSafetyCheckTitle,
        subtitle: l10n.medicineQuickSafetyCheckSubtitle,
        onTap: () => pushAuthRequiredRoute(context, '/medicine/risk-check'),
      ),
    ];

    return Column(
      key: const Key('medicine-quick-actions'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: l10n.medicineQuickOperationTitle),
        const SizedBox(height: AppSpacingTokens.sm),
        MedicinePanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var index = 0; index < operations.length; index += 1) ...[
                _QuickOperationRow(
                  operation: operations[index],
                  typography: typography,
                  surface: surface,
                ),
                if (index < operations.length - 1)
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

class _QuickOperationRow extends StatelessWidget {
  const _QuickOperationRow({
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.md,
            vertical: AppSpacingTokens.sm,
          ),
          child: Row(
            children: [
              AppIconBadge(
                icon: operation.icon,
                color: operation.color,
                backgroundColor: operation.color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                size: AppSpacingTokens.x3l,
                iconSize: AppSpacingTokens.lg,
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      operation.title,
                      style: typography.bodyMdStrong.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacingTokens.xxs),
                    Text(
                      operation.subtitle,
                      style: typography.bodySm.copyWith(
                        color: surface.body,
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
