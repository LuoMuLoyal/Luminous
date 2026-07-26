import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for UserHealthContextApi
void main() {
  final instance = LucentApi().getUserHealthContextApi();

  group(UserHealthContextApi, () {
    // Create an allergy record
    //
    //Future<HealthContextResponseDto> userHealthContextControllerCreateAllergyV1(CreateHealthContextAllergyDto createHealthContextAllergyDto) async
    test('test userHealthContextControllerCreateAllergyV1', () async {
      // TODO
    });

    // Create a condition record
    //
    //Future<HealthContextResponseDto> userHealthContextControllerCreateConditionV1(CreateHealthContextConditionDto createHealthContextConditionDto) async
    test('test userHealthContextControllerCreateConditionV1', () async {
      // TODO
    });

    // Add a current medicine record
    //
    //Future<HealthContextResponseDto> userHealthContextControllerCreateCurrentMedicineV1(CreateCurrentMedicineDto createCurrentMedicineDto) async
    test('test userHealthContextControllerCreateCurrentMedicineV1', () async {
      // TODO
    });

    // Deactivate an allergy record (soft delete)
    //
    //Future<HealthContextResponseDto> userHealthContextControllerDeleteAllergyV1(String id) async
    test('test userHealthContextControllerDeleteAllergyV1', () async {
      // TODO
    });

    // Resolve a condition record (soft delete)
    //
    //Future<HealthContextResponseDto> userHealthContextControllerDeleteConditionV1(String id) async
    test('test userHealthContextControllerDeleteConditionV1', () async {
      // TODO
    });

    // Deactivate a current medicine record (soft delete)
    //
    //Future<HealthContextResponseDto> userHealthContextControllerDeleteCurrentMedicineV1(String id) async
    test('test userHealthContextControllerDeleteCurrentMedicineV1', () async {
      // TODO
    });

    // Get the current user health context aggregate
    //
    //Future<HealthContextResponseDto> userHealthContextControllerGetUserHealthContextV1() async
    test('test userHealthContextControllerGetUserHealthContextV1', () async {
      // TODO
    });

    // Update an allergy record
    //
    //Future<HealthContextResponseDto> userHealthContextControllerUpdateAllergyV1(String id, UpdateHealthContextAllergyDto updateHealthContextAllergyDto) async
    test('test userHealthContextControllerUpdateAllergyV1', () async {
      // TODO
    });

    // Update a condition record
    //
    //Future<HealthContextResponseDto> userHealthContextControllerUpdateConditionV1(String id, UpdateHealthContextConditionDto updateHealthContextConditionDto) async
    test('test userHealthContextControllerUpdateConditionV1', () async {
      // TODO
    });

    // Update a current medicine record
    //
    //Future<HealthContextResponseDto> userHealthContextControllerUpdateCurrentMedicineV1(String id, UpdateCurrentMedicineDto updateCurrentMedicineDto) async
    test('test userHealthContextControllerUpdateCurrentMedicineV1', () async {
      // TODO
    });

    // Update the current user health-context profile
    //
    //Future<HealthContextResponseDto> userHealthContextControllerUpdateUserHealthContextProfileV1(UpdateHealthContextProfileDto updateHealthContextProfileDto) async
    test(
      'test userHealthContextControllerUpdateUserHealthContextProfileV1',
      () async {
        // TODO
      },
    );
  });
}
