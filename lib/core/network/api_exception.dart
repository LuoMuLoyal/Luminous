import 'package:luminous/core/network/error_code.dart';

/// 遗留错误类型：仅保留用于定位剩余构造点（SSE、WeChat 与 medicine
/// datasource 仍在使用）。新代码不得构造本类型 —— HTTP 边界统一使用
/// [LucentFailure]，网络层抛出的 DioException 通过
/// `error` 字段携带 [LucentFailure]。
class LucentApiException implements Exception {
  const LucentApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.requestId,
    this.traceId,
    this.data,
    this.networkErrorCode,
  });

  final String message;
  final int? code;
  final int? statusCode;
  final String? requestId;

  /// The backend trace id of the failing request (from the `traceresponse`
  /// response header, falling back to the outgoing `traceparent`), so logs
  /// can be correlated with the Jaeger trace for this exact request.
  final String? traceId;

  final Object? data;

  /// 当错误来自网络层基础设施（超时、连接失败等），携带此错误码
  /// 供表示层映射为 l10n 字符串。业务错误（code != 0）使用
  /// [NetworkErrorCode.businessFailure]，由服务端 [message] 直接展示。
  final NetworkErrorCode? networkErrorCode;

  bool get isTokenExpired => code == 401002;

  bool get isRefreshTokenInvalid => code == 401003;

  /// True when the error stems from a network connectivity issue
  /// (timeout, connection refused, DNS failure, bad certificate) rather
  /// than an authentication, business, or server-side error.
  ///
  /// Callers should preserve the session store when this is `true` so the
  /// user can retry once connectivity is restored.
  bool get isNetworkConnectivityError =>
      networkErrorCode == NetworkErrorCode.connectionTimeout ||
      networkErrorCode == NetworkErrorCode.sendTimeout ||
      networkErrorCode == NetworkErrorCode.receiveTimeout ||
      networkErrorCode == NetworkErrorCode.connectionError ||
      networkErrorCode == NetworkErrorCode.badCertificate;

  @override
  String toString() {
    final parts = <String>[
      'LucentApiException(message: $message',
      if (code != null) ', code: $code',
      if (statusCode != null) ', statusCode: $statusCode',
      if (requestId != null && requestId!.isNotEmpty) ', requestId: $requestId',
      if (traceId != null && traceId!.isNotEmpty) ', traceId: $traceId',
      if (networkErrorCode != null) ', networkErrorCode: $networkErrorCode',
      ')',
    ];
    return parts.join();
  }
}
