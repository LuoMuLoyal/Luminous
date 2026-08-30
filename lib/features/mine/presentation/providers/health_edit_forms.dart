import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';

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
      final result = await repository.updateProfile(input).run();
      result.fold((failure) => throw failure, (_) {});
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.healthContext);
      state = const HealthProfileFormState(saved: true);
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('HealthProfileFormNotifier.save: failed: $e');
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
    @Default(false) bool deleted,
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
        final result = await repository.updateAllergy(id, update).run();
        result.fold((failure) => throw failure, (_) {});
      } else {
        final result = await repository.createAllergy(create).run();
        result.fold((failure) => throw failure, (_) {});
      }
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.healthContext);
      state = const AllergyFormState(saved: true);
    } catch (e) {
      ref.read(talkerProvider).error('AllergyFormNotifier.save: failed: $e');
      state = AllergyFormState(isSaving: false, errorMessage: e.toString());
    }
  }

  Future<void> delete(String id) async {
    state = const AllergyFormState(isSaving: true);

    try {
      final repository = ref.read(healthContextRepositoryProvider);
      final result = await repository.deleteAllergy(id).run();
      result.fold((failure) => throw failure, (_) {});
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.healthContext);
      state = const AllergyFormState(saved: true, deleted: true);
    } catch (e) {
      ref.read(talkerProvider).error('AllergyFormNotifier.delete: failed: $e');
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
    @Default(false) bool deleted,
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
        final result = await repository.updateCondition(id, update).run();
        result.fold((failure) => throw failure, (_) {});
      } else {
        final result = await repository.createCondition(create).run();
        result.fold((failure) => throw failure, (_) {});
      }
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.healthContext);
      state = const ConditionFormState(saved: true);
    } catch (e) {
      ref.read(talkerProvider).error('ConditionFormNotifier.save: failed: $e');
      state = ConditionFormState(isSaving: false, errorMessage: e.toString());
    }
  }

  Future<void> delete(String id) async {
    state = const ConditionFormState(isSaving: true);

    try {
      final repository = ref.read(healthContextRepositoryProvider);
      final result = await repository.deleteCondition(id).run();
      result.fold((failure) => throw failure, (_) {});
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.healthContext);
      state = const ConditionFormState(saved: true, deleted: true);
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('ConditionFormNotifier.delete: failed: $e');
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
    @Default(false) bool deleted,
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
        final result = await repository.updateCurrentMedicine(id, update).run();
        result.fold((failure) => throw failure, (_) {});
      } else {
        final result = await repository.createCurrentMedicine(create).run();
        result.fold((failure) => throw failure, (_) {});
      }
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.healthContext);
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.currentMedicines);
      state = const CurrentMedicineFormState(saved: true);
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('CurrentMedicineFormNotifier.save: failed: $e');
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
      final result = await repository.deleteCurrentMedicine(id).run();
      result.fold((failure) => throw failure, (_) {});
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.healthContext);
      ref
          .read(dataChangeBusProvider.notifier)
          .emit(DataChangeTopic.currentMedicines);
      state = const CurrentMedicineFormState(saved: true, deleted: true);
    } catch (e) {
      ref
          .read(talkerProvider)
          .error('CurrentMedicineFormNotifier.delete: failed: $e');
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
