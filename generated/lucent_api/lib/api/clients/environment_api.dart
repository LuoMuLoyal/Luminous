// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/environment_snapshot_response_dto.dart';

part 'environment_api.g.dart';

@RestApi()
abstract class EnvironmentApi {
  factory EnvironmentApi(Dio dio, {String? baseUrl}) = _EnvironmentApi;

  /// Get static environment snapshot reference data.
  ///
  /// [lat] - Approximate latitude.
  ///
  /// [lon] - Approximate longitude.
  @GET('/api/v1/environment/snapshot')
  Future<EnvironmentSnapshotResponseDto> environmentControllerGetSnapshotV1({
    @Query('lat') num? lat,
    @Query('lon') num? lon,
  });
}
