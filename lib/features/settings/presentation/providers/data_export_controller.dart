import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';

class DataExportRequestInput {
  const DataExportRequestInput({
    this.kind = CreateDataExportRequestDtoKindEnum.hospital,
    this.format = CreateDataExportRequestDtoFormatEnum.pdf,
    this.range = CreateDataExportRequestDtoRangeEnum.last7Days,
  });

  final CreateDataExportRequestDtoKindEnum kind;
  final CreateDataExportRequestDtoFormatEnum format;
  final CreateDataExportRequestDtoRangeEnum range;

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

  DataExportKind _kindToResponse(CreateDataExportRequestDtoKindEnum value) {
    return switch (value) {
      CreateDataExportRequestDtoKindEnum.hospital => DataExportKind.hospital,
      CreateDataExportRequestDtoKindEnum.monthly => DataExportKind.monthly,
      CreateDataExportRequestDtoKindEnum.print => DataExportKind.print,
      CreateDataExportRequestDtoKindEnum.unknownDefaultOpenApi =>
        DataExportKind.unknownDefaultOpenApi,
    };
  }

  DataExportFormat _formatToResponse(
    CreateDataExportRequestDtoFormatEnum value,
  ) {
    return switch (value) {
      CreateDataExportRequestDtoFormatEnum.pdf => DataExportFormat.pdf,
      CreateDataExportRequestDtoFormatEnum.unknownDefaultOpenApi =>
        DataExportFormat.unknownDefaultOpenApi,
    };
  }

  DataExportRange _rangeToResponse(CreateDataExportRequestDtoRangeEnum value) {
    return switch (value) {
      CreateDataExportRequestDtoRangeEnum.last7Days =>
        DataExportRange.last7Days,
      CreateDataExportRequestDtoRangeEnum.last30Days =>
        DataExportRange.last30Days,
      CreateDataExportRequestDtoRangeEnum.unknownDefaultOpenApi =>
        DataExportRange.unknownDefaultOpenApi,
    };
  }
}

const reportHospitalPdfLast7DaysExportRequest = DataExportRequestInput();

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
    if (requestInFlight) {
      return state.asData?.value;
    }

    ref.read(dataExportRequestInFlightProvider.notifier).state = true;
    final api = ref.read(lucentDataExportApiProvider);
    try {
      final response = await api.dataExportControllerCreateRequestV1(
        createDataExportRequestDto: input.toDto(),
      );
      final data = response.data?.data;
      state = AsyncData(data);
      return data;
    } finally {
      ref.read(dataExportRequestInFlightProvider.notifier).state = false;
    }
  }

  Future<DataExportRequestDataDto?> refresh() async {
    final latest = await _fetchLatest();
    state = AsyncData(latest);
    return latest;
  }

  Future<DataExportRequestDataDto?> _fetchLatest() async {
    final api = ref.read(lucentDataExportApiProvider);
    final response = await api.dataExportControllerGetLatestRequestV1();
    return response.data?.data;
  }
}

final dataExportControllerProvider =
    AsyncNotifierProvider<DataExportController, DataExportRequestDataDto?>(
      DataExportController.new,
    );

class DataExportRequestInFlightNotifier extends Notifier<bool> {
  @override
  bool build() => false;
}

final dataExportRequestInFlightProvider =
    NotifierProvider<DataExportRequestInFlightNotifier, bool>(
      DataExportRequestInFlightNotifier.new,
    );
