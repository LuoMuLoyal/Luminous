import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// A toggle button that confirms or un-confirms the meal analysis for
/// a meal-type daily record.
class MealConfirmAction extends StatelessWidget {
  const MealConfirmAction({
    super.key,
    required this.l10n,
    required this.confirmed,
    required this.onToggle,
  });

  final AppLocalizations l10n;
  final bool confirmed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FButton(
        variant: confirmed ? FButtonVariant.primary : FButtonVariant.outline,
        key: const Key('meal-confirm-action'),
        onPress: onToggle,
        prefix: confirmed
            ? const Icon(SemanticIcons.statusDone, size: 16)
            : null,
        child: Text(
          confirmed
              ? l10n.recordMealConfirmActionSelected
              : l10n.recordMealConfirmAction,
        ),
      ),
    );
  }
}
