import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/features/search/data/repositories/lucent_repository.dart';
import 'package:luminous/features/search/domain/entities/search_entities.dart';

part 'search_provider.freezed.dart';

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
class MedicineSearchNotifier extends Notifier<MedicineSearchState> {
  @override
  MedicineSearchState build() {
    return const MedicineSearchState();
  }

  Future<void> updateQuery(String query) async {
    state = state.copyWith(query: query);
    if (query.trim().isNotEmpty) {
      await _doSearch();
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
    if (state.results.any((r) => r.id == id)) {
      final result = state.results.firstWhere((r) => r.id == id);
      final preview = await ref
          .watch(medicineSearchRepositoryProvider)
          .fetchDetail(result.id, result.source);
      state = state.copyWith(detailPreview: preview);
    }
  }

  Future<void> retry() async {
    if (state.query.trim().isNotEmpty) {
      await _doSearch();
    }
  }

  Future<void> _doSearch() async {
    state = state.copyWith(isSearching: true, errorMessage: null);
    try {
      final results = await ref
          .watch(medicineSearchRepositoryProvider)
          .search(query: state.query.trim(), source: state.source)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException('请求超时，请检查网络后重试。'),
          );

      state = state.copyWith(
        results: results,
        isSearching: false,
        errorMessage: null,
        selectedResultId: results.isNotEmpty ? results.first.id : null,
        detailPreview: results.isNotEmpty
            ? await ref
                  .watch(medicineSearchRepositoryProvider)
                  .fetchDetail(results.first.id, results.first.source)
            : null,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        results: const [],
      );
    }
  }
}

final medicineSearchNotifierProvider =
    NotifierProvider<MedicineSearchNotifier, MedicineSearchState>(
      MedicineSearchNotifier.new,
    );
