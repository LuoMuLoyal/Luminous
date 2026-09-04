import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart' as lucent;
import 'package:luminous/core/database/cache_constants.dart';
import 'package:luminous/core/database/daos/review.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/features/review/domain/entities/review.dart';
import 'package:luminous/features/review/domain/repositories/review.dart';

// 文件级 typedef:生成的 EventReview 读模型枚举名过长(2026-09-03 审查 #4
// 纯可读性收口,不改行为)。仅本文件内使用,不新增导出符号。
typedef _SectionStateEnum =
    lucent.EventReviewDataDtoSectionsWhatHappenedStateEnum;
typedef _TodayCheckInOutcomeEnum =
    lucent.EventReviewDataDtoCoverageCheckInsTodayCheckInOutcomeEnum;
typedef _EventKindEnum = lucent.EventReviewDataDtoEventKindEnum;
typedef _EventStatusEnum = lucent.EventReviewDataDtoEventStatusEnum;
typedef _EventOutcomeEnum = lucent.EventReviewDataDtoEventOutcomeEnum;
typedef _AvailableActionEnum = lucent.EventReviewDataDtoAvailableActionsEnum;

/// Review 端点的远程数据源。
///
/// HTTP Problem Details 由全局错误链处理；当前生成客户端仍处于旧成功
/// 响应 DTO 阶段，这里暂时解包 `data` 字段；current 端点的 data 可为 null
///（无事件时空信封）。空成功响应体按 settings/notification `_requireData`
/// 先例抛 `LucentFailure.network(emptyResponse)`。
class ReviewRemoteDataSource {
  ReviewRemoteDataSource({required this.api});

  final lucent.ReportsApi api;

  Future<lucent.EventReviewDataDto?> fetchCurrentReview() async {
    final response = await api.reportsControllerGetCurrentReviewV1();
    return response.data;
  }

