part of '../views/mobile_dashboard_view.dart';

class _QuickOperationSection extends StatelessWidget {
  const _QuickOperationSection({
    required this.l10n,
    required this.onCreateReminder,
  });

  final AppLocalizations l10n;
  final VoidCallback? onCreateReminder;

  @override
  Widget build(BuildContext context) {
    final operations = [
      _QuickOperation(
        icon: FLucideIcons.plus,
        color: AppColors.primary,
        title: l10n.medicineQuickAddTitle,
        subtitle: l10n.medicineQuickAddSubtitle,
        onTap: () => pushAuthRequiredRoute(context, AppRoutes.mineMedicineNew),
      ),
      _QuickOperation(
        icon: FLucideIcons.search,
        color: AppColors.primary,
        title: l10n.medicineQuickActionSearchTitle,
        subtitle: l10n.medicineQuickActionSearchSubtitle,
        onTap: () => context.push(AppRoutes.medicineSearch),
      ),
      _QuickOperation(
        icon: FLucideIcons.bell,
        color: AppColors.primary,
        title: l10n.medicineReminderQuickTitle,
        subtitle: l10n.medicineReminderQuickSubtitle,
        onTap:
            onCreateReminder ??
            () => context.push(AppRoutes.medicineRemindersNew),
      ),
      _QuickOperation(
        icon: FLucideIcons.shieldAlert,
        color: AppColors.primary,
        title: l10n.medicineQuickSafetyCheckTitle,
        subtitle: l10n.medicineQuickSafetyCheckSubtitle,
        onTap: () =>
            pushAuthRequiredRoute(context, AppRoutes.medicineRiskCheck),
      ),
    ];

    return Column(
      key: const Key('medicine-action-hub'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.medicineQuickOperationTitle,
                style: AppTypographyToken.level7
                    .display(context)
                    .copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacingTokens.level3),
        FCard.raw(
          child: Column(
            children: [
              for (var index = 0; index < operations.length; index += 1) ...[
                _QuickOperationRow(operation: operations[index]),
                if (index < operations.length - 1) const AppDivider(),
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

    return FTappable(
      onPress: operation.onTap,
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
                operation.icon,
                color: operation.color.resolve(colors),
                size: AppSpacingTokens.level5,
              ),
            ),
            const SizedBox(width: AppSpacingTokens.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    operation.title,
                    style: AppTypographyToken.level4
                        .body(context)
                        .copyWith(fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacingTokens.level1),
                  Text(
                    operation.subtitle,
                    style: AppTypographyToken.level3
                        .body(context)
                        .copyWith(color: colors.mutedForeground),
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
