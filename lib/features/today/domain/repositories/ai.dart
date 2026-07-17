import 'package:luminous/features/today/domain/entities/ai_analysis.dart';

sealed class TodayAiGenerationEvent {
  const TodayAiGenerationEvent();
}

class TodayAiGenerationSummaryEvent extends TodayAiGenerationEvent {
  const TodayAiGenerationSummaryEvent(this.summary);

  final String summary;
}

class TodayAiGenerationResultEvent extends TodayAiGenerationEvent {
  const TodayAiGenerationResultEvent(this.analysis);

  final TodayAiAnalysis analysis;
}

abstract interface class TodayAiRepository {
  Future<TodayAiAnalysis> generate({String? date});
  Stream<TodayAiGenerationEvent> generateStream({String? date});
}
