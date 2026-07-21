// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/medicine_detail_response_dto.dart';
import '../models/medicine_safety_tip_response_dto.dart';
import '../models/medicine_search_response_dto.dart';
import '../models/medicines_controller_recognize_async_v1_response.dart';
import '../models/recognize_medicine_dto.dart';
import '../models/source.dart';

part 'medicines_api.g.dart';

@RestApi()
abstract class MedicinesApi {
  factory MedicinesApi(Dio dio, {String? baseUrl}) = _MedicinesApi;

  /// 随机返回用药安全提示.
  ///
  /// [exclude] - 上一次返回的提示 id 列表，用于相邻两次去重.
  @GET('/api/v1/medicines/safety-tips')
  Future<List<MedicineSafetyTipResponseDto>>
  medicinesControllerGetSafetyTipsV1({@Query('exclude') List<String>? exclude});

  /// Search medicines from a selected knowledge source.
  ///
  /// [source] - Knowledge source selector.
  ///
  /// [q] - Search keyword.
  ///
  /// [page] - Page number, 1-based.
  ///
  /// [pageSize] - Page size.
  ///
  /// [xBypassCache] - Set to true/1/no-cache to bypass medicines read cache for this request only.
  @GET('/api/v1/medicines')
  Future<MedicineSearchResponseDto> medicinesControllerSearchV1({
    @Query('q') String? q,
    @Header('x-bypass-cache') String? xBypassCache,
    @Query('source') Source? source = Source.drugbank,
    @Query('page') num? page = 1,
    @Query('pageSize') num? pageSize = 20,
  });

  /// Get medicine detail from a selected knowledge source.
  ///
  /// [id] - Medicine id in the selected source.
  ///
  /// [source] - Knowledge source selector.
  ///
  /// [xBypassCache] - Set to true/1/no-cache to bypass medicines read cache for this request only.
  @GET('/api/v1/medicines/{id}')
  Future<MedicineDetailResponseDto> medicinesControllerGetDetailV1({
    @Path('id') required String id,
    @Header('x-bypass-cache') String? xBypassCache,
    @Query('source') Source? source = Source.drugbank,
  });

  /// AI识别药盒图片，提取药品信息.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/medicines/recognize')
  Future<void> medicinesControllerRecognizeV1({
    @Body() required RecognizeMedicineDto body,
  });

  /// Enqueue async medicine box image recognition.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/medicines/recognize/async')
  Future<MedicinesControllerRecognizeAsyncV1Response>
  medicinesControllerRecognizeAsyncV1({
    @Body() required RecognizeMedicineDto body,
  });

  /// Poll async medicine recognition status
  @GET('/api/v1/medicines/recognize/status/{jobId}')
  Future<void> medicinesControllerRecognizeStatusV1({
    @Path('jobId') required String jobId,
  });
}
