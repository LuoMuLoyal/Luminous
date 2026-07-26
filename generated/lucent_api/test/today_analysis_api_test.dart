import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for TodayAnalysisApi
void main() {
  final instance = LucentApi().getTodayAnalysisApi();

  group(TodayAnalysisApi, () {
    // Enqueue async today AI analysis generation
    //
    //Future<MedicinesControllerRecognizeAsyncV1200Response> todayAnalysisControllerGenerateAsyncV1(GenerateTodayAnalysisDto generateTodayAnalysisDto) async
    test('test todayAnalysisControllerGenerateAsyncV1', () async {
      // TODO
    });

    // Poll async today analysis generation status
    //
    //Future todayAnalysisControllerGenerateStatusV1(String jobId) async
    test('test todayAnalysisControllerGenerateStatusV1', () async {
      // TODO
    });

    // Stream authenticated user today AI analysis generation
    //
    //Future<String> todayAnalysisControllerGenerateStreamV1(GenerateTodayAnalysisDto generateTodayAnalysisDto) async
    test('test todayAnalysisControllerGenerateStreamV1', () async {
      // TODO
    });

    // Generate authenticated user today AI analysis
    //
    //Future<TodayAnalysisResponseDto> todayAnalysisControllerGenerateV1(GenerateTodayAnalysisDto generateTodayAnalysisDto) async
    test('test todayAnalysisControllerGenerateV1', () async {
      // TODO
    });

    // Get random daily health recommendations
    //
    //Future<List<TodayRecommendationResponseDto>> todayAnalysisControllerGetRecommendationsV1({ List<String> exclude }) async
    test('test todayAnalysisControllerGetRecommendationsV1', () async {
      // TODO
    });
  });
}
