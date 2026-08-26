import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/network/client_providers.dart';
import 'package:luminous/core/network/response_body.dart';
import 'package:luminous/core/providers/auth_guarded.dart';

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
    this.kind = CreateDataExportRequestDtoKindEnum.hospital,
    this.format = CreateDataExportRequestDtoFormatEnum.pdf,
    this.range = CreateDataExportRequestDtoRangeEnum.last7Days,
  });

  final CreateDataExportRequestDtoKindEnum kind;
  final CreateDataExportRequestDtoFormatEnum format;
  final CreateDataExportRequestDtoRangeEnum range;

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

  CreateDataExportRequestDto toDto({required String password}) {
    return CreateDataExportRequestDto(
      kind: kind,
      format: format,
      range: range,
      password: password,
    );
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
    DataExportStatus.unknownDefaultOpenApi => DataExportUiStatus.failed,
  };
}

const reportHospitalPdfLast7DaysExportRequest = DataExportRequestInput();

const reportMonthlyPdfExportRequest = DataExportRequestInput(
  kind: CreateDataExportRequestDtoKindEnum.monthly,
  format: CreateDataExportRequestDtoFormatEnum.pdf,
  range: CreateDataExportRequestDtoRangeEnum.last30Days,
);

const reportPrintPdfExportRequest = DataExportRequestInput(
  kind: CreateDataExportRequestDtoKindEnum.print,
  format: CreateDataExportRequestDtoFormatEnum.pdf,
  range: CreateDataExportRequestDtoRangeEnum.last7Days,
);

/// Controller for the data-export feature.
///
/// - [fetchLatest] reads `GET /api/v1/user/data-export-requests/latest`.
/// - [requestExport] posts `POST /api/v1/user/data-export-requests` and
///   updates the cached latest state.
///
/// The provider is kept alive to avoid disposal/recreation cycles when the
/// report page transitions between loading and ready states.
class DataExportController extends AsyncNotifier<DataExportRequestDataDto?> {
  @override
  Future<DataExportRequestDataDto?> build() async {
    // Keep this provider alive to avoid disposal/recreation cycles when
    // the report page transitions between loading and ready states.
    ref.keepAlive();
    return authGuarded(
      ref: ref,
      fetch: _fetchLatestSafe,
      signedOutFallback: () => pendingAuthSessionResolution(),
    );
  }

  /// Wraps [_fetchLatest] with graceful error handling — returns `null`
  /// instead of throwing so the provider never enters an error state.
  Future<DataExportRequestDataDto?> _fetchLatestSafe() async {
    try {
      return await _fetchLatest();
    } catch (e, st) {
      appTalker.handle(e, st, 'DataExportController._fetchLatestSafe: failed');
      return null;
    }
  }

  /// Posts a new data-export request and updates the cached latest state.
  ///
  /// Throws on failure (network error, server business error, or protocol
  /// error). Callers must wrap this call in a try/catch and surface the error
  /// to the user. The [dataExportRequestInFlightProvider] is always reset in
  /// the finally block, regardless of success or failure.
  Future<DataExportRequestDataDto?> requestExport(
    DataExportRequestInput input, {
    required String password,
  }) async {
    final requestInFlight = ref.read(dataExportRequestInFlightProvider);
    if (requestInFlight.inFlight) {
      return state.asData?.value;
    }

    ref.read(dataExportRequestInFlightProvider.notifier).state =
        DataExportRequestInFlightState(inFlight: true, input: input);
    final api = ref.read(lucentClientProvider).dataExport;
    try {
      final response = await api.dataExportControllerCreateRequestV1(
        createDataExportRequestDto: input.toDto(password: password),
      );
      final responseData = requireData(
        response.data,
        operation: 'createDataExportRequest',
      );
      final data = DataExportRequestDataDto.fromJson(responseData.toJson());
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
    return requireData(response.data, operation: 'fetchLatestDataExport');
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
