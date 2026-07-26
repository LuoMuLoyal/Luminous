import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

// tests for CreateDailyRecordDto
void main() {
  final CreateDailyRecordDto? instance = /* CreateDailyRecordDto(...) */ null;
  // TODO add properties to the entity

  group(CreateDailyRecordDto, () {
    // DailyRecordKind kind
    test('to test the property `kind`', () async {
      // TODO
    });

    // Date in YYYY-MM-DD format. For sleep records this is the wake date (the morning the user wakes up from that sleep).
    // String occurredAt
    test('to test the property `occurredAt`', () async {
      // TODO
    });

    // Time in HH:mm 24-hour format. When omitted, UI flows may treat the record as date-only.
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

    // Structured payload for kind-specific data. For sleep: { startAt, endAt, durationMinutes, quality?, deepMinutes?, lightMinutes?, remMinutes? }. endAt is an ISO 8601 timestamp whose date component matches occurredAt (wake date). startAt is the bedtime ISO 8601 timestamp and may fall on the day before occurredAt for cross-midnight sleep.
    // Object payload
    test('to test the property `payload`', () async {
      // TODO
    });

    // Attachment metadata. File upload itself is handled separately.
    // List<DailyRecordAttachmentInputDto> attachments
    test('to test the property `attachments`', () async {
      // TODO
    });
  });
}
