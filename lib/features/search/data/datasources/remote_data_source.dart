import 'package:lucent_api/api/export.dart';
import 'package:luminous/core/network/api.dart';

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
    return _api.medicinesControllerSearchV1(
      source: Source.fromJson(source),
      q: query,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Calls GET /api/v1/medicines/:id?source=
  Future<MedicineDetailResponseDto> getDetail({
    required String id,
    required String source,
  }) async {
    return _api.medicinesControllerGetDetailV1(
      id: id,
      source: Source.fromJson(source),
    );
  }
}
