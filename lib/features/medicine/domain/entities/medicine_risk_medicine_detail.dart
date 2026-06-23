import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/domain/services/medicine_risk_checker_utils.dart';

class MedicineRiskMedicineDetail {
  const MedicineRiskMedicineDetail({required this.item, required this.detail});

  final CurrentMedicineItem item;
  final MedicineDetailDataDto detail;

  String get displayName =>
      item.displayName.trim().isNotEmpty ? item.displayName : detail.name;

  Set<String> get normalizedIngredientTokens {
    if (item.source == 'cn') {
      final ingredients = asNonEmptyString(detail.detail.ingredients);
      if (ingredients == null) return const {};
      return extractIngredientTokens(ingredients);
    }
    if (item.source == 'drugbank') {
      return drugbankSynonymTokens;
    }
    return const {};
  }

  Set<String> get allSourceIngredientTokens {
    final tokens = <String>{};
    tokens.addAll(normalizedIngredientTokens);
    tokens.add(normalizeToken(displayName));
    return tokens;
  }

  Set<String> get drugbankSynonymTokens {
    if (item.source != 'drugbank') return const {};
    final names = detail.name.trim();
    final result = <String>{if (names.isNotEmpty) normalizeToken(names)};
    for (final synonym in detail.detail.synonyms) {
      final token = normalizeToken(synonym);
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
