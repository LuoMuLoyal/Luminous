import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
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
  TaskEither<LucentFailure, TodayAiAnalysis> read(DateTime date);

  /// Requests a bounded refresh for [date] and returns the current persisted
  /// analysis state (which may still be pending).
  TaskEither<LucentFailure, TodayAiAnalysis> refresh(DateTime date);

  /// 兼容保留的同步生成入口：当前无生产消费者，仅保留 API 兼容；流结束
  /// 无结果按本地不变量映射 Left(unknown)。
  TaskEither<LucentFailure, TodayAiAnalysis> generate({String? date});

  /// Legacy stream generation (still used by the stream path).
  ///
  /// Keeps stream event semantics — not wrapped in [TaskEither]. Stream
  /// failures (server errors, user cancellation) surface as stream errors.
  Stream<TodayAiGenerationEvent> generateStream({String? date});
}
