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
    final normalizedAllergies = snapshot.allergies
        .where((item) => item.isActive)
        .map((item) => _normalizeToken(item.label))
        .where((item) => item.isNotEmpty)
        .toSet();
    final findings = <MedicineRiskFinding>[];

    for (final medicine in medicines) {
      findings.addAll(_specialGroupFindings(snapshot, medicine));
      findings.addAll(_allergyFindings(normalizedAllergies, medicine));
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

    return MedicineRiskCheckResult(
      currentMedicineCount: currentMedicines.length,
      checkedMedicineCount: medicines.length,
      findings: findings,
      coverageIssues: currentMedicines
          .where((item) => !medicines.any((detail) => detail.item.id == item.id))
          .map(_coverageIssueFor)
          .toList(growable: false),
    );
  }

  List<MedicineRiskFinding> _specialGroupFindings(
    HealthContextSnapshot snapshot,
    MedicineRiskMedicineDetail medicine,
  ) {
    final findings = <MedicineRiskFinding>[];
    final detail = medicine.detail.detail;
    final pregnancyText = _asNonEmptyString(detail.pregnancyLactation);
    if (pregnancyText != null) {
      final pregnancyState = snapshot.profile.pregnancyState;
      if (pregnancyState == 'pregnant' ||
          pregnancyState == 'trying' ||
          pregnancyState == 'postpartum') {
        findings.add(
          MedicineRiskFinding(
            type: MedicineRiskFindingType.specialGroup,
            severity: MedicineRiskSeverity.high,
            context: MedicineRiskFindingContext.pregnancy,
            primaryMedicineName: medicine.displayName,
            evidence: pregnancyText,
          ),
        );
      }

      final lactationState = snapshot.profile.lactationState;
      if (lactationState == 'yes') {
        findings.add(
          MedicineRiskFinding(
            type: MedicineRiskFindingType.specialGroup,
            severity: MedicineRiskSeverity.high,
            context: MedicineRiskFindingContext.lactation,
            primaryMedicineName: medicine.displayName,
            evidence: pregnancyText,
          ),
        );
      }
    }

    final pediatricText = _asNonEmptyString(detail.pediatricUse);
    if (pediatricText != null) {
      findings.add(
        MedicineRiskFinding(
          type: MedicineRiskFindingType.specialGroup,
          severity: MedicineRiskSeverity.info,
          context: MedicineRiskFindingContext.pediatric,
          primaryMedicineName: medicine.displayName,
          evidence: pediatricText,
        ),
      );
    }

    final geriatricText = _asNonEmptyString(detail.geriatricUse);
    if (geriatricText != null) {
      findings.add(
        MedicineRiskFinding(
          type: MedicineRiskFindingType.specialGroup,
          severity: MedicineRiskSeverity.info,
          context: MedicineRiskFindingContext.geriatric,
          primaryMedicineName: medicine.displayName,
          evidence: geriatricText,
        ),
      );
    }

    return findings;
  }

  List<MedicineRiskFinding> _allergyFindings(
    Set<String> normalizedAllergies,
    MedicineRiskMedicineDetail medicine,
  ) {
    if (normalizedAllergies.isEmpty) return const [];

    final detail = medicine.detail.detail;
    final haystacks = <String>[
      medicine.displayName,
      _asNonEmptyString(detail.ingredients) ?? '',
      _asNonEmptyString(detail.contraindications) ?? '',
      _asNonEmptyString(detail.precautions) ?? '',
    ];
    final normalizedHaystack = _normalizeToken(haystacks.join(' '));

    final findings = <MedicineRiskFinding>[];
    for (final allergy in normalizedAllergies) {
      if (allergy.isEmpty) continue;
      if (!normalizedHaystack.contains(allergy)) continue;
      findings.add(
        MedicineRiskFinding(
          type: MedicineRiskFindingType.allergy,
          severity: MedicineRiskSeverity.high,
          context: MedicineRiskFindingContext.none,
          primaryMedicineName: medicine.displayName,
          relatedLabel: allergy,
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

  Set<String> get normalizedIngredientTokens {
    if (item.source != 'cn') return const {};
    final ingredients = _asNonEmptyString(detail.detail.ingredients);
    if (ingredients == null) return const {};
    return _extractIngredientTokens(ingredients);
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
