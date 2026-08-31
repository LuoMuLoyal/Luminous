// ignore_for_file: avoid_renaming_method_parameters

import 'package:dio/dio.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';

/// Error interceptor: maps `DioException` → `LucentFailure`.
///
/// The actual mapping logic lives in [LucentErrorMapper.fromObject], which is
/// keeping a single source of truth for Problem Details parsing and transport
/// failure classification.
/// This interceptor only adapts the mapped exception back into a rejected
/// [DioException].
///
/// Extracted from the original `LucentDioClient._mapToApiException()` +
/// `_fallbackMessage()`. Placed last in the interceptor chain so that
/// auth-refresh and retry interceptors have already had a chance to
/// recover the request before the error is mapped.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(_rejectWithMappedError(err));
  }

  /// Maps [err] via [LucentErrorMapper.fromObject] and re-wraps it so
  /// downstream handlers receive a [DioException] carrying [LucentFailure].
  DioException _rejectWithMappedError(DioException err) {
    final mapped = LucentErrorMapper.fromObject(err);
    return DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: mapped,
      stackTrace: err.stackTrace,
    );
  }
}
