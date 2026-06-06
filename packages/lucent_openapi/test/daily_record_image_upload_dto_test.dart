import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';

// tests for DailyRecordImageUploadDto
void main() {
  final DailyRecordImageUploadDto? instance = /* DailyRecordImageUploadDto(...) */ null;
  // TODO add properties to the entity

  group(DailyRecordImageUploadDto, () {
    // String provider
    test('to test the property `provider`', () async {
      // TODO
    });

    // String bucket
    test('to test the property `bucket`', () async {
      // TODO
    });

    // String objectKey
    test('to test the property `objectKey`', () async {
      // TODO
    });

    // Signed PUT URL for direct COS upload.
    // String uploadUrl
    test('to test the property `uploadUrl`', () async {
      // TODO
    });

    // Headers that must be sent with the PUT upload.
    // Object headers
    test('to test the property `headers`', () async {
      // TODO
    });

    // Optional public/CDN URL when TENCENT_COS_PUBLIC_BASE_URL is configured.
    // Object publicUrl
    test('to test the property `publicUrl`', () async {
      // TODO
    });

    // Signed URL expiry timestamp (ISO 8601).
    // String expiresAt
    test('to test the property `expiresAt`', () async {
      // TODO
    });

    // Maximum accepted upload size in bytes.
    // num maxSizeBytes
    test('to test the property `maxSizeBytes`', () async {
      // TODO
    });

  });
}
