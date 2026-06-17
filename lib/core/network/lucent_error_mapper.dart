import 'package:dio/dio.dart';
import 'package:luminous/core/network/lucent_api_exception.dart';

abstract final class LucentErrorMapper {
  static LucentApiException fromObject(Object error) {
    if (error is LucentApiException) {
      return error;
    }

    if (error is DioException && error.error is LucentApiException) {
      return error.error! as LucentApiException;
    }

    if (error is DioException) {
      return LucentApiException(message: _fallbackMessage(error));
    }

    return const LucentApiException(message: '发生了未预期的错误。');
  }

  static String _fallbackMessage(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout => '连接超时，请稍后再试。',
      DioExceptionType.sendTimeout => '请求发送超时，请稍后再试。',
      DioExceptionType.receiveTimeout => '响应接收超时，请稍后再试。',
      DioExceptionType.badCertificate => '服务器证书校验失败。',
      DioExceptionType.connectionError => '网络请求失败，请检查当前连接。',
      DioExceptionType.cancel => '请求已取消。',
      DioExceptionType.badResponse => '请求失败，请稍后再试。',
      DioExceptionType.unknown => '发生了未预期的网络错误。',
    };
  }
}
