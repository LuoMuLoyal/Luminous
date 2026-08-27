import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/review/domain/entities/dashboard.dart';
import 'package:luminous/features/review/presentation/widgets/shared/section_models.dart';

void main() {
  // ── reportExportInputForKind ──────────────────────────────────
  group('reportExportInputForKind', () {
    test('returns hospital request for hospital kind', () {
      final input = reportExportInputForKind(ReviewExportKind.hospital);
      expect(input, isNotNull);
      expect(input!.kind, CreateDataExportRequestDtoKindEnum.hospital);
      expect(input.format, CreateDataExportRequestDtoFormatEnum.pdf);
      expect(input.range, CreateDataExportRequestDtoRangeEnum.last7Days);
    });

    test('returns monthly request for monthly kind', () {
      final input = reportExportInputForKind(ReviewExportKind.monthly);
      expect(input, isNotNull);
      expect(input!.kind, CreateDataExportRequestDtoKindEnum.monthly);
      expect(input.format, CreateDataExportRequestDtoFormatEnum.pdf);
      expect(input.range, CreateDataExportRequestDtoRangeEnum.last30Days);
    });

    test('returns print request for print kind', () {
      final input = reportExportInputForKind(ReviewExportKind.print);
      expect(input, isNotNull);
      expect(input!.kind, CreateDataExportRequestDtoKindEnum.print);
      expect(input.format, CreateDataExportRequestDtoFormatEnum.pdf);
      expect(input.range, CreateDataExportRequestDtoRangeEnum.last7Days);
    });

    test('returns null for clinicShare kind', () {
      final input = reportExportInputForKind(ReviewExportKind.clinicShare);
      expect(input, isNull);
    });

    test('returns correct request for all enum values', () {
      for (final kind in ReviewExportKind.values) {
        final input = reportExportInputForKind(kind);
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
