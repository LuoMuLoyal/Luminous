// Shared type conversion utilities for safely casting dynamic JSON values.

/// Casts [value] to a [Map<String, dynamic>] if possible.
///
/// If [value] is already a [Map<String, dynamic>] it is returned as-is. If it
/// is a generic [Map] with non-string keys, keys are converted to strings.
Map<String, dynamic>? asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return null;
}

/// Casts [value] to a list, returning an empty list if it is not a list.
List<Object?> asList(Object? value) {
  if (value is List) return value.cast<Object?>();
  return const <Object?>[];
}

/// Converts [value] to a non-empty trimmed string, returning null otherwise.
String? asString(Object? value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

/// Casts [value] to a [num] if possible.
num? asNum(Object? value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '');
}
