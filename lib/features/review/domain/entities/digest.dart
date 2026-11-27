enum ReviewDigestRange {
  last7Days('last_7_days'),
  last30Days('last_30_days'),
  custom('custom');

  const ReviewDigestRange(this.apiValue);

  final String apiValue;
}

enum ReviewDigestPatternKind { medication, hydration, sleep }

class ReviewDigestCoverageDimension {
  const ReviewDigestCoverageDimension({
    required this.trackedDays,
    required this.totalDays,
  });

  final int trackedDays;
  final int totalDays;
}

class ReviewDigestCoverage {
  const ReviewDigestCoverage({
    required this.medication,
    required this.water,
    required this.sleep,
  });

  final ReviewDigestCoverageDimension medication;
  final ReviewDigestCoverageDimension water;
  final ReviewDigestCoverageDimension sleep;
}

class ReviewDigestObservedPattern {
  const ReviewDigestObservedPattern({
    required this.kind,
    required this.text,
    required this.source,
  });

  final ReviewDigestPatternKind kind;
  final String text;
  final String source;
}

class ReviewDigestLowRiskAction {
  const ReviewDigestLowRiskAction({required this.label, required this.text});

  final String label;
  final String text;
}

class ReviewDigest {
  const ReviewDigest({
    required this.range,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.summary,
    required this.coverage,
    required this.observedPattern,
    required this.lowRiskAction,
    required this.disclaimer,
  });

  final ReviewDigestRange range;
  final String startDate;
  final String endDate;
  final DateTime generatedAt;
  final String summary;
  final ReviewDigestCoverage coverage;
  final ReviewDigestObservedPattern? observedPattern;
  final ReviewDigestLowRiskAction? lowRiskAction;
  final String disclaimer;
}

enum ReviewDigestCardStatus { idle, loading, success, error, disabled }

class ReviewDigestCardState {
  const ReviewDigestCardState({
    required this.status,
    this.summary,
    this.streamingSummary,
    this.error,
  });

  const ReviewDigestCardState.idle()
    : this(status: ReviewDigestCardStatus.idle);

  const ReviewDigestCardState.loading({
    ReviewDigest? previousSummary,
    String? streamingSummary,
  }) : this(
         status: ReviewDigestCardStatus.loading,
         summary: previousSummary,
         streamingSummary: streamingSummary,
       );

  const ReviewDigestCardState.success(ReviewDigest summary)
    : this(status: ReviewDigestCardStatus.success, summary: summary);

  const ReviewDigestCardState.error({
    required Object error,
    ReviewDigest? previousSummary,
  }) : this(
         status: ReviewDigestCardStatus.error,
         summary: previousSummary,
         error: error,
       );

  const ReviewDigestCardState.disabled()
    : this(status: ReviewDigestCardStatus.disabled);

  final ReviewDigestCardStatus status;
  final ReviewDigest? summary;
  final String? streamingSummary;

  /// The failure behind the last failed generation, kept as the object so the
  /// card resolves copy through the error seam at the render site.
  final Object? error;

  bool get isLoading => status == ReviewDigestCardStatus.loading;
  bool get isDisabled => status == ReviewDigestCardStatus.disabled;
  bool get hasSummary => summary != null;
}
