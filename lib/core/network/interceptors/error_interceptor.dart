// ignore_for_file: avoid_renaming_method_parameters

import 'package:dio/dio.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/envelope.dart';
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
      ),
      stackTrace: err.stackTrace,
    );
  }

  static String _fallbackMessage(DioException err) {
    return switch (err.type) {
      DioExceptionType.connectionTimeout => '连接超时，请稍后再试。',
      DioExceptionType.sendTimeout => '请求发送超时，请稍后再试。',
      DioExceptionType.receiveTimeout => '响应接收超时，请稍后再试。',
      DioExceptionType.badCertificate => '服务器证书校验失败。',
      DioExceptionType.connectionError => '网络请求失败，请检查当前连接。',
      DioExceptionType.cancel => '请求已取消。',
      DioExceptionType.badResponse => '请求失败，请稍后再试。',
      DioExceptionType.unknown => '发生了未预期的网络错误。',
    };
  }
}
