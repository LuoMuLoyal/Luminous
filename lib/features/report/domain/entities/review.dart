import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';

/// 健康事件回顾（event review）的领域读模型。
///
/// 以单个健康事件为单位的回顾快照，由 Lucent 的 event review read model
/// 聚合健康事件、check-in、关联记录与 dose slots 得到。时间戳与日历日期
/// 保持契约原文（ISO 8601 / YYYY-MM-DD），格式化属于表示层职责。
@freezed
abstract class EventReview with _$EventReview {
  const factory EventReview({
    required ReviewEvent event,
    required ReviewSections sections,
    required ReviewCoverage coverage,
    required ReviewSourceTimestamps sourceTimestamps,
    required List<ReviewAction> availableActions,
    required String generatedAt,
  }) = _EventReview;
}

/// 回顾对应的事件头部信息。
@freezed
abstract class ReviewEvent with _$ReviewEvent {
  const factory ReviewEvent({
    required String id,
    required ReviewEventKind kind,
    required String title,
    required ReviewEventStatus status,
    required String startedAt,
    String? endedAt,
    ReviewEventOutcome? outcome,
    required List<String> currentMedicineIds,
  }) = _ReviewEvent;
}

enum ReviewEventKind {
  symptom,
  other,

  /// 契约外或无法识别的 kind 值。保留原始语义而不是折叠成 [other]。
  unknown,
}

enum ReviewEventStatus {
  active,
  ended,

  /// 契约外或无法识别的 status 值。保留原始语义而不是折叠成 [ended]。
  unknown,
}

enum ReviewEventOutcome {
  improved,
  unchanged,
  worsened,

  /// 契约外或无法识别的 outcome 值。保留原始语义而不是折叠成 [unchanged]。
  unknown,
}

/// 四个固定回顾段落：发生了什么、有什么变化、完成了什么、接下来怎么办。
///
/// 每一段可独立 available/unknown，任一维度缺失不得锁住整页。
@freezed
abstract class ReviewSections with _$ReviewSections {
  const factory ReviewSections({
    required ReviewSection whatHappened,
    required ReviewSection keyChanges,
    required ReviewSection completedActions,
    required ReviewSection nextStep,
  }) = _ReviewSections;
}

@freezed
abstract class ReviewSection with _$ReviewSection {
  const factory ReviewSection({
    required ReviewSectionState state,

    /// state 为 unknown 时后端给出的固定原因码，按原文保留。
    ///
    /// 已知取值见 [ReviewSectionReasonCodes]；契约新增原因码时也原样透传，
    /// 不会被折叠成 null 或空语义。
    String? reasonCode,

    /// state 为 available 时的结构化事实。
    ReviewSectionFacts? facts,
  }) = _ReviewSection;
}

enum ReviewSectionState { available, unknown }

/// [ReviewSection.reasonCode] 的已知契约取值。
abstract final class ReviewSectionReasonCodes {
  ReviewSectionReasonCodes._();

  /// 窗口内没有任何观察。
  static const noObservations = 'no_observations';

  /// 没有已确认的剂量或 check-in。
  static const noCompletedActions = 'no_completed_actions';

  /// 有观察但尚不足以计算趋势。
  static const insufficientCoverage = 'insufficient_coverage';
}

/// 结构化事实：由客户端本地化的 fact code 与参数。
@freezed
abstract class ReviewSectionFacts with _$ReviewSectionFacts {
  const factory ReviewSectionFacts({
    required String code,
    required Map<String, dynamic> arguments,
  }) = _ReviewSectionFacts;
}

/// 三个数据源的覆盖率汇总。
@freezed
abstract class ReviewCoverage with _$ReviewCoverage {
  const factory ReviewCoverage({
    required ReviewCheckInCoverage checkIns,
    required ReviewObservedCoverage dailyRecords,
    required ReviewObservedCoverage doseLogs,
  }) = _ReviewCoverage;
}

@freezed
abstract class ReviewCheckInCoverage with _$ReviewCheckInCoverage {
  const factory ReviewCheckInCoverage({
    required ReviewCoverageState state,
    required ReviewCoverageLevel coverage,
    required List<ReviewObservedSource> sources,
    required int observedCount,
    int? expectedCount,
    String? firstCheckInDate,
    String? lastCheckInDate,
    ReviewTodayCheckIn? todayCheckIn,
    required String windowStart,
    required String windowEnd,
  }) = _ReviewCheckInCoverage;
}

/// 单一数据源（每日记录 / 剂量日志）的窗口内覆盖率。
@freezed
abstract class ReviewObservedCoverage with _$ReviewObservedCoverage {
  const factory ReviewObservedCoverage({
    required ReviewCoverageState state,
    required ReviewCoverageLevel coverage,
    required List<ReviewObservedSource> sources,
    required int observedCount,
    int? expectedCount,
    required String windowStart,
    required String windowEnd,
  }) = _ReviewObservedCoverage;
}

enum ReviewCoverageState { observed, unknown }

enum ReviewCoverageLevel {
  sufficient,
  partial,
  none,

  /// 契约外或无法识别的 coverage 值。保留原始语义而不是折叠成 [none]。
  unknown,
}

/// 数据来源。契约外的来源值映射为 [unknown]，列表长度与契约保持一致。
enum ReviewObservedSource {
  manual,
  healthPlatform,
  reminderPlan,
  derived,
  unknown,
}

/// 今天的 check-in 摘要（仅 active 事件有意义）。
@freezed
abstract class ReviewTodayCheckIn with _$ReviewTodayCheckIn {
  const factory ReviewTodayCheckIn({
    required String date,
    required ReviewEventOutcome outcome,
    required String updatedAt,
  }) = _ReviewTodayCheckIn;
}

/// 各数据源最近一次写入时间，无写入时为 null。
@freezed
abstract class ReviewSourceTimestamps with _$ReviewSourceTimestamps {
  const factory ReviewSourceTimestamps({
    String? checkIns,
    String? dailyRecords,
    String? doseLogs,
  }) = _ReviewSourceTimestamps;
}

/// 回顾页可提供的用户动作。
enum ReviewAction { checkIn, endEvent, clinicSummary, export }

/// 一页事件回顾历史（列表接口返回的是事件头部，不含完整回顾）。
@freezed
abstract class ReviewEventPage with _$ReviewEventPage {
  const factory ReviewEventPage({
    required List<ReviewEvent> items,
    required int total,
    String? nextCursor,
  }) = _ReviewEventPage;
}
