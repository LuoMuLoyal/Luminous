import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/network_providers.dart';

class DataExportRequestInFlightState {
  const DataExportRequestInFlightState({required this.inFlight, this.input});

  final bool inFlight;
  final DataExportRequestInput? input;

  bool matches(DataExportRequestInput candidate) {
    return inFlight && input == candidate;
  }
}

class DataExportRequestInput {
  const DataExportRequestInput({
    this.kind = CreateDataExportRequestDtoKindKind.hospital,
    this.format = CreateDataExportRequestDtoFormatFormat.pdf,
    this.range = CreateDataExportRequestDtoRangeRange.last7Days,
  });

  final CreateDataExportRequestDtoKindKind kind;
  final CreateDataExportRequestDtoFormatFormat format;
  final CreateDataExportRequestDtoRangeRange range;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DataExportRequestInput &&
            kind == other.kind &&
            format == other.format &&
            range == other.range;
  }

  @override
  int get hashCode => Object.hash(kind, format, range);

  CreateDataExportRequestDto toDto() {
    return CreateDataExportRequestDto(kind: kind, format: format, range: range);
  }

  bool matches(DataExportRequestDataDto? request) {
    if (request == null) {
      return false;
    }

    return request.kind == _kindToResponse(kind) &&
        request.format == _formatToResponse(format) &&
        request.range == _rangeToResponse(range);
  }

  DataExportKind _kindToResponse(CreateDataExportRequestDtoKindKind value) {
    return switch (value) {
      CreateDataExportRequestDtoKindKind.hospital => DataExportKind.hospital,
      CreateDataExportRequestDtoKindKind.monthly => DataExportKind.monthly,
      CreateDataExportRequestDtoKindKind.print => DataExportKind.print,
      CreateDataExportRequestDtoKindKind.$unknown => DataExportKind.$unknown,
    };
  }

  DataExportFormat _formatToResponse(
    CreateDataExportRequestDtoFormatFormat value,
  ) {
    return switch (value) {
      CreateDataExportRequestDtoFormatFormat.pdf => DataExportFormat.pdf,
      CreateDataExportRequestDtoFormatFormat.$unknown =>
        DataExportFormat.$unknown,
    };
  }

  DataExportRange _rangeToResponse(CreateDataExportRequestDtoRangeRange value) {
    return switch (value) {
      CreateDataExportRequestDtoRangeRange.last7Days =>
        DataExportRange.last7Days,
      CreateDataExportRequestDtoRangeRange.last30Days =>
        DataExportRange.last30Days,
      CreateDataExportRequestDtoRangeRange.$unknown => DataExportRange.$unknown,
    };
  }
}

enum DataExportUiStatus {
  idle,
  requested,
  processing,
  completed,
  completedLinkMissing,
  failed,
  unavailable,
}

DataExportUiStatus dataExportUiStatusForRequest(
  DataExportRequestDataDto? request,
) {
  if (request == null) {
    return DataExportUiStatus.idle;
  }

  return switch (request.status) {
    DataExportStatus.requested => DataExportUiStatus.requested,
    DataExportStatus.processing => DataExportUiStatus.processing,
    DataExportStatus.completed =>
      request.downloadUrl?.isNotEmpty != true
          ? DataExportUiStatus.completedLinkMissing
          : DataExportUiStatus.completed,
    DataExportStatus.failed => DataExportUiStatus.failed,
    DataExportStatus.unavailable => DataExportUiStatus.unavailable,
    DataExportStatus.$unknown => DataExportUiStatus.failed,
  };
}

const reportHospitalPdfLast7DaysExportRequest = DataExportRequestInput();

const reportMonthlyPdfExportRequest = DataExportRequestInput(
  kind: CreateDataExportRequestDtoKindKind.monthly,
  format: CreateDataExportRequestDtoFormatFormat.pdf,
  range: CreateDataExportRequestDtoRangeRange.last30Days,
);

const reportPrintPdfExportRequest = DataExportRequestInput(
  kind: CreateDataExportRequestDtoKindKind.print,
  format: CreateDataExportRequestDtoFormatFormat.pdf,
  range: CreateDataExportRequestDtoRangeRange.last7Days,
);

/// Controller for the data-export feature.
///
/// - [fetchLatest] reads `GET /api/v1/user/data-export-requests/latest`.
/// - [requestExport] posts `POST /api/v1/user/data-export-requests` and
///   updates the cached latest state.
class DataExportController extends AsyncNotifier<DataExportRequestDataDto?> {
  @override
  Future<DataExportRequestDataDto?> build() async {
    return _fetchLatest();
  }

  Future<DataExportRequestDataDto?> requestExport([
    DataExportRequestInput input = reportHospitalPdfLast7DaysExportRequest,
  ]) async {
    final requestInFlight = ref.read(dataExportRequestInFlightProvider);
    if (requestInFlight.inFlight) {
      return state.asData?.value;
    }

    ref.read(dataExportRequestInFlightProvider.notifier).state =
        DataExportRequestInFlightState(inFlight: true, input: input);
    final api = ref.read(lucentClientProvider).dataExport;
    try {
      final response = await api.dataExportControllerCreateRequestV1(
        body: input.toDto(),
      );
      final data = response.data;
      state = AsyncData(data);
      return data;
    } finally {
      ref.read(dataExportRequestInFlightProvider.notifier).state =
          const DataExportRequestInFlightState(inFlight: false);
    }
  }

  Future<DataExportRequestDataDto?> refresh() async {
    final latest = await _fetchLatest();
    state = AsyncData(latest);
    return latest;
  }

  Future<DataExportRequestDataDto?> _fetchLatest() async {
    final api = ref.read(lucentClientProvider).dataExport;
    final response = await api.dataExportControllerGetLatestRequestV1();
    return response.data;
  }
}

final dataExportControllerProvider =
    AsyncNotifierProvider<DataExportController, DataExportRequestDataDto?>(
      DataExportController.new,
    );

class DataExportRequestInFlightNotifier
    extends Notifier<DataExportRequestInFlightState> {
  @override
  DataExportRequestInFlightState build() =>
      const DataExportRequestInFlightState(inFlight: false);
}

final dataExportRequestInFlightProvider =
    NotifierProvider<
      DataExportRequestInFlightNotifier,
      DataExportRequestInFlightState
    >(DataExportRequestInFlightNotifier.new);
