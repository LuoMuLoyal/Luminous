import 'medicine_risk_checker_utils.dart';

/// Maps a canonical ingredient key to its known cross-language variants.
///
/// This is intentionally conservative: only well-established mappings should
/// live here. It is used for duplicate-ingredient detection and allergy
/// matching so that e.g. “acetaminophen” and “对乙酰氨基酚” are treated as the
/// same ingredient.
const Map<String, Set<String>> canonicalIngredientVariants = {
  'acetaminophen': {'acetaminophen', 'paracetamol', '对乙酰氨基酚', '扑热息痛'},
  'aspirin': {'aspirin', 'acetylsalicylicacid', '乙酰水杨酸', '阿司匹林'},
  'ibuprofen': {'ibuprofen', '布洛芬'},
  'amoxicillin': {'amoxicillin', '阿莫西林'},
  'penicillin': {'penicillin', '青霉素', '盘尼西林'},
  'cephalosporin': {'cephalosporin', '头孢', '先锋霉素'},
  'sulfa': {'sulfa', 'sulfonamide', '磺胺'},
  'metformin': {'metformin', '二甲双胍'},
  'loratadine': {'loratadine', '氯雷他定'},
  'cetirizine': {'cetirizine', '西替利嗪'},
  'diphenhydramine': {'diphenhydramine', '苯海拉明'},
  'chlorpheniramine': {'chlorpheniramine', '氯苯那敏', '扑尔敏'},
  'pseudoephedrine': {'pseudoephedrine', '伪麻黄碱'},
  'dextromethorphan': {'dextromethorphan', '右美沙芬'},
  'guaifenesin': {'guaifenesin', '愈创甘油醚'},
};

/// Maps each token to its canonical key if one exists, otherwise keeps the
/// token as-is. Useful for duplicate detection where the evidence should be a
/// single normalized name rather than every known synonym.
Set<String> canonicalIngredientKeysFor(Set<String> tokens) {
  final result = <String>{};
  for (final token in tokens) {
    var matched = false;
    for (final entry in canonicalIngredientVariants.entries) {
      if (entry.value.map(normalizeToken).contains(token)) {
        result.add(entry.key);
        matched = true;
        break;
      }
    }
    if (!matched) {
      result.add(token);
    }
  }
  return result;
}

/// Expands a set of normalized ingredient tokens into the union of all known
/// variants that share a canonical group with at least one input token.
Set<String> expandCanonicalIngredientTokens(Set<String> tokens) {
  final result = <String>{...tokens};
  for (final variants in canonicalIngredientVariants.values) {
    final normalizedVariants = variants.map(normalizeToken).toSet();
    if (normalizedVariants.intersection(tokens).isNotEmpty) {
      result.addAll(normalizedVariants);
    }
  }
  return result;
}
