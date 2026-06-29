import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_medicine_detail.dart';
import 'package:luminous/features/medicine/domain/services/allergy_severity_helper.dart';
import 'package:luminous/features/medicine/domain/services/ingredient_canonicalizer.dart';
import 'package:luminous/features/medicine/domain/services/medicine_risk_checker_utils.dart';

export 'package:luminous/features/medicine/domain/entities/medicine_risk_medicine_detail.dart';

class MedicineRiskChecker {
  const MedicineRiskChecker();

  MedicineRiskCheckResult evaluate({
    required HealthContextSnapshot snapshot,
    required List<MedicineRiskMedicineDetail> medicines,
  }) {
    final currentMedicines = snapshot.currentMedicines
        .where((item) => item.isCurrent)
        .toList(growable: false);
    final activeAllergies = snapshot.allergies
        .where((item) => item.isActive)
        .toList(growable: false);
    final findings = <MedicineRiskFinding>[];

    for (final medicine in medicines) {
      findings.addAll(_specialGroupFindings(snapshot, medicine));
      findings.addAll(_allergyFindings(activeAllergies, medicine));
      findings.addAll(_foodInteractionFindings(medicine));
    }

    for (var index = 0; index < medicines.length; index += 1) {
      final current = medicines[index];
      for (
        var otherIndex = index + 1;
        otherIndex < medicines.length;
        otherIndex += 1
      ) {
        final other = medicines[otherIndex];
        final interaction = _pairInteractionFinding(current, other);
        if (interaction != null) {
          findings.add(interaction);
        }
        final duplicate = _duplicateIngredientFinding(current, other);
        if (duplicate != null) {
          findings.add(duplicate);
        }
      }
    }

    final coverageIssues = currentMedicines
        .where((item) => !medicines.any((detail) => detail.item.id == item.id))
        .map(_coverageIssueFor)
        .toList(growable: false);

    return MedicineRiskCheckResult(
      currentMedicineCount: currentMedicines.length,
      checkedMedicineCount: medicines.length,
      findings: findings,
      coverageIssues: coverageIssues,
      coverageSummary: _buildCoverageSummary(
        currentMedicineCount: currentMedicines.length,
        checkedMedicineCount: medicines.length,
        coverageIssues: coverageIssues,
        medicines: medicines,
      ),
    );
  }

  static final _pediatricAgeThreshold = 18;
  static final _geriatricAgeThreshold = 65;

  // Inclusive boundaries: pediatric <= 18, geriatric >= 65.

  // ── Special-population text classifier ──────────────────────────
  // Conservative keyword matching only — no NLP.
  // Falls back to insufficientInformation when no keyword matches.

  static const _contraindicatedKeywords = [
    '禁用',
    '禁忌',
    '禁止使用',
    '不得使用',
    '不应使用',
    'contraindicated',
    'contraindication',
    'must not be used',
    'should not be used',
    'do not use',
  ];

  static const _avoidKeywords = [
    '避免使用',
    '避免',
    '不宜使用',
    '不推荐',
    '不建议',
    'avoid',
    'not recommended',
    'should be avoided',
    'not advised',
  ];

  static const _cautionKeywords = [
    '慎用',
    '谨慎',
    '注意',
    '小心',
    '慎重',
    'caution',
    'with caution',
    'careful',
    'use with care',
  ];

  static const _consultKeywords = [
    '咨询医生',
    '咨询医师',
    '咨询药师',
    '遵医嘱',
    '在医生指导下',
    '医师指导',
    '医生指导下',
    'consult',
    'physician',
    'doctor',
    'pharmacist',
    'under medical supervision',
    'seek medical advice',
  ];

  SpecialPopulationConclusion _classifySpecialPopulationText(String text) {
    final lower = text.toLowerCase();
    if (_containsAny(lower, _contraindicatedKeywords)) {
      return SpecialPopulationConclusion.contraindicated;
    }
    if (_containsAny(lower, _avoidKeywords)) {
      return SpecialPopulationConclusion.avoid;
    }
    if (_containsAny(lower, _cautionKeywords)) {
      return SpecialPopulationConclusion.caution;
    }
    if (_containsAny(lower, _consultKeywords)) {
      return SpecialPopulationConclusion.consultClinician;
    }
    return SpecialPopulationConclusion.insufficientInformation;
  }

