import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';

const _anaphylaxisKeywords = {
  'anaphylaxis',
  'anaphylactic',
  '过敏性休克',
  '严重过敏',
  '重度过敏',
  '休克',
};

/// Infer the effective severity of an allergy.
///
/// When the severity field is missing/unknown but the reaction text describes
/// anaphylaxis or a severe allergic response, treat it as severe for safety.
String inferredAllergySeverity(AllergyItem allergy) {
  final reaction = (allergy.reaction ?? '').toLowerCase();
  if (_anaphylaxisKeywords.any((kw) => reaction.contains(kw))) {
    return 'severe';
  }
  final severity = allergy.severity?.toLowerCase().trim();
  if (severity == null || severity.isEmpty || severity == 'unknown') {
    return 'unknown';
  }
  return severity;
}

bool isSevereAllergy(AllergyItem allergy) =>
    inferredAllergySeverity(allergy) == 'severe';
