import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_medicine_detail.dart';
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

  static const _pregnancyContextKeywords = [
    '孕',
    '妊娠',
    '胎儿',
    '胚胎',
    '备孕',
    '产后',
    'pregnan',
    'gestat',
    'fetus',
    'foetus',
    'conception',
    'postpartum',
  ];

  static const _lactationContextKeywords = [
    '哺乳',
    '乳汁',
    '授乳',
    '喂奶',
    'lactat',
    'breastfeed',
    'breast-feeding',
    'breast feeding',
    'nursing',
    'milk',
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

  /// Filters legacy combined pregnancy/lactation text so that context-only
  /// evidence does not leak into the opposite context. Used only as a fallback
  /// when the backend has not yet provided split [pregnancy]/[lactation] fields.
  String? _legacySpecialPopulationEvidence(
    Object? rawText,
    MedicineRiskFindingContext context,
  ) {
    final text = asNonEmptyString(rawText);
    if (text == null) return null;

    final lower = text.toLowerCase();
    final mentionsPregnancy = _containsAny(lower, _pregnancyContextKeywords);
    final mentionsLactation = _containsAny(lower, _lactationContextKeywords);

    if (context == MedicineRiskFindingContext.pregnancy &&
        mentionsLactation &&
        !mentionsPregnancy) {
      return null;
    }
    if (context == MedicineRiskFindingContext.lactation &&
        mentionsPregnancy &&
        !mentionsLactation) {
      return null;
    }

    return text;
  }

  // ── Special-group evaluation ────────────────────────────────────

  List<MedicineRiskFinding> _specialGroupFindings(
    HealthContextSnapshot snapshot,
    MedicineRiskMedicineDetail medicine,
  ) {
    final findings = <MedicineRiskFinding>[];
    final detail = medicine.detail.detail;
    final age = snapshot.summary.age;

    final pregnancyText =
        asNonEmptyString(detail.pregnancy) ??
        _legacySpecialPopulationEvidence(
          detail.pregnancyLactation, // ignore: deprecated_member_use
          MedicineRiskFindingContext.pregnancy,
        );
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
    final lactationText =
        asNonEmptyString(detail.lactation) ??
        _legacySpecialPopulationEvidence(
          detail.pregnancyLactation, // ignore: deprecated_member_use
          MedicineRiskFindingContext.lactation,
        );
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

  static final _allergyCrossLanguageMap = <String, Set<String>>{
    'penicillin': {'青霉素', 'penicillin', '盘尼西林'},
    'aspirin': {'阿司匹林', 'aspirin', '乙酰水杨酸', 'acetylsalicylicacid'},
    'cephalosporin': {'头孢', 'cephalosporin', '先锋霉素'},
    'sulfa': {'磺胺', 'sulfa', 'sulfonamide'},
    'ibuprofen': {'布洛芬', 'ibuprofen'},
    'acetaminophen': {'对乙酰氨基酚', 'acetaminophen', 'paracetamol', '扑热息痛'},
    'metformin': {'二甲双胍', 'metformin'},
    'amoxicillin': {'阿莫西林', 'amoxicillin'},
  };

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
          severity: MedicineRiskSeverity.high,
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

  /// Expand an allergy token into all known variants via the cross-language map.
  Set<String> _expandAllergyTokens(String normalizedAllergy) {
    final result = <String>{normalizedAllergy};
    for (final entry in _allergyCrossLanguageMap.entries) {
      final hasMatch = entry.value.any(
        (variant) => normalizeToken(variant) == normalizedAllergy,
      );
      if (hasMatch) {
        result.addAll(entry.value.map(normalizeToken));
      }
    }
    return result;
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
    if (currentTargets.isNotEmpty &&
        other.item.source == 'drugbank' &&
        other.item.sourceRefId != null &&
        currentTargets.contains(other.item.sourceRefId)) {
      return MedicineRiskFinding(
        type: MedicineRiskFindingType.interaction,
        severity: MedicineRiskSeverity.high,
        context: MedicineRiskFindingContext.none,
        primaryMedicineName: current.displayName,
        secondaryMedicineName: other.displayName,
        evidence: _interactionEvidenceFor(
          current.detail.detail.drugInteractions,
          other.item.sourceRefId!,
        ),
      );
    }

    final otherTargets = other.drugbankInteractionTargets;
    if (otherTargets.isNotEmpty &&
        current.item.source == 'drugbank' &&
        current.item.sourceRefId != null &&
        otherTargets.contains(current.item.sourceRefId)) {
      return MedicineRiskFinding(
        type: MedicineRiskFindingType.interaction,
        severity: MedicineRiskSeverity.high,
        context: MedicineRiskFindingContext.none,
        primaryMedicineName: other.displayName,
        secondaryMedicineName: current.displayName,
        evidence: _interactionEvidenceFor(
          other.detail.detail.drugInteractions,
          current.item.sourceRefId!,
        ),
      );
    }

    return null;
  }

  MedicineRiskFinding? _duplicateIngredientFinding(
    MedicineRiskMedicineDetail current,
    MedicineRiskMedicineDetail other,
  ) {
    final currentTokens = current.normalizedIngredientTokens;
    final otherTokens = other.normalizedIngredientTokens;
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
