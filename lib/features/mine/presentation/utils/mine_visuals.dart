import 'package:flutter/widgets.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';

/// Presentation-layer mapping from a mine entity to the icon and accent it
/// renders with.
///
/// These two values are client-owned styling, not server data. They used to
/// live on the domain entities, which made the entities unserializable — the
/// dashboard could not be cached because `IconData` / `SemanticColor` have no
/// JSON form. Keeping them here lets the domain stay pure data.
abstract final class MineVisuals {
  /// Icon + accent for a status card, keyed by its [MineStatusCard.kind].
  static (IconData, SemanticColor) statusCard(MineStatusCardKind kind) {
    return switch (kind) {
      MineStatusCardKind.allergy => (
        SemanticIcons.statusWarning,
        SemanticColor.destructive,
      ),
      MineStatusCardKind.medicine => (
        SemanticIcons.recordMedicine,
        SemanticColor.primary,
      ),
      MineStatusCardKind.privacy => (
        SemanticIcons.profileUser,
        SemanticColor.success,
      ),
    };
  }

  /// Icon + accent for an archive row, keyed by its [MineArchiveEntry.titleKey].
  ///
  /// The archive rows are a fixed four-entry set, so the title key is the
  /// stable discriminator (the entity carries no enum of its own).
  static (IconData, SemanticColor) archiveEntry(MineCopyKey titleKey) {
    return switch (titleKey) {
      MineCopyKey.archiveBasicTitle => (
        SemanticIcons.profileArchiveBasic,
        SemanticColor.success,
      ),
      MineCopyKey.archiveAllergyTitle => (
        SemanticIcons.recordWater,
        SemanticColor.warning,
      ),
      MineCopyKey.archiveConditionTitle => (
        SemanticIcons.profileCondition,
        SemanticColor.destructive,
      ),
      MineCopyKey.archiveMedicineTitle => (
        SemanticIcons.recordMedicine,
        SemanticColor.primary,
      ),
      _ => (SemanticIcons.profileArchiveBasic, SemanticColor.neutral),
    };
  }

  /// Icon for the privacy notice footer.
  static IconData privacyNotice() => SemanticIcons.safetyNeutral;
}
