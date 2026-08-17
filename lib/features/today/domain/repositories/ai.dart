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
  /// Reads the latest persisted analysis for [date].
  Future<TodayAiAnalysis> read(DateTime date);

  /// Requests a bounded refresh for [date] and returns the current persisted
  /// analysis state (which may still be pending).
  Future<TodayAiAnalysis> refresh(DateTime date);

  /// Legacy synchronous generation (still used by the stream path).
  Future<TodayAiAnalysis> generate({String? date});

  /// Legacy stream generation (still used by the stream path).
  Stream<TodayAiGenerationEvent> generateStream({String? date});
}
