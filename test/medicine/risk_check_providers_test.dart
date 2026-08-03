import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/repositories/risk_check.dart';
import 'package:luminous/features/medicine/presentation/providers/risk_check.dart';

import '../helpers/test_helpers.dart';

class _FakeRiskCheckRepository implements MedicineRiskCheckRepository {
  MedicineRiskCheckRecords records = const MedicineRiskCheckRecords();
  MedicineRiskCheckRecord runResult = _record(MedicineRiskCheckType.static_);
  int runCount = 0;

  @override
  Future<MedicineRiskCheckRecords> getRecords() async => records;

  @override
  Future<MedicineRiskCheckRecord> runCheck(MedicineRiskCheckType type) async {
    runCount++;
    return runResult;
  }
}

MedicineRiskCheckRecord _record(
  MedicineRiskCheckType type, {
  bool stale = false,
  MedicineRiskCheckResult? result,
}) {
  return MedicineRiskCheckRecord(
    checkType: type,
    result: result ?? const MedicineRiskCheckResult(),
    riskScore: 0,
    riskLevel: MedicineRiskLevel.safe,
    stale: stale,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 1),
  );
}

void main() {
  late _FakeRiskCheckRepository repo;

  setUp(() {
    repo = _FakeRiskCheckRepository();
  });

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [
        authSessionProvider.overrideWith(SignedInAuthSessionNotifier.new),
        medicineRiskCheckRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('medicineRiskCheckRecords', () {
    test('returns empty records when never checked', () async {
      final c = makeContainer();
      final records = await c.read(medicineRiskCheckRecordsProvider.future);
      expect(records.isEmpty, isTrue);
    });

    test('returns records from repository', () async {
      repo.records = MedicineRiskCheckRecords(
        staticRecord: _record(MedicineRiskCheckType.static_),
      );
      final c = makeContainer();

      final records = await c.read(medicineRiskCheckRecordsProvider.future);
      expect(records.isEmpty, isFalse);
      expect(records.staticRecord?.checkType, MedicineRiskCheckType.static_);
    });
  });

  group('medicineRiskCheckBestRecord', () {
    test('prefers llm record over static', () async {
      repo.records = MedicineRiskCheckRecords(
        staticRecord: _record(MedicineRiskCheckType.static_),
        llmRecord: _record(
          MedicineRiskCheckType.llm,
          stale: true,
          result: const MedicineRiskCheckResult(overallRiskScore: 30),
        ),
      );
      final c = makeContainer();

      final best = await c.read(medicineRiskCheckBestRecordProvider.future);
      expect(best?.checkType, MedicineRiskCheckType.llm);
      expect(best?.result.overallRiskScore, 30);
      expect(c.read(medicineRiskCheckRecordsProvider).value?.isStale, isTrue);
    });

    test('returns null when no records', () async {
      final c = makeContainer();
      expect(await c.read(medicineRiskCheckBestRecordProvider.future), isNull);
    });
  });

  group('medicineRiskCheck', () {
    test('returns empty result defaults when no record', () async {
      final c = makeContainer();
      final result = await c.read(medicineRiskCheckProvider.future);
      expect(result.overallRiskLevel, MedicineRiskLevel.safe);
      expect(result.overallRiskScore, 0);
      expect(result.findings, isEmpty);
      expect(result.redFlags, isEmpty);
    });

    test('returns result from best record', () async {
      repo.records = MedicineRiskCheckRecords(
        llmRecord: _record(
          MedicineRiskCheckType.llm,
          result: const MedicineRiskCheckResult(
            overallRiskLevel: MedicineRiskLevel.danger,
            overallRiskScore: 95,
          ),
        ),
      );
      final c = makeContainer();

      final result = await c.read(medicineRiskCheckProvider.future);
      expect(result.overallRiskLevel, MedicineRiskLevel.danger);
      expect(result.overallRiskScore, 95);
    });
  });

  group('redFlagAlerts', () {
    test('returns empty list without red flags', () async {
      final c = makeContainer();
      expect(await c.read(redFlagAlertsProvider.future), isEmpty);
    });

    test('returns red flags from best record', () async {
      repo.records = MedicineRiskCheckRecords(
        staticRecord: _record(
          MedicineRiskCheckType.static_,
          result: const MedicineRiskCheckResult(
            redFlags: [
              RedFlagAlert(
                rule: RedFlagRule.severeAllergy,
                primaryMedicineName: '阿莫西林',
              ),
            ],
          ),
        ),
      );
      final c = makeContainer();

      final alerts = await c.read(redFlagAlertsProvider.future);
      expect(alerts, hasLength(1));
      expect(alerts.single.rule, RedFlagRule.severeAllergy);
    });
  });

  group('runMedicineRiskCheck', () {
    test('runs check and returns the record', () async {
      repo.runResult = _record(
        MedicineRiskCheckType.llm,
        result: const MedicineRiskCheckResult(overallRiskScore: 55),
      );
      final c = makeContainer();

      final record = await c.read(
        runMedicineRiskCheckProvider(MedicineRiskCheckType.llm).future,
      );

      expect(record.checkType, MedicineRiskCheckType.llm);
      expect(record.result.overallRiskScore, 55);
      expect(repo.runCount, 1);
    });

    test('invalidates cached records after a run', () async {
      repo.records = const MedicineRiskCheckRecords();
      final c = makeContainer();

      // Cache an empty result first
      final recordsBefore = await c.read(
        medicineRiskCheckRecordsProvider.future,
      );
      expect(recordsBefore.isEmpty, isTrue);

      // Run a check → provider should refetch on the next read
      await c.read(
        runMedicineRiskCheckProvider(MedicineRiskCheckType.static_).future,
      );
      repo.records = MedicineRiskCheckRecords(
        staticRecord: _record(MedicineRiskCheckType.static_),
      );

      final refreshed = await c.read(medicineRiskCheckRecordsProvider.future);
      expect(refreshed.isEmpty, isFalse);
    });
  });

  group('signed-out behavior', () {
    test(
      'records provider throws AuthRequiredException when signed out',
      () async {
        final c = ProviderContainer(
          overrides: [
            authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
            medicineRiskCheckRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(c.dispose);

        final state = c.read(medicineRiskCheckRecordsProvider);
        expect(state.hasError, isTrue);
        expect(state.error, isA<AuthRequiredException>());
      },
    );

    test('run provider throws AuthRequiredException when signed out', () async {
      final c = ProviderContainer(
        overrides: [
          authSessionProvider.overrideWith(SignedOutAuthSessionNotifier.new),
          medicineRiskCheckRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(c.dispose);

      final state = c.read(
        runMedicineRiskCheckProvider(MedicineRiskCheckType.static_),
      );
      expect(state.hasError, isTrue);
      expect(state.error, isA<AuthRequiredException>());
    });
  });
}
