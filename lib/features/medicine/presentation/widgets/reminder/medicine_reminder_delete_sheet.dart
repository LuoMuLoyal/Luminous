import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/l10n/app_localizations.dart';

Future<bool?> showMedicineReminderDeleteSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  final surface = theme.extension<AppThemeSurface>()!;
  final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacingTokens.md,
            0,
            AppSpacingTokens.md,
            AppSpacingTokens.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: surface.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: AppSpacingTokens.x3l,
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: surface.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacingTokens.md),
              Text(
                l10n.medicineReminderDeleteConfirmTitle,
                textAlign: TextAlign.center,
                style: typography.displaySm.copyWith(letterSpacing: 0),
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                l10n.medicineReminderDeleteConfirmBody,
                textAlign: TextAlign.center,
                style: typography.bodySm.copyWith(
                  color: surface.body,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              FilledButton(
                key: const Key('medicine-reminder-delete-confirm-button'),
                style: FilledButton.styleFrom(
                  backgroundColor: surface.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadiusTokens.md),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacingTokens.md,
                  ),
                ),
                onPressed: () => Navigator.of(sheetContext).pop(true),
                child: Text(l10n.medicineReminderConfirmDeleteAction),
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              OutlinedButton(
                onPressed: () => Navigator.of(sheetContext).pop(false),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadiusTokens.md),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacingTokens.md,
                  ),
                ),
                child: Text(l10n.medicineReminderCancelAction),
              ),
            ],
          ),
        ),
      );
    },
  );
}
