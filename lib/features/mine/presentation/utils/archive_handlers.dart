import 'package:luminous/app/router.dart';
import 'package:luminous/features/mine/domain/entities/dashboard.dart';

/// Maps an archive entry's [MineCopyKey] to its default edit route.
///
/// Returns `null` for entries that have no dedicated edit page.
String? fallbackArchiveRoute(MineCopyKey titleKey) {
  return switch (titleKey) {
    MineCopyKey.archiveBasicTitle => Routes.profile,
    MineCopyKey.archiveAllergyTitle => Routes.mineAllergyNew,
    MineCopyKey.archiveConditionTitle => Routes.mineConditionNew,
    MineCopyKey.archiveMedicineTitle => Routes.mineMedicineNew,
    _ => null,
  };
}
