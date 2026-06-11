import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_network_providers.dart';

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

  Future<void> requestExport() async {
    final api = ref.read(lucentDataExportApiProvider);
    final response =
        await api.dataExportControllerCreateRequestV1();
    state = AsyncData(response.data?.data);
  }

  Future<void> refresh() async {
    state = AsyncData(await _fetchLatest());
  }

  Future<DataExportRequestDataDto?> _fetchLatest() async {
    final api = ref.read(lucentDataExportApiProvider);
    final response =
        await api.dataExportControllerGetLatestRequestV1();
    return response.data?.data;
  }
}

final dataExportControllerProvider =
    AsyncNotifierProvider<DataExportController, DataExportRequestDataDto?>(
  DataExportController.new,
);
