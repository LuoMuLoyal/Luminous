import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/search/data/repositories/lucent.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/domain/repositories/search.dart';
import 'package:luminous/features/search/presentation/providers/medicine_search.dart';

/// Fake implementation of [MedicineSearchRepository] for testing
/// [MedicineSearchNotifier] state transitions.
class _FakeSearchRepository implements MedicineSearchRepository {
  _FakeSearchRepository();

  List<MedicineSearchResult> searchResults = [];
  MedicineSearchSafetyPreview? detailPreview;
  Object? searchError;
  Object? detailError;
  Duration searchDelay = Duration.zero;
  Duration detailDelay = Duration.zero;

  String? lastSearchQuery;
  MedicineSearchSource? lastSearchSource;
  String? lastDetailId;
  MedicineSearchSource? lastDetailSource;

  @override
  Future<List<MedicineSearchResult>> search({
    required String query,
    required MedicineSearchSource source,
    int page = 1,
    int pageSize = 20,
  }) async {
    lastSearchQuery = query;
    lastSearchSource = source;
    if (searchDelay != Duration.zero) {
      await Future.delayed(searchDelay);
    }
    if (searchError != null) throw searchError!;
    return searchResults;
  }

  @override
  Future<MedicineSearchSafetyPreview?> fetchDetail(
    String id,
    MedicineSearchSource source,
  ) async {
    lastDetailId = id;
    lastDetailSource = source;
    if (detailDelay != Duration.zero) {
      await Future.delayed(detailDelay);
    }
    if (detailError != null) throw detailError!;
    return detailPreview;
  }
}

MedicineSearchResult _result(String id, {MedicineSearchSource? source}) {
  return MedicineSearchResult(
    id: id,
    source: source ?? MedicineSearchSource.cn,
    name: 'Medicine $id',
    subtitle: 'Subtitle $id',
    summary: 'Summary $id',
    tags: const [],
    matchType: MedicineSearchMatchType.name,
  );
}

MedicineSearchSafetyPreview _preview(String title) {
  return MedicineSearchSafetyPreview(
    title: title,
    conditions: const [],
    checklist: const [],
  );
}

