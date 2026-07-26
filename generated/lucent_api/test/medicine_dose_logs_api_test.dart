import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for MedicineDoseLogsApi
void main() {
  final instance = LucentApi().getMedicineDoseLogsApi();

  group(MedicineDoseLogsApi, () {
    // Create a dose log
    //
    //Future<DoseLogResponseDto> medicineDoseLogsControllerCreateV1(CreateDoseLogDto createDoseLogDto) async
    test('test medicineDoseLogsControllerCreateV1', () async {
      // TODO
    });

    // Soft-delete a dose log
    //
    //Future medicineDoseLogsControllerDeleteV1(String id) async
    test('test medicineDoseLogsControllerDeleteV1', () async {
      // TODO
    });

    // List dose logs for a date
    //
    //Future<DoseLogListResponseDto> medicineDoseLogsControllerListV1(String date, { num page, num pageSize }) async
    test('test medicineDoseLogsControllerListV1', () async {
      // TODO
    });

    // Mark a dose log idempotently for one reminder slot
    //
    //Future<DoseLogResponseDto> medicineDoseLogsControllerMarkV1(MarkDoseLogDto markDoseLogDto) async
    test('test medicineDoseLogsControllerMarkV1', () async {
      // TODO
    });

    // Update a dose log
    //
    //Future<DoseLogResponseDto> medicineDoseLogsControllerUpdateV1(String id, UpdateDoseLogDto updateDoseLogDto) async
    test('test medicineDoseLogsControllerUpdateV1', () async {
      // TODO
    });
  });
}
