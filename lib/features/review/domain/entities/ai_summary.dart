enum ReviewAiSummaryRange {
  last7Days('last_7_days'),
  last30Days('last_30_days'),
  custom('custom');

  const ReviewAiSummaryRange(this.apiValue);

  final String apiValue;
}

enum ReviewAiSummaryPatternKind { medication, hydration, sleep }

class ReviewAiSummaryCoverageDimension {
  const ReviewAiSummaryCoverageDimension({
    required this.trackedDays,
    required this.totalDays,
  });

  final int trackedDays;
  final int totalDays;
}

class ReviewAiSummaryCoverage {
  const ReviewAiSummaryCoverage({
    required this.medication,
    required this.water,
    required this.sleep,
  });

  final ReviewAiSummaryCoverageDimension medication;
  final ReviewAiSummaryCoverageDimension water;
  final ReviewAiSummaryCoverageDimension sleep;
}

class ReviewAiSummaryObservedPattern {
  const ReviewAiSummaryObservedPattern({
    required this.kind,
    required this.text,
    required this.source,
  });

  final ReviewAiSummaryPatternKind kind;
  final String text;
  final String source;
}

class ReviewAiSummaryLowRiskAction {
  const ReviewAiSummaryLowRiskAction({required this.label, required this.text});

  final String label;
  final String text;
}

class ReviewAiSummary {
  const ReviewAiSummary({
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

  final ReviewAiSummaryRange range;
  final String startDate;
  final String endDate;
  final DateTime generatedAt;
  final String summary;
  final ReviewAiSummaryCoverage coverage;
  final ReviewAiSummaryObservedPattern? observedPattern;
  final ReviewAiSummaryLowRiskAction? lowRiskAction;
  final String disclaimer;
}

enum ReviewAiSummaryCardStatus { idle, loading, success, error, disabled }

class ReviewAiSummaryCardState {
  const ReviewAiSummaryCardState({
    required this.status,
    this.summary,
    this.streamingSummary,
    this.errorMessage,
  });

  const ReviewAiSummaryCardState.idle()
    : this(status: ReviewAiSummaryCardStatus.idle);

  const ReviewAiSummaryCardState.loading({
    ReviewAiSummary? previousSummary,
    String? streamingSummary,
  }) : this(
         status: ReviewAiSummaryCardStatus.loading,
         summary: previousSummary,
         streamingSummary: streamingSummary,
       );

  const ReviewAiSummaryCardState.success(ReviewAiSummary summary)
    : this(status: ReviewAiSummaryCardStatus.success, summary: summary);

  const ReviewAiSummaryCardState.error({
    required String message,
    ReviewAiSummary? previousSummary,
  }) : this(
         status: ReviewAiSummaryCardStatus.error,
         summary: previousSummary,
         errorMessage: message,
       );

  const ReviewAiSummaryCardState.disabled()
    : this(status: ReviewAiSummaryCardStatus.disabled);

  final ReviewAiSummaryCardStatus status;
  final ReviewAiSummary? summary;
  final String? streamingSummary;
  final String? errorMessage;

  bool get isLoading => status == ReviewAiSummaryCardStatus.loading;
  bool get isDisabled => status == ReviewAiSummaryCardStatus.disabled;
  bool get hasSummary => summary != null;
}
