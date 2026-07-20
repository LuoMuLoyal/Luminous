import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/error_mapper.dart';

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

    test('maps connectionTimeout to locale-neutral message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(
        result.message,
        equals('Connection timed out. Please try again later.'),
      );
    });

    test('maps sendTimeout to locale-neutral message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.sendTimeout,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(
        result.message,
        equals('Request timed out. Please try again later.'),
      );
    });

    test('maps receiveTimeout to locale-neutral message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.receiveTimeout,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(
        result.message,
        equals('Response timed out. Please try again later.'),
      );
    });

    test('maps badCertificate to locale-neutral message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badCertificate,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(result.message, equals('Server certificate verification failed.'));
    });

    test('maps connectionError to locale-neutral message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(
        result.message,
        equals('Network request failed. Please check your connection.'),
      );
    });

    test('maps cancel to locale-neutral message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(result.message, equals('Request was cancelled.'));
    });

    test('maps badResponse to locale-neutral message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(result.message, equals('Request failed. Please try again later.'));
    });

    test('maps unknown to locale-neutral fallback message', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.unknown,
      );
      final result = LucentErrorMapper.fromObject(dioError);
      expect(result.message, equals('An unexpected network error occurred.'));
    });

    test('returns fallback for non-DioException non-Lucent error', () {
      final result = LucentErrorMapper.fromObject(Exception('Some error'));
      expect(result.message, equals('An unexpected error occurred.'));
    });
  });
}
