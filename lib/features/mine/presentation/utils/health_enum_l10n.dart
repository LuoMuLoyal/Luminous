import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Localized display labels for health-context wire enums.
///
/// The raw enum [HealthContextWireEnum.value] is an English wire string (e.g.
/// `'drug'`, `'mild'`) used for API transport. These helpers map each enum
/// value to a user-facing localized string so the UI never shows raw English
/// wire values.

String allergyKindLabel(AppLocalizations l10n, HealthAllergyKind kind) {
  return switch (kind) {
    HealthAllergyKind.drug => l10n.mineAllergyKindDrug,
    HealthAllergyKind.food => l10n.mineAllergyKindFood,
    HealthAllergyKind.environment => l10n.mineAllergyKindEnvironment,
    HealthAllergyKind.other => l10n.mineAllergyKindOther,
  };
}

String allergySeverityLabel(
  AppLocalizations l10n,
  HealthAllergySeverity severity,
) {
  return switch (severity) {
    HealthAllergySeverity.mild => l10n.mineAllergySeverityMild,
    HealthAllergySeverity.moderate => l10n.mineAllergySeverityModerate,
    HealthAllergySeverity.severe => l10n.mineAllergySeveritySevere,
    HealthAllergySeverity.unknown => l10n.mineAllergySeverityUnknown,
  };
}

/// Short helper description shown below the severity selector to explain
/// what each level means in practice.
String allergySeverityDescription(
  AppLocalizations l10n,
  HealthAllergySeverity severity,
) {
  return switch (severity) {
    HealthAllergySeverity.mild => l10n.mineAllergySeverityMildDesc,
    HealthAllergySeverity.moderate => l10n.mineAllergySeverityModerateDesc,
    HealthAllergySeverity.severe => l10n.mineAllergySeveritySevereDesc,
    HealthAllergySeverity.unknown => l10n.mineAllergySeverityUnknownDesc,
  };
}

String conditionStatusLabel(
  AppLocalizations l10n,
  HealthConditionStatus status,
) {
  return switch (status) {
    HealthConditionStatus.active => l10n.mineConditionStatusActive,
    HealthConditionStatus.resolved => l10n.mineConditionStatusResolved,
    HealthConditionStatus.suspected => l10n.mineConditionStatusSuspected,
  };
}

/// Short helper description shown below the status selector to explain
/// what each status means.
String conditionStatusDescription(
  AppLocalizations l10n,
  HealthConditionStatus status,
) {
  return switch (status) {
    HealthConditionStatus.active => l10n.mineConditionStatusActiveDesc,
    HealthConditionStatus.resolved => l10n.mineConditionStatusResolvedDesc,
    HealthConditionStatus.suspected => l10n.mineConditionStatusSuspectedDesc,
  };
}

String medicineSourceLabel(AppLocalizations l10n, HealthMedicineSource source) {
  return switch (source) {
    HealthMedicineSource.drugbank => l10n.mineMedicineSourceDrugbank,
    HealthMedicineSource.cn => l10n.mineMedicineSourceCn,
    HealthMedicineSource.manual => l10n.mineMedicineSourceManual,
  };
}
