import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/features/scan/presentation/pages/box_scan.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 快捷操作区块：加药 / 搜索 / 扫码 / 拍照识药 / 新建提醒 / 安全自查。
///
/// 每个入口自己 `context.push`；原先页面注入的 `onCreateReminder` 已取消——
/// 组件不再依赖页面装配。
class QuickOperationSection extends StatelessWidget {
  const QuickOperationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
        onTap: () => context.push(Routes.medicineRemindersNew),
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
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
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

class _QuickOperation {
  const _QuickOperation({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final SemanticColor color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
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
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        child: Row(
          children: [
            Icon(
              operation.icon,
              color: operation.color.solid(context),
              size: IconSizeTokens.lg,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    operation.title,
                    style: typography.body.sm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: Spacing.xs),
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
              size: IconSizeTokens.lg,
            ),
          ],
        ),
      ),
    );
  }
}
