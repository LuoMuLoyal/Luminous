import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';


/// tests for DailyRecordsApi
void main() {
  final instance = LucentOpenapi().getDailyRecordsApi();

  group(DailyRecordsApi, () {
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

    // List daily records for a given date
    //
    //Future<DailyRecordListResponseDto> dailyRecordsControllerListV1(String date, { String kind, String page, String pageSize }) async
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
