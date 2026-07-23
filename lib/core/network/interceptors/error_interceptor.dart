// ignore_for_file: avoid_renaming_method_parameters

import 'package:dio/dio.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/envelope.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/core/network/map_utils.dart';

/// Error interceptor: maps `DioException` → `LucentApiException`.
///
/// Extracted from the original `LucentDioClient._mapToApiException()` +
/// `_fallbackMessage()`. Placed last in the interceptor chain so that
/// auth-refresh and retry interceptors have already had a chance to
/// recover the request before the error is mapped.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(_mapToApiException(err));
  }

  DioException _mapToApiException(DioException err) {
    final response = err.response;
    final json = coerceToStringMap(response?.data);
    final envelope = json == null
        ? null
        : LucentEnvelope<Object?>.fromJson(json, dataDecoder: (raw) => raw);
    final requestId = response?.headers.value('X-Request-Id');

    return DioException(
      requestOptions: err.requestOptions,
      response: response,
      type: err.type,
      error: LucentApiException(
        message: () {
          final env = envelope;
          if (env != null && env.message.isNotEmpty) {
            return env.message;
          }
          return _fallbackMessage(err);
        }(),
        code: envelope?.code,
        statusCode: response?.statusCode,
        requestId: requestId,
        data: json,
        networkErrorCode: envelope != null && !envelope.isSuccess
            ? NetworkErrorCode.businessFailure
            : _errorCodeFromDioType(err.type),
      ),
      stackTrace: err.stackTrace,
    );
  }

  static String _fallbackMessage(DioException err) {
    return switch (err.type) {
      DioExceptionType.connectionTimeout =>
        'Connection timed out. Please try again later.',
      DioExceptionType.sendTimeout =>
        'Request timed out. Please try again later.',
      DioExceptionType.receiveTimeout =>
        'Response timed out. Please try again later.',
      DioExceptionType.badCertificate =>
        'Server certificate verification failed.',
      DioExceptionType.connectionError =>
        'Network request failed. Please check your connection.',
      DioExceptionType.cancel => 'Request was cancelled.',
      DioExceptionType.badResponse => 'Request failed. Please try again later.',
      DioExceptionType.unknown => 'An unexpected network error occurred.',
    };
  }

  static NetworkErrorCode _errorCodeFromDioType(DioExceptionType type) {
    return switch (type) {
      DioExceptionType.connectionTimeout => NetworkErrorCode.connectionTimeout,
      DioExceptionType.sendTimeout => NetworkErrorCode.sendTimeout,
      DioExceptionType.receiveTimeout => NetworkErrorCode.receiveTimeout,
      DioExceptionType.badCertificate => NetworkErrorCode.badCertificate,
      DioExceptionType.connectionError => NetworkErrorCode.connectionError,
      DioExceptionType.cancel => NetworkErrorCode.cancelled,
      DioExceptionType.badResponse => NetworkErrorCode.badResponse,
      DioExceptionType.unknown => NetworkErrorCode.unknown,
    };
  }
}
