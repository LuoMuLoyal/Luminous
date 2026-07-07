import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/colors.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/scan/presentation/pages/box_scan_page.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/l10n/app_localizations.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.actions, required this.l10n});

  final List<MedicineSearchQuickAction> actions;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level3),
        child: Row(
          children: actions
              .map(
                (action) => Expanded(
                  child: _QuickActionButton(action: action, l10n: l10n),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action, required this.l10n});

  final MedicineSearchQuickAction action;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return FTappable(
      onPress: () {
        switch (action.type) {
          case MedicineSearchActionType.barcode:
            context.push(AppRoutes.scanBarcode);
          case MedicineSearchActionType.photo:
            unawaited(showMedicineBoxScanSheet(context));
          default:
            AppToast.show(context, actionToast(l10n, action.type));
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacingTokens.level4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.accent.resolve(colors)),
            const SizedBox(width: AppSpacingTokens.level3),
            Text(
              actionLabel(l10n, action.type),
              style: AppTypographyToken.level5
                  .body(context)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
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
