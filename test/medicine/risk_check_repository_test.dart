import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/services/risk_checker.dart';
import 'package:luminous/features/search/data/datasources/medicine_search.dart';
import 'package:lucent_api/api/export.dart' as lucent;

class _FakeSearchDataSource implements MedicineSearchRemoteDataSource {
  _FakeSearchDataSource();

  final Map<String, MedicineDetailResponseDto> detailResponses = {};
  Object? detailError;
  String? lastDetailId;
  String? lastDetailSource;

  @override
  Future<MedicineSearchResponseDto> search({
    required String source,
    String? query,
    int page = 1,
    int pageSize = 20,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<MedicineDetailResponseDto> getDetail({
    required String id,
    required String source,
  }) async {
    lastDetailId = id;
    lastDetailSource = source;
    if (detailError != null) throw detailError!;
    return detailResponses[id] ??
        MedicineDetailResponseDto(
          code: 0,
          message: '',
          data: MedicineDetailDataDto(
            id: id,
            source: lucent.MedicineDetailDataDtoSourceSource.cn,
            name: 'Unknown',
            subtitle: null,
            detail: const lucent.MedicineDetailDataDtoDetailDetail({}),
          ),
        );
  }
}

HealthContextSnapshot _buildSnapshot({
  List<CurrentMedicineItem> currentMedicines = const [],
  List<AllergyItem> allergies = const [],
  List<ConditionItem> conditions = const [],
}) {
  return HealthContextSnapshot(
    summary: HealthSummary(
      age: 30,
      onboardingCompleted: true,
      activeAllergyCount: allergies.length,
      conditionCount: conditions.length,
      currentMedicineCount: currentMedicines.length,
      missingCoreProfileFields: const [],
    ),
    profile: const HealthProfile(
      birthDate: '1996-01-01',
      sexAtBirth: 'male',
      heightCm: 175,
      bloodType: 'A',
      locale: 'zh-CN',
      timezone: 'Asia/Shanghai',
      unitSystem: 'metric',
      onboardingCompletedAt: '2026-01-01T00:00:00.000Z',
      extras: {},
    ),
    allergies: allergies,
    conditions: conditions,
    currentMedicines: currentMedicines,
  );
}

CurrentMedicineItem _buildMedicineItem({
  required String id,
  required String source,
  String? sourceRefId,
  String displayName = 'Test Medicine',
  bool isCurrent = true,
}) {
  return CurrentMedicineItem(
    id: id,
    source: source,
    sourceRefId: sourceRefId,
    displayName: displayName,
    strengthText: null,
    doseText: null,
    route: null,
    startedAt: null,
    endedAt: null,
    isCurrent: isCurrent,
    note: null,
    createdAt: '2026-01-01T00:00:00.000Z',
    updatedAt: '2026-01-01T00:00:00.000Z',
  );
}

MedicineDetailResponseDto _detailResponse({
  required String id,
  required String name,
  String? subtitle,
  Map<String, dynamic>? detailJson,
}) {
  return MedicineDetailResponseDto(
    code: 0,
    message: '',
    data: MedicineDetailDataDto(
      id: id,
      source: lucent.MedicineDetailDataDtoSourceSource.cn,
      name: name,
      subtitle: subtitle,
      detail: lucent.MedicineDetailDataDtoDetailDetail.fromJson(
        detailJson ?? {},
      ),
    ),
  );
}

void main() {
  group('LucentMedicineRiskCheckRepository', () {
    late _FakeSearchDataSource remoteDataSource;
    late MedicineRiskCheckRepository repo;

    setUp(() {
      remoteDataSource = _FakeSearchDataSource();
      repo = LucentMedicineRiskCheckRepository(
        remoteDataSource: remoteDataSource,
      );
    });

    // ─── fetchForSnapshot — basic behavior ───────────────────────────
    group('fetchForSnapshot', () {
      test(
        'returns empty result when snapshot has no current medicines',
        () async {
          final snapshot = _buildSnapshot();

          final result = await repo.fetchForSnapshot(snapshot);

          expect(result.currentMedicineCount, 0);
          expect(result.checkedMedicineCount, 0);
          expect(result.findings, isEmpty);
          expect(result.coverageIssues, isEmpty);
        },
      );

      test(
        'returns coverage issue for current medicines without source',
        () async {
          final snapshot = _buildSnapshot(
            currentMedicines: [
              _buildMedicineItem(
                id: 'med-1',
                source: 'manual',
                displayName: 'Hand-entered Med',
              ),
            ],
          );

          final result = await repo.fetchForSnapshot(snapshot);

          expect(result.currentMedicineCount, 1);
          expect(result.checkedMedicineCount, 0);
          expect(result.coverageIssues, hasLength(1));
          expect(
            result.coverageIssues.first.reason,
            MedicineRiskCoverageReason.manualEntry,
          );
        },
      );

      test(
        'returns coverage issue for cn medicine without sourceRefId',
        () async {
          final snapshot = _buildSnapshot(
            currentMedicines: [
              _buildMedicineItem(
                id: 'med-1',
                source: 'cn',
                sourceRefId: null,
                displayName: 'CN Med',
              ),
            ],
          );

          final result = await repo.fetchForSnapshot(snapshot);

          expect(result.currentMedicineCount, 1);
          expect(result.coverageIssues, hasLength(1));
          expect(
            result.coverageIssues.first.reason,
            MedicineRiskCoverageReason.missingSourceRef,
          );
        },
      );

      test(
        'returns coverage issue for cn medicine with empty sourceRefId',
        () async {
          final snapshot = _buildSnapshot(
            currentMedicines: [
              _buildMedicineItem(
                id: 'med-1',
                source: 'cn',
                sourceRefId: '   ',
                displayName: 'CN Med',
              ),
            ],
          );

          final result = await repo.fetchForSnapshot(snapshot);

          expect(result.coverageIssues, hasLength(1));
          expect(
            result.coverageIssues.first.reason,
            MedicineRiskCoverageReason.missingSourceRef,
          );
        },
      );

      test('fetches detail for cn medicine with valid sourceRefId', () async {
        remoteDataSource.detailResponses['cn-1'] = _detailResponse(
          id: 'cn-1',
          name: 'Test CN Medicine',
          detailJson: {
            'ingredients': '测试成分',
            'contraindications': '无',
            'precautions': '',
            'foodInteractions': <dynamic>[],
            'drugInteractions': <dynamic>[],
            'synonyms': <String>[],
            'drugbankIds': <String>[],
          },
        );

        final snapshot = _buildSnapshot(
          currentMedicines: [
            _buildMedicineItem(
              id: 'med-1',
              source: 'cn',
              sourceRefId: 'cn-1',
              displayName: 'CN Medicine',
            ),
          ],
        );

        final result = await repo.fetchForSnapshot(snapshot);

        expect(result.currentMedicineCount, 1);
        expect(result.checkedMedicineCount, 1);
        expect(result.coverageIssues, isEmpty);
        expect(remoteDataSource.lastDetailId, 'cn-1');
        expect(remoteDataSource.lastDetailSource, 'cn');
      });

      test(
        'fetches detail for drugbank medicine with valid sourceRefId',
        () async {
          remoteDataSource.detailResponses['DB-1'] = _detailResponse(
            id: 'DB-1',
            name: 'DrugBank Medicine',
            detailJson: {
              'ingredients': '',
              'contraindications': '',
              'precautions': '',
              'foodInteractions': <dynamic>[],
              'drugInteractions': <dynamic>[],
              'synonyms': <String>[],
              'drugbankIds': <String>[],
            },
          );

          final snapshot = _buildSnapshot(
            currentMedicines: [
              _buildMedicineItem(
                id: 'med-1',
                source: 'drugbank',
                sourceRefId: 'DB-1',
                displayName: 'DB Medicine',
              ),
            ],
          );

          final result = await repo.fetchForSnapshot(snapshot);

          expect(result.checkedMedicineCount, 1);
          expect(remoteDataSource.lastDetailId, 'DB-1');
          expect(remoteDataSource.lastDetailSource, 'drugbank');
        },
      );

      test('skips medicines with unknown source', () async {
        final snapshot = _buildSnapshot(
          currentMedicines: [
            _buildMedicineItem(
              id: 'med-1',
              source: 'unknown_source',
              sourceRefId: 'ref-1',
              displayName: 'Unknown Source Med',
            ),
          ],
        );

        final result = await repo.fetchForSnapshot(snapshot);

        expect(result.currentMedicineCount, 1);
        expect(result.checkedMedicineCount, 0);
        // Source is unknown so it's not cn/drugbank — gets detailUnavailable
        expect(result.coverageIssues, hasLength(1));
      });

      test('skips non-current medicines', () async {
        final snapshot = _buildSnapshot(
          currentMedicines: [
            _buildMedicineItem(
              id: 'med-1',
              source: 'cn',
              sourceRefId: 'cn-1',
              isCurrent: false,
            ),
          ],
        );

        final result = await repo.fetchForSnapshot(snapshot);

        expect(result.currentMedicineCount, 0);
        expect(result.checkedMedicineCount, 0);
      });

      test('returns coverage issue when API returns non-zero code', () async {
        remoteDataSource.detailResponses['cn-1'] =
            const MedicineDetailResponseDto(
              code: 1001,
              message: 'Not found',
              data: MedicineDetailDataDto(
                id: 'cn-1',
                source: lucent.MedicineDetailDataDtoSourceSource.cn,
                name: '',
                subtitle: null,
                detail: lucent.MedicineDetailDataDtoDetailDetail({}),
              ),
            );

        final snapshot = _buildSnapshot(
          currentMedicines: [
            _buildMedicineItem(
              id: 'med-1',
              source: 'cn',
              sourceRefId: 'cn-1',
              displayName: 'CN Med',
            ),
          ],
        );

        final result = await repo.fetchForSnapshot(snapshot);

        expect(result.checkedMedicineCount, 0);
        expect(result.coverageIssues, hasLength(1));
      });

      test('handles network error gracefully with coverage issue', () async {
        remoteDataSource.detailError = Exception('Network error');

        final snapshot = _buildSnapshot(
          currentMedicines: [
            _buildMedicineItem(
              id: 'med-1',
              source: 'cn',
              sourceRefId: 'cn-1',
              displayName: 'CN Med',
            ),
          ],
        );

        final result = await repo.fetchForSnapshot(snapshot);

        expect(result.checkedMedicineCount, 0);
        expect(result.coverageIssues, hasLength(1));
      });

      test('handles mixed scenario: fetched + failed + manual', () async {
        remoteDataSource.detailResponses['cn-1'] = _detailResponse(
          id: 'cn-1',
          name: 'Fetched Med',
          detailJson: {},
        );

        final snapshot = _buildSnapshot(
          currentMedicines: [
            _buildMedicineItem(
              id: 'med-1',
              source: 'cn',
              sourceRefId: 'cn-1',
              displayName: 'Fetched Med',
            ),
            _buildMedicineItem(
              id: 'med-2',
              source: 'cn',
              sourceRefId: 'cn-2',
              displayName: 'Failed Med',
            ),
            _buildMedicineItem(
              id: 'med-3',
              source: 'manual',
              displayName: 'Manual Med',
            ),
          ],
        );

        // cn-2 will return default (not in detailResponses, but the fake
        // returns a default response with code 0, so it will succeed but
        // with the "Unknown" name).
        // Let's make cn-2 return a non-zero code to simulate failure.
        remoteDataSource.detailResponses['cn-2'] =
            const MedicineDetailResponseDto(
              code: 1001,
              message: 'Not found',
              data: MedicineDetailDataDto(
                id: 'cn-2',
                source: lucent.MedicineDetailDataDtoSourceSource.cn,
                name: '',
                subtitle: null,
                detail: lucent.MedicineDetailDataDtoDetailDetail({}),
              ),
            );

        final result = await repo.fetchForSnapshot(snapshot);

        expect(result.currentMedicineCount, 3);
        expect(
          result.checkedMedicineCount,
          1,
        ); // Only cn-1 was successfully fetched
        expect(result.coverageIssues, hasLength(2)); // cn-2 + manual
      });

      test('uses custom MedicineRiskChecker when provided', () async {
        final fakeChecker = _NoOpRiskChecker();

        final repo = LucentMedicineRiskCheckRepository(
          remoteDataSource: remoteDataSource,
          checker: fakeChecker,
        );

        final snapshot = _buildSnapshot(
          currentMedicines: [
            _buildMedicineItem(
              id: 'med-1',
              source: 'manual',
              displayName: 'Manual Med',
            ),
          ],
        );

        final result = await repo.fetchForSnapshot(snapshot);

        expect(fakeChecker.evaluateCalled, isTrue);
        expect(result, isA<MedicineRiskCheckResult>());
      });
    });

    // ─── Multiple medicines ──────────────────────────────────────────
    group('fetchForSnapshot — multiple medicines', () {
      test('fetches details for multiple medicines in order', () async {
        remoteDataSource.detailResponses['cn-1'] = _detailResponse(
          id: 'cn-1',
          name: 'Med A',
          detailJson: {},
        );
        remoteDataSource.detailResponses['cn-2'] = _detailResponse(
          id: 'cn-2',
          name: 'Med B',
          detailJson: {},
        );

        final snapshot = _buildSnapshot(
          currentMedicines: [
            _buildMedicineItem(
              id: 'med-1',
              source: 'cn',
              sourceRefId: 'cn-1',
              displayName: 'Med A',
            ),
            _buildMedicineItem(
              id: 'med-2',
              source: 'cn',
              sourceRefId: 'cn-2',
              displayName: 'Med B',
            ),
          ],
        );

        final result = await repo.fetchForSnapshot(snapshot);

        expect(result.currentMedicineCount, 2);
        expect(result.checkedMedicineCount, 2);
        expect(result.coverageIssues, isEmpty);
      });

      test('trims sourceRefId before API call', () async {
        remoteDataSource.detailResponses['cn-1'] = _detailResponse(
          id: 'cn-1',
          name: 'Med A',
          detailJson: {},
        );

        final snapshot = _buildSnapshot(
          currentMedicines: [
            _buildMedicineItem(
              id: 'med-1',
              source: 'cn',
              sourceRefId: '  cn-1  ',
              displayName: 'Med A',
            ),
          ],
        );

        await repo.fetchForSnapshot(snapshot);

        expect(remoteDataSource.lastDetailId, 'cn-1');
      });
    });
  });
}

class _NoOpRiskChecker implements MedicineRiskChecker {
  bool evaluateCalled = false;

  @override
  MedicineRiskCheckResult evaluate({
    required HealthContextSnapshot snapshot,
    required List<MedicineRiskMedicineDetail> medicines,
  }) {
    evaluateCalled = true;
    return const MedicineRiskCheckResult(
      currentMedicineCount: 0,
      checkedMedicineCount: 0,
      findings: [],
      coverageIssues: [],
    );
  }
}
