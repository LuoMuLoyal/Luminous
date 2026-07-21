// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/generate_today_analysis_dto.dart';
import '../models/today_analysis_controller_generate_async_v1_response.dart';
import '../models/today_analysis_response_dto.dart';
import '../models/today_recommendation_response_dto.dart';

part 'today_analysis_api.g.dart';

@RestApi()
abstract class TodayAnalysisApi {
  factory TodayAnalysisApi(Dio dio, {String? baseUrl}) = _TodayAnalysisApi;

  /// Generate authenticated user today AI analysis.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/today-analysis/generate')
  Future<TodayAnalysisResponseDto> todayAnalysisControllerGenerateV1({
    @Body() required GenerateTodayAnalysisDto body,
  });

  /// Enqueue async today AI analysis generation.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/today-analysis/generate/async')
  Future<TodayAnalysisControllerGenerateAsyncV1Response>
  todayAnalysisControllerGenerateAsyncV1({
    @Body() required GenerateTodayAnalysisDto body,
  });

  /// Poll async today analysis generation status
  @GET('/api/v1/user/today-analysis/generate/status/{jobId}')
  Future<void> todayAnalysisControllerGenerateStatusV1({
    @Path('jobId') required String jobId,
  });

  /// 随机返回今日健康推荐.
  ///
  /// [exclude] - 上一次返回的推荐 id 列表，用于相邻两次去重.
  @GET('/api/v1/user/today-analysis/recommendations')
  Future<List<TodayRecommendationResponseDto>>
  todayAnalysisControllerGetRecommendationsV1({
    @Query('exclude') List<String>? exclude,
  });

  /// Stream authenticated user today AI analysis generation.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/today-analysis/generate/stream')
  Future<String> todayAnalysisControllerGenerateStreamV1({
    @Body() required GenerateTodayAnalysisDto body,
  });
}
