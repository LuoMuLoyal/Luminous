import 'package:luminous/features/today/domain/entities/suggestion.dart';

/// Domain interface for reading today suggestions and history.
///
/// Implemented by [TodaySuggestionRemoteDataSource] in the data layer.
/// Consumers in other features should depend on this interface, not the
/// concrete data source.
abstract interface class SuggestionRepository {
  /// Fetches the current suggestion bundle.
  Future<TodaySuggestionBundle> fetchSuggestions({
    required String language,
    String? date,
    List<String>? excludeIds,
  });

  /// Submits user feedback for a suggestion.
  Future<TodaySuggestionFeedbackResult> submitFeedback({
    required String id,
    required TodaySuggestionFeedback feedback,
  });

  /// Fetches AI explanation for a suggestion.
  Future<TodaySuggestionExplanation> explainSuggestion({
    required String id,
    required String language,
  });

  /// Fetches suggestion history for the Report page.
  Future<TodaySuggestionHistory> fetchHistory({
    required String language,
    String? startDate,
    String? endDate,
    String? lifecycleState,
    String? type,
    int? limit,
  });
}
