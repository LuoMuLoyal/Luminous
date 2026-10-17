import 'package:dio/dio.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/client/interceptors/trace_interceptor.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/contract/problem_details.dart';
import 'package:luminous/core/network/map_utils.dart';

abstract final class LucentErrorMapper {
  /// Maps a Dio failure type to its [NetworkErrorCode].
  ///
  /// Exposed so non-Problem-Details transports (object storage's presigned PUT)
  /// can classify connectivity failures with the same vocabulary as the
  /// central mapper instead of inventing their own.
  static NetworkErrorCode errorCodeFromDioType(DioExceptionType type) {
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
        message: _networkDiagnostic(error.type),
        networkErrorCode: errorCodeFromDioType(error.type),
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

  /// Developer-facing diagnostic only — never rendered to users.
  ///
  /// User copy always resolves from [NetworkErrorCode] at the render site via
  /// `NetworkErrorL10n.map` (see `userMessageFromError`). Keeping a second,
  /// English-only copy of that text here caused it to drift from the ARB
  /// strings and leak untranslated text wherever `l10n` was not threaded
  /// through, so this deliberately carries no user wording.
  static String _networkDiagnostic(DioExceptionType type) {
    return 'DioExceptionType.$type';
  }
}
