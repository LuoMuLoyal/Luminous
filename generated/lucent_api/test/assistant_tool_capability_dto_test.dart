import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

// tests for AssistantToolCapabilityDto
void main() {
  final AssistantToolCapabilityDto?
  instance = /* AssistantToolCapabilityDto(...) */ null;
  // TODO add properties to the entity

  group(AssistantToolCapabilityDto, () {
    // Stable tool identifier exposed to the client.
    // String name
    test('to test the property `name`', () async {
      // TODO
    });

    // Context sources this tool requires before it may run. Allowed values: health_profile, daily_records, sleep_records, current_medicines.
    // List<String> requiredContextSources
    test('to test the property `requiredContextSources`', () async {
      // TODO
    });

    // Whether the current user settings permit this tool in principle.
    // bool permittedByUser
    test('to test the property `permittedByUser`', () async {
      // TODO
    });

    // Whether this tool is currently executable for this user.
    // bool enabled
    test('to test the property `enabled`', () async {
      // TODO
    });

    // Whether the server has already implemented this tool beyond planning/foundation wiring.
    // bool implemented
    test('to test the property `implemented`', () async {
      // TODO
    });

    // Why the tool is currently disabled, or null when enabled.
    // String disabledReason
    test('to test the property `disabledReason`', () async {
      // TODO
    });
  });
}
