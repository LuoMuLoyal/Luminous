import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/database/database_providers.dart';
import 'package:luminous/core/network/network_providers.dart';
import 'package:luminous/core/providers/auth_guarded.dart';
import 'package:luminous/features/today/data/datasources/suggestion_remote.dart';
import 'package:luminous/features/today/data/utils/suggestion_json_codec.dart';
import 'package:luminous/features/today/domain/entities/suggestion.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'suggestion.g.dart';

@riverpod
TodaySuggestionRemoteDataSource todaySuggestionRemoteDataSource(Ref ref) {
  return TodaySuggestionRemoteDataSource(
    api: ref.watch(lucentClientProvider).todaySuggestion,
  );
}

/// Manages the lifecycle of Today suggestion cards: fetch, dismiss, feedback.
///
/// Cache-first: on build, returns cached bundle immediately (if available),
/// then fetches fresh data from the network in the background.
/// After [submitFeedback] or [dismiss], the provider re-fetches and updates
/// the cache.
///
/// Returns `null` when the user is not authenticated (signed-out / preview).
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
    final dao = ref.read(todaySuggestionDaoProvider);

    try {
      final bundle = await ds.fetchSuggestions(
        excludeIds: _dismissedIds.isEmpty ? null : _dismissedIds,
      );
      // Persist to cache
      await dao.replace(TodaySuggestionJsonCodec.bundleToJson(bundle));
      return bundle;
    } catch (e) {
      // Network failed — try cache as fallback (stale-while-error)
      final cached = await dao.fetch();
      if (cached != null) {
        return TodaySuggestionJsonCodec.bundleFromJson(cached);
      }
      rethrow;
    }
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

/// Suggestion history for the Report page.
///
/// Returns `null` when the user is not authenticated.
/// Fetches the most recent 20 suggestion history items.
final suggestionHistoryProvider =
    FutureProvider.autoDispose<TodaySuggestionHistory?>((ref) async {
      return authGuarded(
        ref: ref,
        fetch: () {
          final ds = ref.watch(todaySuggestionRemoteDataSourceProvider);
          return ds.fetchHistory(limit: 20);
        },
        signedOutFallback: () async => null,
      );
    });

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
