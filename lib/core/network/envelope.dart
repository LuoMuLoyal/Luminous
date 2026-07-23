import 'api_exception.dart';
import 'error_code.dart';
import 'map_utils.dart';

class LucentEnvelope<T> {
  factory LucentEnvelope.fromJson(
    Map<String, dynamic> json, {
    T Function(Object? rawData)? dataDecoder,
  }) {
    final codeValue = json['code'];
    final messageValue = json['message'];
    final rawData = json['data'];
    final metaValue = json['meta'];

    return LucentEnvelope<T>(
      code: _parseCode(codeValue),
      message: messageValue?.toString() ?? '',
      data: dataDecoder == null ? rawData as T? : dataDecoder(rawData),
      meta: coerceToStringMap(metaValue),
    );
  }
  const LucentEnvelope({
    required this.code,
    required this.message,
    required this.data,
    this.meta,
  });

  final int code;
  final String message;
  final T? data;
  final Map<String, dynamic>? meta;

  bool get isSuccess => code == 0;

  /// Throws [LucentApiException] if [isSuccess] is false. No-op on success.
  ///
  /// Use this for fire-and-forget operations where the caller doesn't need
  /// the [data] payload — only validation that the business code is zero.
  void throwIfFailed() {
    if (!isSuccess) {
      throw LucentApiException(
        message: message.isNotEmpty
            ? message
            : 'Business failure (code: $code)',
        code: code,
        networkErrorCode: NetworkErrorCode.businessFailure,
      );
    }
  }

  /// Returns [data] if [isSuccess], otherwise throws [LucentApiException].
  ///
  /// Equivalent to [throwIfFailed] followed by returning [data]. Use this
  /// when the caller needs the unwrapped data payload.
  T unwrapOrThrow() {
    throwIfFailed();
    return data as T;
  }

  static int _parseCode(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? -1;
    return -1;
  }
}

/// Throws [LucentApiException] when [code] is non-zero (business failure).
///
/// Use this at call sites that work with generated API client response DTOs
/// (which share the `{ code, message, data }` envelope shape but don't
/// inherit from [LucentEnvelope]). For raw envelope objects parsed via
/// [LucentEnvelope.fromJson], prefer [LucentEnvelope.throwIfFailed] or
/// [LucentEnvelope.unwrapOrThrow] instead.
void ensureEnvelopeSuccess({required num code, required String message}) {
  if (code != 0) {
    final intCode = code is int ? code : code.toInt();
    throw LucentApiException(
      message: message.isNotEmpty
          ? message
          : 'Business failure (code: $intCode)',
      code: intCode,
      networkErrorCode: NetworkErrorCode.businessFailure,
    );
  }
}
