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

/// Debounce delay for search input before firing the network request.
const _searchDebounceDuration = Duration(milliseconds: 400);

/// Notifier that manages medicine search state interactively.
class MedicineSearchNotifier extends Notifier<MedicineSearchState> {
  Timer? _debounceTimer;

  @override
  MedicineSearchState build() {
    ref.onDispose(() => _debounceTimer?.cancel());
    return const MedicineSearchState();
  }

  Future<void> updateQuery(String query) async {
    state = state.copyWith(query: query, errorMessage: null);
    _debounceTimer?.cancel();
    if (query.trim().isNotEmpty) {
      _debounceTimer = Timer(_searchDebounceDuration, _doSearch);
    } else {
      state = state.copyWith(results: const [], errorMessage: null);
    }
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
