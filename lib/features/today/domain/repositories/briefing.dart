import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/today/domain/entities/briefing.dart';
import 'package:luminous/shared/domain/failure.dart';

sealed class TodayBriefingEvent {
  const TodayBriefingEvent();
}

class TodayBriefingSummaryEvent extends TodayBriefingEvent {
  const TodayBriefingSummaryEvent(this.summary);

  final String summary;
}

class TodayBriefingResultEvent extends TodayBriefingEvent {
  const TodayBriefingResultEvent(this.analysis);

  final TodayBriefing analysis;
}

abstract interface class TodayBriefingRepository {
  /// Reads the latest persisted analysis for [date].
  TaskEither<LucentFailure, TodayBriefing> read(DateTime date);

  /// Requests a bounded refresh for [date] and returns the current persisted
  /// analysis state (which may still be pending).
  TaskEither<LucentFailure, TodayBriefing> refresh(DateTime date);

  /// 兼容保留的同步生成入口：当前无生产消费者，仅保留 API 兼容；流结束
  /// 无结果按本地不变量映射 Left(unknown)。
  TaskEither<LucentFailure, TodayBriefing> generate({String? date});

  /// Legacy stream generation (still used by the stream path).
  ///
  /// Keeps stream event semantics — not wrapped in [TaskEither]. Stream
  /// failures (server errors, user cancellation) surface as stream errors.
  Stream<TodayBriefingEvent> generateStream({String? date});
}
