import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_write_inputs.dart';

/// Repository interface for reading and writing the authenticated user health context.
abstract class HealthContextRepository {
  /// Fetches the aggregated health context snapshot for the current user.
  Future<HealthContextSnapshot> fetchHealthContext();

  /// Updates the profile and returns the refreshed snapshot.
  Future<HealthContextSnapshot> updateProfile(HealthProfileUpdateInput input);

  /// Creates an allergy and returns the refreshed snapshot.
  Future<HealthContextSnapshot> createAllergy(HealthAllergyWriteInput input);

  /// Updates an allergy and returns the refreshed snapshot.
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    HealthAllergyUpdateInput input,
  );

  /// Deletes (soft-deactivates) an allergy and returns the refreshed snapshot.
  Future<HealthContextSnapshot> deleteAllergy(String id);

  /// Creates a condition and returns the refreshed snapshot.
  Future<HealthContextSnapshot> createCondition(
    HealthConditionWriteInput input,
  );

  /// Updates a condition and returns the refreshed snapshot.
  Future<HealthContextSnapshot> updateCondition(
    String id,
    HealthConditionUpdateInput input,
  );

  /// Deletes (soft-resolves) a condition and returns the refreshed snapshot.
  Future<HealthContextSnapshot> deleteCondition(String id);

  /// Creates a current medicine and returns the refreshed snapshot.
  Future<HealthContextSnapshot> createCurrentMedicine(
    CurrentMedicineWriteInput input,
  );

  /// Updates a current medicine and returns the refreshed snapshot.
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    CurrentMedicineUpdateInput input,
  );

  /// Deletes (soft-deactivates) a current medicine and returns the refreshed snapshot.
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id);
}
