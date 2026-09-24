import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/scan/domain/entities/scan_result.dart';
import 'package:luminous/features/scan/domain/repositories/scan.dart';
import 'package:luminous/features/scan/domain/services/candidate_search.dart';
import 'package:mocktail/mocktail.dart';

class _MockScanRepository extends Mock implements ScanRepository {}

void main() {
  late _MockScanRepository repository;

  MedicineMatchCandidate candidate(
    String query, {
    double confidence = 0.5,
    MedicineMatchType matchType = MedicineMatchType.nameFuzzy,
  }) {
    return MedicineMatchCandidate(
      query: query,
      confidence: confidence,
      matchType: matchType,
    );
  }

  ScanSearchResult item(String id, String name) {
    return ScanSearchResult(id: id, name: name);
  }

  void stubSearch(
    String query,
    TaskEither<LucentFailure, List<ScanSearchResult>> outcome,
  ) {
    when(() => repository.search(query)).thenAnswer((_) => outcome);
  }

  LucentFailure offline([String message = 'offline']) {
    return LucentFailure.network(
      message: message,
      networkErrorCode: NetworkErrorCode.connectionError,
    );
  }

  setUp(() {
    repository = _MockScanRepository();
  });

  test('keeps searching the remaining candidates after one fails', () async {
    stubSearch('国药准字H20044321', TaskEither.left(offline()));
    stubSearch('布洛芬缓释胶囊', TaskEither.right([item('1', '布洛芬缓释胶囊')]));

    final results = await searchCandidates(repository, [
      candidate(
        '国药准字H20044321',
        confidence: 0.9,
        matchType: MedicineMatchType.approvalNumber,
      ),
      candidate('布洛芬缓释胶囊', confidence: 0.6),
    ]);

    expect(results, hasLength(1));
    expect(results.single.name, '布洛芬缓释胶囊');
    expect(results.single.id, '1');
    expect(results.single.confidence, 0.6);
    expect(results.single.matchType, MedicineMatchType.nameFuzzy);
  });

  test('collects hits from every candidate in order', () async {
    stubSearch('a', TaskEither.right([item('1', 'A')]));
    stubSearch('b', TaskEither.right([item('2', 'B'), item('3', 'C')]));

    final results = await searchCandidates(repository, [
      candidate('a'),
      candidate('b'),
    ]);

    expect(results.map((result) => result.name), ['A', 'B', 'C']);
  });

  test('rethrows the first failure when every candidate failed', () async {
    final first = offline('first');
    stubSearch('a', TaskEither.left(first));
    stubSearch('b', TaskEither.left(offline('second')));

    await expectLater(
      searchCandidates(repository, [candidate('a'), candidate('b')]),
      throwsA(same(first)),
    );
  });

  test('rethrows when an empty result hides a failed candidate', () async {
    final failure = offline();
    stubSearch('a', TaskEither.right(const []));
    stubSearch('b', TaskEither.left(failure));

    await expectLater(
      searchCandidates(repository, [candidate('a'), candidate('b')]),
      throwsA(same(failure)),
    );
  });

  test('a clean search that matched nothing is not a failure', () async {
    stubSearch('a', TaskEither.right(const []));
    stubSearch('b', TaskEither.right(const []));

    expect(
      await searchCandidates(repository, [candidate('a'), candidate('b')]),
      isEmpty,
    );
  });

  test('no candidates searches nothing and returns empty', () async {
    expect(await searchCandidates(repository, const []), isEmpty);
    verifyNever(() => repository.search(any()));
  });
}
