enum TodayBriefingMaterializationStatus { empty, pending, ready, stale, failed }

class TodayBriefing {
  const TodayBriefing({
    required this.date,
    required this.generatedAt,
    required this.summary,
    required this.bullets,
    required this.actionLabel,
    required this.confidenceNote,
    this.materializationStatus = TodayBriefingMaterializationStatus.ready,
    this.briefingGenerated = true,
    this.sourceVersion = 0,
    this.computedVersion = 0,
  });

  final String date;
  final DateTime generatedAt;
  final String summary;
  final List<TodayBriefingBullet> bullets;
  final String actionLabel;
  final String confidenceNote;
  final TodayBriefingMaterializationStatus materializationStatus;
  final bool briefingGenerated;

  /// Backend source version used to detect whether the underlying records
  /// changed between reads.
  final int sourceVersion;

  /// Backend computed version for the materialized analysis.
  final int computedVersion;
}

class TodayBriefingBullet {
  const TodayBriefingBullet({required this.kind, required this.text});

  final TodayBriefingBulletKind kind;
  final String text;
}

enum TodayBriefingBulletKind { medication, hydration, sleep, general }

enum TodayBriefingCardStatus { idle, loading, success, error, disabled }

class TodayBriefingCardState {
  const TodayBriefingCardState({
    required this.status,
    this.analysis,
    this.materializationStatus,
    this.computedAt,
    this.sourceVersion = 0,
    this.computedVersion = 0,
    this.streamingSummary,
    this.errorMessage,
  });

  const TodayBriefingCardState.idle()
    : this(status: TodayBriefingCardStatus.idle);

  const TodayBriefingCardState.loading({
    TodayBriefing? previousAnalysis,
    String? streamingSummary,
  }) : this(
         status: TodayBriefingCardStatus.loading,
         analysis: previousAnalysis,
         streamingSummary: streamingSummary,
       );

  const TodayBriefingCardState.success(
    TodayBriefing? analysis, {
    TodayBriefingMaterializationStatus? materializationStatus,
    DateTime? computedAt,
    int sourceVersion = 0,
    int computedVersion = 0,
  }) : this(
         status: TodayBriefingCardStatus.success,
         analysis: analysis,
         materializationStatus: materializationStatus,
         computedAt: computedAt,
         sourceVersion: sourceVersion,
         computedVersion: computedVersion,
       );

  const TodayBriefingCardState.error({
    required String message,
    TodayBriefing? previousAnalysis,
  }) : this(
         status: TodayBriefingCardStatus.error,
         analysis: previousAnalysis,
         errorMessage: message,
       );

  const TodayBriefingCardState.disabled()
    : this(status: TodayBriefingCardStatus.disabled);

  final TodayBriefingCardStatus status;
  final TodayBriefing? analysis;
  final TodayBriefingMaterializationStatus? materializationStatus;
  final DateTime? computedAt;
  final int sourceVersion;
  final int computedVersion;
  final String? streamingSummary;
  final String? errorMessage;

  bool get isLoading => status == TodayBriefingCardStatus.loading;
  bool get isDisabled => status == TodayBriefingCardStatus.disabled;
  bool get hasAnalysis => analysis != null;
}
