import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_copy.dart';
import 'package:luminous/features/medicine/presentation/widgets/workspace/medicine_workspace_helpers.dart';
import 'package:luminous/features/scan/presentation/pages/medicine_box_scan_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineQuickActionSection extends StatelessWidget {
  const MedicineQuickActionSection({
    super.key,
    required this.workspace,
    required this.l10n,
  });

  final MedicineWorkspace workspace;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Row(
          children: [
            for (
              var index = 0;
              index < workspace.quickActions.length;
              index += 1
            )
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == workspace.quickActions.length - 1
                        ? 0
                        : AppSpacingTokens.level3,
                  ),
                  child: _QuickActionTile(
                    action: workspace.quickActions[index],
                    l10n: l10n,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action, required this.l10n});

  final MedicineQuickAction action;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return FTappable(
      onPress: () {
        if (action.titleKey == MedicineCopyKey.quickActionCameraTitle ||
            action.titleKey == MedicineCopyKey.quickActionPrescriptionTitle) {
          unawaited(showMedicineBoxScanSheet(context));
        } else if (action.titleKey == MedicineCopyKey.quickActionBarcodeTitle) {
          context.push('/scan/barcode');
        } else {
          showPlannedAction(
            context,
            medicineCopy(l10n, action.titleKey),
            quickActionResult(action.titleKey, l10n),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.level3),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: action.accent.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(AppRadiusTokens.level5),
                border: Border.all(
                  color: action.accent.withValues(alpha: 0.12),
                ),
              ),
              child: Icon(action.icon, color: action.accent, size: 32),
            ),
            const SizedBox(height: AppSpacingTokens.level3),
            Text(
              medicineCopy(l10n, action.titleKey),
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
