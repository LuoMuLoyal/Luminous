import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/network/envelope.dart';
import 'package:luminous/features/report/domain/entities/review.dart';
import 'package:luminous/features/report/domain/repositories/review.dart';

/// Review 端点的远程数据源。
///
/// HTTP Problem Details 由全局错误链处理；当前生成客户端仍处于旧成功
/// 响应 DTO 阶段，这里暂时解包 `data` 字段；current 端点的 data 可为 null
///（无事件时空信封）。
class ReviewRemoteDataSource {
  ReviewRemoteDataSource({required this.api});

  final lucent.ReportsApi api;

  Future<lucent.EventReviewDataDto?> fetchCurrentReview() async {
    final response = await api.reportsControllerGetCurrentReviewV1();
    return response.data?.data;
  }

  Future<lucent.EventReviewListDataDto> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int? limit,
  }) async {
    final response = await api.reportsControllerListReviewsV1(
      status: _apiStatus(status),
      cursor: cursor,
      limit: limit,
    );
    return requireData(response.data, operation: 'fetchHistory').data;
  }

  Future<lucent.EventReviewDataDto> fetchReview(String eventId) async {
    final response = await api.reportsControllerGetEventReviewV1(
      eventId: eventId,
    );
    return requireData(response.data, operation: 'fetchReview').data;
  }

  /// [ReviewEventStatus.unknown] 是契约外的防御值，不能发给后端。
  lucent.HealthEventStatus? _apiStatus(ReviewEventStatus? status) {
    return switch (status) {
      null => null,
      ReviewEventStatus.active => lucent.HealthEventStatus.active,
      ReviewEventStatus.ended => lucent.HealthEventStatus.ended,
      ReviewEventStatus.unknown => null,
    };
  }
}

/// 调用 Lucent event review read model 并映射为领域实体的实现。
class LucentReviewRepository implements ReviewRepository {
  LucentReviewRepository({required this.dataSource});

  final ReviewRemoteDataSource dataSource;

  @override
  Future<EventReview?> fetchCurrentReview() async {
    final dto = await dataSource.fetchCurrentReview();
    return dto == null ? null : _mapReview(dto);
  }

