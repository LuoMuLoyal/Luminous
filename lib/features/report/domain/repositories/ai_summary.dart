import 'package:luminous/features/report/domain/entities/ai_summary.dart';

sealed class ReportAiGenerationEvent {
  const ReportAiGenerationEvent();
}

class ReportAiGenerationSummaryEvent extends ReportAiGenerationEvent {
  const ReportAiGenerationSummaryEvent(this.summary);

  final String summary;
}

class ReportAiGenerationResultEvent extends ReportAiGenerationEvent {
  const ReportAiGenerationResultEvent(this.summary);

  final ReportAiSummary summary;
}

abstract interface class ReportAiSummaryRepository {
  Future<ReportAiSummary> generate(
    ReportAiSummaryRange range, {
    String? startDate,
    String? endDate,
  });
  Stream<ReportAiGenerationEvent> generateStream(
    ReportAiSummaryRange range, {
    String? startDate,
    String? endDate,
  });
}
