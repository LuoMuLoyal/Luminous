import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

// tests for TodaySuggestionsDataDto
void main() {
  final TodaySuggestionsDataDto? instance = /* TodaySuggestionsDataDto(...) */
      null;
  // TODO add properties to the entity

  group(TodaySuggestionsDataDto, () {
    // When the suggestions were generated
    // String generatedAt
    test('to test the property `generatedAt`', () async {
      // TODO
    });

    // Primary suggestion card (highest priority)
    // SuggestionItemDto primary
    test('to test the property `primary`', () async {
      // TODO
    });

    // Secondary suggestion cards (max 2)
    // List<SuggestionItemDto> secondary
    test('to test the property `secondary`', () async {
      // TODO
    });

    // Low-confidence observations
    // List<SuggestionItemDto> observations
    test('to test the property `observations`', () async {
      // TODO
    });

    // When true, one or more suggestion rules threw an error during evaluation — the returned list may be incomplete.
    // Object degraded
    test('to test the property `degraded`', () async {
      // TODO
    });
  });
}
