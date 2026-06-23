/// Shared utility functions for medicine risk checking.
String normalizeToken(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
}

String? asNonEmptyString(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

String? firstNonEmpty(String? a, String? b, String? c) {
  if (a != null && a.isNotEmpty) return a;
  if (b != null && b.isNotEmpty) return b;
  if (c != null && c.isNotEmpty) return c;
  return null;
}

Set<String> extractIngredientTokens(String value) {
  final normalized = value
      .replaceAll('（', '(')
      .replaceAll('）', ')')
      .replaceAll('；', ';')
      .replaceAll('，', ',')
      .replaceAll('、', ',')
      .replaceAll('+', ',')
      .replaceAll(' and ', ',')
      .replaceAll(' AND ', ',');
  final parts = normalized.split(RegExp(r'[;,/\n\r\+\|]'));
  return parts.map(cleanIngredientToken).whereType<String>().toSet();
}

String? cleanIngredientToken(String raw) {
  final withoutParens = raw.replaceAll(RegExp(r'\([^)]*\)'), ' ');
  final withoutStrength = withoutParens.replaceAll(
    RegExp(
      r'\b\d+(\.\d+)?\s*(mg|g|ml|mcg|iu|%|片|粒|袋|支|丸)\b',
      caseSensitive: false,
    ),
    ' ',
  );
  final n = normalizeToken(
    withoutStrength
        .replaceAll(RegExp(r'[·\.\-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim(),
  );
  if (n.isEmpty) return null;
  if (n.length <= 1) return null;
  return n;
}

String duplicateIngredientEvidence(Set<String> sharedTokens) {
  final values = sharedTokens.toList()..sort();
  return values.join(' / ');
}
