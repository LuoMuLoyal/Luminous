import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for ReportsApi
void main() {
  final instance = LucentApi().getReportsApi();

  group(ReportsApi, () {
    // Download a de-identified clinic summary as PDF (auth required)
    //
    //Future reportsControllerDownloadClinicSummaryPdfV1() async
    test('test reportsControllerDownloadClinicSummaryPdfV1', () async {
      // TODO
    });

    // Download a shared clinic summary as PDF (no auth required)
    //
    //Future reportsControllerDownloadSharedClinicSummaryPdfV1(String token) async
    test('test reportsControllerDownloadSharedClinicSummaryPdfV1', () async {
      // TODO
    });

    // Enqueue async clinic summary PDF export
    //
    //Future<MedicinesControllerRecognizeAsyncV1200Response> reportsControllerExportClinicSummaryPdfAsyncV1() async
    test('test reportsControllerExportClinicSummaryPdfAsyncV1', () async {
      // TODO
    });

    // Poll async clinic summary PDF export status
    //
    //Future reportsControllerExportClinicSummaryPdfStatusV1(String jobId) async
    test('test reportsControllerExportClinicSummaryPdfStatusV1', () async {
      // TODO
    });

    // Enqueue async AI summary generation for report
    //
    //Future<MedicinesControllerRecognizeAsyncV1200Response> reportsControllerGenerateSummaryAsyncV1(GenerateReportSummaryDto generateReportSummaryDto) async
    test('test reportsControllerGenerateSummaryAsyncV1', () async {
      // TODO
    });

    // Poll async report AI summary generation status
    //
    //Future reportsControllerGenerateSummaryStatusV1(String jobId) async
    test('test reportsControllerGenerateSummaryStatusV1', () async {
      // TODO
    });

    // Stream authenticated user AI summary generation for report
    //
    //Future<String> reportsControllerGenerateSummaryStreamV1(GenerateReportSummaryDto generateReportSummaryDto) async
    test('test reportsControllerGenerateSummaryStreamV1', () async {
      // TODO
    });

    // Generate authenticated user AI summary for report
    //
    //Future<ReportSummaryResponseDto> reportsControllerGenerateSummaryV1(GenerateReportSummaryDto generateReportSummaryDto) async
    test('test reportsControllerGenerateSummaryV1', () async {
      // TODO
    });

    // Get authenticated user report dashboard
    //
    //Future<ReportDashboardResponseDto> reportsControllerGetDashboardV1({ String range, String startDate, String endDate }) async
    test('test reportsControllerGetDashboardV1', () async {
      // TODO
    });

    // Access a shared clinic summary by token (no auth required)
    //
    //Future<ClinicSummaryDto> reportsControllerGetSharedClinicSummaryV1(String token) async
    test('test reportsControllerGetSharedClinicSummaryV1', () async {
      // TODO
    });

    // Generate a de-identified clinic summary for sharing with a doctor
    //
    //Future<ClinicSummaryDto> reportsControllerPreviewClinicSummaryV1() async
    test('test reportsControllerPreviewClinicSummaryV1', () async {
      // TODO
    });

    // Create a shareable link for the clinic summary (24h expiry)
    //
    //Future<ClinicSummaryShareResponseDto> reportsControllerShareClinicSummaryV1() async
    test('test reportsControllerShareClinicSummaryV1', () async {
      // TODO
    });
  });
}
