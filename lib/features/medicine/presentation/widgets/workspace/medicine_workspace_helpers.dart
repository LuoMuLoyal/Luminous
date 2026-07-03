import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_workspace.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/medicine_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class SectionTextAction extends StatelessWidget {
  const SectionTextAction({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FTappable(
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level1),
        child: Text(
          label,
          style: AppTypographyToken.level3
              .body(context)
              .copyWith(color: context.theme.colors.primary),
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
