import 'package:luminous/core/widgets/common/app_ink_well.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/common/app_section_surface.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_copy.dart';
import 'package:luminous/features/medicine/presentation/widgets/workspace/medicine_workspace_helpers.dart';
import 'package:luminous/features/scan/presentation/pages/medicine_box_scan_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

// Deferred by Product_Vision MVP: this quick-action section is kept because the scan/OCR/barcode/prescription capability is useful, but it is not surfaced in the current MVP UI.
class MedicineQuickActionSection extends StatelessWidget {
  const MedicineQuickActionSection({
    super.key,
    required this.workspace,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MedicineWorkspace workspace;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AppSectionSurface(
      title: l10n.medicineQuickActionSectionTitle,
      typography: typography,
      surface: surface,
      child: Row(
        children: [
          for (var index = 0; index < workspace.quickActions.length; index += 1)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == workspace.quickActions.length - 1
                      ? 0
                      : AppSpacingTokens.sm,
                ),
                child: _QuickActionTile(
                  action: workspace.quickActions[index],
                  typography: typography,
                  surface: surface,
                  l10n: l10n,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.action,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final MedicineQuickAction action;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      onTap: () {
        // Navigate to scan based on action type
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
      borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.sm),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: action.accent.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
                border: Border.all(
                  color: action.accent.withValues(alpha: 0.12),
                ),
              ),
              child: Icon(action.icon, color: action.accent, size: 32),
            ),
            const SizedBox(height: AppSpacingTokens.sm),
            Text(
              medicineCopy(l10n, action.titleKey),
              style: typography.bodySmStrong,
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
