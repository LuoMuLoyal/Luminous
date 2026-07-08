// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/app_info_response_dto.dart';
import '../models/scope.dart';
import '../models/support_resource_list_response_dto.dart';

part 'support_resources_api.g.dart';

@RestApi()
abstract class SupportResourcesApi {
  factory SupportResourcesApi(Dio dio, {String? baseUrl}) =
      _SupportResourcesApi;

  /// Get static support resource entries.
  ///
  /// [scope] - Filter by scope: 'help', 'about'. Default: all.
  @GET('/api/v1/public/support-resources')
  Future<SupportResourceListResponseDto>
  supportResourcesControllerGetResourcesV1({@Query('scope') Scope? scope});

  /// Get application metadata
  @GET('/api/v1/public/app-info')
  Future<AppInfoResponseDto> supportResourcesControllerGetAppInfoV1();
}
