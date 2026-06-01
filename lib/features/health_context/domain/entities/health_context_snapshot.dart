import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_context_snapshot.freezed.dart';

/// Aggregate health context snapshot fetched from GET /api/v1/me/health-context.
@freezed
abstract class HealthContextSnapshot with _$HealthContextSnapshot {
  const factory HealthContextSnapshot({
    required HealthSummary summary,
    required HealthProfile profile,
    required List<AllergyItem> allergies,
    required List<ConditionItem> conditions,
    required List<CurrentMedicineItem> currentMedicines,
  }) = _HealthContextSnapshot;
}

@freezed
abstract class HealthSummary with _$HealthSummary {
  const factory HealthSummary({
    required int? age,
    required bool onboardingCompleted,
    required int activeAllergyCount,
    required int conditionCount,
    required int currentMedicineCount,
    required List<String> missingCoreProfileFields,
  }) = _HealthSummary;
}

@freezed
abstract class HealthProfile with _$HealthProfile {
  const factory HealthProfile({
    required String? birthDate,
    required String? sexAtBirth,
    required double? heightCm,
    required String? pregnancyState,
    required String? lactationState,
    required String? bloodType,
    required String? locale,
    required String? timezone,
    required String? unitSystem,
    required String? onboardingCompletedAt,
    required Map<String, dynamic> extras,
  }) = _HealthProfile;
}

@freezed
abstract class AllergyItem with _$AllergyItem {
  const factory AllergyItem({
    required String id,
    required String kind,
    required String label,
    required String? reaction,
    required String? severity,
    required bool isActive,
    required String? note,
    required String createdAt,
    required String updatedAt,
  }) = _AllergyItem;
}

@freezed
abstract class ConditionItem with _$ConditionItem {
  const factory ConditionItem({
    required String id,
    required String label,
    required String status,
    required String? diagnosedAt,
    required String? resolvedAt,
    required String? note,
    required String createdAt,
    required String updatedAt,
  }) = _ConditionItem;
}

@freezed
abstract class CurrentMedicineItem with _$CurrentMedicineItem {
  const factory CurrentMedicineItem({
    required String id,
    required String source,
    required String? sourceRefId,
    required String displayName,
    required String? strengthText,
    required String? doseText,
    required String? route,
    required String? startedAt,
    required String? endedAt,
    required bool isCurrent,
    required String? note,
    required String createdAt,
    required String updatedAt,
  }) = _CurrentMedicineItem;
}
