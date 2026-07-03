part of '../views/medicine_mobile_dashboard_view.dart';

class _QuickOperationSection extends StatelessWidget {
  const _QuickOperationSection({
    required this.l10n,
    required this.onCreateReminder,
  });

  final AppLocalizations l10n;
  final VoidCallback? onCreateReminder;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final operations = [
      _QuickOperation(
        icon: FLucideIcons.plus,
        color: AppColors.primary,
        title: l10n.medicineQuickAddTitle,
        subtitle: l10n.medicineQuickAddSubtitle,
        onTap: () => context.push('/medicine/search'),
      ),
      _QuickOperation(
        icon: FLucideIcons.clipboardCheck,
        color: AppColors.primary,
        title: l10n.medicineQuickRecordTitle,
        subtitle: l10n.medicineQuickRecordSubtitle,
        onTap: () => context.push('/record/create'),
      ),
      _QuickOperation(
        icon: FLucideIcons.bell,
        color: AppColors.primary,
        title: l10n.medicineReminderQuickTitle,
        subtitle: l10n.medicineReminderQuickSubtitle,
        onTap:
            onCreateReminder ?? () => context.push('/medicine/reminders/new'),
      ),
      _QuickOperation(
        icon: FLucideIcons.shieldAlert,
        color: AppColors.primary,
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
        const SizedBox(height: AppSpacingTokens.level3),
        FCard.raw(
          child: Column(
            children: [
              for (var index = 0; index < operations.length; index += 1) ...[
                _QuickOperationRow(operation: operations[index]),
                if (index < operations.length - 1)
                  AppDivider(color: colors.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickOperationRow extends StatelessWidget {
  const _QuickOperationRow({required this.operation});

  final _QuickOperation operation;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    return FTappable(
      onPress: operation.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level4,
          vertical: AppSpacingTokens.level3,
        ),
        child: Row(
          children: [
            AppIconBadge(
              icon: operation.icon,
              color: operation.color,
              backgroundColor: operation.color
                  .resolve(colors)
                  .withValues(alpha: 0.08),
              shape: BoxShape.circle,
              size: AppSpacingTokens.level8,
              iconSize: AppSpacingTokens.level5,
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    operation.title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacingTokens.level1),
                  Text(
                    operation.subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
