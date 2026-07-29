import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Prompt shown when no medicine is selected in the reminder edit page.
class MedicineSelectorPrompt extends StatelessWidget {
  const MedicineSelectorPrompt({super.key, required this.onSelect});

  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.medicineReminderSelectMedicineHint,
              style: TypographyToken.level4.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.level4),
            FButton(
              onPress: onSelect,
              child: Text(l10n.medicineReminderSelectMedicineAction),
            ),
          ],
        ),
      ),
    );
  }
}
