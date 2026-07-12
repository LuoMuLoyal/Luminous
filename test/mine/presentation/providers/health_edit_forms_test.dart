import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/health_context/data/providers/data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/features/health_context/domain/repositories/snapshot.dart';
import 'package:luminous/features/mine/presentation/providers/health_edit_forms.dart';

/// A fake [HealthContextRepository] that returns a fixed snapshot for all
/// write methods, or throws if [throwOnNext] is set.
class _FakeHealthContextRepository implements HealthContextRepository {
  _FakeHealthContextRepository(this._snapshot);

  final HealthContextSnapshot _snapshot;
  Object? throwOnNext;
  int callCount = 0;
  String? lastMethodCalled;
  List<String> deleteCallIds = [];

  @override
  Future<HealthContextSnapshot> fetchHealthContext() async => _snapshot;

  @override
  Future<HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  ) async {
    lastMethodCalled = 'updateProfile';
    callCount++;
    if (throwOnNext != null) {
      final e = throwOnNext!;
      throwOnNext = null;
      throw e;
    }
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  ) async {
    lastMethodCalled = 'createAllergy';
    callCount++;
    if (throwOnNext != null) {
      final e = throwOnNext!;
      throwOnNext = null;
      throw e;
    }
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  ) async {
    lastMethodCalled = 'updateAllergy';
    callCount++;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> deleteAllergy(String id) async {
    lastMethodCalled = 'deleteAllergy';
    callCount++;
    deleteCallIds.add(id);
    if (throwOnNext != null) {
      final e = throwOnNext!;
      throwOnNext = null;
      throw e;
    }
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  ) async {
    lastMethodCalled = 'createCondition';
    callCount++;
    if (throwOnNext != null) {
      final e = throwOnNext!;
      throwOnNext = null;
      throw e;
    }
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  ) async {
    lastMethodCalled = 'updateCondition';
    callCount++;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> deleteCondition(String id) async {
    lastMethodCalled = 'deleteCondition';
    callCount++;
    deleteCallIds.add(id);
    if (throwOnNext != null) {
      final e = throwOnNext!;
      throwOnNext = null;
      throw e;
    }
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  ) async {
    lastMethodCalled = 'createCurrentMedicine';
    callCount++;
    if (throwOnNext != null) {
      final e = throwOnNext!;
      throwOnNext = null;
      throw e;
    }
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  ) async {
    lastMethodCalled = 'updateCurrentMedicine';
    callCount++;
    return _snapshot;
  }

  @override
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id) async {
    lastMethodCalled = 'deleteCurrentMedicine';
    callCount++;
    deleteCallIds.add(id);
    if (throwOnNext != null) {
      final e = throwOnNext!;
      throwOnNext = null;
      throw e;
    }
    return _snapshot;
  }
}

HealthContextSnapshot _testSnapshot() => const HealthContextSnapshot(
  summary: HealthSummary(
    age: 25,
    onboardingCompleted: true,
    activeAllergyCount: 1,
    conditionCount: 0,
    currentMedicineCount: 1,
    missingCoreProfileFields: [],
  ),
  profile: HealthProfile(
    birthDate: '2000-01-01',
    sexAtBirth: null,
    heightCm: 170.0,
    bloodType: null,
    locale: null,
    timezone: null,
    unitSystem: null,
    onboardingCompletedAt: null,
    extras: {},
  ),
  allergies: [],
  conditions: [],
  currentMedicines: [],
);

