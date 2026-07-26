import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

// tests for DailyRecordItemDto
void main() {
  final DailyRecordItemDto? instance = /* DailyRecordItemDto(...) */ null;
  // TODO add properties to the entity

  group(DailyRecordItemDto, () {
    // Record id.
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // DailyRecordKind kind
    test('to test the property `kind`', () async {
      // TODO
    });

    // Date in YYYY-MM-DD format.
    // String occurredAt
    test('to test the property `occurredAt`', () async {
      // TODO
    });

    // Time in HH:mm 24-hour format when available.
    // String occurredTime
    test('to test the property `occurredTime`', () async {
      // TODO
    });

    // Short label.
    // String title
    test('to test the property `title`', () async {
      // TODO
    });

    // Measured value.
    // String value
    test('to test the property `value`', () async {
      // TODO
    });

    // Unit label.
    // String unit
    test('to test the property `unit`', () async {
      // TODO
    });

    // Free-text note.
    // String note
    test('to test the property `note`', () async {
      // TODO
    });

    // Source.
    // String source_
    test('to test the property `source_`', () async {
      // TODO
    });

    // Structured payload for kind-specific data. For sleep: { startAt, endAt, durationMinutes, quality?, deepMinutes?, lightMinutes?, remMinutes? }.
    // Map<String, Object> payload
    test('to test the property `payload`', () async {
      // TODO
    });

    // Meal analysis status for meal records.
    // String mealAnalysisStatus
    test('to test the property `mealAnalysisStatus`', () async {
      // TODO
    });

    // Meal analysis coverage for meal records.
    // String mealAnalysisCoverage
    test('to test the property `mealAnalysisCoverage`', () async {
      // TODO
    });

    // Meal analysis updated timestamp (ISO 8601).
    // String mealAnalysisUpdatedAt
    test('to test the property `mealAnalysisUpdatedAt`', () async {
      // TODO
    });

    // Display-safe meal analysis failure reason.
    // String mealAnalysisFailureReason
    test('to test the property `mealAnalysisFailureReason`', () async {
      // TODO
    });

    // Short meal description for list reads.
    // String mealShortDescription
    test('to test the property `mealShortDescription`', () async {
      // TODO
    });

    // Top recognized foods for list reads.
    // List<String> mealTopFoods
    test('to test the property `mealTopFoods`', () async {
      // TODO
    });

    // List<DailyRecordAttachmentDto> attachments
    test('to test the property `attachments`', () async {
      // TODO
    });

    // Created at (ISO 8601).
    // String createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

    // Updated at (ISO 8601).
    // String updatedAt
    test('to test the property `updatedAt`', () async {
      // TODO
    });
  });
}
