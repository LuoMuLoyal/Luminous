import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_api.dart';

/// Remote data source that fetches medicine search/detail data from Lucent.
class MedicineSearchRemoteDataSource {
  MedicineSearchRemoteDataSource({required this._api});

  final MedicinesApi _api;

  /// Calls GET /api/v1/medicines?source=&q=&page=&pageSize=
  Future<MedicineSearchResponseDto> search({
    required String source,
    String? query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _api.medicinesControllerSearchV1(
      source_: source,
      q: query,
      page: page,
      pageSize: pageSize,
    );
    return response.data!;
  }

  /// Calls GET /api/v1/medicines/:id?source=
  Future<MedicineDetailResponseDto> getDetail({
    required String id,
    required String source,
  }) async {
    final response = await _api.medicinesControllerGetDetailV1(
      id: id,
      source_: source,
    );
    return response.data!;
  }
}
