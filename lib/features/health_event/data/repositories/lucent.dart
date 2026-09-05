import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart' as api;
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/domain/repositories/health_event.dart';

/// Lucent-backed implementation of [HealthEventRepository].
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`; a successful response is a Right. A legal
/// empty history stays a Right. An empty success response body on the list
/// endpoint is a `LucentFailure.network(emptyResponse)` (settings /
/// notification `_requireData` precedent).
///
/// 404 semantics: `fetchActive` / `fetchById` answer 404 when there is no
/// active event / no such event — a normal business state ("未配置可选数据"),
/// kept as `Right(null)` and observed via [appTalker] ("记录+继续"); it is
/// not a catch-all — other 4xx/5xx and network errors are rethrown into the
/// mapper and become a Left.
///
/// Transport goes through the typed generated [api.HealthEventsApi] again
/// after the Lucent contract fix. The history list item DTO is the canonical
/// event shape; the per-endpoint detail/active DTOs share its JSON shape and
/// are normalized into it before mapping (same pattern as the record
/// datasource and the pre-raw-Dio typed usage).
///
/// Protocol invariants (kept as recorded `StateError`, mapped to
/// `Left(unknown)` with the cause preserved, scan/medicine pattern): a
/// write/detail response missing the event body (`_mapRequired`), and an
/// unknown enum value (`_mapStatus` / `_mapOutcome` / `_mapCheckInOutcome`).
/// Structurally malformed payloads fail the generated client's checked
/// deserialization and surface here as a `CheckedFromJsonException` /
/// `DioException` (unknown) that the mapper turns into a `Left(unknown)`
/// keeping the cause. Protocol violations on error bodies (non `problem+json`)
/// keep the mapper's `FormatException` which propagates from `.run()`.
class LucentHealthEventRepository implements HealthEventRepository {
  LucentHealthEventRepository({required api.HealthEventsApi apiClient})
    : _api = apiClient;

  final api.HealthEventsApi _api;

  @override
  TaskEither<LucentFailure, HealthEvent?> fetchActive() {
    return TaskEither.tryCatch(() async {
      try {
        final response = await _api.active();
        final dto = response.data;
        // 200 with an empty / JSON-null body: no active event — a normal
        // business state, mapped to Right(null).
        return dto == null ? null : _map(_canonicalNullable(dto));
      } on DioException catch (error) {
        if (error.response?.statusCode == 404) {
          // 文档化语义：无活动事件是正常业务状态（"未配置可选数据保持
          // Right"），404 → Right(null)，观察记录后继续。
          appTalker.warning(
            'LucentHealthEventRepository: fetchActive 404, 无活动事件',
          );
          return null;
        }
        rethrow;
      }
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, HealthEvent?> fetchById(String eventId) {
    return TaskEither.tryCatch(() async {
      try {
        final response = await _api.getHealthEvent(id: eventId);
        final dto = response.data;
        return dto == null ? null : _map(_canonical(dto));
      } on DioException catch (error) {
        if (error.response?.statusCode == 404) {
          // 文档化语义：查询不存在的事件详情是正常业务状态 → Right(null)。
          appTalker.warning(
            'LucentHealthEventRepository: fetchById 404, 事件不存在',
          );
          return null;
        }
        rethrow;
      }
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, List<HealthEvent>> fetchHistory() {
    return TaskEither.tryCatch(() async {
      final response = await _api.listHealthEvents();
      final dto = _requireData(response.data, operation: 'fetchHistory');
      return dto.items.map(_map).toList(growable: false);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, HealthEvent> create({
    required String title,
    String? reasonRecordId,
    List<String> currentMedicineIds = const [],
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _api.createHealthEvent(
        createHealthEventRequest:
            api.CreateHealthEventRequest(
              title: title,
              reasonRecordId: reasonRecordId,
              currentMedicineIds: currentMedicineIds.isEmpty
                  ? null
                  : List<String>.of(currentMedicineIds),
            ),
      );
      return _mapRequired(response.data);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, HealthEvent> checkIn({
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _api.upsertCheckIn(
        id: eventId,
        // 日键 wire 形态为纯 YYYY-MM-DD 字符串(方案 A),直接透传调用方入参
        // 字符串;不再经 DateTime 中转(此前 DateTime.parse 会让生成客户端把
        // date.toString() 塞进路径,产出带时间的畸形日键)。
        date: date,
        upsertCheckInRequest:
            api.UpsertCheckInRequest(
              outcome: _toCheckInApiOutcome(outcome),
            ),
      );
      return _mapRequired(response.data);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, HealthEvent> end({
    required String eventId,
    required HealthEventOutcome outcome,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _api.end(
        id: eventId,
        endRequest:
            api.EndRequest(
              outcome: _toEndApiOutcome(outcome),
            ),
      );
      return _mapRequired(response.data);
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
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

  /// Protocol invariant: a write/detail response without event data is not a
  /// valid success. Kept as a recorded [StateError]; the repository boundary
  /// maps it to `Left(unknown)` with the cause preserved.
  HealthEvent _mapRequired(api.HealthEventResponse? dto) {
    if (dto == null) {
      appTalker.error('LucentHealthEventRepository: 响应缺少事件数据（协议不变量）');
      throw StateError('Health event response did not include event data.');
    }
    return _map(_canonical(dto));
  }

  /// Normalizes a per-endpoint event DTO to the canonical list-item DTO
  /// (identical JSON shape).
  api.HealthEventListResponseItems _canonical(
    api.HealthEventResponse dto,
  ) {
    return api.HealthEventListResponseItems.fromJson(dto.toJson());
  }

  /// Normalizes the nullable active-event DTO to the canonical list-item DTO
  /// (identical JSON shape).
  api.HealthEventListResponseItems _canonicalNullable(
    api.HealthEventNullableResponse dto,
  ) {
    return api.HealthEventListResponseItems.fromJson(dto.toJson());
  }

  HealthEvent _map(api.HealthEventListResponseItems dto) {
    return HealthEvent(
      id: dto.id,
      title: dto.title,
      status: _mapStatus(dto.status),
      startedAt: dto.startedAt,
      endedAt: dto.endedAt,
      outcome: dto.outcome == null ? null : _mapOutcome(dto.outcome!),
      reasonRecordId: dto.reasonRecordId,
      currentMedicineIds: List<String>.unmodifiable(dto.currentMedicineIds),
      checkIn: dto.checkIn == null ? null : _mapCheckIn(dto.checkIn!),
      coverage: HealthEventCoverage(
        checkInCount: dto.coverage.checkInCount,
        firstCheckInDate: dto.coverage.firstCheckInDate,
        lastCheckInDate: dto.coverage.lastCheckInDate,
      ),
    );
  }

  HealthEventCheckIn _mapCheckIn(api.HealthEventListResponseItemsCheckIn dto) {
    return HealthEventCheckIn(
      id: dto.id,
      eventId: dto.eventId,
      date: dto.date,
      outcome: _mapCheckInOutcome(dto.outcome),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  HealthEventStatus _mapStatus(
    api.HealthEventListResponseItemsStatusEnum value,
  ) {
    return switch (value) {
      api.HealthEventListResponseItemsStatusEnum.active =>
        HealthEventStatus.active,
      api.HealthEventListResponseItemsStatusEnum.ended =>
        HealthEventStatus.ended,
      api
          .HealthEventListResponseItemsStatusEnum
          .unknownDefaultOpenApi =>
        _unknownStatus(value.value),
    };
  }

  /// 协议不变量：未知状态枚举，记录后保持抛 `StateError` →
  /// `Left(unknown)`（cause 保留）。
  Never _unknownStatus(String value) {
    appTalker.error('LucentHealthEventRepository: 未知健康事件状态 $value');
    throw StateError('Unknown health event status: $value');
  }

  HealthEventOutcome _mapOutcome(
    api.HealthEventListResponseItemsOutcomeEnum value,
  ) {
    return switch (value) {
      api.HealthEventListResponseItemsOutcomeEnum.improved =>
        HealthEventOutcome.improved,
      api.HealthEventListResponseItemsOutcomeEnum.unchanged =>
        HealthEventOutcome.unchanged,
      api.HealthEventListResponseItemsOutcomeEnum.worsened =>
        HealthEventOutcome.worsened,
      api
          .HealthEventListResponseItemsOutcomeEnum
          .unknownDefaultOpenApi =>
        _unknownOutcome(value.value),
    };
  }

  /// 协议不变量：未知结果枚举，记录后保持抛 `StateError` →
  /// `Left(unknown)`（cause 保留）。
  Never _unknownOutcome(String value) {
    appTalker.error('LucentHealthEventRepository: 未知健康事件结果 $value');
    throw StateError('Unknown health event outcome: $value');
  }

  HealthEventOutcome _mapCheckInOutcome(
    api.HealthEventListResponseItemsCheckInOutcomeEnum value,
  ) {
    return switch (value) {
      api.HealthEventListResponseItemsCheckInOutcomeEnum.improved =>
        HealthEventOutcome.improved,
      api.HealthEventListResponseItemsCheckInOutcomeEnum.unchanged =>
        HealthEventOutcome.unchanged,
      api.HealthEventListResponseItemsCheckInOutcomeEnum.worsened =>
        HealthEventOutcome.worsened,
      api.HealthEventListResponseItemsCheckInOutcomeEnum.unknownDefaultOpenApi =>
        _unknownOutcome(value.value),
    };
  }

  api.UpsertCheckInRequestOutcomeEnum
  _toCheckInApiOutcome(HealthEventOutcome value) {
    return switch (value) {
      HealthEventOutcome.improved =>
        api.UpsertCheckInRequestOutcomeEnum.improved,
      HealthEventOutcome.unchanged =>
        api.UpsertCheckInRequestOutcomeEnum.unchanged,
      HealthEventOutcome.worsened =>
        api.UpsertCheckInRequestOutcomeEnum.worsened,
    };
  }

  api.EndRequestOutcomeEnum _toEndApiOutcome(
    HealthEventOutcome value,
  ) {
    return switch (value) {
      HealthEventOutcome.improved =>
        api.EndRequestOutcomeEnum.improved,
      HealthEventOutcome.unchanged =>
        api.EndRequestOutcomeEnum.unchanged,
      HealthEventOutcome.worsened =>
        api.EndRequestOutcomeEnum.worsened,
    };
  }
}
