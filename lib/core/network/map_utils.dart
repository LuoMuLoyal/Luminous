/// Coerces a JSON-decoded value into a `Map<String, dynamic>`.
///
/// Handles the common case where deserialized maps come back as
/// `Map<dynamic, dynamic>` and need their keys cast to `String`.
Map<String, dynamic>? coerceToStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, dynamic val) => MapEntry(key.toString(), val));
  }
  return null;
}
