import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/contract/response_body.dart';
import 'package:luminous/core/providers/network/network_client.dart';
import 'package:luminous/core/providers/session/auth_guarded.dart';
import 'package:luminous/core/providers/session/session_snapshot.dart';

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
    this.kind = CreateRequestRequestKindEnum.hospital,
    this.format = CreateRequestRequestFormatEnum.pdf,
    this.range = CreateRequestRequestRangeEnum.last7Days,
  });

  final CreateRequestRequestKindEnum kind;
  final CreateRequestRequestFormatEnum format;
  final CreateRequestRequestRangeEnum range;

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

  CreateRequestRequest toDto({required String password}) {
    return CreateRequestRequest(
      kind: kind,
      format: format,
      range: range,
      password: password,
    );
  }

  bool matches(ExportRequestData? request) {
    if (request == null) {
      return false;
    }

    return request.kind == _kindToResponse(kind) &&
        request.format == _formatToResponse(format) &&
        request.range == _rangeToResponse(range);
  }

  ExportRequestDataKindEnum _kindToResponse(
    CreateRequestRequestKindEnum value,
  ) {
    return switch (value) {
      CreateRequestRequestKindEnum.hospital =>
        ExportRequestDataKindEnum.hospital,
      CreateRequestRequestKindEnum.monthly => ExportRequestDataKindEnum.monthly,
      CreateRequestRequestKindEnum.print => ExportRequestDataKindEnum.print,
      CreateRequestRequestKindEnum.unknownDefaultOpenApi =>
        ExportRequestDataKindEnum.unknownDefaultOpenApi,
    };
  }

  ExportRequestDataFormatEnum _formatToResponse(
    CreateRequestRequestFormatEnum value,
  ) {
    return switch (value) {
      CreateRequestRequestFormatEnum.pdf => ExportRequestDataFormatEnum.pdf,
      CreateRequestRequestFormatEnum.unknownDefaultOpenApi =>
        ExportRequestDataFormatEnum.unknownDefaultOpenApi,
    };
  }

  ExportRequestDataRangeEnum _rangeToResponse(
    CreateRequestRequestRangeEnum value,
  ) {
    return switch (value) {
      CreateRequestRequestRangeEnum.last7Days =>
        ExportRequestDataRangeEnum.last7Days,
      CreateRequestRequestRangeEnum.last30Days =>
        ExportRequestDataRangeEnum.last30Days,
      CreateRequestRequestRangeEnum.unknownDefaultOpenApi =>
        ExportRequestDataRangeEnum.unknownDefaultOpenApi,
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

DataExportUiStatus dataExportUiStatusForRequest(ExportRequestData? request) {
  if (request == null) {
    return DataExportUiStatus.idle;
  }

  return switch (request.status) {
    ExportRequestDataStatusEnum.requested => DataExportUiStatus.requested,
    ExportRequestDataStatusEnum.processing => DataExportUiStatus.processing,
    ExportRequestDataStatusEnum.completed =>
      request.downloadUrl?.isNotEmpty != true
          ? DataExportUiStatus.completedLinkMissing
          : DataExportUiStatus.completed,
    ExportRequestDataStatusEnum.failed => DataExportUiStatus.failed,
    ExportRequestDataStatusEnum.unavailable => DataExportUiStatus.unavailable,
    ExportRequestDataStatusEnum.unknownDefaultOpenApi =>
      DataExportUiStatus.failed,
  };
}

const reviewHospitalPdfLast7DaysExportRequest = DataExportRequestInput();

const reviewMonthlyPdfExportRequest = DataExportRequestInput(
  kind: CreateRequestRequestKindEnum.monthly,
  format: CreateRequestRequestFormatEnum.pdf,
  range: CreateRequestRequestRangeEnum.last30Days,
);

const reviewPrintPdfExportRequest = DataExportRequestInput(
  kind: CreateRequestRequestKindEnum.print,
  format: CreateRequestRequestFormatEnum.pdf,
  range: CreateRequestRequestRangeEnum.last7Days,
);

/// Controller for the data-export feature.
///
/// - [fetchLatest] reads `GET /api/v1/user/export-requests/latest`.
/// - [requestExport] posts `POST /api/v1/user/export-requests` and
///   updates the cached latest state.
///
/// The provider is kept alive to avoid disposal/recreation cycles when the
/// report page transitions between loading and ready states.
class DataExportController extends AsyncNotifier<ExportRequestData?> {
  @override
  Future<ExportRequestData?> build() async {
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
  Future<ExportRequestData?> _fetchLatestSafe() async {
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
  Future<ExportRequestData?> requestExport(
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
      final response = await api.createRequest(
        createRequestRequest: input.toDto(password: password),
      );
      final responseData = requireData(
        response.data,
        operation: 'createDataExportRequest',
      );
      final data = ExportRequestData.fromJson(responseData.toJson());
      state = AsyncData(data);
      return data;
    } finally {
      ref.read(dataExportRequestInFlightProvider.notifier).state =
          const DataExportRequestInFlightState(inFlight: false);
    }
  }

  Future<ExportRequestData?> refresh() async {
    final latest = await _fetchLatest();
    state = AsyncData(latest);
    return latest;
  }

  Future<ExportRequestData?> _fetchLatest() async {
    final api = ref.read(lucentClientProvider).dataExport;
    final response = await api.getLatestRequest();
    return requireData(response.data, operation: 'fetchLatestDataExport');
  }
}

final dataExportControllerProvider =
    AsyncNotifierProvider<DataExportController, ExportRequestData?>(
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
