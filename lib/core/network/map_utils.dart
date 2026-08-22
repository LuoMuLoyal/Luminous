import 'package:dio/dio.dart';

import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/core/network/problem_details.dart';

/// Coerces a JSON-decoded value into a `Map<String, dynamic>`.
///
/// Handles the common case where deserialized maps come back as
/// `Map<dynamic, dynamic>` and need their keys cast to `String`.
Map<String, dynamic>? coerceToStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, dynamic val) => MapEntry(key.toString(), val));
  }
  return null;
}

/// Coerces a [Response.data] into a `Map<String, dynamic>`, throwing a
/// [DioException] if the body is empty or not a map.
Map<String, dynamic> requireBody(
  Response<dynamic> response, {
  String? message,
}) {
  final body = coerceToStringMap(response.data);
  if (body == null) {
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      type: DioExceptionType.badResponse,
      error: message ?? 'Response body is empty.',
    );
  }
  return body;
}

/// Coerces a JSON-decoded SSE payload into a `Map<String, dynamic>`,
/// throwing [LucentApiException] if the data is not a map.
Map<String, dynamic> requireMap(Object? data) {
  final map = coerceToStringMap(data);
  if (map == null) {
    throw const LucentApiException(
      message: 'Lucent SSE payload is invalid.',
      networkErrorCode: NetworkErrorCode.invalidSsePayload,
    );
  }
  return map;
}

/// Maps a strict SSE Problem Details event into a [LucentFailure].
LucentFailure mapSseStreamError(Object? data) {
  final problem = SseProblemDetails.fromJson(requireMap(data));
  return LucentFailure.fromSseProblemDetails(problem);
}
