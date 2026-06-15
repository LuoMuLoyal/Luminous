import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';

class RedFlagEvaluator {
  const RedFlagEvaluator();

  List<RedFlagAlert> evaluate({
    required HealthContextSnapshot snapshot,
    required MedicineRiskCheckResult result,
  }) {
    final alerts = <RedFlagAlert>[];

    alerts.addAll(_severeAllergyAlerts(snapshot, result));
    alerts.addAll(_pregnancyContraindicationAlerts(result));
    alerts.addAll(_informationGapAlerts(snapshot, result));

    return alerts;
  }

  // ── Rule 1: Severe allergy match ──────────────────────────
  List<RedFlagAlert> _severeAllergyAlerts(
    HealthContextSnapshot snapshot,
    MedicineRiskCheckResult result,
  ) {
    final severeAllergens = snapshot.allergies
        .where((a) => a.isActive && a.severity == 'severe')
        .map((a) => a.label.trim())
        .where((l) => l.isNotEmpty)
        .toSet();

    if (severeAllergens.isEmpty) return const [];

    return result.findings
        .where((f) =>
            f.type == MedicineRiskFindingType.allergy &&
            f.relatedLabel != null &&
            severeAllergens.contains(f.relatedLabel!.trim()))
        .map(
          (f) => RedFlagAlert(
            rule: RedFlagRule.severeAllergy,
            primaryMedicineName: f.primaryMedicineName,
            relatedLabel: f.relatedLabel,
            resourceId: 'campus-emergency',
          ),
        )
        .toList(growable: false);
  }

  // ── Rule 2: Pregnancy / lactation contraindication ────────
  List<RedFlagAlert> _pregnancyContraindicationAlerts(
    MedicineRiskCheckResult result,
  ) {
    const contraindicationKeywords = ['禁用', 'contraindicated', '禁忌'];

    return result.findings
        .where((f) {
          if (f.type != MedicineRiskFindingType.specialGroup) return false;
          if (f.context != MedicineRiskFindingContext.pregnancy &&
              f.context != MedicineRiskFindingContext.lactation) {
            return false;
          }
          final evidence = f.evidence?.toLowerCase() ?? '';
          return contraindicationKeywords.any(
            (kw) => evidence.contains(kw.toLowerCase()),
          );
        })
        .map(
          (f) => RedFlagAlert(
            rule: RedFlagRule.pregnancyContraindication,
            primaryMedicineName: f.primaryMedicineName,
            resourceId: 'campus-hospital',
          ),
        )
        .toList(growable: false);
  }

  // ── Rule 3: Information gap for high-risk profiles ────────
  List<RedFlagAlert> _informationGapAlerts(
    HealthContextSnapshot snapshot,
    MedicineRiskCheckResult result,
  ) {
    if (result.coverageIssues.isEmpty) return const [];

    final hasHighRiskProfile = snapshot.allergies
            .any((a) => a.isActive && a.severity == 'severe') ||
        snapshot.profile.pregnancyState == 'pregnant' ||
        snapshot.profile.lactationState == 'yes';

    if (!hasHighRiskProfile) return const [];

    return result.coverageIssues
        .take(2)
        .map(
          (issue) => RedFlagAlert(
            rule: RedFlagRule.informationGap,
            primaryMedicineName: issue.medicineName,
            resourceId: 'campus-hospital',
          ),
        )
        .toList(growable: false);
  }
}
