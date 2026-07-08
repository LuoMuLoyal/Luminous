// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/health_response_dto.dart';

part 'health_api.g.dart';

@RestApi()
abstract class HealthApi {
  factory HealthApi(Dio dio, {String? baseUrl}) = _HealthApi;

  /// Readiness probe alias used by existing scripts
  @GET('/api/v1/health')
  Future<HealthResponseDto> appControllerGetHealthV1();

  /// Liveness probe for process health
  @GET('/api/v1/health/live')
  Future<HealthResponseDto> appControllerGetLiveHealthV1();

  /// Readiness probe for critical runtime dependencies
  @GET('/api/v1/health/ready')
  Future<HealthResponseDto> appControllerGetReadyHealthV1();

  /// Detailed health probe with per-component diagnostics
  @GET('/api/v1/health/deep')
  Future<HealthResponseDto> appControllerGetDeepHealthV1();
}
