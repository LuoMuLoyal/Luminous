import 'package:luminous/core/network/error_code.dart';

class LucentApiException implements Exception {
  const LucentApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.requestId,
    this.data,
    this.networkErrorCode,
  });

  final String message;
  final int? code;
  final int? statusCode;
  final String? requestId;
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
      if (networkErrorCode != null) ', networkErrorCode: $networkErrorCode',
      ')',
    ];
    return parts.join();
  }
}
