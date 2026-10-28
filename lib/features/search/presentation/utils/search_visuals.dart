import 'package:flutter/widgets.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';

/// Presentation-layer mapping from search domain identities to the icons and
/// accents they render with.
///
/// These are client-owned styling choices; keeping them out of the entities lets
/// the entities stay pure data and stay JSON-serializable for caching.
abstract final class SearchVisuals {
  /// Icon + accent for a quick action, keyed by its type.
  static (IconData, SemanticColor) quickAction(MedicineSearchActionType type) {
    return switch (type) {
      MedicineSearchActionType.photo => (
        SemanticIcons.actionCamera,
        SemanticColor.primary,
      ),
      MedicineSearchActionType.barcode => (
        SemanticIcons.actionScan,
        SemanticColor.primary,
      ),
      MedicineSearchActionType.keyword => (
        SemanticIcons.actionSearch,
        SemanticColor.primary,
      ),
      MedicineSearchActionType.switchSource => (
        SemanticIcons.actionRefresh,
        SemanticColor.neutral,
      ),
    };
  }

  /// Icon + accents for a category chip, keyed by its type.
  static (IconData, SemanticColor, SemanticColor) category(
    MedicineSearchCategoryType type,
  ) {
    return switch (type) {
      MedicineSearchCategoryType.painFever => (
        SemanticIcons.recordSymptom,
        SemanticColor.warning,
        SemanticColor.warning,
      ),
      MedicineSearchCategoryType.coldCough => (
        SemanticIcons.recordSymptom,
        SemanticColor.info,
        SemanticColor.info,
      ),
      MedicineSearchCategoryType.stomach => (
        SemanticIcons.recordMeal,
        SemanticColor.success,
        SemanticColor.success,
      ),
      MedicineSearchCategoryType.supplement => (
        SemanticIcons.medicineBottle,
        SemanticColor.primary,
        SemanticColor.primary,
      ),
      MedicineSearchCategoryType.chronic => (
        SemanticIcons.profileCondition,
        SemanticColor.primary,
        SemanticColor.primary,
      ),
    };
  }
}
