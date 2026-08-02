import 'package:dio/dio.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/envelope.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/core/network/interceptors/trace_interceptor.dart';
import 'package:luminous/core/network/map_utils.dart';

/// Envelope interceptor: validates the Lucent `{ code, message, data }`
/// envelope on every successful HTTP response.
///
/// Placed last in the interceptor chain (after [ErrorInterceptor]) so that
/// `onResponse` runs first in the reverse-order response pipeline. When the
/// envelope indicates a business failure (`code != 0`), the response is
/// rejected as a [DioException] — which then flows backward through
/// [ErrorInterceptor] → [RetryInterceptor] → [AuthInterceptor] via their
/// `onError` handlers, exactly like a network or HTTP-level error.
///
/// This prevents two crash scenarios that `response.data!.data` callers
/// would otherwise hit:
///
/// 1. **Business error with `data: null`** — the generated `fromJson` has
///    `@JsonKey(required: true)` on `data`, so it throws
///    `CheckedFromJsonException` (unmapped, ugly error).
/// 2. **Empty response body** — `response.data` is `null`, causing a null
///    check crash at `response.data!`.
///
/// With this interceptor in place, by the time the response reaches the
/// generated deserialization code, the envelope is guaranteed to have
/// `code == 0` and a non-null body.
class EnvelopeInterceptor extends Interceptor {
  /// Trace id of the request that produced [response]: the backend-confirmed
  /// `traceresponse` header when present, else the outgoing `traceparent`.
  static String? _traceIdFor(Response<dynamic> response) {
    final traceResponse = response.headers.value('traceresponse');
    if (traceResponse != null && traceResponse.isNotEmpty) {
      return traceIdFromTraceHeader(traceResponse);
    }
    return response.requestOptions.extra['traceId'] as String?;
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    // Allow callers to opt out (e.g. raw file downloads).
    if (response.requestOptions.extra['skipEnvelopeCheck'] == true) {
      handler.next(response);
      return;
    }

    final json = coerceToStringMap(response.data);

    // Not a Map — could be a String, List, or null.
    if (json == null) {
      if (response.data == null &&
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: LucentApiException(
              message: '服务器返回了空响应体',
              traceId: _traceIdFor(response),
              networkErrorCode: NetworkErrorCode.emptyResponse,
            ),
          ),
        );
        return;
      }
      handler.next(response);
      return;
    }

    // Only inspect responses that look like a Lucent envelope.
    if (!json.containsKey('code')) {
      handler.next(response);
      return;
    }

    final envelope = LucentEnvelope<Object?>.fromJson(
      json,
      dataDecoder: (raw) => raw,
    );

    if (!envelope.isSuccess) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: LucentApiException(
            message: envelope.message.isNotEmpty
                ? envelope.message
                : '业务错误 (code: ${envelope.code})',
            code: envelope.code,
            statusCode: response.statusCode,
            traceId: _traceIdFor(response),
            networkErrorCode: NetworkErrorCode.businessFailure,
          ),
        ),
      );
      return;
    }

    handler.next(response);
  }
}
