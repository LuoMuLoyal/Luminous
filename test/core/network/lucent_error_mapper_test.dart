import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/core/network/lucent_error_mapper.dart';

void main() {
  group('LucentErrorMapper', () {
    test('passes through LucentApiException', () {
      const original = LucentApiException(message: 'Original', code: 400001);
      final result = LucentErrorMapper.fromObject(original);
      expect(identical(result, original), isTrue);
    });

    test('extracts LucentApiException from DioException error field', () {
      const inner = LucentApiException(message: 'Inner error', code: 401001);
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        error: inner,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(result.message, equals('Inner error'));
      expect(result.code, equals(401001));
    });

    test('maps connectionTimeout to Chinese message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(result.message, equals('连接超时，请稍后再试。'));
    });

    test('maps sendTimeout to Chinese message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.sendTimeout,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(result.message, equals('请求发送超时，请稍后再试。'));
    });

    test('maps receiveTimeout to Chinese message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.receiveTimeout,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(result.message, equals('响应接收超时，请稍后再试。'));
    });

    test('maps badCertificate to Chinese message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badCertificate,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(result.message, equals('服务器证书校验失败。'));
    });

    test('maps connectionError to Chinese message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(result.message, equals('网络请求失败，请检查当前连接。'));
    });

    test('maps cancel to Chinese message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(result.message, equals('请求已取消。'));
    });

    test('maps badResponse to Chinese message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(result.message, equals('请求失败，请稍后再试。'));
    });

    test('maps unknown to Chinese fallback message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.unknown,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(result.message, equals('发生了未预期的网络错误。'));
    });

    test('returns fallback for non-DioException non-Lucent error', () {
      final result = LucentErrorMapper.fromObject(Exception('Some error'));
      expect(result.message, equals('发生了未预期的错误。'));
    });
  });
}
