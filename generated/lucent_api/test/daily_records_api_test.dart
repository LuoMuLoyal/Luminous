import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for DailyRecordsApi
void main() {
  final instance = LucentApi().getDailyRecordsApi();

  group(DailyRecordsApi, () {
    // Create a Tencent COS signed URL for daily record image upload
    //
    //Future<DailyRecordImageUploadResponseDto> dailyRecordsControllerCreateImageUploadV1(CreateDailyRecordImageUploadDto createDailyRecordImageUploadDto) async
    test('test dailyRecordsControllerCreateImageUploadV1', () async {
      // TODO
    });

    // Create a daily record
    //
    //Future<DailyRecordResponseDto> dailyRecordsControllerCreateV1(CreateDailyRecordDto createDailyRecordDto) async
    test('test dailyRecordsControllerCreateV1', () async {
      // TODO
    });

    // Soft-delete a daily record
    //
    //Future dailyRecordsControllerDeleteV1(String id) async
    test('test dailyRecordsControllerDeleteV1', () async {
      // TODO
    });

    // Generate AI candidate daily records from a natural-language note
    //
    //Future<DailyRecordCandidateResponseDto> dailyRecordsControllerGenerateCandidatesV1(GenerateDailyRecordCandidatesDto generateDailyRecordCandidatesDto) async
    test('test dailyRecordsControllerGenerateCandidatesV1', () async {
      // TODO
    });

    // Get a daily record by id
    //
    //Future<DailyRecordResponseDto> dailyRecordsControllerGetV1(String id) async
    test('test dailyRecordsControllerGetV1', () async {
      // TODO
    });

    // List daily records for a given date
    //
    //Future<DailyRecordListResponseDto> dailyRecordsControllerListV1(String date, { DailyRecordKind kind, num page, num pageSize }) async
    test('test dailyRecordsControllerListV1', () async {
      // TODO
    });

    // Get daily record summary (counts by kind)
    //
    //Future<DailyRecordSummaryResponseDto> dailyRecordsControllerSummaryV1(String date) async
    test('test dailyRecordsControllerSummaryV1', () async {
      // TODO
    });

    // Update a daily record
    //
    //Future<DailyRecordResponseDto> dailyRecordsControllerUpdateV1(String id, UpdateDailyRecordDto updateDailyRecordDto) async
    test('test dailyRecordsControllerUpdateV1', () async {
      // TODO
    });
  });
}
