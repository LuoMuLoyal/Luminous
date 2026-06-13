import 'package:flutter/material.dart';

enum ReportAiSummaryRange {
  last7Days('last_7_days'),
  last30Days('last_30_days');

  const ReportAiSummaryRange(this.apiValue);

  final String apiValue;
}

class ReportAiSummary {
  const ReportAiSummary({
    required this.range,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.summary,
    required this.bullets,
    required this.actionLabel,
    required this.confidenceNote,
  });

  final ReportAiSummaryRange range;
  final String startDate;
  final String endDate;
  final DateTime generatedAt;
  final String summary;
  final List<ReportAiSummaryBullet> bullets;
  final String actionLabel;
  final String confidenceNote;
}

class ReportAiSummaryBullet {
  const ReportAiSummaryBullet({
    required this.kind,
    required this.text,
    required this.color,
    required this.icon,
  });

  final ReportAiSummaryBulletKind kind;
  final String text;
  final Color color;
  final IconData icon;
}

enum ReportAiSummaryBulletKind { medication, hydration, sleep, general }

enum ReportAiSummaryCardStatus { idle, loading, success, error, disabled }

class ReportAiSummaryCardState {
  const ReportAiSummaryCardState({
    required this.status,
    this.summary,
    this.errorMessage,
  });

  const ReportAiSummaryCardState.idle()
    : this(status: ReportAiSummaryCardStatus.idle);

  const ReportAiSummaryCardState.loading({
    ReportAiSummary? previousSummary,
  }) : this(
         status: ReportAiSummaryCardStatus.loading,
         summary: previousSummary,
       );

  const ReportAiSummaryCardState.success(ReportAiSummary summary)
    : this(
        status: ReportAiSummaryCardStatus.success,
        summary: summary,
      );

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
  final String? errorMessage;

  bool get isLoading => status == ReportAiSummaryCardStatus.loading;
  bool get isDisabled => status == ReportAiSummaryCardStatus.disabled;
  bool get hasSummary => summary != null;
}
