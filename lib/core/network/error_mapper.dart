import 'package:dio/dio.dart';
import 'package:luminous/core/errors/error.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/envelope.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/core/network/interceptors/trace_interceptor.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/core/network/result_code.dart';

abstract final class LucentErrorMapper {
  static LucentApiException fromObject(Object error) {
    if (error is LucentApiException) {
      return error;
    }

    if (error is DioException && error.error is LucentApiException) {
      return error.error! as LucentApiException;
    }

    if (error is DioException) {
      final embedded = error.error;
      if (embedded is LucentApiException) {
        return embedded;
      }

      final response = error.response;
      final json = coerceToStringMap(response?.data);
      final envelope = json == null
          ? null
          : LucentEnvelope<Object?>.fromJson(json, dataDecoder: (raw) => raw);
      final requestId = response?.headers.value('X-Request-Id');
      final traceResponse = response?.headers.value('traceresponse');
      final traceId = traceResponse != null && traceResponse.isNotEmpty
          ? traceIdFromTraceHeader(traceResponse)
          : error.requestOptions.extra['traceId'] as String?;

      return LucentApiException(
        message: () {
          final env = envelope;
          if (env != null && env.message.isNotEmpty) {
            return env.message;
          }
          return _fallbackMessage(error);
        }(),
        code: envelope?.code,
        statusCode: response?.statusCode,
        requestId: requestId,
        traceId: traceId,
        data: json,
        networkErrorCode: envelope != null && !envelope.isSuccess
            ? NetworkErrorCode.businessFailure
            : _errorCodeFromDioType(error.type),
      );
    }

    return const LucentApiException(
      message: 'An unexpected error occurred.',
      networkErrorCode: NetworkErrorCode.unknown,
    );
  }

  /// Converts any thrown object into a structured [AppError].
  ///
  /// Delegates to [fromObject] to extract the [LucentApiException], then
  /// derives [AppErrorKind] from HTTP status code, Lucent envelope code,
  /// and Dio error type.
  ///
  /// - HTTP 401 / 403 or auth-related envelope codes → [AppErrorKind.auth]
  /// - HTTP 5xx or server-side envelope codes → [AppErrorKind.server]
  /// - Network timeouts / connection errors → [AppErrorKind.network]
  /// - Other HTTP 4xx with a business envelope code → [AppErrorKind.business]
  /// - Everything else → [AppErrorKind.unknown]
  static AppError toAppError(Object error) {
    final apiException = fromObject(error);
    return AppError(
      message: apiException.message,
      kind: _deriveKind(apiException, error),
      code: apiException.code,
      statusCode: apiException.statusCode,
      requestId: apiException.requestId,
      traceId: apiException.traceId,
      networkErrorCode: apiException.networkErrorCode,
      cause: error,
    );
  }

  static AppErrorKind _deriveKind(
    LucentApiException apiException,
    Object original,
  ) {
    final statusCode = apiException.statusCode;
    final code = apiException.code;

    // Known auth/session envelope codes take priority over HTTP status.
    // wrongPassword (401005) is deliberately excluded — it's a credential
    // validation error, not a session/permission error.
    if (code == LucentResultCode.unauthorized ||
        code == LucentResultCode.tokenExpired ||
        code == LucentResultCode.refreshTokenInvalid ||
        code == LucentResultCode.forbidden) {
      return AppErrorKind.auth;
    }

    // HTTP 401/403 without a specific business code → auth.
    if ((statusCode == 401 || statusCode == 403) && code == null) {
      return AppErrorKind.auth;
    }

    // Server-side: HTTP 5xx or server envelope codes.
    if ((statusCode != null && statusCode >= 500) ||
        code == LucentResultCode.internalError ||
        code == LucentResultCode.databaseError ||
        code == LucentResultCode.externalServiceError) {
      return AppErrorKind.server;
    }

    // Network errors: Dio timeouts / connection failures (no HTTP response).
    if (original is DioException) {
      switch (original.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
        case DioExceptionType.badCertificate:
          return AppErrorKind.network;
        case DioExceptionType.cancel:
        case DioExceptionType.badResponse:
        case DioExceptionType.unknown:
          break;
      }
    }

    // Business logic: HTTP 4xx with a Lucent envelope code (non-auth).
    if (statusCode != null &&
        statusCode >= 400 &&
        statusCode < 500 &&
        code != null) {
      return AppErrorKind.business;
    }

    return AppErrorKind.unknown;
  }

  static String _fallbackMessage(DioException error) {
    return switch (error.type) {
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
