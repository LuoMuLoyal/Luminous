// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/clinic_summary_dto.dart';
import '../models/clinic_summary_share_response_dto.dart';
import '../models/generate_report_summary_dto.dart';
import '../models/range.dart';
import '../models/report_dashboard_response_dto.dart';
import '../models/report_summary_response_dto.dart';
import '../models/reports_controller_export_clinic_summary_pdf_async_v1_response.dart';
import '../models/reports_controller_generate_summary_async_v1_response.dart';

part 'reports_api.g.dart';

@RestApi()
abstract class ReportsApi {
  factory ReportsApi(Dio dio, {String? baseUrl}) = _ReportsApi;

  /// Get authenticated user report dashboard.
  ///
  /// [range] - Supported report aggregation range.
  ///
  /// [startDate] - Required when range is "custom". ISO 8601 date string (YYYY-MM-DD).
  ///
  /// [endDate] - Required when range is "custom". ISO 8601 date string (YYYY-MM-DD).
  @GET('/api/v1/user/reports/dashboard')
  Future<ReportDashboardResponseDto> reportsControllerGetDashboardV1({
    @Query('startDate') String? startDate,
    @Query('endDate') String? endDate,
    @Query('range') Range? range = Range.last7Days,
  });

  /// Generate authenticated user AI summary for report.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/reports/summary/generate')
  Future<ReportSummaryResponseDto> reportsControllerGenerateSummaryV1({
    @Body() required GenerateReportSummaryDto body,
  });

  /// Enqueue async AI summary generation for report.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/reports/summary/generate/async')
  Future<ReportsControllerGenerateSummaryAsyncV1Response>
  reportsControllerGenerateSummaryAsyncV1({
    @Body() required GenerateReportSummaryDto body,
  });

  /// Poll async report AI summary generation status
  @GET('/api/v1/user/reports/summary/generate/status/{jobId}')
  Future<void> reportsControllerGenerateSummaryStatusV1({
    @Path('jobId') required String jobId,
  });

  /// Stream authenticated user AI summary generation for report.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/reports/summary/generate/stream')
  Future<String> reportsControllerGenerateSummaryStreamV1({
    @Body() required GenerateReportSummaryDto body,
  });

  /// Generate a de-identified clinic summary for sharing with a doctor
  @POST('/api/v1/user/reports/clinic-summary/preview')
  Future<ClinicSummaryDto> reportsControllerPreviewClinicSummaryV1();

  /// Create a shareable link for the clinic summary (24h expiry)
  @POST('/api/v1/user/reports/clinic-summary/share')
  Future<ClinicSummaryShareResponseDto> reportsControllerShareClinicSummaryV1();

  /// Access a shared clinic summary by token (no auth required)
  @GET('/api/v1/user/reports/clinic-summary/shared/{token}')
  Future<ClinicSummaryDto> reportsControllerGetSharedClinicSummaryV1({
    @Path('token') required String token,
  });

  /// Enqueue async clinic summary PDF export
  @POST('/api/v1/user/reports/clinic-summary/export/async')
  Future<ReportsControllerExportClinicSummaryPdfAsyncV1Response>
  reportsControllerExportClinicSummaryPdfAsyncV1();

  /// Poll async clinic summary PDF export status
  @GET('/api/v1/user/reports/clinic-summary/export/status/{jobId}')
  Future<void> reportsControllerExportClinicSummaryPdfStatusV1({
    @Path('jobId') required String jobId,
  });

  /// Download a de-identified clinic summary as PDF (auth required)
  @GET('/api/v1/user/reports/clinic-summary/preview/pdf')
  Future<void> reportsControllerDownloadClinicSummaryPdfV1();

  /// Download a shared clinic summary as PDF (no auth required)
  @GET('/api/v1/user/reports/clinic-summary/shared/{token}/pdf')
  Future<void> reportsControllerDownloadSharedClinicSummaryPdfV1({
    @Path('token') required String token,
  });
}
