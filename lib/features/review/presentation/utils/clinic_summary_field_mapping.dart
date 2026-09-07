import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/logger/log_level.dart';

/// Maps [PreviewClinicSummaryRequestSelectedFieldsEnum] values to their
/// [ShareClinicSummaryRequestSelectedFieldsEnum] counterparts by wire value.
///
/// The two enums are generated independently (different request schemas) but
/// share the same wire values for matching members. Unrecognised values — for
/// example if Lucent trims a share-only field that the preview schema still
/// carries — are dropped with a warning rather than crashing, protecting
/// against `firstWhere` throwing `StateError` at runtime (2026-09-04 review
/// #2).
List<ShareClinicSummaryRequestSelectedFieldsEnum> mapPreviewFieldsToShare(
  List<PreviewClinicSummaryRequestSelectedFieldsEnum> fields,
) {
  final result = <ShareClinicSummaryRequestSelectedFieldsEnum>[];
  for (final field in fields) {
    final match = ShareClinicSummaryRequestSelectedFieldsEnum.values.firstWhere(
      (candidate) => candidate.value == field.value,
      orElse: () =>
          ShareClinicSummaryRequestSelectedFieldsEnum.unknownDefaultOpenApi,
    );
    if (match ==
        ShareClinicSummaryRequestSelectedFieldsEnum.unknownDefaultOpenApi) {
      appTalker.warning(
        'ClinicSummary share: preview field "${field.value}" has no share '
        'enum equivalent; dropping from share payload.',
      );
    } else {
      result.add(match);
    }
  }
  return result;
}
