import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/features/search/data/repositories/lucent.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';
import 'package:luminous/features/search/domain/repositories/search.dart';
import 'package:luminous/features/search/presentation/providers/medicine_search.dart';
import 'package:luminous/features/search/presentation/providers/recent_searches.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake implementation of [MedicineSearchRepository] for testing
/// [MedicineSearchNotifier] state transitions.
///
/// `*Failure` produces a `TaskEither` Left (repository boundary failure);
/// `*Throws` makes the task reject with the given object (protocol-exception
/// shape, e.g. a `FormatException`/`TimeoutException` escaping `.run()`).
class _FakeSearchRepository implements MedicineSearchRepository {
  _FakeSearchRepository();

  List<MedicineSearchResult> searchResults = [];
  MedicineSearchSafetyPreview? detailPreview;
  LucentFailure? searchFailure;
  LucentFailure? detailFailure;
  Object? searchThrows;
  Object? detailThrows;
  Duration searchDelay = Duration.zero;
  Duration detailDelay = Duration.zero;

  String? lastSearchQuery;
  MedicineSearchSource? lastSearchSource;
  String? lastDetailId;
  MedicineSearchSource? lastDetailSource;

  @override
  TaskEither<LucentFailure, List<MedicineSearchResult>> search({
    required String query,
    required MedicineSearchSource source,
    int page = 1,
    int pageSize = 20,
  }) {
    return TaskEither(() async {
      lastSearchQuery = query;
      lastSearchSource = source;
      if (searchDelay != Duration.zero) {
        await Future.delayed(searchDelay);
      }
      final throws = searchThrows;
      if (throws != null) throw throws;
      final failure = searchFailure;
      if (failure != null) return Left(failure);
      return Right(searchResults);
    });
  }