  static bool _containsAny(String text, Iterable<String> keywords) {
    return keywords.any((kw) => text.contains(kw));
  }

  MedicineRiskSeverity _severityForConclusion(
    SpecialPopulationConclusion conclusion,
  ) {
    return switch (conclusion) {
      SpecialPopulationConclusion.contraindicated => MedicineRiskSeverity.high,
      SpecialPopulationConclusion.avoid => MedicineRiskSeverity.high,
      SpecialPopulationConclusion.caution => MedicineRiskSeverity.medium,
      SpecialPopulationConclusion.consultClinician =>
        MedicineRiskSeverity.medium,
      SpecialPopulationConclusion.insufficientInformation =>
        MedicineRiskSeverity.info,
    };
  }

  MedicineRiskFinding _specialGroupClassifiedFinding({
    required String medicineName,
    required MedicineRiskFindingContext context,
    required String evidenceText,
  }) {
    final conclusion = _classifySpecialPopulationText(evidenceText);
    return MedicineRiskFinding(
      type: MedicineRiskFindingType.specialGroup,
      severity: _severityForConclusion(conclusion),
      context: context,
      primaryMedicineName: medicineName,
      evidence: evidenceText,
      specialPopulationConclusion: conclusion,
    );
  }

  // ── Special-group evaluation ────────────────────────────────────

  List<MedicineRiskFinding> _specialGroupFindings(
    HealthContextSnapshot snapshot,
    MedicineRiskMedicineDetail medicine,
  ) {
    final findings = <MedicineRiskFinding>[];
    final detail = medicine.detail.detail;
    final age = snapshot.summary.age;

    final pregnancyText = asNonEmptyString(detail.pregnancy);
    final pregnancyState = snapshot.profile.pregnancyState;
    final hasPregnancyRisk =
        pregnancyState == 'pregnant' ||
        pregnancyState == 'trying' ||
        pregnancyState == 'postpartum';
    if (pregnancyText != null && hasPregnancyRisk) {
      findings.add(
        _specialGroupClassifiedFinding(
          medicineName: medicine.displayName,
          context: MedicineRiskFindingContext.pregnancy,
          evidenceText: pregnancyText,
        ),
      );
    } else if (pregnancyText == null && hasPregnancyRisk) {
      findings.add(
        _noSpecialGroupWarningFinding(
          medicine.displayName,
          MedicineRiskFindingContext.pregnancy,
        ),
      );
    }

    final lactationState = snapshot.profile.lactationState;
    final hasLactationRisk = lactationState == 'yes';
    final lactationText = asNonEmptyString(detail.lactation);
    if (lactationText != null && hasLactationRisk) {
      findings.add(
        _specialGroupClassifiedFinding(
          medicineName: medicine.displayName,
          context: MedicineRiskFindingContext.lactation,
          evidenceText: lactationText,
        ),
      );
    } else if (lactationText == null && hasLactationRisk) {
      findings.add(
        _noSpecialGroupWarningFinding(
          medicine.displayName,
          MedicineRiskFindingContext.lactation,
        ),
      );
    }

    final isPediatric = age != null && age <= _pediatricAgeThreshold;
    final pediatricText = asNonEmptyString(detail.pediatricUse);
    if (pediatricText != null && isPediatric) {
      findings.add(
        _specialGroupClassifiedFinding(
          medicineName: medicine.displayName,
          context: MedicineRiskFindingContext.pediatric,
          evidenceText: pediatricText,
        ),
      );
    } else if (pediatricText == null && isPediatric) {
      findings.add(
        _noSpecialGroupWarningFinding(
          medicine.displayName,
          MedicineRiskFindingContext.pediatric,
        ),
      );
    }

    final isGeriatric = age != null && age >= _geriatricAgeThreshold;
    final geriatricText = asNonEmptyString(detail.geriatricUse);
    if (geriatricText != null && isGeriatric) {
      findings.add(
        _specialGroupClassifiedFinding(
          medicineName: medicine.displayName,
          context: MedicineRiskFindingContext.geriatric,
          evidenceText: geriatricText,
        ),
      );
    } else if (geriatricText == null && isGeriatric) {
      findings.add(
        _noSpecialGroupWarningFinding(
          medicine.displayName,
          MedicineRiskFindingContext.geriatric,
        ),
      );
    }

    return findings;
  }

