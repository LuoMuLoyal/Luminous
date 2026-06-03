import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';

/// Form state for the profile edit page.
class HealthProfileFormState {
  const HealthProfileFormState({
    this.isSaving = false,
    this.errorMessage,
    this.saved = false,
  });

  final bool isSaving;
  final String? errorMessage;
  final bool saved;
}

class HealthProfileFormNotifier extends Notifier<HealthProfileFormState> {
  @override
  HealthProfileFormState build() => const HealthProfileFormState();

  Future<void> save(UpdateHealthContextProfileDto dto) async {
    state = const HealthProfileFormState(isSaving: true);

    try {
      final repository = ref.read(healthContextRepositoryProvider);
      await repository.updateProfile(dto);
      ref.invalidate(healthContextSnapshotProvider);
      state = const HealthProfileFormState(saved: true);
    } catch (e) {
      state = HealthProfileFormState(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final healthProfileFormProvider = NotifierProvider<HealthProfileFormNotifier,
  HealthProfileFormState>(HealthProfileFormNotifier.new);

// ── Allergy ──

class AllergyFormState {
  const AllergyFormState({
    this.isSaving = false,
    this.errorMessage,
    this.saved = false,
  });

  final bool isSaving;
  final String? errorMessage;
  final bool saved;
}

class AllergyFormNotifier extends Notifier<AllergyFormState> {
  @override
  AllergyFormState build() => const AllergyFormState();

  Future<void> save({
    required CreateHealthContextAllergyDto create,
    String? id,
    UpdateHealthContextAllergyDto? update,
  }) async {
    state = const AllergyFormState(isSaving: true);

    try {
      final repository = ref.read(healthContextRepositoryProvider);
      if (id != null && update != null) {
        await repository.updateAllergy(id, update);
      } else {
        await repository.createAllergy(create);
      }
      ref.invalidate(healthContextSnapshotProvider);
      state = const AllergyFormState(saved: true);
    } catch (e) {
      state = AllergyFormState(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> delete(String id) async {
    state = const AllergyFormState(isSaving: true);

    try {
      final repository = ref.read(healthContextRepositoryProvider);
      await repository.deleteAllergy(id);
      ref.invalidate(healthContextSnapshotProvider);
      state = const AllergyFormState(saved: true);
    } catch (e) {
      state = AllergyFormState(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final allergyFormProvider =
    NotifierProvider<AllergyFormNotifier, AllergyFormState>(
      AllergyFormNotifier.new,
    );

// ── Condition ──

class ConditionFormState {
  const ConditionFormState({
    this.isSaving = false,
    this.errorMessage,
    this.saved = false,
  });

  final bool isSaving;
  final String? errorMessage;
  final bool saved;
}

class ConditionFormNotifier extends Notifier<ConditionFormState> {
  @override
  ConditionFormState build() => const ConditionFormState();

  Future<void> save({
    required CreateHealthContextConditionDto create,
    String? id,
    UpdateHealthContextConditionDto? update,
  }) async {
    state = const ConditionFormState(isSaving: true);

    try {
      final repository = ref.read(healthContextRepositoryProvider);
      if (id != null && update != null) {
        await repository.updateCondition(id, update);
      } else {
        await repository.createCondition(create);
      }
      ref.invalidate(healthContextSnapshotProvider);
      state = const ConditionFormState(saved: true);
    } catch (e) {
      state = ConditionFormState(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> delete(String id) async {
    state = const ConditionFormState(isSaving: true);

    try {
      final repository = ref.read(healthContextRepositoryProvider);
      await repository.deleteCondition(id);
      ref.invalidate(healthContextSnapshotProvider);
      state = const ConditionFormState(saved: true);
    } catch (e) {
      state = ConditionFormState(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final conditionFormProvider = NotifierProvider<ConditionFormNotifier,
  ConditionFormState>(ConditionFormNotifier.new);

// ── Current Medicine ──

class CurrentMedicineFormState {
  const CurrentMedicineFormState({
    this.isSaving = false,
    this.errorMessage,
    this.saved = false,
  });

  final bool isSaving;
  final String? errorMessage;
  final bool saved;
}

class CurrentMedicineFormNotifier extends Notifier<CurrentMedicineFormState> {
  @override
  CurrentMedicineFormState build() => const CurrentMedicineFormState();

  Future<void> save({
    required CreateCurrentMedicineDto create,
    String? id,
    UpdateCurrentMedicineDto? update,
  }) async {
    state = const CurrentMedicineFormState(isSaving: true);

    try {
      final repository = ref.read(healthContextRepositoryProvider);
      if (id != null && update != null) {
        await repository.updateCurrentMedicine(id, update);
      } else {
        await repository.createCurrentMedicine(create);
      }
      ref.invalidate(healthContextSnapshotProvider);
      state = const CurrentMedicineFormState(saved: true);
    } catch (e) {
      state = CurrentMedicineFormState(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> delete(String id) async {
    state = const CurrentMedicineFormState(isSaving: true);

    try {
      final repository = ref.read(healthContextRepositoryProvider);
      await repository.deleteCurrentMedicine(id);
      ref.invalidate(healthContextSnapshotProvider);
      state = const CurrentMedicineFormState(saved: true);
    } catch (e) {
      state = CurrentMedicineFormState(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final currentMedicineFormProvider = NotifierProvider<CurrentMedicineFormNotifier,
  CurrentMedicineFormState>(CurrentMedicineFormNotifier.new);
