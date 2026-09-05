import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/review/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart';

/// Locks the preview→share field-enum mapping used by the clinic summary
/// share flow. The two enums are generated independently; this test anchors
/// the wire-value 1:1 correspondence and the defensive drop for values the
/// share schema no longer carries (2026-09-04 review #2 — the previous bare
/// `firstWhere` would throw StateError on any drift).
void main() {
  group('mapPreviewFieldsToShare', () {
    test('maps matching wire values 1:1', () {
      final result = mapPreviewFieldsToShare(const [
        PreviewClinicSummaryRequestSelectedFieldsEnum.eventOverview,
        PreviewClinicSummaryRequestSelectedFieldsEnum.symptomChanges,
        PreviewClinicSummaryRequestSelectedFieldsEnum.medicationSlots,
        PreviewClinicSummaryRequestSelectedFieldsEnum.water,
        PreviewClinicSummaryRequestSelectedFieldsEnum.sleep,
        PreviewClinicSummaryRequestSelectedFieldsEnum.notes,
      ]);

      expect(result, hasLength(6));
      expect(
        result,
        containsAll([
          ShareClinicSummaryRequestSelectedFieldsEnum.eventOverview,
          ShareClinicSummaryRequestSelectedFieldsEnum.symptomChanges,
          ShareClinicSummaryRequestSelectedFieldsEnum.medicationSlots,
          ShareClinicSummaryRequestSelectedFieldsEnum.water,
          ShareClinicSummaryRequestSelectedFieldsEnum.sleep,
          ShareClinicSummaryRequestSelectedFieldsEnum.notes,
        ]),
      );
    });

    test('preserves order', () {
      final result = mapPreviewFieldsToShare(const [
        PreviewClinicSummaryRequestSelectedFieldsEnum.notes,
        PreviewClinicSummaryRequestSelectedFieldsEnum.eventOverview,
      ]);

      expect(
        result,
        equals([
          ShareClinicSummaryRequestSelectedFieldsEnum.notes,
          ShareClinicSummaryRequestSelectedFieldsEnum.eventOverview,
        ]),
      );
    });

    test('drops unknown values instead of throwing', () {
      // A value present in the preview enum but absent from the share enum
      // must be dropped, not crash with StateError from a bare firstWhere.
      final result = mapPreviewFieldsToShare(const [
        PreviewClinicSummaryRequestSelectedFieldsEnum.eventOverview,
        PreviewClinicSummaryRequestSelectedFieldsEnum.unknownDefaultOpenApi,
      ]);

      expect(
        result,
        equals([ShareClinicSummaryRequestSelectedFieldsEnum.eventOverview]),
      );
    });

    test('returns an empty list for empty input', () {
      expect(mapPreviewFieldsToShare(const []), isEmpty);
    });
  });
}
