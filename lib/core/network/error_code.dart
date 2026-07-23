/// 网络层错误码，用于在表示层映射 l10n 字符串。
///
/// 网络层抛出 [LucentApiException] 时携带此枚举而非硬编码消息文本。
/// 表示层通过 [NetworkErrorL10n] 将此枚举映射为本地化字符串。
enum NetworkErrorCode {
  /// 业务码非零（{code, message, data} envelope 的 code != 0）
  businessFailure,

  /// 流式响应为空
  emptyStreamResponse,

  /// SSE payload 无法解析为 Map
  invalidSsePayload,

  /// 响应体为空
  emptyResponse,

  /// 连接超时
  connectionTimeout,

  /// 请求发送超时
  sendTimeout,

  /// 响应接收超时
  receiveTimeout,

  /// 服务器证书校验失败
  badCertificate,

  /// 网络连接失败
  connectionError,

  /// 请求已取消
  cancelled,

  /// HTTP 状态码错误
  badResponse,

  /// 未知网络错误
  unknown,
}
