/// RFC 9457 Problem Details plus the stable Lucent error extensions.
///
/// This parser intentionally accepts only the target error representation.
/// The retired `{code, message, data}` envelope is not interpreted here.
final class ProblemDetails {
  const ProblemDetails({
    required this.type,
    required this.title,
    required this.code,
    this.detail,
    this.errors,
    this.retryable,
    this.retryAfter,
    this.traceId,
  });

  factory ProblemDetails.fromJson(Map<String, dynamic> json) {
    return ProblemDetails(
      type: _requiredString(json, 'type'),
      title: _requiredString(json, 'title'),
      code: _requiredString(json, 'code'),
      detail: _optionalString(json, 'detail'),
      errors: _optionalErrors(json, 'errors'),
      retryable: _optionalBool(json, 'retryable'),
      retryAfter: _optionalRetryAfter(json, 'retryAfter'),
      traceId: _optionalString(json, 'traceId'),
    );
  }

  final String type;
  final String title;
  final String? detail;
  final String code;
  final Map<String, dynamic>? errors;
  final bool? retryable;
  final Duration? retryAfter;
  final String? traceId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'type': type,
      'title': title,
      if (detail != null) 'detail': detail,
      'code': code,
      if (errors != null) 'errors': errors,
      if (retryable != null) 'retryable': retryable,
      if (retryAfter != null) 'retryAfter': retryAfter!.inSeconds,
      if (traceId != null) 'traceId': traceId,
    };
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Problem Details field "$key" must be a string');
    }
    return value;
  }

  static String? _optionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Problem Details field "$key" must be a string');
    }
    return value;
  }

  static Map<String, dynamic>? _optionalErrors(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value == null) return null;
    if (value is! Map) {
      throw FormatException('Problem Details field "$key" must be an object');
    }
    if (value.keys.any((key) => key is! String)) {
      throw FormatException(
        'Problem Details field "$key" must have string keys',
      );
    }
    return Map<String, dynamic>.unmodifiable(
      value.map((key, value) => MapEntry(key as String, value)),
    );
  }

  static bool? _optionalBool(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! bool) {
      throw FormatException('Problem Details field "$key" must be a boolean');
    }
    return value;
  }

  static Duration? _optionalRetryAfter(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! num ||
        !value.isFinite ||
        value < 0 ||
        value != value.toInt()) {
      throw FormatException(
        'Problem Details field "$key" must be a non-negative integer number of seconds',
      );
    }
    return Duration(seconds: value.toInt());
  }
}
