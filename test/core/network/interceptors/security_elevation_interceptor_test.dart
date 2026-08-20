import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/network/interceptors/security_elevation_interceptor.dart';
import 'package:luminous/core/network/security_elevation_token_holder.dart';

void main() {
  test('injects the bearer elevation token when the holder is valid', () {
    final holder = SecurityElevationTokenHolder();
    holder.set(
      'test-elevation-token',
      DateTime.now().add(const Duration(minutes: 5)),
    );
    final interceptor = SecurityElevationInterceptor(holder: holder);
    final options = RequestOptions(path: '/api/v1/account/password');
    final handler = RequestInterceptorHandler();

    interceptor.onRequest(options, handler);

    expect(
      options.headers['x-security-elevation'],
      'Bearer test-elevation-token',
    );
  });

  test('does not inject an expired elevation token', () {
    final holder = SecurityElevationTokenHolder();
    holder.set(
      'expired-elevation-token',
      DateTime.now().subtract(const Duration(minutes: 1)),
    );
    final interceptor = SecurityElevationInterceptor(holder: holder);
    final options = RequestOptions(path: '/api/v1/account/password');
    final handler = RequestInterceptorHandler();

    interceptor.onRequest(options, handler);

    expect(options.headers.containsKey('x-security-elevation'), isFalse);
  });
}
