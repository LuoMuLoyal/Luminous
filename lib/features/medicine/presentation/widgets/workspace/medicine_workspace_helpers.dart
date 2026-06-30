import 'package:luminous/core/widgets/common/app_ink_well.dart';
import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

abstract final class MedicineWorkspacePalette {
  static const Color green = AppColorTokens.cyanDeep;
  static const Color greenSoft = AppColorTokens.cyanSoft;
  static const Color greenLine = AppColorTokens.cyanSoft;
  static const Color orange = AppColorTokens.warning;
}

class SectionTextAction extends StatelessWidget {
  const SectionTextAction({
    super.key,
    required this.label,
    required this.typography,
    required this.surface,
    required this.onTap,
  });

  final String label;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.xxs),
        child: Text(
          label,
          style: typography.bodySm.copyWith(
            color: MedicineWorkspacePalette.green,
          ),
        ),
      ),
    );
  }
}

// Deferred by Product_Vision MVP: scan/OCR/barcode/prescription quick actions are kept but not surfaced in the MVP UI.
String quickActionResult(MedicineCopyKey key, AppLocalizations l10n) {
  return switch (key) {
    MedicineCopyKey.quickActionCameraTitle =>
      l10n.medicineQuickActionCameraToast,
    MedicineCopyKey.quickActionBarcodeTitle =>
      l10n.medicineQuickActionBarcodeToast,
    MedicineCopyKey.quickActionPrescriptionTitle =>
      l10n.medicineQuickActionPrescriptionToast,
    _ => l10n.todayRetryAction,
  };
}

String slotTimeLabel(AppLocalizations l10n, MedicineDoseSlot slot) {
  final raw = slot.rawTime?.trim();
  if (raw != null && raw.isNotEmpty) return raw;
  final key = slot.timeKey;
  return key == null ? l10n.medicineScheduleNotSet : medicineCopy(l10n, key);
}

void showPlannedAction(BuildContext context, String title, String message) {
  AppToast.show(context, '$title: $message');
}