  @override
  TaskEither<LucentFailure, MedicineSearchSafetyPreview?> fetchDetail(
    String id,
    MedicineSearchSource source,
  ) {
    return TaskEither(() async {
      lastDetailId = id;
      lastDetailSource = source;
      if (detailDelay != Duration.zero) {
        await Future.delayed(detailDelay);
      }
      final throws = detailThrows;
      if (throws != null) throw throws;
      final failure = detailFailure;
      if (failure != null) return Left(failure);
      return Right(detailPreview);
    });
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
    // The search notifier writes successful queries into the persisted recent
    // searches provider, which is backed by SharedPreferences.
    SharedPreferences.setMockInitialValues({});
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
        // Wait for the 400ms debounce timer to fire.
        await Future.delayed(const Duration(milliseconds: 450));

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

    test('sets error message when search returns a failure Left', () async {
      repo.searchFailure = LucentFailure.network(
        message: 'Network request failed.',
        networkErrorCode: NetworkErrorCode.connectionError,
      );

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('test');
      await Future.delayed(const Duration(milliseconds: 450));

      final state = container.read(medicineSearchNotifierProvider);
      expect(state.isSearching, isFalse);
      expect(state.errorMessage, isNotNull);
      expect(state.results, isEmpty);
    });

    test(
      'maps generic Exception to user-friendly message via mapper',
      () async {
        repo.searchThrows = Exception('Something went wrong');

        final notifier = container.read(
          medicineSearchNotifierProvider.notifier,
        );
        await notifier.updateQuery('test');
        await Future.delayed(const Duration(milliseconds: 450));

        final state = container.read(medicineSearchNotifierProvider);
        // userMessageFromError delegates to LucentErrorMapper which returns a
        // localized generic message for non-API exceptions, never exposing the
        // raw exception text to the user.
        expect(state.errorMessage, isNotNull);
        expect(state.errorMessage, isNot(contains('Exception')));
        expect(state.errorMessage, isNot(contains('Something went wrong')));
      },
    );

    test('trims query before search', () async {
      repo.searchResults = [_result('m1')];

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('  aspirin  ');
      await Future.delayed(const Duration(milliseconds: 450));

      expect(repo.lastSearchQuery, 'aspirin');
    });

    test('sets isSearching to true during search', () async {
      repo.searchResults = [_result('m1')];
      repo.searchDelay = const Duration(milliseconds: 50);

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      // Don't await — check loading state
      unawaited(notifier.updateQuery('aspirin'));

      // Wait for the 400ms debounce to fire, then a bit for search to start.
      await Future.delayed(const Duration(milliseconds: 410));

      final state = container.read(medicineSearchNotifierProvider);
      expect(state.isSearching, isTrue);

      // Wait for completion (50ms search delay)
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
      await Future.delayed(const Duration(milliseconds: 450));

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
      repo.searchThrows = TimeoutException('请求超时，请检查网络后重试。');

      await notifier.updateQuery('test');
      await Future.delayed(const Duration(milliseconds: 450));

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

  // ── detail preview failure ─────────────────────────────────────
  group('detail preview failure', () {
    test('degrades only the preview, keeping the search results', () async {
      repo.searchResults = [_result('m1')];
      repo.detailPreview = _preview('Detail m1');
      repo.detailFailure = LucentFailure.network(
        message: 'Network request failed.',
        networkErrorCode: NetworkErrorCode.connectionError,
      );

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('test');
      await Future.delayed(const Duration(milliseconds: 450));

      final state = container.read(medicineSearchNotifierProvider);
      expect(state.isSearching, isFalse);
      expect(state.results, hasLength(1));
      expect(state.selectedResultId, 'm1');
      // A detail failure must not fail the search — no preview, no error.
      expect(state.detailPreview, isNull);
      expect(state.errorMessage, isNull);
    });

    test(
      'degrades only the preview when detail raises a protocol exception',
      () async {
        repo.searchResults = [_result('m1')];
        repo.detailThrows = const FormatException('malformed error body');

        final notifier = container.read(
          medicineSearchNotifierProvider.notifier,
        );
        await notifier.updateQuery('test');
        await Future.delayed(const Duration(milliseconds: 450));

        final state = container.read(medicineSearchNotifierProvider);
        expect(state.isSearching, isFalse);
        expect(state.results, hasLength(1));
        expect(state.selectedResultId, 'm1');
        // A thrown FormatException from `run()` must not escape the
        // fire-and-forget selectResult/_doSearch path — no preview, no error.
        expect(state.detailPreview, isNull);
        expect(state.errorMessage, isNull);
      },
    );
  });

  // ── recent searches (F-12) ────────────────────────────────────
  group('recent searches', () {
    test('records the trimmed keyword after a successful search', () async {
      repo.searchResults = [_result('m1')];

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('  aspirin  ');
      await Future.delayed(const Duration(milliseconds: 450));

      final keywords = container.read(recentSearchesProvider).asData?.value;
      expect(keywords, ['aspirin']);
    });

    test('records the keyword even when results are empty', () async {
      repo.searchResults = [];

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('nonexistent');
      await Future.delayed(const Duration(milliseconds: 450));

      final keywords = container.read(recentSearchesProvider).asData?.value;
      expect(keywords, ['nonexistent']);
    });

    test('does not record the keyword when the search fails', () async {
      repo.searchFailure = LucentFailure.network(
        message: 'Network request failed.',
        networkErrorCode: NetworkErrorCode.connectionError,
      );

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('aspirin');
      await Future.delayed(const Duration(milliseconds: 450));

      final keywords = container.read(recentSearchesProvider).asData?.value;
      expect(keywords ?? const <String>[], isEmpty);
    });

    test('does not record whitespace-only queries', () async {
      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('   ');
      await Future.delayed(const Duration(milliseconds: 450));

      final keywords = container.read(recentSearchesProvider).asData?.value;
      expect(keywords ?? const <String>[], isEmpty);
    });

    test('re-searching a keyword moves it to the front', () async {
      repo.searchResults = [_result('m1')];

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('aspirin');
      await Future.delayed(const Duration(milliseconds: 450));
      await notifier.updateQuery('bayer');
      await Future.delayed(const Duration(milliseconds: 450));
      await notifier.updateQuery('aspirin');
      await Future.delayed(const Duration(milliseconds: 450));

      final keywords = container.read(recentSearchesProvider).asData?.value;
      expect(keywords, ['aspirin', 'bayer']);
    });

    test('clears all keywords via the notifier', () async {
      repo.searchResults = [_result('m1')];

      final notifier = container.read(medicineSearchNotifierProvider.notifier);
      await notifier.updateQuery('aspirin');
      await Future.delayed(const Duration(milliseconds: 450));

      await container.read(recentSearchesProvider.notifier).clearAll();

      final keywords = container.read(recentSearchesProvider).asData?.value;
      expect(keywords, isEmpty);
    });

    test('a write while the initial load is in flight survives the load '
        'completion (F-12 P2-2)', () async {
      // Race guard: `addKeyword` must wait for the initial `build()` load to
      // settle before writing. Otherwise the load's completion (riverpod
      // `handleFuture`) could overwrite the just-persisted write with the
      // stale pre-write read value.
      //
      // Determinism note: with the in-memory mock store, the load's read
      // happens-before the write's read because both await the same memoized
      // `getInstance()` future, but the load's completion (riverpod
      // `handleFuture` → state set) is scheduled *after* the write's
      // continuation — so without the guard this test actually fails: the
      // stale pre-write value lands in state last and overwrites the written
      // keyword. The guard (`_settleInitialLoad` awaiting the in-flight
      // load before writing) is what makes the write survive; this test pins
      // that outcome and would break if the guard deadlocked or dropped the
      // write.
      final notifier = container.read(recentSearchesProvider.notifier);
      // Premise: the initial load is still pending here — `getInstance()`
      // has not resolved, so `build()`'s load future is genuinely in flight
      // when the write below runs (pinning this keeps the guard path
      // exercised even if the mock store's timing changes).
      expect(container.read(recentSearchesProvider).isLoading, isTrue);
      await notifier.addKeyword('布洛芬');

      await Future<void>.delayed(Duration.zero);

      final keywords = container.read(recentSearchesProvider).asData?.value;
      expect(keywords, ['布洛芬']);
    });
  });
}
