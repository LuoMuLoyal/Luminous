import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';

/// Repository interface for reading and writing the authenticated user health context.
abstract interface class HealthContextRepository {
  /// Fetches the aggregated health context snapshot for the current user.
  TaskEither<LucentFailure, HealthContextSnapshot> fetchHealthContext();

  /// Updates the profile and returns the refreshed snapshot.
  TaskEither<LucentFailure, HealthContextSnapshot> updateProfile(
    HealthProfileUpdateInput input,
  );

  /// Creates an allergy and returns the refreshed snapshot.
  TaskEither<LucentFailure, HealthContextSnapshot> createAllergy(
    HealthAllergyWriteInput input,
  );

  /// Updates an allergy and returns the refreshed snapshot.
  TaskEither<LucentFailure, HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  );

  /// Deletes (soft-deactivates) an allergy and returns the refreshed snapshot.
  TaskEither<LucentFailure, HealthContextSnapshot> deleteAllergy(String id);

  /// Creates a condition and returns the refreshed snapshot.
  TaskEither<LucentFailure, HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  );

  /// Updates a condition and returns the refreshed snapshot.
  TaskEither<LucentFailure, HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  );

  /// Deletes (soft-resolves) a condition and returns the refreshed snapshot.
  TaskEither<LucentFailure, HealthContextSnapshot> deleteCondition(String id);

  /// Creates a current medicine and returns the refreshed snapshot.
  TaskEither<LucentFailure, HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  );

  /// Updates a current medicine and returns the refreshed snapshot.
  TaskEither<LucentFailure, HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  );

  /// Deletes (soft-deactivates) a current medicine and returns the refreshed snapshot.
  TaskEither<LucentFailure, HealthContextSnapshot> deleteCurrentMedicine(
    String id,
  );
}
