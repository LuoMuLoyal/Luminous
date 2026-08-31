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
/// Protocol invariants (kept as recorded `StateError`, mapped to
/// `Left(unknown)` with the cause preserved, scan/medicine pattern): a
/// write/detail response missing the event body (`_mapRequired`), an unknown
/// enum value (`_mapStatus` / `_mapOutcome`), and a non-string optional field
/// (`_asString`). Protocol violations on error bodies (non `problem+json`)
/// keep the mapper's `FormatException` which propagates from `.run()`.
class LucentHealthEventRepository implements HealthEventRepository {
  LucentHealthEventRepository({required api.HealthEventsApi apiClient})
    : _api = apiClient;

  final api.HealthEventsApi _api;

  @override
  TaskEither<LucentFailure, HealthEvent?> fetchActive() {
    return TaskEither.tryCatch(() async {
      try {
        final response = await _api.healthEventsControllerActiveV1();
        return _mapNullable(response.data);
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
        final response = await _api.healthEventsControllerGetV1(id: eventId);
        final dto = response.data;
        return dto == null
            ? null
            : _mapRequired(api.HealthEventItemDto.fromJson(dto.toJson()));
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
      final response = await _api.healthEventsControllerListV1();
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
      final response = await _api.healthEventsControllerCreateV1(
        createHealthEventDto: api.CreateHealthEventDto(
          title: title,
          reasonRecordId: reasonRecordId,
          currentMedicineIds: currentMedicineIds.isEmpty
              ? null
              : List<String>.of(currentMedicineIds),
        ),
      );
      final dto = response.data;
      return _mapRequired(
        dto == null ? null : api.HealthEventItemDto.fromJson(dto.toJson()),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, HealthEvent> checkIn({
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _api.healthEventsControllerUpsertCheckInV1(
        id: eventId,
        date: date,
        upsertHealthEventCheckInDto: api.UpsertHealthEventCheckInDto(
          outcome: _toApiOutcome(outcome),
        ),
      );
      final dto = response.data;
      return _mapRequired(
        dto == null ? null : api.HealthEventItemDto.fromJson(dto.toJson()),
      );
    }, (error, stackTrace) => LucentErrorMapper.fromObject(error));
  }

  @override
  TaskEither<LucentFailure, HealthEvent> end({
    required String eventId,
    required HealthEventOutcome outcome,
  }) {
    return TaskEither.tryCatch(() async {
      final response = await _api.healthEventsControllerEndV1(
        id: eventId,
        endHealthEventDto: api.EndHealthEventDto(
          outcome: _toApiOutcome(outcome),
        ),
      );
      final dto = response.data;
      return _mapRequired(
        dto == null ? null : api.HealthEventItemDto.fromJson(dto.toJson()),
      );
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

  HealthEvent? _mapNullable(api.HealthEventItemDto? dto) {
    return dto == null ? null : _map(dto);
  }

  /// Protocol invariant: a write/detail response without event data is not a
  /// valid success. Kept as a recorded [StateError]; the repository boundary
  /// maps it to `Left(unknown)` with the cause preserved.
  HealthEvent _mapRequired(api.HealthEventItemDto? dto) {
    if (dto == null) {
      appTalker.error('LucentHealthEventRepository: 响应缺少事件数据（协议不变量）');
      throw StateError('Health event response did not include event data.');
    }
    return _map(dto);
  }

  HealthEvent _map(api.HealthEventItemDto dto) {
    return HealthEvent(
      id: dto.id,
      title: dto.title,
      status: _mapStatus(dto.status),
      startedAt: dto.startedAt,
      endedAt: _asString(dto.endedAt, 'endedAt'),
      outcome: _mapNullableOutcome(dto.outcome),
      reasonRecordId: _asString(dto.reasonRecordId, 'reasonRecordId'),
      currentMedicineIds: List<String>.unmodifiable(dto.currentMedicineIds),
      checkIn: dto.checkIn == null ? null : _mapCheckIn(dto.checkIn!),
      coverage: HealthEventCoverage(
        checkInCount: dto.coverage.checkInCount.toInt(),
        firstCheckInDate: _asString(
          dto.coverage.firstCheckInDate,
          'coverage.firstCheckInDate',
        ),
        lastCheckInDate: _asString(
          dto.coverage.lastCheckInDate,
          'coverage.lastCheckInDate',
        ),
      ),
    );
  }

  HealthEventCheckIn _mapCheckIn(api.HealthEventCheckInResponseDto dto) {
    return HealthEventCheckIn(
      id: dto.id,
      eventId: dto.eventId,
      date: dto.date,
      outcome: _mapOutcome(dto.outcome),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  HealthEventStatus _mapStatus(api.HealthEventStatus value) {
    return switch (value) {
      api.HealthEventStatus.active => HealthEventStatus.active,
      api.HealthEventStatus.ended => HealthEventStatus.ended,
      api.HealthEventStatus.unknownDefaultOpenApi => _unknownStatus(value),
    };
  }

  /// 协议不变量：未知状态枚举，记录后保持抛 `StateError` →
  /// `Left(unknown)`（cause 保留）。
  Never _unknownStatus(api.HealthEventStatus value) {
    appTalker.error('LucentHealthEventRepository: 未知健康事件状态 $value');
    throw StateError('Unknown health event status: $value');
  }

  HealthEventOutcome? _mapNullableOutcome(api.HealthEventOutcome? value) {
    return value == null ? null : _mapOutcome(value);
  }

  HealthEventOutcome _mapOutcome(api.HealthEventOutcome value) {
    return switch (value) {
      api.HealthEventOutcome.improved => HealthEventOutcome.improved,
      api.HealthEventOutcome.unchanged => HealthEventOutcome.unchanged,
      api.HealthEventOutcome.worsened => HealthEventOutcome.worsened,
      api.HealthEventOutcome.unknownDefaultOpenApi => _unknownOutcome(value),
    };
  }

  /// 协议不变量：未知结果枚举，记录后保持抛 `StateError` →
  /// `Left(unknown)`（cause 保留）。
  Never _unknownOutcome(api.HealthEventOutcome value) {
    appTalker.error('LucentHealthEventRepository: 未知健康事件结果 $value');
    throw StateError('Unknown health event outcome: $value');
  }

  api.HealthEventOutcome _toApiOutcome(HealthEventOutcome value) {
    return switch (value) {
      HealthEventOutcome.improved => api.HealthEventOutcome.improved,
      HealthEventOutcome.unchanged => api.HealthEventOutcome.unchanged,
      HealthEventOutcome.worsened => api.HealthEventOutcome.worsened,
    };
  }

  String? _asString(Object? value, String fieldName) {
    if (value == null || value is String) return value as String?;
    // 协议不变量：字段类型不符，记录后保持抛 StateError →
    // Left(unknown)（cause 保留）。
    appTalker.error(
      'LucentHealthEventRepository: 字段 "$fieldName" 不是字符串: $value',
    );
    throw StateError('Health event field "$fieldName" was not a string.');
  }
}
