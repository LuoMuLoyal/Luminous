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

    return const LucentApiException(message: 'Unexpected error.');
  }

  static String _fallbackMessage(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out.',
      DioExceptionType.sendTimeout => 'Request send timed out.',
      DioExceptionType.receiveTimeout => 'Response receive timed out.',
      DioExceptionType.badCertificate => 'Bad server certificate.',
      DioExceptionType.connectionError => 'Network request failed.',
      DioExceptionType.cancel => 'Request was cancelled.',
      DioExceptionType.badResponse => 'Request failed.',
      DioExceptionType.unknown => 'Unexpected network error.',
    };
  }
}
