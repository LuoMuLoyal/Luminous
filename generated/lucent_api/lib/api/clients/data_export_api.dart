// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/create_data_export_request_dto.dart';
import '../models/data_export_latest_response_dto.dart';
import '../models/data_export_request_response_dto.dart';

part 'data_export_api.g.dart';

@RestApi()
abstract class DataExportApi {
  factory DataExportApi(Dio dio, {String? baseUrl}) = _DataExportApi;

  /// Create a new data export request.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/data-export-requests')
  Future<DataExportRequestResponseDto> dataExportControllerCreateRequestV1({
    @Body() required CreateDataExportRequestDto body,
  });

  /// Get the latest data export request
  @GET('/api/v1/user/data-export-requests/latest')
  Future<DataExportLatestResponseDto> dataExportControllerGetLatestRequestV1();
}
