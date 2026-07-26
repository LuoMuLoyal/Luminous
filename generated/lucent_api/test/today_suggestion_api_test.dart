import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for TodaySuggestionApi
void main() {
  final instance = LucentApi().getTodaySuggestionApi();

  group(TodaySuggestionApi, () {
    // Enqueue async AI explanation for a suggestion card
    //
    //Future<MedicinesControllerRecognizeAsyncV1200Response> todaySuggestionControllerExplainSuggestionAsyncV1(String id, String acceptLanguage) async
    test('test todaySuggestionControllerExplainSuggestionAsyncV1', () async {
      // TODO
    });

    // Poll async suggestion explanation status
    //
    //Future todaySuggestionControllerExplainSuggestionStatusV1(String jobId) async
    test('test todaySuggestionControllerExplainSuggestionStatusV1', () async {
      // TODO
    });

    // Get AI explanation for a suggestion card
    //
    //Future<SuggestionExplanationResponseDto> todaySuggestionControllerExplainSuggestionV1(String id, String acceptLanguage) async
    test('test todaySuggestionControllerExplainSuggestionV1', () async {
      // TODO
    });

    // Get suggestion history for the Report page
    //
    //Future<SuggestionHistoryResponseDto> todaySuggestionControllerGetHistoryV1({ String startDate, String endDate, String lifecycleState, String type, num limit }) async
    test('test todaySuggestionControllerGetHistoryV1', () async {
      // TODO
    });

    // Get Today page suggestion cards
    //
    //Future<TodaySuggestionsResponseDto> todaySuggestionControllerGetSuggestionsV1(String acceptLanguage, { String date, List<String> excludeIds }) async
    test('test todaySuggestionControllerGetSuggestionsV1', () async {
      // TODO
    });

    // Submit feedback for a suggestion card
    //
    //Future<SuggestionFeedbackResponseDto> todaySuggestionControllerSubmitFeedbackV1(String id, SuggestionFeedbackDto suggestionFeedbackDto) async
    test('test todaySuggestionControllerSubmitFeedbackV1', () async {
      // TODO
    });
  });
}