  Future<lucent.EventReviewListResponseDto> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int? limit,
  }) async {
    final response = await api.reportsControllerListReviewsV1(
      status: _apiStatus(status),
      cursor: cursor,
      limit: limit,
    );
    return _requireData(response.data, operation: 'fetchHistory');
  }

  Future<lucent.EventReviewDataDto> fetchReview(String eventId) async {
    final response = await api.reportsControllerGetEventReviewV1(
      eventId: eventId,
    );
    final dto = _requireData(response.data, operation: 'fetchReview');
    return lucent.EventReviewDataDto.fromJson(dto.toJson());
  }

  /// Extracts a non-null generated-client payload, throwing
  /// [LucentFailure.network] (emptyResponse) when the success body is absent
  /// (settings / notification `_requireData` precedent).
  T _requireData<T>(T? data, {String? operation}) {
    if (data == null) {
      final context = operation != null ? ' ($operation)' : '';
      throw LucentFailure.network(
        message: 'Empty response body$context',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return data;
  }

  /// [ReviewEventStatus.unknown] 是契约外的防御值，不能发给后端。返回
  /// 后端查询参数所需的 wire 字符串（查询参数现为 String，非枚举）。
  String? _apiStatus(ReviewEventStatus? status) {
    return switch (status) {
      null => null,
      ReviewEventStatus.active => _EventStatusEnum.active.value,
      ReviewEventStatus.ended => _EventStatusEnum.ended.value,
      ReviewEventStatus.unknown => null,
    };
  }
}

/// 调用 Lucent event review read model 并映射为领域实体的实现。
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a successful response is a Right. "无事件"
///（`fetchCurrentReview` 空信封）保持 `Right(null)`；服务端业务失败（如
/// detail 事件不存在 404 Problem Details）为 Left 保留 code/status，不本地
/// 猜 status。空成功响应体（datasource `_requireData`）为
/// `Left(network/emptyResponse)`；非 `problem+json` / 畸形错误体的
/// `FormatException` 从 `.run()` 直接传播。
class LucentReviewRepository implements ReviewRepository {
  LucentReviewRepository({required this.dataSource, required this.dao});

  final ReviewRemoteDataSource dataSource;
  final ReviewDao dao;

  DateTime? _lastCurrentRefresh;
  DateTime? _lastHistoryRefresh;

  @override
  TaskEither<LucentFailure, EventReview?> fetchCurrentReview() {
    return TaskEither.tryCatch(() async {
      // 1. Check cache
      final cachedJson = await dao.fetchCurrent();
      if (cachedJson != null) {
        final dto = lucent.EventReviewDataDto.fromJson(
          jsonDecode(cachedJson) as Map<String, dynamic>,
        );
        final review = _mapReview(dto);
        // Background refresh (throttled) — best-effort.
        _refreshCurrentInBackground();
        return review;
      }

      // 2. Cache empty → fetch from network.
      final dto = await dataSource.fetchCurrentReview();
      if (dto != null) {
        await dao.replaceCurrent(jsonEncode(dto.toJson()));
        return _mapReview(dto);
      }
      return null;
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, ReviewEventPage> fetchHistory({
    ReviewEventStatus? status,
    String? cursor,
    int limit = 20,
  }) {
    return TaskEither.tryCatch(() async {
      final cacheKey = ReviewDao.historyKey(
        status: status?.name,
        cursor: cursor,
      );

      // 1. Check cache
      final cachedJson = await dao.fetchHistory(cacheKey);
      if (cachedJson != null) {
        try {
          final dto = lucent.EventReviewListResponseDto.fromJson(
            jsonDecode(cachedJson) as Map<String, dynamic>,
          );
          final page = ReviewEventPage(
            items: dto.items.map(_mapEvent).toList(growable: false),
            total: dto.total.toInt(),
            nextCursor: dto.nextCursor,
          );
          // Background refresh (throttled) — best-effort.
          _refreshHistoryInBackground(
            status: status,
            cursor: cursor,
            limit: limit,
            cacheKey: cacheKey,
          );
          return page;
        } on FormatException catch (e, st) {
          appTalker.warning(
            'Review history cache parse failed, falling back to network',
            e,
            st,
          );
          // Fall through to network path below.
        } catch (e, st) {
          // Schema evolution (missing fields, type mismatches) throws
          // TypeError/RangeError — degrade to network instead of surfacing
          // an "unknown error" to the user.
          appTalker.warning(
            'Review history cache parse failed, falling back to network',
            e,
            st,
          );
          // Fall through to network path below.
        }
      }

      // 2. Cache empty → fetch from network.
      final dto = await dataSource.fetchHistory(
        status: status,
        cursor: cursor,
        limit: limit,
      );
      await dao.replaceHistory(cacheKey, jsonEncode(dto.toJson()));
      return ReviewEventPage(
        items: dto.items.map(_mapEvent).toList(growable: false),
        total: dto.total.toInt(),
        nextCursor: dto.nextCursor,
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, EventReview> fetchReview(String eventId) {
    return TaskEither.tryCatch(() async {
      final dto = await dataSource.fetchReview(eventId);
      return _mapReview(dto);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  void _refreshCurrentInBackground() {
    final now = DateTime.now();
    if (_lastCurrentRefresh != null &&
        now.difference(_lastCurrentRefresh!) < backgroundRefreshThrottle) {
      return;
    }
    _lastCurrentRefresh = now;

    unawaited(
      Future(() async {
        try {
          final dto = await dataSource.fetchCurrentReview();
          if (dto != null) {
            await dao.replaceCurrent(jsonEncode(dto.toJson()));
          }
        } catch (e) {
          appTalker.warning('Review current background refresh failed: $e');
        }
      }),
    );
  }

  void _refreshHistoryInBackground({
    required ReviewEventStatus? status,
    required String? cursor,
    required int limit,
    required String cacheKey,
  }) {
    final now = DateTime.now();
    if (_lastHistoryRefresh != null &&
        now.difference(_lastHistoryRefresh!) < backgroundRefreshThrottle) {
      return;
    }
    _lastHistoryRefresh = now;

    unawaited(
      Future(() async {
        try {
          final dto = await dataSource.fetchHistory(
            status: status,
            cursor: cursor,
            limit: limit,
          );
          await dao.replaceHistory(cacheKey, jsonEncode(dto.toJson()));
        } catch (e) {
          appTalker.warning('Review history background refresh failed: $e');
        }
      }),
    );
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

  ReviewEvent _mapEvent(lucent.EventReviewDataDtoEvent dto) {
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

  ReviewSection _mapSection(lucent.EventReviewDataDtoSectionsWhatHappened dto) {
    return ReviewSection(
      state: switch (dto.state) {
        _SectionStateEnum.available => ReviewSectionState.available,
        _SectionStateEnum.unknown => ReviewSectionState.unknown,
        _SectionStateEnum.unknownDefaultOpenApi => ReviewSectionState.unknown,
      },
      // 原因码按原文保留；未知码在生成 DTO 反序列化层已被折叠为
      // unknown_default_open_api 占位符，这里保留占位原文而不是折叠成 null。
      reasonCode: dto.reasonCode?.value,
      facts: dto.facts == null ? null : _mapFacts(dto.facts!),
    );
  }

  ReviewSectionFacts _mapFacts(
    lucent.EventReviewDataDtoSectionsWhatHappenedFacts dto,
  ) {
    // 契约声明 arguments 为 object；生成 DTO 反序列化为 Map<String, Object>。
    // 拷贝一份 Map<String, dynamic>，防止上游引用后续被修改。
    return ReviewSectionFacts(
      code: dto.code,
      arguments: Map<String, dynamic>.from(dto.arguments),
    );
  }

  ReviewCheckInCoverage _mapCheckInCoverage(
    lucent.EventReviewDataDtoCoverageCheckIns dto,
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
    lucent.EventReviewDataDtoCoverageDailyRecords dto,
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

  ReviewTodayCheckIn _mapTodayCheckIn(
    lucent.EventReviewDataDtoCoverageCheckInsTodayCheckIn dto,
  ) {
    return ReviewTodayCheckIn(
      date: dto.date,
      outcome: switch (dto.outcome) {
        _TodayCheckInOutcomeEnum.improved => ReviewEventOutcome.improved,
        _TodayCheckInOutcomeEnum.unchanged => ReviewEventOutcome.unchanged,
        _TodayCheckInOutcomeEnum.worsened => ReviewEventOutcome.worsened,
        _TodayCheckInOutcomeEnum.unknownDefaultOpenApi =>
          ReviewEventOutcome.unknown,
      },
      updatedAt: dto.updatedAt,
    );
  }

  ReviewEventKind _mapKind(_EventKindEnum kind) {
    return switch (kind) {
      _EventKindEnum.symptom => ReviewEventKind.symptom,
      _EventKindEnum.other => ReviewEventKind.other,
      _EventKindEnum.unknownDefaultOpenApi => ReviewEventKind.unknown,
    };
  }

  ReviewEventStatus _mapStatus(_EventStatusEnum status) {
    return switch (status) {
      _EventStatusEnum.active => ReviewEventStatus.active,
      _EventStatusEnum.ended => ReviewEventStatus.ended,
      _EventStatusEnum.unknownDefaultOpenApi => ReviewEventStatus.unknown,
    };
  }

  ReviewEventOutcome _mapOutcome(_EventOutcomeEnum outcome) {
    return switch (outcome) {
      _EventOutcomeEnum.improved => ReviewEventOutcome.improved,
      _EventOutcomeEnum.unchanged => ReviewEventOutcome.unchanged,
      _EventOutcomeEnum.worsened => ReviewEventOutcome.worsened,
      _EventOutcomeEnum.unknownDefaultOpenApi => ReviewEventOutcome.unknown,
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
  ReviewAction? _mapAction(_AvailableActionEnum action) {
    return switch (action) {
      _AvailableActionEnum.checkIn => ReviewAction.checkIn,
      _AvailableActionEnum.endEvent => ReviewAction.endEvent,
      _AvailableActionEnum.clinicSummary => ReviewAction.clinicSummary,
      _AvailableActionEnum.export_ => ReviewAction.export,
      _AvailableActionEnum.unknownDefaultOpenApi => null,
    };
  }
}
