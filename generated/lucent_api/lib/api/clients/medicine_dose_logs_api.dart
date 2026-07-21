// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/create_dose_log_dto.dart';
import '../models/dose_log_list_response_dto.dart';
import '../models/dose_log_response_dto.dart';
import '../models/mark_dose_log_dto.dart';
import '../models/update_dose_log_dto.dart';

part 'medicine_dose_logs_api.g.dart';

@RestApi()
abstract class MedicineDoseLogsApi {
  factory MedicineDoseLogsApi(Dio dio, {String? baseUrl}) =
      _MedicineDoseLogsApi;

  /// List dose logs for a date
  @GET('/api/v1/user/medicine-dose-logs')
  Future<DoseLogListResponseDto> medicineDoseLogsControllerListV1({
    @Query('date') required String date,
    @Query('page') num? page,
    @Query('pageSize') num? pageSize,
  });

  /// Create a dose log.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/medicine-dose-logs')
  Future<DoseLogResponseDto> medicineDoseLogsControllerCreateV1({
    @Body() required CreateDoseLogDto body,
  });

  /// Mark a dose log idempotently for one reminder slot.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/medicine-dose-logs/mark')
  Future<DoseLogResponseDto> medicineDoseLogsControllerMarkV1({
    @Body() required MarkDoseLogDto body,
  });

  /// Update a dose log.
  ///
  /// [body] - Name not received - field will be skipped.
  @PATCH('/api/v1/user/medicine-dose-logs/{id}')
  Future<DoseLogResponseDto> medicineDoseLogsControllerUpdateV1({
    @Path('id') required String id,
    @Body() required UpdateDoseLogDto body,
  });

  /// Soft-delete a dose log
  @DELETE('/api/v1/user/medicine-dose-logs/{id}')
  Future<void> medicineDoseLogsControllerDeleteV1({
    @Path('id') required String id,
  });
}
