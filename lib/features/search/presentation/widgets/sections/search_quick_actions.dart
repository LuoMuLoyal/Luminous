import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/scan/presentation/pages/medicine_box_scan_page.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';
import 'package:luminous/l10n/app_localizations.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.actions,
    required this.l10n,
    required this.typography,
    required this.surface,
  });
  final List<MedicineSearchQuickAction> actions;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: surface.canvas,
      borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      border: Border.all(color: surface.hairline),
    ),
    child: Row(
      children: actions
          .map(
            (action) => Expanded(
              child: _QuickActionButton(
                action: action,
                l10n: l10n,
                typography: typography,
                surface: surface,
              ),
            ),
          )
          .toList(),
    ),
  );
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.action,
    required this.l10n,
    required this.typography,
    required this.surface,
  });
  final MedicineSearchQuickAction action;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        switch (action.type) {
          case MedicineSearchActionType.barcode:
            context.push('/scan/barcode');
          case MedicineSearchActionType.photo:
            unawaited(showMedicineBoxScanSheet(context));
          default:
            AppToast.show(context, actionToast(l10n, action.type));
        }
      },
      borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.accent),
            const SizedBox(width: AppSpacingTokens.sm),
            Text(
              actionLabel(l10n, action.type),
              style: typography.bodySmStrong,
            ),
          ],
        ),
      ),
    ),
  );
}

String actionLabel(AppLocalizations l10n, MedicineSearchActionType type) =>
    switch (type) {
      MedicineSearchActionType.photo => l10n.medicineSearchPhotoAction,
      MedicineSearchActionType.barcode => l10n.medicineSearchBarcodeAction,
      MedicineSearchActionType.keyword => l10n.medicineSearchNoResultKeyword,
      MedicineSearchActionType.switchSource =>
        l10n.medicineSearchNoResultSwitch,
    };
String actionToast(AppLocalizations l10n, MedicineSearchActionType type) =>
    switch (type) {
      MedicineSearchActionType.photo => l10n.medicineSearchPhotoToast,
      MedicineSearchActionType.barcode => l10n.medicineSearchBarcodeToast,
      MedicineSearchActionType.keyword => l10n.medicineSearchNoResultKeyword,
      MedicineSearchActionType.switchSource =>
        l10n.medicineSearchNoResultSwitch,
    };
