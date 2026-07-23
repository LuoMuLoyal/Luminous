/// Network-layer error codes used to map l10n strings in the presentation layer.
///
/// The network layer carries this enum (not hardcoded message text) when throwing
/// [LucentApiException]. The presentation layer maps it to a localized string via
/// [NetworkErrorL10n].
enum NetworkErrorCode {
  /// Business code is non-zero ({code, message, data} envelope code != 0)
  businessFailure,

  /// Stream response is empty
  emptyStreamResponse,

  /// SSE payload cannot be parsed as a Map
  invalidSsePayload,

  /// Response body is empty
  emptyResponse,

  /// Connection timeout
  connectionTimeout,

  /// Request send timeout
  sendTimeout,

  /// Response receive timeout
  receiveTimeout,

  /// Server certificate validation failed
  badCertificate,

  /// Network connection failed
  connectionError,

  /// Request cancelled
  cancelled,

  /// HTTP 状态码错误
  badResponse,

  /// 未知网络错误
  unknown,
}
