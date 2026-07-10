import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/today/data/datasources/suggestion_remote_data_source.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';

final todaySuggestionRemoteDataSourceProvider =
    Provider<TodaySuggestionRemoteDataSource>((ref) {
      return TodaySuggestionRemoteDataSource(
        api: ref.watch(lucentTodaySuggestionApiProvider),
      );
    });

/// Manages the lifecycle of Today suggestion cards: fetch, dismiss, feedback.
///
/// Returns `null` when the user is not authenticated (signed-out / preview).
/// After [submitFeedback] or [dismiss], the provider automatically re-fetches
/// so the UI stays in sync with the backend arbitration engine.
final todaySuggestionProvider =
    AsyncNotifierProvider<TodaySuggestionNotifier, TodaySuggestionBundle?>(
      TodaySuggestionNotifier.new,
    );

class TodaySuggestionNotifier extends AsyncNotifier<TodaySuggestionBundle?> {
  /// Locally dismissed suggestion IDs — passed as `excludeIds` on re-fetch.
  final List<String> _dismissedIds = [];

  @override
  Future<TodaySuggestionBundle?> build() async {
    return authGuarded(
      ref: ref,
      fetch: _fetch,
      signedOutFallback: () async => null,
    );
  }

  Future<TodaySuggestionBundle?> _fetch() async {
    final ds = ref.read(todaySuggestionRemoteDataSourceProvider);
    return ds.fetchSuggestions(
      excludeIds: _dismissedIds.isEmpty ? null : _dismissedIds,
    );
  }

  /// Submit user feedback for a suggestion card, then refresh.
  Future<void> submitFeedback({
    required String suggestionId,
    required TodaySuggestionFeedback feedback,
  }) async {
    final ds = ref.read(todaySuggestionRemoteDataSourceProvider);
    await ds.submitFeedback(id: suggestionId, feedback: feedback);

    if (feedback == TodaySuggestionFeedback.suppress) {
      _dismissedIds.add(suggestionId);
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Dismiss a card locally (no API call) and re-fetch without it.
  Future<void> dismiss(String suggestionId) async {
    _dismissedIds.add(suggestionId);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Manual refresh.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

/// AI explanation for a single suggestion, loaded on demand.
///
/// The [language] parameter should be the current locale tag (e.g. `zh-CN`).
/// Returns `null` if the user is not authenticated.
final suggestionExplanationProvider = FutureProvider.autoDispose
    .family<
      TodaySuggestionExplanation?,
      ({String suggestionId, String language})
    >((ref, params) async {
      return authGuarded(
        ref: ref,
        fetch: () {
          final ds = ref.watch(todaySuggestionRemoteDataSourceProvider);
          return ds.explainSuggestion(
            id: params.suggestionId,
            language: params.language,
          );
        },
        signedOutFallback: () async => null,
      );
    });
