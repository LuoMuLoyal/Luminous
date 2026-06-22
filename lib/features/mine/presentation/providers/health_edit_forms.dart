import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_workspace_provider.dart';
import 'package:luminous/features/mine/presentation/providers/mine_dashboard_provider.dart';
import 'package:luminous/features/today/presentation/providers/today_dashboard_provider.dart';

part 'health_edit_forms.freezed.dart';

/// Form state for the profile edit page.
@freezed
abstract class HealthProfileFormState with _$HealthProfileFormState {
  const factory HealthProfileFormState({
    @Default(false) bool isSaving,
    String? errorMessage,
    @Default(false) bool saved,
  }) = _HealthProfileFormState;
}

class HealthProfileFormNotifier extends Notifier<HealthProfileFormState> {
  @override
  HealthProfileFormState build() => const HealthProfileFormState();

  Future<void> save(HealthProfileUpdateInput input) async {
    state = const HealthProfileFormState(isSaving: true);

    try {
      final repository = ref.read(healthContextRepositoryProvider);
      await repository.updateProfile(input);
      ref.invalidate(healthContextSnapshotProvider);
      ref.invalidate(mineDashboardProvider);
      state = const HealthProfileFormState(saved: true);
    } catch (e) {
      state = HealthProfileFormState(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final healthProfileFormProvider =
    NotifierProvider<HealthProfileFormNotifier, HealthProfileFormState>(
      HealthProfileFormNotifier.new,
    );

// ── Allergy ──

@freezed
abstract class AllergyFormState with _$AllergyFormState {
  const factory AllergyFormState({
    @Default(false) bool isSaving,
    String? errorMessage,
    @Default(false) bool saved,
  }) = _AllergyFormState;
}

class AllergyFormNotifier extends Notifier<AllergyFormState> {
  @override
  AllergyFormState build() => const AllergyFormState();

  Future<void> save({
    required HealthAllergyWriteInput create,
    String? id,
    HealthAllergyUpdateInput? update,
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
      ref.invalidate(mineDashboardProvider);
      state = const AllergyFormState(saved: true);
    } catch (e) {
      state = AllergyFormState(isSaving: false, errorMessage: e.toString());
    }
  }

  Future<void> delete(String id) async {
    state = const AllergyFormState(isSaving: true);

    try {
      final repository = ref.read(healthContextRepositoryProvider);
      await repository.deleteAllergy(id);
      ref.invalidate(healthContextSnapshotProvider);
      ref.invalidate(mineDashboardProvider);
      state = const AllergyFormState(saved: true);
    } catch (e) {
      state = AllergyFormState(isSaving: false, errorMessage: e.toString());
    }
  }
}

final allergyFormProvider =
    NotifierProvider<AllergyFormNotifier, AllergyFormState>(
      AllergyFormNotifier.new,
    );

// ── Condition ──

@freezed
abstract class ConditionFormState with _$ConditionFormState {
  const factory ConditionFormState({
    @Default(false) bool isSaving,
    String? errorMessage,
    @Default(false) bool saved,
  }) = _ConditionFormState;
}

class ConditionFormNotifier extends Notifier<ConditionFormState> {
  @override
  ConditionFormState build() => const ConditionFormState();

  Future<void> save({
    required HealthConditionWriteInput create,
    String? id,
    HealthConditionUpdateInput? update,
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
      ref.invalidate(mineDashboardProvider);
      state = const ConditionFormState(saved: true);
    } catch (e) {
      state = ConditionFormState(isSaving: false, errorMessage: e.toString());
    }
  }

  Future<void> delete(String id) async {
    state = const ConditionFormState(isSaving: true);

    try {
      final repository = ref.read(healthContextRepositoryProvider);
      await repository.deleteCondition(id);
      ref.invalidate(healthContextSnapshotProvider);
      ref.invalidate(mineDashboardProvider);
      state = const ConditionFormState(saved: true);
    } catch (e) {
      state = ConditionFormState(isSaving: false, errorMessage: e.toString());
    }
  }
}

final conditionFormProvider =
    NotifierProvider<ConditionFormNotifier, ConditionFormState>(
      ConditionFormNotifier.new,
    );

// ── Current Medicine ──

@freezed
abstract class CurrentMedicineFormState with _$CurrentMedicineFormState {
  const factory CurrentMedicineFormState({
    @Default(false) bool isSaving,
    String? errorMessage,
    @Default(false) bool saved,
  }) = _CurrentMedicineFormState;
}

class CurrentMedicineFormNotifier extends Notifier<CurrentMedicineFormState> {
  @override
  CurrentMedicineFormState build() => const CurrentMedicineFormState();

  Future<void> save({
    required CurrentMedicineWriteInput create,
    String? id,
    CurrentMedicineUpdateInput? update,
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
      ref.invalidate(mineDashboardProvider);
      ref.invalidate(medicineWorkspaceProvider);
      ref.invalidate(todayDashboardProvider);
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
      ref.invalidate(mineDashboardProvider);
      ref.invalidate(medicineWorkspaceProvider);
      ref.invalidate(todayDashboardProvider);
      state = const CurrentMedicineFormState(saved: true);
    } catch (e) {
      state = CurrentMedicineFormState(
        isSaving: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final currentMedicineFormProvider =
    NotifierProvider<CurrentMedicineFormNotifier, CurrentMedicineFormState>(
      CurrentMedicineFormNotifier.new,
    );
