import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';


/// tests for MedicineDoseLogsApi
void main() {
  final instance = LucentOpenapi().getMedicineDoseLogsApi();

  group(MedicineDoseLogsApi, () {
    // Create a dose log
    //
    //Future medicineDoseLogsControllerCreateV1(CreateDoseLogDto createDoseLogDto) async
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
    //Future medicineDoseLogsControllerListV1(String date) async
    test('test medicineDoseLogsControllerListV1', () async {
      // TODO
    });

    // Update a dose log
    //
    //Future medicineDoseLogsControllerUpdateV1(String id, UpdateDoseLogDto updateDoseLogDto) async
    test('test medicineDoseLogsControllerUpdateV1', () async {
      // TODO
    });

  });
}
