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
        icon: SemanticIcons.actionAdd,
        color: SemanticColor.primary,
        title: l10n.medicineQuickAddTitle,
        subtitle: l10n.medicineQuickAddSubtitle,
        onTap: () => pushAuthRequiredRoute(context, Routes.mineMedicineNew),
      ),
      _QuickOperation(
        icon: SemanticIcons.actionSearch,
        color: SemanticColor.primary,
        title: l10n.medicineQuickActionSearchTitle,
        subtitle: l10n.medicineQuickActionSearchSubtitle,
        onTap: () => context.push(Routes.medicineSearch),
      ),
      _QuickOperation(
        icon: SemanticIcons.actionScan,
        color: SemanticColor.primary,
        title: l10n.medicineQuickActionBarcodeTitle,
        subtitle: l10n.medicineQuickActionBarcodeSubtitle,
        onTap: () => context.push(Routes.scanBarcode),
      ),
      _QuickOperation(
        icon: SemanticIcons.actionCamera,
        color: SemanticColor.primary,
        title: l10n.medicineQuickActionCameraTitle,
        subtitle: l10n.medicineQuickActionCameraSubtitle,
        onTap: () => unawaited(showMedicineBoxScanSheet(context)),
      ),
      _QuickOperation(
        icon: SemanticIcons.notificationBell,
        color: SemanticColor.primary,
        title: l10n.medicineReminderQuickTitle,
        subtitle: l10n.medicineReminderQuickSubtitle,
        onTap:
            onCreateReminder ?? () => context.push(Routes.medicineRemindersNew),
      ),
      _QuickOperation(
        icon: SemanticIcons.safetyCaution,
        color: SemanticColor.primary,
        title: l10n.medicineQuickSafetyCheckTitle,
        subtitle: l10n.medicineQuickSafetyCheckSubtitle,
        onTap: () => pushAuthRequiredRoute(context, Routes.medicineRiskCheck),
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
                style: context.theme.typography.display.xl.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.level3),
        FCard(
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
    final typography = context.theme.typography;
    return FTappable(
      onPress: operation.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level4,
          vertical: Spacing.level3,
        ),
        child: Row(
          children: [
            FAvatar.raw(
              size: Spacing.level8,
              child: Icon(
                operation.icon,
                color: operation.color.solid(context),
                size: Spacing.level5,
              ),
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    operation.title,
                    style: typography.body.sm.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Spacing.level1),
                  Text(
                    operation.subtitle,
                    style: typography.body.xs.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              SemanticIcons.actionNext,
              color: SemanticColor.neutral.solid(context),
              size: Spacing.level5,
            ),
          ],
        ),
      ),
    );
  }
}
