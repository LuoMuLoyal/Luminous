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

enum SseErrorStatus {
  clientError,
  serverError,
  cancelled,
  serverShutdown,
  unknown,
}

final class SseProblemDetails {
  const SseProblemDetails({required this.problem, required this.status});

  factory SseProblemDetails.fromJson(Map<String, dynamic> json) {
    final problem = ProblemDetails.fromJson(json);
    if (problem.detail == null || problem.detail!.trim().isEmpty) {
      throw const FormatException(
        'SSE Problem Details field "detail" must be a non-empty string',
      );
    }
    return SseProblemDetails(
      problem: problem,
      status: _parseStatus(json['status']),
    );
  }

  final ProblemDetails problem;
  final SseErrorStatus status;

  String get type => problem.type;
  String get title => problem.title;
  String get detail => problem.detail!;
  String get code => problem.code;
  Map<String, dynamic>? get errors => problem.errors;
  bool? get retryable => problem.retryable;
  Duration? get retryAfter => problem.retryAfter;
  String? get traceId => problem.traceId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...problem.toJson(),
      'status': _statusValue(status),
    };
  }

  static SseErrorStatus _parseStatus(Object? value) {
    return switch (value) {
      'client_error' => SseErrorStatus.clientError,
      'server_error' => SseErrorStatus.serverError,
      'cancelled' => SseErrorStatus.cancelled,
      'server_shutdown' => SseErrorStatus.serverShutdown,
      'unknown' => SseErrorStatus.unknown,
      _ => throw const FormatException(
        'SSE Problem Details field "status" has an unsupported value',
      ),
    };
  }

  static String _statusValue(SseErrorStatus status) {
    return switch (status) {
      SseErrorStatus.clientError => 'client_error',
      SseErrorStatus.serverError => 'server_error',
      SseErrorStatus.cancelled => 'cancelled',
      SseErrorStatus.serverShutdown => 'server_shutdown',
      SseErrorStatus.unknown => 'unknown',
    };
  }
}
