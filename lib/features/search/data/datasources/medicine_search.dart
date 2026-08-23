import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/error_code.dart';

/// Remote data source that fetches medicine search/detail data from Lucent.
///
/// Transport-only: keeps a `Future` boundary and propagates [DioException]
/// (HTTP errors) and [LucentFailure] (empty success body, per the auth
/// `_requireBody` precedent). Failure mapping to the repository boundary
/// happens exclusively in the repository via `LucentErrorMapper.fromObject`.
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
    return _requireBody(response.data, 'medicine search');
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
    return _requireBody(response.data, 'medicine detail');
  }

  /// Extracts the response body, throwing a network failure when the server
  /// returns an empty body (auth `_requireBody` precedent — an empty success
  /// body is a transport-level failure, not a protocol invariant).
  ///
  /// [operation] names the API call so production errors carry request
  /// context.
  T _requireBody<T>(T? body, String operation) {
    if (body == null) {
      throw LucentFailure.network(
        message: 'API 返回空响应体（$operation）',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return body;
  }
}