void main() {
  late _FakeHealthContextRepository fakeRepo;

  ProviderContainer buildContainer() {
    final c = ProviderContainer(
      overrides: [healthContextRepositoryProvider.overrideWithValue(fakeRepo)],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() {
    fakeRepo = _FakeHealthContextRepository(_testSnapshot());
  });

  group('HealthProfileFormNotifier', () {
    test('initial state is idle', () {
      final c = buildContainer();
      final state = c.read(healthProfileFormProvider);
      expect(state.isSaving, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.saved, isFalse);
    });

    test('save succeeds and sets saved state', () async {
      final c = buildContainer();
      await c
          .read(healthProfileFormProvider.notifier)
          .save(const HealthProfileUpdateInput());

      final state = c.read(healthProfileFormProvider);
      expect(state.isSaving, isFalse);
      expect(state.saved, isTrue);
      expect(state.errorMessage, isNull);
      expect(fakeRepo.lastMethodCalled, 'updateProfile');
    });

    test('save failure sets error message', () async {
      fakeRepo.throwOnNext = Exception('Update failed');

      final c = buildContainer();
      await c
          .read(healthProfileFormProvider.notifier)
          .save(const HealthProfileUpdateInput());

      final state = c.read(healthProfileFormProvider);
      expect(state.isSaving, isFalse);
      expect(state.saved, isFalse);
      expect(state.errorMessage, isNotNull);
    });
  });

  group('AllergyFormNotifier', () {
    test('create allergy succeeds and sets saved state', () async {
      const input = HealthAllergyWriteInput(
        kind: HealthAllergyKind.drug,
        label: 'Penicillin',
      );

      final c = buildContainer();
      await c.read(allergyFormProvider.notifier).save(create: input);

      final state = c.read(allergyFormProvider);
      expect(state.saved, isTrue);
      expect(state.errorMessage, isNull);
      expect(fakeRepo.lastMethodCalled, 'createAllergy');
    });

    test('update allergy succeeds when id and update are provided', () async {
      const update = HealthAllergyUpdateInput(label: 'Updated');

      final c = buildContainer();
      await c
          .read(allergyFormProvider.notifier)
          .save(
            create: const HealthAllergyWriteInput(
              kind: HealthAllergyKind.drug,
              label: 'temp',
            ),
            id: 'a1',
            update: update,
          );

      final state = c.read(allergyFormProvider);
      expect(state.saved, isTrue);
      expect(fakeRepo.lastMethodCalled, 'updateAllergy');
    });

    test('delete allergy succeeds and sets saved state', () async {
      final c = buildContainer();
      await c.read(allergyFormProvider.notifier).delete('a1');

      final state = c.read(allergyFormProvider);
      expect(state.saved, isTrue);
      expect(state.errorMessage, isNull);
      expect(fakeRepo.deleteCallIds, ['a1']);
    });

    test('delete allergy failure sets error message', () async {
      fakeRepo.throwOnNext = Exception('Delete failed');

      final c = buildContainer();
      await c.read(allergyFormProvider.notifier).delete('a1');

      final state = c.read(allergyFormProvider);
      expect(state.saved, isFalse);
      expect(state.errorMessage, isNotNull);
    });
  });

  group('ConditionFormNotifier', () {
    test('create condition succeeds', () async {
      const input = HealthConditionWriteInput(label: 'Hypertension');

      final c = buildContainer();
      await c.read(conditionFormProvider.notifier).save(create: input);

      expect(c.read(conditionFormProvider).saved, isTrue);
      expect(fakeRepo.lastMethodCalled, 'createCondition');
    });

    test('update condition succeeds when id and update are provided', () async {
      const update = HealthConditionUpdateInput(label: 'Updated');

      final c = buildContainer();
      await c
          .read(conditionFormProvider.notifier)
          .save(
            create: const HealthConditionWriteInput(label: 'temp'),
            id: 'c1',
            update: update,
          );

      expect(c.read(conditionFormProvider).saved, isTrue);
      expect(fakeRepo.lastMethodCalled, 'updateCondition');
    });

    test('delete condition succeeds', () async {
      final c = buildContainer();
      await c.read(conditionFormProvider.notifier).delete('c1');

      expect(c.read(conditionFormProvider).saved, isTrue);
      expect(fakeRepo.deleteCallIds, ['c1']);
    });

    test('delete condition failure sets error', () async {
      fakeRepo.throwOnNext = Exception('Delete failed');

      final c = buildContainer();
      await c.read(conditionFormProvider.notifier).delete('c1');

      final state = c.read(conditionFormProvider);
      expect(state.saved, isFalse);
      expect(state.errorMessage, isNotNull);
    });
  });

  group('CurrentMedicineFormNotifier', () {
    test('create current medicine succeeds', () async {
      const input = CurrentMedicineWriteInput(
        source: HealthMedicineSource.manual,
        displayName: 'Aspirin',
      );

      final c = buildContainer();
      await c.read(currentMedicineFormProvider.notifier).save(create: input);

      expect(c.read(currentMedicineFormProvider).saved, isTrue);
      expect(fakeRepo.lastMethodCalled, 'createCurrentMedicine');
    });

    test(
      'update current medicine succeeds when id and update are provided',
      () async {
        const update = CurrentMedicineUpdateInput(displayName: 'Updated');

        final c = buildContainer();
        await c
            .read(currentMedicineFormProvider.notifier)
            .save(
              create: const CurrentMedicineWriteInput(
                source: HealthMedicineSource.manual,
                displayName: 'temp',
              ),
              id: 'm1',
              update: update,
            );

        expect(c.read(currentMedicineFormProvider).saved, isTrue);
        expect(fakeRepo.lastMethodCalled, 'updateCurrentMedicine');
      },
    );

    test('delete current medicine succeeds', () async {
      final c = buildContainer();
      await c.read(currentMedicineFormProvider.notifier).delete('m1');

      expect(c.read(currentMedicineFormProvider).saved, isTrue);
      expect(fakeRepo.deleteCallIds, ['m1']);
    });

    test('create current medicine failure sets error', () async {
      fakeRepo.throwOnNext = Exception('Create failed');

      final c = buildContainer();
      await c
          .read(currentMedicineFormProvider.notifier)
          .save(
            create: const CurrentMedicineWriteInput(
              source: HealthMedicineSource.manual,
              displayName: 'Aspirin',
            ),
          );

      final state = c.read(currentMedicineFormProvider);
      expect(state.saved, isFalse);
      expect(state.errorMessage, isNotNull);
    });

    test('delete current medicine failure sets error', () async {
      fakeRepo.throwOnNext = Exception('Delete failed');

      final c = buildContainer();
      await c.read(currentMedicineFormProvider.notifier).delete('m1');

      final state = c.read(currentMedicineFormProvider);
      expect(state.saved, isFalse);
      expect(state.errorMessage, isNotNull);
    });
  });

  group('Form state transitions', () {
    test('HealthProfileForm transitions through isSaving during save', () async {
      final c = buildContainer();
      final saveFuture = c
          .read(healthProfileFormProvider.notifier)
          .save(const HealthProfileUpdateInput());

      // While saving, isSaving should be true
      expect(c.read(healthProfileFormProvider).isSaving, isTrue);

      await saveFuture;

      // After save completes, isSaving should be false and saved should be true
      final state = c.read(healthProfileFormProvider);
      expect(state.isSaving, isFalse);
      expect(state.saved, isTrue);
    });
  });
}
