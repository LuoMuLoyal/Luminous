// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/lang.dart';
import '../models/legal_document_detail_response_dto.dart';
import '../models/legal_document_list_response_dto.dart';

part 'legal_documents_api.g.dart';

@RestApi()
abstract class LegalDocumentsApi {
  factory LegalDocumentsApi(Dio dio, {String? baseUrl}) = _LegalDocumentsApi;

  /// List all active legal documents.
  ///
  /// [lang] - Content language: 'zh' or 'en'. Default: 'zh'.
  @GET('/api/v1/legal-documents')
  Future<LegalDocumentListResponseDto> legalDocumentsControllerFindAllV1({
    @Query('lang') Lang? lang,
  });

  /// Get a specific legal document by type.
  ///
  /// [lang] - Content language: 'zh' or 'en'. Default: 'zh'.
  @GET('/api/v1/legal-documents/{docType}')
  Future<LegalDocumentDetailResponseDto> legalDocumentsControllerFindOneV1({
    @Path('docType') required String docType,
    @Query('lang') Lang? lang,
  });
}