  MedicineRiskFinding _noSpecialGroupWarningFinding(
    String medicineName,
    MedicineRiskFindingContext context,
  ) {
    return MedicineRiskFinding(
      type: MedicineRiskFindingType.specialGroup,
      severity: MedicineRiskSeverity.info,
      context: context,
      primaryMedicineName: medicineName,
      evidence: null,
    );
  }

  List<MedicineRiskFinding> _allergyFindings(
    List<AllergyItem> activeAllergies,
    MedicineRiskMedicineDetail medicine,
  ) {
    if (activeAllergies.isEmpty) return const [];

    final ingredientTokens = medicine.allSourceIngredientTokens;
    final detail = medicine.detail.detail;
    final haystacks = <String>[
      medicine.displayName,
      asNonEmptyString(detail.ingredients) ?? '',
      asNonEmptyString(detail.contraindications) ?? '',
      asNonEmptyString(detail.precautions) ?? '',
      ...medicine.drugbankSynonymTokens,
    ];
    final normalizedHaystack = normalizeToken(haystacks.join(' '));

    final findings = <MedicineRiskFinding>[];
    for (final allergyItem in activeAllergies) {
      final rawLabel = allergyItem.label.trim();
      if (rawLabel.isEmpty) continue;
      final allergyToken = normalizeToken(rawLabel);
      if (allergyToken.isEmpty) continue;

      final matchTokens = _expandAllergyTokens(allergyToken);
      final matchedViaToken = ingredientTokens
          .intersection(matchTokens)
          .isNotEmpty;
      final matchedViaHaystack = matchTokens.any(
        (token) => normalizedHaystack.contains(token),
      );

      if (!matchedViaToken && !matchedViaHaystack) continue;

      findings.add(
        MedicineRiskFinding(
          type: MedicineRiskFindingType.allergy,
          severity: _allergyFindingSeverity(allergyItem),
          context: MedicineRiskFindingContext.none,
          primaryMedicineName: medicine.displayName,
          relatedLabel: rawLabel,
          evidence: firstNonEmpty(
            asNonEmptyString(detail.contraindications),
            asNonEmptyString(detail.ingredients),
            asNonEmptyString(detail.precautions),
          ),
        ),
      );
    }

    return findings;
  }

  MedicineRiskSeverity _allergyFindingSeverity(AllergyItem allergy) {
    return switch (inferredAllergySeverity(allergy)) {
      'severe' => MedicineRiskSeverity.high,
      'moderate' => MedicineRiskSeverity.medium,
      'mild' => MedicineRiskSeverity.info,
      _ => MedicineRiskSeverity.high,
    };
  }

  /// Expand an allergy token into all known variants via the canonical
  /// cross-language ingredient map.
  Set<String> _expandAllergyTokens(String normalizedAllergy) {
    return expandCanonicalIngredientTokens({normalizedAllergy});
  }

  List<MedicineRiskFinding> _foodInteractionFindings(
    MedicineRiskMedicineDetail medicine,
  ) {
    final findings = <MedicineRiskFinding>[];
    for (final interaction in medicine.detail.detail.foodInteractions) {
      final normalized = normalizeToken(interaction);
      if (normalized.contains('alcohol') || normalized.contains('酒')) {
        findings.add(
          MedicineRiskFinding(
            type: MedicineRiskFindingType.foodInteraction,
            severity: MedicineRiskSeverity.medium,
            context: MedicineRiskFindingContext.alcohol,
            primaryMedicineName: medicine.displayName,
            evidence: interaction,
          ),
        );
      }
      if (normalized.contains('caffeine') ||
          normalized.contains('coffee') ||
          normalized.contains('tea') ||
          normalized.contains('咖啡') ||
          normalized.contains('浓茶')) {
        findings.add(
          MedicineRiskFinding(
            type: MedicineRiskFindingType.foodInteraction,
            severity: MedicineRiskSeverity.info,
            context: MedicineRiskFindingContext.caffeine,
            primaryMedicineName: medicine.displayName,
            evidence: interaction,
          ),
        );
      }
    }
    return findings;
  }

