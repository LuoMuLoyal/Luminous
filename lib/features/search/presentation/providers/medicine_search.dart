import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/errors/user_message.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/search/data/repositories/lucent.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/presentation/providers/data_access.dart';
import 'package:luminous/features/search/presentation/providers/recent_searches.dart';

part 'medicine_search.freezed.dart';

/// State for the medicine search page.
@freezed
abstract class MedicineSearchState with _$MedicineSearchState {
  const MedicineSearchState._();

  const factory MedicineSearchState({
    @Default('') String query,
    @Default(MedicineSearchSource.cn) MedicineSearchSource source,
    @Default([]) List<MedicineSearchResult> results,
    @Default(false) bool isSearching,
    String? errorMessage,
    String? selectedResultId,
    MedicineSearchSafetyPreview? detailPreview,

    /// The query the current [results]/[detailPreview] were produced for, or
    /// null while the field holds text that has not been searched yet.
    ///
    /// The results panel is gated on this instead of on the raw [query] so
    /// typing never renders an (empty) result list — which reads as an
    /// automatic search. It is set by an explicit submit and cleared as soon as
    /// the text no longer matches it (typing, clearing, switching source).
    String? submittedQuery,
  }) = _MedicineSearchState;

  /// Whether [results]/[detailPreview] describe the text currently in the
  /// field, i.e. an explicit search was submitted for [query] and the text has
  /// not been edited since.
  bool get hasSubmittedResults =>
      submittedQuery != null && submittedQuery == query.trim();
}

/// Notifier that manages medicine search state interactively.
///
/// Search is **submit-driven**: [updateQuery] only records what the user typed,
/// and the request goes out from [submitQuery] — the field's search button or
/// the keyboard's search action (`TextInputAction.search` / Enter). Nothing
/// else triggers a request: typing, clearing and [switchSource] must never fire
/// one on their own.
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
  /// user submits. As soon as the text stops matching the query that produced
  /// the current results (including the empty case), the results are dropped
  /// and the submitted marker cleared — so typing shows the suggestions again
  /// instead of a result list that no longer describes the field.
  Future<void> updateQuery(String query) async {
    final trimmed = query.trim();
    final matchesSubmitted =
        trimmed.isNotEmpty && trimmed == state.submittedQuery;
    if (matchesSubmitted) {
      state = state.copyWith(query: query, errorMessage: null);
      return;
    }

    // Bump the generation so any in-flight search for the previous text is
    // discarded instead of repopulating results for the edited query, and clear
    // isSearching here — the discarded search returns early without doing it.
    _searchGeneration += 1;
    state = state.copyWith(
      query: query,
      submittedQuery: null,
      results: const [],
      detailPreview: null,
      selectedResultId: null,
      errorMessage: null,
      isSearching: false,
    );
  }

  /// Searches the current query.
  ///
  /// The only trigger besides the keyboard's search action; a no-op for an
  /// empty or whitespace-only query.
  Future<void> submitQuery() async {
    if (state.query.trim().isEmpty) return;
    await _doSearch();
  }

  /// Switches the data source without searching.
  ///
  /// The source tab is not a search trigger — the request goes out only from
  /// [submitQuery]. Switching clears the submitted results (and any in-flight
  /// search) so the previous source's list never lingers under the new tab; the
  /// user re-submits to search the new source.
  Future<void> switchSource(MedicineSearchSource source) async {
    _searchGeneration += 1;
    state = state.copyWith(
      source: source,
      submittedQuery: null,
      results: const [],
      selectedResultId: null,
      detailPreview: null,
      errorMessage: null,
      isSearching: false,
    );
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
    state = state.copyWith(
      submittedQuery: searchedQuery,
      isSearching: true,
      errorMessage: null,
    );
    try {
      final either = await ref
          .watch(medicineSearchRepositoryProvider)
          .search(query: searchedQuery, source: state.source)
          .run()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw LucentFailure.network(
              message: NetworkErrorCode.receiveTimeout.name,
              networkErrorCode: NetworkErrorCode.receiveTimeout,
            ),
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
