import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/settings/presentation/providers/data_export.dart';

void main() {
  group('dataExportUiStatusForRequest', () {
    test('returns idle when request is null', () {
      expect(dataExportUiStatusForRequest(null), DataExportUiStatus.idle);
    });

    test('returns requested when status is requested', () {
      final dto = DataExportRequestData(
        id: 'req-1',
        status: DataExportRequestDataStatusEnum.requested,
        kind: DataExportRequestDataKindEnum.hospital,
        format: DataExportRequestDataFormatEnum.pdf,
        range: DataExportRequestDataRangeEnum.last7Days,
        requestedAt: '2026-07-01T00:00:00.000Z',
        downloadUrl: null,
        completedAt: null,
        fileName: null,
        fileSizeBytes: null,
        errorMessage: null,
      );
      expect(dataExportUiStatusForRequest(dto), DataExportUiStatus.requested);
    });

    test('returns processing when status is processing', () {
      final dto = DataExportRequestData(
        id: 'req-1',
        status: DataExportRequestDataStatusEnum.processing,
        kind: DataExportRequestDataKindEnum.hospital,
        format: DataExportRequestDataFormatEnum.pdf,
        range: DataExportRequestDataRangeEnum.last7Days,
        requestedAt: '2026-07-01T00:00:00.000Z',
        downloadUrl: null,
        completedAt: null,
        fileName: null,
        fileSizeBytes: null,
        errorMessage: null,
      );
      expect(dataExportUiStatusForRequest(dto), DataExportUiStatus.processing);
    });

    test(
      'returns completed when status is completed and downloadUrl exists',
      () {
        final dto = DataExportRequestData(
          id: 'req-1',
          status: DataExportRequestDataStatusEnum.completed,
          downloadUrl: 'https://example.com/export.pdf',
          kind: DataExportRequestDataKindEnum.hospital,
          format: DataExportRequestDataFormatEnum.pdf,
          range: DataExportRequestDataRangeEnum.last7Days,
          requestedAt: '2026-07-01T00:00:00.000Z',
          completedAt: null,
          fileName: null,
          fileSizeBytes: null,
          errorMessage: null,
        );
        expect(dataExportUiStatusForRequest(dto), DataExportUiStatus.completed);
      },
    );

    test(
      'returns completedLinkMissing when status is completed but downloadUrl is null',
      () {
        final dto = DataExportRequestData(
          id: 'req-1',
          status: DataExportRequestDataStatusEnum.completed,
          downloadUrl: null,
          kind: DataExportRequestDataKindEnum.hospital,
          format: DataExportRequestDataFormatEnum.pdf,
          range: DataExportRequestDataRangeEnum.last7Days,
          requestedAt: '2026-07-01T00:00:00.000Z',
          completedAt: null,
          fileName: null,
          fileSizeBytes: null,
          errorMessage: null,
        );
        expect(
          dataExportUiStatusForRequest(dto),
          DataExportUiStatus.completedLinkMissing,
        );
      },
    );

    test(
      'returns completedLinkMissing when status is completed but downloadUrl is empty',
      () {
        final dto = DataExportRequestData(
          id: 'req-1',
          status: DataExportRequestDataStatusEnum.completed,
          downloadUrl: '',
          kind: DataExportRequestDataKindEnum.hospital,
          format: DataExportRequestDataFormatEnum.pdf,
          range: DataExportRequestDataRangeEnum.last7Days,
          requestedAt: '2026-07-01T00:00:00.000Z',
          completedAt: null,
          fileName: null,
          fileSizeBytes: null,
          errorMessage: null,
        );
        expect(
          dataExportUiStatusForRequest(dto),
          DataExportUiStatus.completedLinkMissing,
        );
      },
    );

    test('returns failed when status is failed', () {
      final dto = DataExportRequestData(
        id: 'req-1',
        status: DataExportRequestDataStatusEnum.failed,
        kind: DataExportRequestDataKindEnum.hospital,
        format: DataExportRequestDataFormatEnum.pdf,
        range: DataExportRequestDataRangeEnum.last7Days,
        requestedAt: '2026-07-01T00:00:00.000Z',
        downloadUrl: null,
        completedAt: null,
        fileName: null,
        fileSizeBytes: null,
        errorMessage: null,
      );
      expect(dataExportUiStatusForRequest(dto), DataExportUiStatus.failed);
    });

    test('returns unavailable when status is unavailable', () {
      final dto = DataExportRequestData(
        id: 'req-1',
        status: DataExportRequestDataStatusEnum.unavailable,
        kind: DataExportRequestDataKindEnum.hospital,
        format: DataExportRequestDataFormatEnum.pdf,
        range: DataExportRequestDataRangeEnum.last7Days,
        requestedAt: '2026-07-01T00:00:00.000Z',
        downloadUrl: null,
        completedAt: null,
        fileName: null,
        fileSizeBytes: null,
        errorMessage: null,
      );
      expect(dataExportUiStatusForRequest(dto), DataExportUiStatus.unavailable);
    });

    test('returns failed when status is unknown', () {
      final dto = DataExportRequestData(
        id: 'req-1',
        status: DataExportRequestDataStatusEnum.unknownDefaultOpenApi,
        kind: DataExportRequestDataKindEnum.hospital,
        format: DataExportRequestDataFormatEnum.pdf,
        range: DataExportRequestDataRangeEnum.last7Days,
        requestedAt: '2026-07-01T00:00:00.000Z',
        downloadUrl: null,
        completedAt: null,
        fileName: null,
        fileSizeBytes: null,
        errorMessage: null,
      );
      expect(dataExportUiStatusForRequest(dto), DataExportUiStatus.failed);
    });
  });

  group('DataExportUiStatus enum', () {
    test('has exactly 7 values', () {
      expect(DataExportUiStatus.values, hasLength(7));
    });

    test('contains all expected statuses', () {
      expect(DataExportUiStatus.values, contains(DataExportUiStatus.idle));
      expect(DataExportUiStatus.values, contains(DataExportUiStatus.requested));
      expect(
        DataExportUiStatus.values,
        contains(DataExportUiStatus.processing),
      );
      expect(DataExportUiStatus.values, contains(DataExportUiStatus.completed));
      expect(
        DataExportUiStatus.values,
        contains(DataExportUiStatus.completedLinkMissing),
      );
      expect(DataExportUiStatus.values, contains(DataExportUiStatus.failed));
      expect(
        DataExportUiStatus.values,
        contains(DataExportUiStatus.unavailable),
      );
    });
  });

  group('DataExportRequestInput', () {
    test('default values are hospital/pdf/last7Days', () {
      const input = DataExportRequestInput();
      expect(
        input.kind,
        CreateRequestRequestKindEnum.hospital,
      );
      expect(
        input.format,
        CreateRequestRequestFormatEnum.pdf,
      );
      expect(
        input.range,
        CreateRequestRequestRangeEnum.last7Days,
      );
    });

    test('equality works correctly', () {
      const a = DataExportRequestInput();
      const b = DataExportRequestInput();
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
    });

    test('different inputs are not equal', () {
      const a = DataExportRequestInput();
      const b = DataExportRequestInput(
        kind: CreateRequestRequestKindEnum.monthly,
      );
      expect(a == b, isFalse);
    });

    test('matches returns true for matching request', () {
      const input = DataExportRequestInput();
      final dto = DataExportRequestData(
        id: 'req-1',
        status: DataExportRequestDataStatusEnum.completed,
        kind: DataExportRequestDataKindEnum.hospital,
        format: DataExportRequestDataFormatEnum.pdf,
        range: DataExportRequestDataRangeEnum.last7Days,
        requestedAt: '2026-07-01T00:00:00.000Z',
        downloadUrl: null,
        completedAt: null,
        fileName: null,
        fileSizeBytes: null,
        errorMessage: null,
      );
      expect(input.matches(dto), isTrue);
    });

    test('matches returns false for non-matching request', () {
      const input = DataExportRequestInput();
      final dto = DataExportRequestData(
        id: 'req-1',
        status: DataExportRequestDataStatusEnum.completed,
        kind: DataExportRequestDataKindEnum.monthly,
        format: DataExportRequestDataFormatEnum.pdf,
        range: DataExportRequestDataRangeEnum.last7Days,
        requestedAt: '2026-07-01T00:00:00.000Z',
        downloadUrl: null,
        completedAt: null,
        fileName: null,
        fileSizeBytes: null,
        errorMessage: null,
      );
      expect(input.matches(dto), isFalse);
    });

    test('matches returns false for null request', () {
      const input = DataExportRequestInput();
      expect(input.matches(null), isFalse);
    });

    test('toDto creates correct DTO', () {
      const input = DataExportRequestInput();
      final dto = input.toDto(password: 'export-password');
      expect(
        dto.kind,
        CreateRequestRequestKindEnum.hospital,
      );
      expect(
        dto.format,
        CreateRequestRequestFormatEnum.pdf,
      );
      expect(
        dto.range,
        CreateRequestRequestRangeEnum.last7Days,
      );
    });
  });

  group('DataExportRequestInFlightState', () {
    test('default state is not in flight', () {
      const state = DataExportRequestInFlightState(inFlight: false);
      expect(state.inFlight, isFalse);
      expect(state.input, isNull);
    });

    test('matches returns true when inFlight and input matches', () {
      const input = DataExportRequestInput();
      const state = DataExportRequestInFlightState(
        inFlight: true,
        input: input,
      );
      expect(state.matches(input), isTrue);
    });

    test('matches returns false when not inFlight', () {
      const input = DataExportRequestInput();
      const state = DataExportRequestInFlightState(inFlight: false);
      expect(state.matches(input), isFalse);
    });

    test('matches returns false when input differs', () {
      const state = DataExportRequestInFlightState(
        inFlight: true,
        input: DataExportRequestInput(
          kind: CreateRequestRequestKindEnum.monthly,
        ),
      );
      const other = DataExportRequestInput();
      expect(state.matches(other), isFalse);
    });
  });

  group('Predefined export request constants', () {
    test('reviewHospitalPdfLast7DaysExportRequest has correct defaults', () {
      const input = reviewHospitalPdfLast7DaysExportRequest;
      expect(
        input.kind,
        CreateRequestRequestKindEnum.hospital,
      );
      expect(
        input.format,
        CreateRequestRequestFormatEnum.pdf,
      );
      expect(
        input.range,
        CreateRequestRequestRangeEnum.last7Days,
      );
    });

    test('reviewMonthlyPdfExportRequest has monthly kind', () {
      const input = reviewMonthlyPdfExportRequest;
      expect(
        input.kind,
        CreateRequestRequestKindEnum.monthly,
      );
      expect(
        input.range,
        CreateRequestRequestRangeEnum.last30Days,
      );
    });

    test('reviewPrintPdfExportRequest has print kind', () {
      const input = reviewPrintPdfExportRequest;
      expect(
        input.kind,
        CreateRequestRequestKindEnum.print,
      );
    });
  });
}
