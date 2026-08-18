enum ReportAiSummaryRange {
  last7Days('last_7_days'),
  last30Days('last_30_days'),
  custom('custom');

  const ReportAiSummaryRange(this.apiValue);

  final String apiValue;
}

enum ReportAiSummaryPatternKind { medication, hydration, sleep }

class ReportAiSummaryCoverageDimension {
  const ReportAiSummaryCoverageDimension({
    required this.trackedDays,
    required this.totalDays,
  });

  final int trackedDays;
  final int totalDays;
}

class ReportAiSummaryCoverage {
  const ReportAiSummaryCoverage({
    required this.medication,
    required this.water,
    required this.sleep,
  });

  final ReportAiSummaryCoverageDimension medication;
  final ReportAiSummaryCoverageDimension water;
  final ReportAiSummaryCoverageDimension sleep;
}

class ReportAiSummaryObservedPattern {
  const ReportAiSummaryObservedPattern({
    required this.kind,
    required this.text,
    required this.source,
  });

  final ReportAiSummaryPatternKind kind;
  final String text;
  final String source;
}

class ReportAiSummaryLowRiskAction {
  const ReportAiSummaryLowRiskAction({required this.label, required this.text});

  final String label;
  final String text;
}

class ReportAiSummary {
  const ReportAiSummary({
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

  final ReportAiSummaryRange range;
  final String startDate;
  final String endDate;
  final DateTime generatedAt;
  final String summary;
  final ReportAiSummaryCoverage coverage;
  final ReportAiSummaryObservedPattern? observedPattern;
  final ReportAiSummaryLowRiskAction? lowRiskAction;
  final String disclaimer;
}

enum ReportAiSummaryCardStatus { idle, loading, success, error, disabled }

class ReportAiSummaryCardState {
  const ReportAiSummaryCardState({
    required this.status,
    this.summary,
    this.streamingSummary,
    this.errorMessage,
  });

  const ReportAiSummaryCardState.idle()
    : this(status: ReportAiSummaryCardStatus.idle);

  const ReportAiSummaryCardState.loading({
    ReportAiSummary? previousSummary,
    String? streamingSummary,
  }) : this(
         status: ReportAiSummaryCardStatus.loading,
         summary: previousSummary,
         streamingSummary: streamingSummary,
       );

  const ReportAiSummaryCardState.success(ReportAiSummary summary)
    : this(status: ReportAiSummaryCardStatus.success, summary: summary);

  const ReportAiSummaryCardState.error({
    required String message,
    ReportAiSummary? previousSummary,
  }) : this(
         status: ReportAiSummaryCardStatus.error,
         summary: previousSummary,
         errorMessage: message,
       );

  const ReportAiSummaryCardState.disabled()
    : this(status: ReportAiSummaryCardStatus.disabled);

  final ReportAiSummaryCardStatus status;
  final ReportAiSummary? summary;
  final String? streamingSummary;
  final String? errorMessage;

  bool get isLoading => status == ReportAiSummaryCardStatus.loading;
  bool get isDisabled => status == ReportAiSummaryCardStatus.disabled;
  bool get hasSummary => summary != null;
}
