import 'package:dio/dio.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/interceptors/trace_interceptor.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/contract/problem_details.dart';
import 'package:luminous/core/network/map_utils.dart';

abstract final class LucentErrorMapper {
  /// Converts a transport error into the target application failure type.
  ///
  /// HTTP errors must be RFC 9457 Problem Details with the
  /// `application/problem+json` media type. The retired success envelope is
  /// intentionally not parsed here.
  static LucentFailure fromObject(Object error) {
    if (error is LucentFailure) {
      return error;
    }

    if (error is DioException) {
      final embedded = error.error;
      if (embedded is LucentFailure) {
        return embedded;
      }

      final response = error.response;
      if (response != null) {
        return _fromProblemResponse(error, response);
      }

      return LucentFailure.network(
        message: _networkMessage(error.type),
        networkErrorCode: _errorCodeFromDioType(error.type),
        traceId: _traceIdFor(error),
        cause: error,
      );
    }

    return LucentFailure.unknown(
      message: 'An unexpected error occurred.',
      cause: error,
    );
  }

  static LucentFailure _fromProblemResponse(
    DioException error,
    Response<dynamic> response,
  ) {
    final mediaType = response.headers
        .value(Headers.contentTypeHeader)
        ?.split(';')
        .first
        .trim()
        .toLowerCase();
    if (mediaType != 'application/problem+json') {
      throw FormatException(
        'Lucent HTTP error must use application/problem+json, got ${mediaType ?? '<missing>'}',
      );
    }

    final json = coerceToStringMap(response.data);
    if (json == null) {
      throw const FormatException(
        'Lucent Problem Details body must be an object',
      );
    }

    final problem = ProblemDetails.fromJson(json);
    return LucentFailure.fromProblemDetails(
      problem,
      statusCode: response.statusCode ?? 0,
      traceId: _traceIdFor(error),
      cause: error,
    );
  }

  static String? _traceIdFor(DioException error) {
    final traceResponse = error.response?.headers.value('traceresponse');
    if (traceResponse != null && traceResponse.isNotEmpty) {
      return traceIdFromTraceHeader(traceResponse);
    }
    return error.requestOptions.extra['traceId'] as String?;
  }

  static String _networkMessage(DioExceptionType type) {
    return switch (type) {
      DioExceptionType.connectionTimeout =>
        'Connection timed out. Please try again later.',
      DioExceptionType.sendTimeout =>
        'Request timed out. Please try again later.',
      DioExceptionType.receiveTimeout =>
        'Response timed out. Please try again later.',
      DioExceptionType.transformTimeout =>
        'Response processing timed out. Please try again later.',
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
      DioExceptionType.transformTimeout => NetworkErrorCode.receiveTimeout,
      DioExceptionType.badCertificate => NetworkErrorCode.badCertificate,
      DioExceptionType.connectionError => NetworkErrorCode.connectionError,
      DioExceptionType.cancel => NetworkErrorCode.cancelled,
      DioExceptionType.badResponse => NetworkErrorCode.badResponse,
      DioExceptionType.unknown => NetworkErrorCode.unknown,
    };
  }
}
