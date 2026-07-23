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

  @override
  String toString() {
    final parts = <String>[
      'LucentApiException(message: $message',
      if (code != null) ', code: $code',
      if (statusCode != null) ', statusCode: $statusCode',
      if (requestId != null && (requestId?.isNotEmpty ?? false))
        ', requestId: $requestId',
      if (networkErrorCode != null) ', networkErrorCode: $networkErrorCode',
      ')',
    ];
    return parts.join();
  }
}
