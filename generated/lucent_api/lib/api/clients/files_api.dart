// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/create_file_upload_dto.dart';

part 'files_api.g.dart';

@RestApi()
abstract class FilesApi {
  factory FilesApi(Dio dio, {String? baseUrl}) = _FilesApi;

  /// Create a presigned upload URL for a file.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/files/upload')
  Future<void> filesControllerCreateUploadV1({
    @Body() required CreateFileUploadDto body,
  });
}
