import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';


/// tests for MedicineRemindersApi
void main() {
  final instance = LucentOpenapi().getMedicineRemindersApi();

  group(MedicineRemindersApi, () {
    // Create a medicine reminder schedule
    //
    //Future<MedicineReminderResponseDto> medicineRemindersControllerCreateV1(CreateMedicineReminderDto createMedicineReminderDto) async
    test('test medicineRemindersControllerCreateV1', () async {
      // TODO
    });

    // Soft-delete a medicine reminder schedule
    //
    //Future medicineRemindersControllerDeleteV1(String id) async
    test('test medicineRemindersControllerDeleteV1', () async {
      // TODO
    });

    // List medicine reminder schedules
    //
    //Future<MedicineReminderListResponseDto> medicineRemindersControllerListV1({ String activeOnly }) async
    test('test medicineRemindersControllerListV1', () async {
      // TODO
    });

    // Update a medicine reminder schedule
    //
    //Future<MedicineReminderResponseDto> medicineRemindersControllerUpdateV1(String id, UpdateMedicineReminderDto updateMedicineReminderDto) async
    test('test medicineRemindersControllerUpdateV1', () async {
      // TODO
    });

  });
}
