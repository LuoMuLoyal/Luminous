import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/copy.dart';
import 'package:luminous/features/medicine/presentation/widgets/workspace/workspace_helpers.dart';
import 'package:luminous/features/scan/presentation/pages/box_scan_page.dart';
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
        padding: const EdgeInsets.all(Spacing.level4),
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
                        : Spacing.level3,
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
    return FButton.raw(
      onPress: () {
        if (action.titleKey == MedicineCopyKey.quickActionCameraTitle ||
            action.titleKey == MedicineCopyKey.quickActionPrescriptionTitle) {
          unawaited(showMedicineBoxScanSheet(context));
        } else if (action.titleKey == MedicineCopyKey.quickActionBarcodeTitle) {
          context.push(AppRoutes.scanBarcode);
        } else {
          showPlannedAction(
            context,
            medicineCopy(l10n, action.titleKey),
            quickActionResult(action.titleKey, l10n),
          );
        }
      },
      variant: FButtonVariant.ghost,
      style: .delta(
        decoration: .delta([
          .all(
            .shapeDelta(
              color: action.accent.muted(context),
              shape: RoundedSuperellipseBorder(
                side: BorderSide(color: action.accent.border(context)),
              ),
            ),
          ),
        ]),
        contentStyle: const .delta(
          padding: .value(EdgeInsets.symmetric(vertical: Spacing.level3)),
        ),
      ),
      child: Column(
        children: [
          Icon(action.icon, color: action.accent.solid(context), size: 32),
          const SizedBox(height: Spacing.level3),
          Text(
            medicineCopy(l10n, action.titleKey),
            style: TypographyToken.level5
                .body(context)
                .copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