void main() {
  late _FakeSearchRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = _FakeSearchRepository();
    container = ProviderContainer(
      overrides: [medicineSearchRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
  });

  // ── Initial state ─────────────────────────────────────────────
  group('initial state', () {
    test('starts with empty query and default source', () {
      final state = container.read(medicineSearchNotifierProvider);
      expect(state.query, '');
      expect(state.source, MedicineSearchSource.cn);
      expect(state.results, isEmpty);
      expect(state.isSearching, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.selectedResultId, isNull);
      expect(state.detailPreview, isNull);
    });
  });

  // ── updateQuery ───────────────────────────────────────────────
  group('updateQuery', () {
    test('clears results when query is empty', () async {
      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('');
      final state = container.read(medicineSearchNotifierProvider);
      expect(state.query, '');
      expect(state.results, isEmpty);
      expect(state.errorMessage, isNull);
    });

    test('clears results when query is whitespace-only', () async {
      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('   ');
      final state = container.read(medicineSearchNotifierProvider);
      expect(state.query, '   ');
      expect(state.results, isEmpty);
    });

    test(
      'triggers search and updates results when query is non-empty',
      () async {
        repo.searchResults = [_result('m1'), _result('m2')];
        repo.detailPreview = _preview('Detail m1');

        final notifier = container.read(
          medicineSearchNotifierProvider.notifier,
        );
        await notifier.updateQuery('aspirin');

        final state = container.read(medicineSearchNotifierProvider);
        expect(state.query, 'aspirin');
        expect(state.isSearching, isFalse);
        expect(state.results, hasLength(2));
        expect(state.results.first.id, 'm1');
        expect(state.selectedResultId, 'm1');
        expect(state.detailPreview, isNotNull);
        expect(state.detailPreview!.title, 'Detail m1');
      },
    );

    test('sets error message when search throws', () async {
      repo.searchError = Exception('Network error');

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('test');

      final state = container.read(medicineSearchNotifierProvider);
      expect(state.isSearching, isFalse);
      expect(state.errorMessage, isNotNull);
      expect(state.results, isEmpty);
    });

    test('strips "Exception: " prefix from error message', () async {
      repo.searchError = Exception('Something went wrong');

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('test');

      final state = container.read(medicineSearchNotifierProvider);
      expect(state.errorMessage, 'Something went wrong');
      expect(state.errorMessage, isNot(contains('Exception:')));
    });

    test('trims query before search', () async {
      repo.searchResults = [_result('m1')];

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('  aspirin  ');

      expect(repo.lastSearchQuery, 'aspirin');
    });

    test('sets isSearching to true during search', () async {
      repo.searchResults = [_result('m1')];
      repo.searchDelay = const Duration(milliseconds: 50);

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      // Don't await — check loading state
      unawaited(notifier.updateQuery('aspirin'));

      // Wait a tick for the search to start
      await Future.delayed(const Duration(milliseconds: 10));

      final state = container.read(medicineSearchNotifierProvider);
      expect(state.isSearching, isTrue);

      // Wait for completion
      await Future.delayed(const Duration(milliseconds: 60));
    });
  });

  // ── switchSource ─────────────────────────────────────────────
  group('switchSource', () {
    test('switches source and clears results when query is empty', () async {
      // Start with empty query (default state)
      final notifier = container.read(medicineSearchNotifierProvider.notifier);

      // Switch source — no search should be triggered
      await notifier.switchSource(MedicineSearchSource.drugbank);

      final state = container.read(medicineSearchNotifierProvider);
      expect(state.source, MedicineSearchSource.drugbank);
      expect(state.results, isEmpty);
    });

    test(
      'clears results before re-searching when query is non-empty',
      () async {
        // Set up a query with results
        repo.searchResults = [_result('m1', source: MedicineSearchSource.cn)];
        final notifier = container.read(
          medicineSearchNotifierProvider.notifier,
        );
        await notifier.updateQuery('aspirin');

        // Switch source with different results
        repo.searchResults = [
          _result('m2', source: MedicineSearchSource.drugbank),
        ];
        await notifier.switchSource(MedicineSearchSource.drugbank);

        final state = container.read(medicineSearchNotifierProvider);
        expect(state.source, MedicineSearchSource.drugbank);
        // Results should be replaced, not appended
        expect(state.results, hasLength(1));
        expect(state.results.first.id, 'm2');
        expect(state.results.first.source, MedicineSearchSource.drugbank);
      },
    );

    test('triggers search when query is non-empty', () async {
      repo.searchResults = [_result('m1', source: MedicineSearchSource.cn)];

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('aspirin');

      // Now switch source
      repo.searchResults = [
        _result('m2', source: MedicineSearchSource.drugbank),
      ];
      await notifier.switchSource(MedicineSearchSource.drugbank);

      final state = container.read(medicineSearchNotifierProvider);
      expect(state.source, MedicineSearchSource.drugbank);
      expect(state.results, hasLength(1));
      expect(state.results.first.id, 'm2');
      expect(state.results.first.source, MedicineSearchSource.drugbank);
    });
  });

  // ── selectResult ─────────────────────────────────────────────
  group('selectResult', () {
    test('updates selectedResultId and fetches detail', () async {
      repo.searchResults = [_result('m1'), _result('m2')];
      repo.detailPreview = _preview('Detail m2');

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('test');

      await notifier.selectResult('m2');

      final state = container.read(medicineSearchNotifierProvider);
      expect(state.selectedResultId, 'm2');
      expect(state.detailPreview, isNotNull);
      expect(state.detailPreview!.title, 'Detail m2');
    });

    test('does not fetch detail when id is not in results', () async {
      repo.searchResults = [_result('m1')];

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('test');

      repo.lastDetailId = null;
      await notifier.selectResult('nonexistent');

      final state = container.read(medicineSearchNotifierProvider);
      expect(state.selectedResultId, 'nonexistent');
      expect(repo.lastDetailId, isNull);
    });
  });

  // ── retry ─────────────────────────────────────────────────────
  group('retry', () {
    test('re-executes search when query is non-empty', () async {
      repo.searchResults = [_result('m1')];

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('aspirin');

      // Clear and retry
      repo.searchResults = [_result('m1'), _result('m2')];
      repo.lastSearchQuery = null;
      await notifier.retry();

      final state = container.read(medicineSearchNotifierProvider);
      expect(state.results, hasLength(2));
      expect(repo.lastSearchQuery, 'aspirin');
    });

    test('does nothing when query is empty', () async {
      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      repo.lastSearchQuery = null;
      await notifier.retry();

      expect(repo.lastSearchQuery, isNull);
    });
  });

  // ── timeout ──────────────────────────────────────────────────
  group('timeout', () {
    test('sets error message when search times out', () async {
      repo.searchDelay = const Duration(seconds: 10);

      final notifier = container.read(medicineSearchNotifierProvider.notifier);

      // Use a shorter timeout by wrapping in a future that we can control
      // The notifier has a 5s timeout. We'll use a shorter delay but
      // simulate timeout by having the repo throw TimeoutException.
      repo.searchDelay = Duration.zero;
      repo.searchError = TimeoutException('请求超时，请检查网络后重试。');

      await notifier.updateQuery('test');

      final state = container.read(medicineSearchNotifierProvider);
      expect(state.isSearching, isFalse);
      expect(state.errorMessage, isNotNull);
      expect(state.results, isEmpty);
    });
  });

  // ── empty results ─────────────────────────────────────────────
  group('empty results', () {
    test('handles empty search results gracefully', () async {
      repo.searchResults = [];

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('nonexistent');

      final state = container.read(medicineSearchNotifierProvider);
      expect(state.results, isEmpty);
      expect(state.isSearching, isFalse);
      expect(state.selectedResultId, isNull);
      expect(state.detailPreview, isNull);
    });
  });
}
