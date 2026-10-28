import 'package:flutter/widgets.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';

/// Presentation-layer mapping from medicine domain identities to the icons and
/// accents they render with.
///
/// These are client-owned styling choices: the domain entities used to carry
/// raw `IconData` / `SemanticColor` values, which cannot be JSON-encoded and
/// therefore blocked caching the workspace. Keeping the mapping here lets the
/// entities stay pure data.
abstract final class MedicineVisuals {
  /// Icon + accent for a quick action, keyed by its title copy key.
  static (IconData, SemanticColor) quickAction(MedicineCopyKey titleKey) {
    return switch (titleKey) {
      MedicineCopyKey.quickActionSearchTitle => (
        SemanticIcons.actionSearch,
        SemanticColor.primary,
      ),
      MedicineCopyKey.quickActionBarcodeTitle => (
        SemanticIcons.actionScan,
        SemanticColor.primary,
      ),
      MedicineCopyKey.quickActionCameraTitle => (
        SemanticIcons.actionCamera,
        SemanticColor.primary,
      ),
      _ => (SemanticIcons.actionAdd, SemanticColor.neutral),
    };
  }

  /// Resolves a [MedicineAlertIcon] to its glyph.
  static IconData alert(MedicineAlertIcon key) {
    return switch (key) {
      MedicineAlertIcon.statusError => SemanticIcons.statusError,
      MedicineAlertIcon.statusWarning => SemanticIcons.statusWarning,
      MedicineAlertIcon.statusInfo => SemanticIcons.statusInfo,
      MedicineAlertIcon.safetyDuplicate => SemanticIcons.safetyDuplicate,
      MedicineAlertIcon.recordMeal => SemanticIcons.recordMeal,
      MedicineAlertIcon.safetyLongTermUse => SemanticIcons.safetyLongTermUse,
      MedicineAlertIcon.dosePlanned => SemanticIcons.dosePlanned,
      MedicineAlertIcon.safetySafe => SemanticIcons.safetySafe,
      MedicineAlertIcon.safetySpecialPopulation =>
        SemanticIcons.safetySpecialPopulation,
      MedicineAlertIcon.safetyFoodInteraction =>
        SemanticIcons.safetyFoodInteraction,
      MedicineAlertIcon.safetyAllClear => SemanticIcons.safetyAllClear,
      MedicineAlertIcon.safetyAlcohol => SemanticIcons.safetyAlcohol,
      MedicineAlertIcon.recordCaffeine => SemanticIcons.recordCaffeine,
      MedicineAlertIcon.recordWater => SemanticIcons.recordWater,
      MedicineAlertIcon.safetyInteraction => SemanticIcons.safetyInteraction,
      MedicineAlertIcon.safetySpecialGroup => SemanticIcons.safetySpecialGroup,
    };
  }
}
