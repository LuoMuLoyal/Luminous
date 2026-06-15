import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_risk_check.dart';

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
      for (var otherIndex = index + 1; otherIndex < medicines.length; otherIndex += 1) {
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

  List<MedicineRiskFinding> _specialGroupFindings(
    HealthContextSnapshot snapshot,
    MedicineRiskMedicineDetail medicine,
  ) {
    final findings = <MedicineRiskFinding>[];
    final detail = medicine.detail.detail;
    final age = snapshot.summary.age;

    final pregnancyText = _asNonEmptyString(detail.pregnancyLactation);
    final pregnancyState = snapshot.profile.pregnancyState;
    final hasPregnancyRisk = pregnancyState == 'pregnant' ||
        pregnancyState == 'trying' ||
        pregnancyState == 'postpartum';
    if (pregnancyText != null && hasPregnancyRisk) {
      findings.add(
        MedicineRiskFinding(
          type: MedicineRiskFindingType.specialGroup,
          severity: MedicineRiskSeverity.high,
          context: MedicineRiskFindingContext.pregnancy,
          primaryMedicineName: medicine.displayName,
          evidence: pregnancyText,
        ),
      );
    } else if (pregnancyText == null && hasPregnancyRisk) {
      findings.add(_noSpecialGroupWarningFinding(
        medicine.displayName,
        MedicineRiskFindingContext.pregnancy,
      ));
    }

    final lactationState = snapshot.profile.lactationState;
    final hasLactationRisk = lactationState == 'yes';
    if (pregnancyText != null && hasLactationRisk) {
      findings.add(
        MedicineRiskFinding(
          type: MedicineRiskFindingType.specialGroup,
          severity: MedicineRiskSeverity.high,
          context: MedicineRiskFindingContext.lactation,
          primaryMedicineName: medicine.displayName,
          evidence: pregnancyText,
        ),
      );
    } else if (pregnancyText == null && hasLactationRisk) {
      findings.add(_noSpecialGroupWarningFinding(
        medicine.displayName,
        MedicineRiskFindingContext.lactation,
      ));
    }

    final isPediatric = age != null && age < _pediatricAgeThreshold;
    final pediatricText = _asNonEmptyString(detail.pediatricUse);
    if (pediatricText != null && isPediatric) {
      findings.add(
        MedicineRiskFinding(
          type: MedicineRiskFindingType.specialGroup,
          severity: MedicineRiskSeverity.medium,
          context: MedicineRiskFindingContext.pediatric,
          primaryMedicineName: medicine.displayName,
          evidence: pediatricText,
        ),
      );
    } else if (pediatricText == null && isPediatric) {
      findings.add(_noSpecialGroupWarningFinding(
        medicine.displayName,
        MedicineRiskFindingContext.pediatric,
      ));
    }

    final isGeriatric = age != null && age > _geriatricAgeThreshold;
    final geriatricText = _asNonEmptyString(detail.geriatricUse);
    if (geriatricText != null && isGeriatric) {
      findings.add(
        MedicineRiskFinding(
          type: MedicineRiskFindingType.specialGroup,
          severity: MedicineRiskSeverity.medium,
          context: MedicineRiskFindingContext.geriatric,
          primaryMedicineName: medicine.displayName,
          evidence: geriatricText,
        ),
      );
    } else if (geriatricText == null && isGeriatric) {
      findings.add(_noSpecialGroupWarningFinding(
        medicine.displayName,
        MedicineRiskFindingContext.geriatric,
      ));
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
      _asNonEmptyString(detail.ingredients) ?? '',
      _asNonEmptyString(detail.contraindications) ?? '',
      _asNonEmptyString(detail.precautions) ?? '',
      ...medicine.drugbankSynonymTokens,
    ];
    final normalizedHaystack = _normalizeToken(haystacks.join(' '));

    final findings = <MedicineRiskFinding>[];
    for (final allergyItem in activeAllergies) {
      final rawLabel = allergyItem.label.trim();
      if (rawLabel.isEmpty) continue;
      final allergyToken = _normalizeToken(rawLabel);
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
          evidence: _firstNonEmpty(
            _asNonEmptyString(detail.contraindications),
            _asNonEmptyString(detail.ingredients),
            _asNonEmptyString(detail.precautions),
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
        (variant) => _normalizeToken(variant) == normalizedAllergy,
      );
      if (hasMatch) {
        result.addAll(entry.value.map(_normalizeToken));
      }
    }
    return result;
  }

  List<MedicineRiskFinding> _foodInteractionFindings(
    MedicineRiskMedicineDetail medicine,
  ) {
    final findings = <MedicineRiskFinding>[];
    for (final interaction in medicine.detail.detail.foodInteractions) {
      final normalized = _normalizeToken(interaction);
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
      evidence: _duplicateIngredientEvidence(sharedTokens),
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
      return _asNonEmptyString(item['description']);
    }
    return null;
  }
}

