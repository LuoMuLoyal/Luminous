import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';

// tests for UserHealthSummaryDto
void main() {
  final UserHealthSummaryDto? instance = /* UserHealthSummaryDto(...) */ null;
  // TODO add properties to the entity

  group(UserHealthSummaryDto, () {
    // Age derived from birth date. Null when birth date is missing.
    // Object age
    test('to test the property `age`', () async {
      // TODO
    });

    // Whether the onboarding flow has been completed.
    // bool onboardingCompleted
    test('to test the property `onboardingCompleted`', () async {
      // TODO
    });

    // Number of active allergy records returned in this payload.
    // num activeAllergyCount
    test('to test the property `activeAllergyCount`', () async {
      // TODO
    });

    // Number of condition records returned in this payload.
    // num conditionCount
    test('to test the property `conditionCount`', () async {
      // TODO
    });

    // Number of current medicine records returned in this payload.
    // num currentMedicineCount
    test('to test the property `currentMedicineCount`', () async {
      // TODO
    });

    // Missing core profile fields that the frontend can use for onboarding nudges.
    // List<String> missingCoreProfileFields
    test('to test the property `missingCoreProfileFields`', () async {
      // TODO
    });

  });
}
