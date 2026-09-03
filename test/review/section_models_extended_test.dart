import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/shared/section_models.dart';

void main() {
  // ── reviewExportInputForKind ──────────────────────────────────
  group('reviewExportInputForKind', () {
    test('returns hospital request for hospital kind', () {
      final input = reviewExportInputForKind(ReviewExportKind.hospital);
      expect(input, isNotNull);
      expect(
        input!.kind,
        DataExportControllerCreateRequestV1RequestKindEnum.hospital,
      );
      expect(
        input.format,
        DataExportControllerCreateRequestV1RequestFormatEnum.pdf,
      );
      expect(
        input.range,
        DataExportControllerCreateRequestV1RequestRangeEnum.last7Days,
      );
    });

    test('returns monthly request for monthly kind', () {
      final input = reviewExportInputForKind(ReviewExportKind.monthly);
      expect(input, isNotNull);
      expect(
        input!.kind,
        DataExportControllerCreateRequestV1RequestKindEnum.monthly,
      );
      expect(
        input.format,
        DataExportControllerCreateRequestV1RequestFormatEnum.pdf,
      );
      expect(
        input.range,
        DataExportControllerCreateRequestV1RequestRangeEnum.last30Days,
      );
    });

    test('returns print request for print kind', () {
      final input = reviewExportInputForKind(ReviewExportKind.print);
      expect(input, isNotNull);
      expect(
        input!.kind,
        DataExportControllerCreateRequestV1RequestKindEnum.print,
      );
      expect(
        input.format,
        DataExportControllerCreateRequestV1RequestFormatEnum.pdf,
      );
      expect(
        input.range,
        DataExportControllerCreateRequestV1RequestRangeEnum.last7Days,
      );
    });

    test('returns null for clinicShare kind', () {
      final input = reviewExportInputForKind(ReviewExportKind.clinicShare);
      expect(input, isNull);
    });

    test('returns correct request for all enum values', () {
      for (final kind in ReviewExportKind.values) {
        final input = reviewExportInputForKind(kind);
        if (kind == ReviewExportKind.clinicShare) {
          expect(input, isNull, reason: 'clinicShare should return null');
        } else {
          expect(
            input,
            isNotNull,
            reason: '$kind should return non-null input',
          );
        }
      }
    });
  });
}
