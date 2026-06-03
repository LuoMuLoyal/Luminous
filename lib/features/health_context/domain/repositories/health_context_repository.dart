import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';

/// Repository interface for reading and writing the authenticated user health context.
abstract class HealthContextRepository {
  /// Fetches the aggregated health context snapshot for the current user.
  Future<HealthContextSnapshot> fetchHealthContext();

  /// Updates the profile and returns the refreshed snapshot.
  Future<HealthContextSnapshot> updateProfile(UpdateHealthContextProfileDto dto);

  /// Creates an allergy and returns the refreshed snapshot.
  Future<HealthContextSnapshot> createAllergy(CreateHealthContextAllergyDto dto);

  /// Updates an allergy and returns the refreshed snapshot.
  Future<HealthContextSnapshot> updateAllergy(
    String id,
    UpdateHealthContextAllergyDto dto,
  );

  /// Deletes (soft-deactivates) an allergy and returns the refreshed snapshot.
  Future<HealthContextSnapshot> deleteAllergy(String id);

  /// Creates a condition and returns the refreshed snapshot.
  Future<HealthContextSnapshot> createCondition(
    CreateHealthContextConditionDto dto,
  );

  /// Updates a condition and returns the refreshed snapshot.
  Future<HealthContextSnapshot> updateCondition(
    String id,
    UpdateHealthContextConditionDto dto,
  );

  /// Deletes (soft-resolves) a condition and returns the refreshed snapshot.
  Future<HealthContextSnapshot> deleteCondition(String id);

  /// Creates a current medicine and returns the refreshed snapshot.
  Future<HealthContextSnapshot> createCurrentMedicine(
    CreateCurrentMedicineDto dto,
  );

  /// Updates a current medicine and returns the refreshed snapshot.
  Future<HealthContextSnapshot> updateCurrentMedicine(
    String id,
    UpdateCurrentMedicineDto dto,
  );

  /// Deletes (soft-deactivates) a current medicine and returns the refreshed snapshot.
  Future<HealthContextSnapshot> deleteCurrentMedicine(String id);
}
