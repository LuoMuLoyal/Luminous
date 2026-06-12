class TodayAiAnalysis {
  const TodayAiAnalysis({
    required this.date,
    required this.generatedAt,
    required this.summary,
    required this.bullets,
    required this.actionLabel,
    required this.confidenceNote,
  });

  final String date;
  final DateTime generatedAt;
  final String summary;
  final List<TodayAiAnalysisBullet> bullets;
  final String actionLabel;
  final String confidenceNote;
}

class TodayAiAnalysisBullet {
  const TodayAiAnalysisBullet({
    required this.kind,
    required this.text,
  });

  final TodayAiAnalysisBulletKind kind;
  final String text;
}

enum TodayAiAnalysisBulletKind { medication, hydration, sleep, general }

enum TodayAiAnalysisCardStatus { idle, loading, success, error, disabled }

class TodayAiAnalysisCardState {
  const TodayAiAnalysisCardState({
    required this.status,
    this.analysis,
    this.errorMessage,
  });

  const TodayAiAnalysisCardState.idle()
    : this(status: TodayAiAnalysisCardStatus.idle);

  const TodayAiAnalysisCardState.loading({
    TodayAiAnalysis? previousAnalysis,
  }) : this(
         status: TodayAiAnalysisCardStatus.loading,
         analysis: previousAnalysis,
       );

  const TodayAiAnalysisCardState.success(TodayAiAnalysis analysis)
    : this(
        status: TodayAiAnalysisCardStatus.success,
        analysis: analysis,
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
  final String? errorMessage;

  bool get isLoading => status == TodayAiAnalysisCardStatus.loading;
  bool get isDisabled => status == TodayAiAnalysisCardStatus.disabled;
  bool get hasAnalysis => analysis != null;
}