class MedicineRiskMedicineDetail {
  const MedicineRiskMedicineDetail({
    required this.item,
    required this.detail,
  });

  final CurrentMedicineItem item;
  final MedicineDetailDataDto detail;

  String get displayName => item.displayName.trim().isNotEmpty
      ? item.displayName
      : detail.name;

  /// Ingredient tokens extracted from the medicine detail, regardless of source.
  /// CN: parsed from the `ingredients` string (Chinese semicolon-separated).
  /// DrugBank: derived from `synonyms` (normalized lowercase).
  Set<String> get normalizedIngredientTokens {
    if (item.source == 'cn') {
      final ingredients = _asNonEmptyString(detail.detail.ingredients);
      if (ingredients == null) return const {};
      return _extractIngredientTokens(ingredients);
    }
    if (item.source == 'drugbank') {
      return drugbankSynonymTokens;
    }
    return const {};
  }

  /// Ingredient tokens from all available sources, useful for allergy matching.
  Set<String> get allSourceIngredientTokens {
    final tokens = <String>{};
    tokens.addAll(normalizedIngredientTokens);
    tokens.add(_normalizeToken(displayName));
    return tokens;
  }

  /// Normalized synonym tokens for DrugBank medicines.
  Set<String> get drugbankSynonymTokens {
    if (item.source != 'drugbank') return const {};
    final names = detail.name.trim();
    final result = <String>{if (names.isNotEmpty) _normalizeToken(names)};
    for (final synonym in detail.detail.synonyms) {
      final token = _normalizeToken(synonym);
      if (token.isNotEmpty) result.add(token);
    }
    return result;
  }

  Set<String> get drugbankInteractionTargets {
    if (item.source != 'drugbank') return const {};
    final value = detail.detail.drugInteractions;
    if (value is! List) return const {};
    return value
        .whereType<Map>()
        .map((entry) => entry['drugbankId']?.toString() ?? '')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
  }
}

String _duplicateIngredientEvidence(Set<String> sharedTokens) {
  final values = sharedTokens.toList()..sort();
  return values.join(' / ');
}

String _buildCoverageSummary({
  required int currentMedicineCount,
  required int checkedMedicineCount,
  required List<MedicineRiskCoverageIssue> coverageIssues,
  required List<MedicineRiskMedicineDetail> medicines,
}) {
  if (currentMedicineCount == 0) {
    return '';
  }
  if (coverageIssues.isEmpty) {
    return '';
  }
  final manualCount = coverageIssues
      .where((issue) => issue.reason == MedicineRiskCoverageReason.manualEntry)
      .length;
  final unavailableCount = coverageIssues.length - manualCount;

  final parts = <String>[];
  if (manualCount > 0) {
    parts.add('$manualCount 种手动录入药品无法自动检查');
  }
  if (unavailableCount > 0) {
    parts.add('$unavailableCount 种药品详情不可用');
  }
  return parts.join('；');
}

Set<String> _extractIngredientTokens(String value) {
  final normalized = value
      .replaceAll('（', '(')
      .replaceAll('）', ')')
      .replaceAll('；', ';')
      .replaceAll('，', ',')
      .replaceAll('、', ',')
      .replaceAll('+', ',')
      .replaceAll(' and ', ',')
      .replaceAll(' AND ', ',');
  final parts = normalized.split(
    RegExp(r'[;,/\n\r\+\|]'),
  );

  return parts
      .map(_cleanIngredientToken)
      .whereType<String>()
      .toSet();
}

String? _cleanIngredientToken(String raw) {
  final withoutParens = raw.replaceAll(RegExp(r'\([^)]*\)'), ' ');
  final withoutStrength = withoutParens.replaceAll(
    RegExp(r'\b\d+(\.\d+)?\s*(mg|g|ml|mcg|iu|%|片|粒|袋|支|丸)\b', caseSensitive: false),
    ' ',
  );
  final normalized = _normalizeToken(
    withoutStrength
        .replaceAll(RegExp(r'[·\.\-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim(),
  );
  if (normalized.isEmpty) return null;
  if (normalized.length <= 1) return null;
  return normalized;
}

String? _asNonEmptyString(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

String? _firstNonEmpty(String? a, String? b, String? c) {
  if (a != null && a.isNotEmpty) return a;
  if (b != null && b.isNotEmpty) return b;
  if (c != null && c.isNotEmpty) return c;
  return null;
}

String _normalizeToken(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
}
