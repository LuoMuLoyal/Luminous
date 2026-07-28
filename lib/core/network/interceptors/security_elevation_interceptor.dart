// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';
import 'package:luminous/core/network/security_elevation_token_holder.dart';

/// Security elevation interceptor: injects the `x-security-elevation`
/// Bearer header on every outgoing request when a valid elevation token
/// is available.
///
/// Endpoints that **require** elevation (e.g. `POST /data-export-requests`,
/// `POST /account/password`) will return 403 without this header. Endpoints
/// that don't require elevation simply ignore the extra header.
class SecurityElevationInterceptor extends Interceptor {
  SecurityElevationInterceptor({required SecurityElevationTokenHolder holder})
    : _holder = holder;

  final SecurityElevationTokenHolder _holder;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _holder.token;
    if (token != null) {
      options.headers['x-security-elevation'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
