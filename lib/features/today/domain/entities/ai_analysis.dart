enum TodayAiAnalysisMaterializationStatus {
  empty,
  pending,
  ready,
  stale,
  failed,
}

class TodayAiAnalysis {
  const TodayAiAnalysis({
    required this.date,
    required this.generatedAt,
    required this.summary,
    required this.bullets,
    required this.actionLabel,
    required this.confidenceNote,
    this.materializationStatus = TodayAiAnalysisMaterializationStatus.ready,
    this.aiGenerated = true,
    this.sourceVersion = 0,
    this.computedVersion = 0,
  });

  final String date;
  final DateTime generatedAt;
  final String summary;
  final List<TodayAiAnalysisBullet> bullets;
  final String actionLabel;
  final String confidenceNote;
  final TodayAiAnalysisMaterializationStatus materializationStatus;
  final bool aiGenerated;

  /// Backend source version used to detect whether the underlying records
  /// changed between reads.
  final int sourceVersion;

  /// Backend computed version for the materialized analysis.
  final int computedVersion;
}

class TodayAiAnalysisBullet {
  const TodayAiAnalysisBullet({required this.kind, required this.text});

  final TodayAiAnalysisBulletKind kind;
  final String text;
}

enum TodayAiAnalysisBulletKind { medication, hydration, sleep, general }

enum TodayAiAnalysisCardStatus { idle, loading, success, error, disabled }

class TodayAiAnalysisCardState {
  const TodayAiAnalysisCardState({
    required this.status,
    this.analysis,
    this.materializationStatus,
    this.computedAt,
    this.sourceVersion = 0,
    this.computedVersion = 0,
    this.streamingSummary,
    this.errorMessage,
  });

  const TodayAiAnalysisCardState.idle()
    : this(status: TodayAiAnalysisCardStatus.idle);

  const TodayAiAnalysisCardState.loading({
    TodayAiAnalysis? previousAnalysis,
    String? streamingSummary,
  }) : this(
         status: TodayAiAnalysisCardStatus.loading,
         analysis: previousAnalysis,
         streamingSummary: streamingSummary,
       );

  const TodayAiAnalysisCardState.success(
    TodayAiAnalysis? analysis, {
    TodayAiAnalysisMaterializationStatus? materializationStatus,
    DateTime? computedAt,
    int sourceVersion = 0,
    int computedVersion = 0,
  }) : this(
         status: TodayAiAnalysisCardStatus.success,
         analysis: analysis,
         materializationStatus: materializationStatus,
         computedAt: computedAt,
         sourceVersion: sourceVersion,
         computedVersion: computedVersion,
       );

  const TodayAiAnalysisCardState.error({
    required String message,
    TodayAiAnalysis? previousAnalysis,
  }) : this(
         status: TodayAiAnalysisCardStatus.error,
         analysis: previousAnalysis,
         errorMessage: message,
       );

  const TodayAiAnalysisCardState.disabled()
    : this(status: TodayAiAnalysisCardStatus.disabled);

  final TodayAiAnalysisCardStatus status;
  final TodayAiAnalysis? analysis;
  final TodayAiAnalysisMaterializationStatus? materializationStatus;
  final DateTime? computedAt;
  final int sourceVersion;
  final int computedVersion;
  final String? streamingSummary;
  final String? errorMessage;

  bool get isLoading => status == TodayAiAnalysisCardStatus.loading;
  bool get isDisabled => status == TodayAiAnalysisCardStatus.disabled;
  bool get hasAnalysis => analysis != null;
}
