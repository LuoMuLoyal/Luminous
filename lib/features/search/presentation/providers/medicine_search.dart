import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/features/search/data/repositories/lucent.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/presentation/providers/recent_searches.dart';

part 'medicine_search.freezed.dart';

/// State for the medicine search page.
@freezed
abstract class MedicineSearchState with _$MedicineSearchState {
  const factory MedicineSearchState({
    @Default('') String query,
    @Default(MedicineSearchSource.cn) MedicineSearchSource source,
    @Default([]) List<MedicineSearchResult> results,
    @Default(false) bool isSearching,
    String? errorMessage,
    String? selectedResultId,
    MedicineSearchSafetyPreview? detailPreview,
  }) = _MedicineSearchState;
}

/// Notifier that manages medicine search state interactively.
///
/// Search is **submit-driven**: [updateQuery] only records what the user typed,
/// and the request goes out from [submitQuery] (the keyboard's search action or
/// the field's submit button). Typing must never fire a request on its own.
class MedicineSearchNotifier extends Notifier<MedicineSearchState> {
  /// Monotonic id of the most recently *started* search. Without this guard a
  /// slow response for an abandoned query (e.g. `a`) would land after the
  /// response for the current query (e.g. `aspirin`) and overwrite results,
  /// `selectedResultId` and `detailPreview` with stale data.
  int _searchGeneration = 0;

  @override
  MedicineSearchState build() => const MedicineSearchState();

  /// Records the typed query without searching it.
  ///
  /// Deliberately does not touch the network: the page searches only when the
  /// user submits. Emptying the field still clears the results (and discards
  /// any in-flight search) so the empty state comes back immediately.
  Future<void> updateQuery(String query) async {
    state = state.copyWith(query: query, errorMessage: null);
    if (query.trim().isEmpty) {
      // Bump the generation so any in-flight search for the cleared query is
      // discarded instead of repopulating the now-empty result list, and clear
      // isSearching here — the discarded search returns early without doing it.
      _searchGeneration += 1;
      state = state.copyWith(
        results: const [],
        errorMessage: null,
        isSearching: false,
      );
    }
  }

  /// Searches the current query.
  ///
  /// Bound to the keyboard's search action and the field's submit button;
  /// a no-op for an empty or whitespace-only query.
  Future<void> submitQuery() async {
    if (state.query.trim().isEmpty) return;
    await _doSearch();
  }

  Future<void> switchSource(MedicineSearchSource source) async {
    state = state.copyWith(source: source, results: const []);
    if (state.query.trim().isNotEmpty) {
      await _doSearch();
    }
  }

  Future<void> selectResult(String id) async {
    state = state.copyWith(selectedResultId: id);
    final result = state.results.firstWhereOrNull((r) => r.id == id);
    if (result != null) {
      final preview = await _fetchDetailPreview(result);
      state = state.copyWith(detailPreview: preview);
    }
  }

  Future<void> retry() async {
    if (state.query.trim().isNotEmpty) {
      await _doSearch();
    }
  }

  Future<void> _doSearch() async {
    // Capture the query before awaiting so the recent-search record matches
    // what was actually searched, even if the user keeps typing mid-flight
    // (F-12 review P2-1).
    final searchedQuery = state.query.trim();
    final generation = ++_searchGeneration;
    state = state.copyWith(isSearching: true, errorMessage: null);
    try {
      final either = await ref
          .watch(medicineSearchRepositoryProvider)
          .search(query: searchedQuery, source: state.source)
          .run()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () =>
                throw TimeoutException('Search timed out. Please try again.'),
          );

      // A newer search started while this one was in flight: its state is the
      // one the user is waiting for, so drop this response entirely.
      if (generation != _searchGeneration) return;

      final results = either.fold((failure) {
        ref
            .read(talkerProvider)
            .error('MedicineSearchNotifier._doSearch: failed: $failure');
        state = state.copyWith(
          isSearching: false,
          errorMessage: userMessageFromError(failure),
          results: const [],
        );
        return null;
      }, (results) => results);
      if (results == null) return;

      final preview = results.isEmpty
          ? null
          : await _fetchDetailPreview(results.first);

      // The detail preview is a second await; re-check before committing so a
      // newer search that started meanwhile still wins.
      if (generation != _searchGeneration) return;

      state = state.copyWith(
        results: results,
        isSearching: false,
        errorMessage: null,
        selectedResultId: results.isNotEmpty ? results.first.id : null,
        detailPreview: preview,
      );

      // F-12: record a successful non-empty query as a recent search. The
      // notifier absorbs persistence failures, so this never fails the search.
      if (searchedQuery.isNotEmpty) {
        await ref
            .read(recentSearchesProvider.notifier)
            .addKeyword(searchedQuery);
      }
    } catch (e) {
      if (generation != _searchGeneration) return;
      ref
          .read(talkerProvider)
          .error('MedicineSearchNotifier._doSearch: failed: $e');
      state = state.copyWith(
        isSearching: false,
        errorMessage: userMessageFromError(e),
        results: const [],
      );
    }
  }

  /// Fetches the legacy detail preview for [result].
  ///
  /// A detail failure must not fail the search itself — it is logged and
  /// yields no preview (equivalent to the previous swallow-to-null, minus the
  /// lost error). This includes protocol errors (e.g. a non-Problem-Details
  /// error body that surfaces as a thrown [FormatException] from `run()`),
  /// which are logged and treated as "no preview" instead of escaping into
  /// the fire-and-forget call site.
  Future<MedicineSearchSafetyPreview?> _fetchDetailPreview(
    MedicineSearchResult result,
  ) async {
    final Either<LucentFailure, MedicineSearchSafetyPreview?> either;
    try {
      either = await ref
          .watch(medicineSearchRepositoryProvider)
          .fetchDetail(result.id, result.source)
          .run();
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('MedicineSearchNotifier: detail preview failed: $e');
      return null;
    }
    return either.fold((failure) {
      ref
          .read(talkerProvider)
          .error('MedicineSearchNotifier: detail preview failed: $failure');
      return null;
    }, (preview) => preview);
  }
}

final medicineSearchNotifierProvider =
    NotifierProvider<MedicineSearchNotifier, MedicineSearchState>(
      MedicineSearchNotifier.new,
    );
