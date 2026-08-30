// Shared string utilities.

/// Trims whitespace and returns null if the value is null or empty.
String? normalizeNullableText(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return normalized;
}
