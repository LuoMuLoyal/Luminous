// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:retrofit/error_logger.dart';

import '../models/lifecycle_state.dart';
import '../models/suggestion_explanation_response_dto.dart';
import '../models/suggestion_feedback_dto.dart';
import '../models/suggestion_feedback_response_dto.dart';
import '../models/suggestion_history_response_dto.dart';
import '../models/today_suggestions_response_dto.dart';
import '../models/type.dart';

part 'today_suggestion_api.g.dart';

@RestApi()
abstract class TodaySuggestionApi {
  factory TodaySuggestionApi(Dio dio, {String? baseUrl}) = _TodaySuggestionApi;

  /// Get Today page suggestion cards.
  ///
  /// [date] - Target date (YYYY-MM-DD). Defaults to today.
  ///
  /// [excludeIds] - Suggestion IDs the user has dismissed.
  @GET('/api/v1/user/today/suggestions')
  Future<TodaySuggestionsResponseDto>
  todaySuggestionControllerGetSuggestionsV1({
    @Query('date') String? date,
    @Query('excludeIds') List<String>? excludeIds,
  });

  /// Submit feedback for a suggestion card.
  ///
  /// [body] - Name not received - field will be skipped.
  @POST('/api/v1/user/today/suggestions/{id}/feedback')
  Future<SuggestionFeedbackResponseDto>
  todaySuggestionControllerSubmitFeedbackV1({
    @Path('id') required String id,
    @Body() required SuggestionFeedbackDto body,
  });

  /// Get AI explanation for a suggestion card
  @POST('/api/v1/user/today/suggestions/{id}/explain')
  Future<SuggestionExplanationResponseDto>
  todaySuggestionControllerExplainSuggestionV1({
    @Path('id') required String id,
    @Header('accept-language') required String acceptLanguage,
  });

  /// Get suggestion history for the Report page.
  ///
  /// [startDate] - Start date (YYYY-MM-DD). Defaults to 30 days ago.
  ///
  /// [endDate] - End date (YYYY-MM-DD). Defaults to today.
  ///
  /// [lifecycleState] - Filter by lifecycle state.
  ///
  /// [type] - Filter by suggestion type.
  ///
  /// [limit] - Max items (default 100, max 500).
  @GET('/api/v1/user/today/suggestions/history')
  Future<SuggestionHistoryResponseDto> todaySuggestionControllerGetHistoryV1({
    @Query('startDate') String? startDate,
    @Query('endDate') String? endDate,
    @Query('lifecycleState') LifecycleState? lifecycleState,
    @Query('type') Type? type,
    @Query('limit') num? limit,
  });
}