  @override
  Future<ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) async {
    final dto = await dataSource.fetchHistory(
      status: status,
      cursor: cursor,
      limit: limit,
    );
    return ReviewEventPage(
      items: dto.items.map(_mapEvent).toList(growable: false),
      total: dto.total.toInt(),
      nextCursor: dto.nextCursor,
    );
  }

  @override
  Future<EventReview> fetchReview(String eventId) async {
    final dto = await dataSource.fetchReview(eventId);
    return _mapReview(dto);
  }

  EventReview _mapReview(lucent.EventReviewDataDto dto) {
    return EventReview(
      event: _mapEvent(dto.event),
      sections: ReviewSections(
        whatHappened: _mapSection(dto.sections.whatHappened),
        keyChanges: _mapSection(dto.sections.keyChanges),
        completedActions: _mapSection(dto.sections.completedActions),
        nextStep: _mapSection(dto.sections.nextStep),
      ),
      coverage: ReviewCoverage(
        checkIns: _mapCheckInCoverage(dto.coverage.checkIns),
        dailyRecords: _mapObservedCoverage(dto.coverage.dailyRecords),
        doseLogs: _mapObservedCoverage(dto.coverage.doseLogs),
      ),
      sourceTimestamps: ReviewSourceTimestamps(
        checkIns: dto.sourceTimestamps.checkIns,
        dailyRecords: dto.sourceTimestamps.dailyRecords,
        doseLogs: dto.sourceTimestamps.doseLogs,
      ),
      availableActions: dto.availableActions
          .map(_mapAction)
          .whereType<ReviewAction>()
          .toList(growable: false),
      generatedAt: dto.generatedAt,
    );
  }

  ReviewEvent _mapEvent(lucent.EventReviewEventDto dto) {
    return ReviewEvent(
      id: dto.id,
      kind: _mapKind(dto.kind),
      title: dto.title,
      status: _mapStatus(dto.status),
      startedAt: dto.startedAt,
      endedAt: dto.endedAt,
      outcome: dto.outcome == null ? null : _mapOutcome(dto.outcome!),
      currentMedicineIds: dto.currentMedicineIds,
    );
  }

  ReviewSection _mapSection(lucent.EventReviewSectionDto dto) {
    return ReviewSection(
      state: switch (dto.state) {
        lucent.EventReviewSectionDtoStateEnum.available =>
          ReviewSectionState.available,
        lucent.EventReviewSectionDtoStateEnum.unknown =>
          ReviewSectionState.unknown,
        lucent.EventReviewSectionDtoStateEnum.unknownDefaultOpenApi =>
          ReviewSectionState.unknown,
      },
      // 原因码按原文保留；未知码在生成 DTO 反序列化层已被折叠为
      // unknown_default_open_api 占位符，这里保留占位原文而不是折叠成 null。
      reasonCode: dto.reasonCode?.value,
      facts: dto.facts == null ? null : _mapFacts(dto.facts!),
    );
  }

  ReviewSectionFacts _mapFacts(lucent.EventReviewSectionFactsDto dto) {
    final rawArguments = dto.arguments;
    // 契约声明 arguments 为 object；防御非 map 值时保留 code 并降级为空
    // 参数表，而不是让整个 section 失败。拷贝为不可变 map，防止 mapper
    // 上游引用后续被修改。
    final arguments = rawArguments is Map<String, dynamic>
        ? Map<String, dynamic>.unmodifiable(rawArguments)
        : <String, dynamic>{};
    return ReviewSectionFacts(code: dto.code, arguments: arguments);
  }

  ReviewCheckInCoverage _mapCheckInCoverage(
    lucent.EventReviewCheckInCoverageDto dto,
  ) {
    return ReviewCheckInCoverage(
      state: _mapCoverageState(dto.state.value),
      coverage: _mapCoverageLevel(dto.coverage.value),
      sources: dto.sources
          .map((source) => _mapSource(source.value))
          .toList(growable: false),
      observedCount: dto.observedCount.toInt(),
      expectedCount: dto.expectedCount?.toInt(),
      firstCheckInDate: dto.firstCheckInDate,
      lastCheckInDate: dto.lastCheckInDate,
      todayCheckIn: dto.todayCheckIn == null
          ? null
          : _mapTodayCheckIn(dto.todayCheckIn!),
      windowStart: dto.windowStart,
      windowEnd: dto.windowEnd,
    );
  }

  ReviewObservedCoverage _mapObservedCoverage(
    lucent.EventReviewObservedSourceDto dto,
  ) {
    return ReviewObservedCoverage(
      state: _mapCoverageState(dto.state.value),
      coverage: _mapCoverageLevel(dto.coverage.value),
      sources: dto.sources
          .map((source) => _mapSource(source.value))
          .toList(growable: false),
      observedCount: dto.observedCount.toInt(),
      expectedCount: dto.expectedCount?.toInt(),
      windowStart: dto.windowStart,
      windowEnd: dto.windowEnd,
    );
  }

  ReviewTodayCheckIn _mapTodayCheckIn(lucent.EventReviewTodayCheckInDto dto) {
    return ReviewTodayCheckIn(
      date: dto.date,
      outcome: _mapOutcome(dto.outcome),
      updatedAt: dto.updatedAt,
    );
  }

  ReviewEventKind _mapKind(lucent.HealthEventKind kind) {
    return switch (kind) {
      lucent.HealthEventKind.symptom => ReviewEventKind.symptom,
      lucent.HealthEventKind.other => ReviewEventKind.other,
      lucent.HealthEventKind.unknownDefaultOpenApi => ReviewEventKind.unknown,
    };
  }

  ReviewEventStatus _mapStatus(lucent.HealthEventStatus status) {
    return switch (status) {
      lucent.HealthEventStatus.active => ReviewEventStatus.active,
      lucent.HealthEventStatus.ended => ReviewEventStatus.ended,
      lucent.HealthEventStatus.unknownDefaultOpenApi =>
        ReviewEventStatus.unknown,
    };
  }

  ReviewEventOutcome _mapOutcome(lucent.HealthEventOutcome outcome) {
    return switch (outcome) {
      lucent.HealthEventOutcome.improved => ReviewEventOutcome.improved,
      lucent.HealthEventOutcome.unchanged => ReviewEventOutcome.unchanged,
      lucent.HealthEventOutcome.worsened => ReviewEventOutcome.worsened,
      lucent.HealthEventOutcome.unknownDefaultOpenApi =>
        ReviewEventOutcome.unknown,
    };
  }

  ReviewCoverageState _mapCoverageState(String value) {
    return switch (value) {
      'observed' => ReviewCoverageState.observed,
      _ => ReviewCoverageState.unknown,
    };
  }

  ReviewCoverageLevel _mapCoverageLevel(String value) {
    return switch (value) {
      'sufficient' => ReviewCoverageLevel.sufficient,
      'partial' => ReviewCoverageLevel.partial,
      'none' => ReviewCoverageLevel.none,
      _ => ReviewCoverageLevel.unknown,
    };
  }

  /// 来源列表长度与契约保持一致：无法识别的来源映射为
  /// [ReviewObservedSource.unknown]，而不是被丢弃。
  ReviewObservedSource _mapSource(String value) {
    return switch (value) {
      'manual' => ReviewObservedSource.manual,
      'health_platform' => ReviewObservedSource.healthPlatform,
      'reminder_plan' => ReviewObservedSource.reminderPlan,
      'derived' => ReviewObservedSource.derived,
      _ => ReviewObservedSource.unknown,
    };
  }

  /// 契约外动作被跳过（客户端无法渲染），已知动作保持顺序。
  ReviewAction? _mapAction(
    lucent.EventReviewDataDtoAvailableActionsEnum action,
  ) {
    return switch (action) {
      lucent.EventReviewDataDtoAvailableActionsEnum.checkIn =>
        ReviewAction.checkIn,
      lucent.EventReviewDataDtoAvailableActionsEnum.endEvent =>
        ReviewAction.endEvent,
      lucent.EventReviewDataDtoAvailableActionsEnum.clinicSummary =>
        ReviewAction.clinicSummary,
      lucent.EventReviewDataDtoAvailableActionsEnum.export_ =>
        ReviewAction.export,
      lucent.EventReviewDataDtoAvailableActionsEnum.unknownDefaultOpenApi =>
        null,
    };
  }
}