  MedicineRiskFinding? _pairInteractionFinding(
    MedicineRiskMedicineDetail current,
    MedicineRiskMedicineDetail other,
  ) {
    final currentTargets = current.drugbankInteractionTargets;
    final otherIds = other.drugbankIds;
    final overlappingIds = currentTargets.intersection(otherIds);
    if (overlappingIds.isNotEmpty) {
      final targetId = overlappingIds.first;
      return MedicineRiskFinding(
        type: MedicineRiskFindingType.interaction,
        severity: MedicineRiskSeverity.high,
        context: MedicineRiskFindingContext.none,
        primaryMedicineName: current.displayName,
        secondaryMedicineName: other.displayName,
        evidence: _interactionEvidenceFor(
          current.detail.detail.drugInteractions,
          targetId,
        ),
      );
    }

    final otherTargets = other.drugbankInteractionTargets;
    final currentIds = current.drugbankIds;
    final reverseOverlappingIds = otherTargets.intersection(currentIds);
    if (reverseOverlappingIds.isNotEmpty) {
      final targetId = reverseOverlappingIds.first;
      return MedicineRiskFinding(
        type: MedicineRiskFindingType.interaction,
        severity: MedicineRiskSeverity.high,
        context: MedicineRiskFindingContext.none,
        primaryMedicineName: other.displayName,
        secondaryMedicineName: current.displayName,
        evidence: _interactionEvidenceFor(
          other.detail.detail.drugInteractions,
          targetId,
        ),
      );
    }

    return null;
  }

  MedicineRiskFinding? _duplicateIngredientFinding(
    MedicineRiskMedicineDetail current,
    MedicineRiskMedicineDetail other,
  ) {
    final currentTokens = current.canonicalIngredientKeys;
    final otherTokens = other.canonicalIngredientKeys;
    if (currentTokens.isEmpty || otherTokens.isEmpty) {
      return null;
    }

    final sharedTokens = currentTokens.intersection(otherTokens);
    if (sharedTokens.isEmpty) {
      return null;
    }

    return MedicineRiskFinding(
      type: MedicineRiskFindingType.duplicateIngredient,
      severity: MedicineRiskSeverity.medium,
      context: MedicineRiskFindingContext.none,
      primaryMedicineName: current.displayName,
      secondaryMedicineName: other.displayName,
      evidence: duplicateIngredientEvidence(sharedTokens),
    );
  }

  MedicineRiskCoverageIssue _coverageIssueFor(CurrentMedicineItem item) {
    if (item.source == 'manual') {
      return MedicineRiskCoverageIssue(
        medicineName: item.displayName,
        reason: MedicineRiskCoverageReason.manualEntry,
      );
    }
    if (item.sourceRefId == null || item.sourceRefId!.trim().isEmpty) {
      return MedicineRiskCoverageIssue(
        medicineName: item.displayName,
        reason: MedicineRiskCoverageReason.missingSourceRef,
      );
    }
    return MedicineRiskCoverageIssue(
      medicineName: item.displayName,
      reason: MedicineRiskCoverageReason.detailUnavailable,
    );
  }

  String? _interactionEvidenceFor(Object? value, String targetId) {
    if (value is! List) return null;
    for (final item in value) {
      if (item is! Map) continue;
      final dynamic id = item['drugbankId'];
      if (id?.toString() != targetId) continue;
      return asNonEmptyString(item['description']);
    }
    return null;
  }

  String _buildCoverageSummary({
    required int currentMedicineCount,
    required int checkedMedicineCount,
    required List<MedicineRiskCoverageIssue> coverageIssues,
    required List<MedicineRiskMedicineDetail> medicines,
  }) {
    if (currentMedicineCount == 0) return '';
    if (coverageIssues.isEmpty) return '';
    final manualCount = coverageIssues
        .where(
          (issue) => issue.reason == MedicineRiskCoverageReason.manualEntry,
        )
        .length;
    final unavailableCount = coverageIssues.length - manualCount;
    final parts = <String>[];
    if (manualCount > 0) parts.add('$manualCount 种手动录入药品无法自动检查');
    if (unavailableCount > 0) parts.add('$unavailableCount 种药品详情不可用');
    return parts.join('；');
  }
}
