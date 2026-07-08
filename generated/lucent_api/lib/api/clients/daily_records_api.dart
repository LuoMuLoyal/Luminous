// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/create_daily_record_dto.dart';
import '../models/create_daily_record_image_upload_dto.dart';
import '../models/daily_record_candidate_response_dto.dart';
import '../models/daily_record_image_upload_response_dto.dart';
import '../models/daily_record_kind.dart';
import '../models/daily_record_list_response_dto.dart';
import '../models/daily_record_response_dto.dart';
import '../models/daily_record_summary_response_dto.dart';
import '../models/generate_daily_record_candidates_dto.dart';
import '../models/update_daily_record_dto.dart';

part 'daily_records_api.g.dart';

@RestApi()
abstract class DailyRecordsApi {
  factory DailyRecordsApi(Dio dio, {String? baseUrl}) = _DailyRecordsApi;

  /// List daily records for a given date.
  ///
  /// [date] - Date in YYYY-MM-DD format.
  ///
  /// [page] - Page number (1-based).
  ///
  /// [pageSize] - Page size (1-100).
  @GET('/api/v1/user/daily-records')
  Future<DailyRecordListResponseDto> dailyRecordsControllerListV1({
    @Query('date') required String date,
    @Query('kind') DailyRecordKind? kind,
    @Query('page') num? page,
    @Query('pageSize') num? pageSize,
  });

  /// Create a daily record.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/daily-records')
  Future<DailyRecordResponseDto> dailyRecordsControllerCreateV1({
    @Body() required CreateDailyRecordDto body,
  });

  /// Get daily record summary (counts by kind)
  @GET('/api/v1/user/daily-records/summary')
  Future<DailyRecordSummaryResponseDto> dailyRecordsControllerSummaryV1({
    @Query('date') required String date,
  });

  /// Create a Tencent COS signed URL for daily record image upload.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/daily-records/attachments/images/presign-upload')
  Future<DailyRecordImageUploadResponseDto>
  dailyRecordsControllerCreateImageUploadV1({
    @Body() required CreateDailyRecordImageUploadDto body,
  });

  /// Generate AI candidate daily records from a natural-language note.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/daily-records/candidate-records/generate')
  Future<DailyRecordCandidateResponseDto>
  dailyRecordsControllerGenerateCandidatesV1({
    @Body() required GenerateDailyRecordCandidatesDto body,
  });

  /// Get a daily record by id
  @GET('/api/v1/user/daily-records/{id}')
  Future<DailyRecordResponseDto> dailyRecordsControllerGetV1({
    @Path('id') required String id,
  });

  /// Update a daily record.
  ///
  /// [body] - Name not received - field will be skipped.
  @PATCH('/api/v1/user/daily-records/{id}')
  Future<DailyRecordResponseDto> dailyRecordsControllerUpdateV1({
    @Path('id') required String id,
    @Body() required UpdateDailyRecordDto body,
  });

  /// Soft-delete a daily record
  @DELETE('/api/v1/user/daily-records/{id}')
  Future<void> dailyRecordsControllerDeleteV1({@Path('id') required String id});
}
