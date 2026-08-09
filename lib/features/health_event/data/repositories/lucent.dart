import 'package:dio/dio.dart';
import 'package:lucent_api/lucent_api.dart' as api;
import 'package:luminous/features/health_event/domain/entities/health_event.dart';
import 'package:luminous/features/health_event/domain/repositories/health_event.dart';

class LucentHealthEventRepository implements HealthEventRepository {
  LucentHealthEventRepository({required api.HealthEventsApi apiClient})
    : _api = apiClient;

  final api.HealthEventsApi _api;

  @override
  Future<HealthEvent?> fetchActive() async {
    try {
      final response = await _api.healthEventsControllerActiveV1();
      return _mapNullable(response.data?.data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<HealthEvent?> fetchById(String eventId) async {
    try {
      final response = await _api.healthEventsControllerGetV1(id: eventId);
      return _mapNullable(response.data?.data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<HealthEvent>> fetchHistory() async {
    final response = await _api.healthEventsControllerListV1();
    final items = response.data?.data.items ?? const <api.HealthEventItemDto>[];
    return items.map(_map).toList(growable: false);
  }

  @override
  Future<HealthEvent> create({
    required String title,
    String? reasonRecordId,
    List<String> currentMedicineIds = const [],
  }) async {
    final response = await _api.healthEventsControllerCreateV1(
      createHealthEventDto: api.CreateHealthEventDto(
        title: title,
        reasonRecordId: reasonRecordId,
        currentMedicineIds: currentMedicineIds.isEmpty
            ? null
            : List<String>.of(currentMedicineIds),
      ),
    );
    return _mapRequired(response.data?.data);
  }

  @override
  Future<HealthEvent> checkIn({
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
  }) async {
    final response = await _api.healthEventsControllerUpsertCheckInV1(
      id: eventId,
      date: date,
      upsertHealthEventCheckInDto: api.UpsertHealthEventCheckInDto(
        outcome: _toApiOutcome(outcome),
      ),
    );
    return _mapRequired(response.data?.data);
  }

  @override
  Future<HealthEvent> end({
    required String eventId,
    required HealthEventOutcome outcome,
  }) async {
    final response = await _api.healthEventsControllerEndV1(
      id: eventId,
      endHealthEventDto: api.EndHealthEventDto(outcome: _toApiOutcome(outcome)),
    );
    return _mapRequired(response.data?.data);
  }

  HealthEvent? _mapNullable(api.HealthEventItemDto? dto) {
    return dto == null ? null : _map(dto);
  }

  HealthEvent _mapRequired(api.HealthEventItemDto? dto) {
    if (dto == null) {
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
      api.HealthEventStatus.unknownDefaultOpenApi => throw StateError(
        'Unknown health event status: $value',
      ),
    };
  }

  HealthEventOutcome? _mapNullableOutcome(api.HealthEventOutcome? value) {
    return value == null ? null : _mapOutcome(value);
  }

  HealthEventOutcome _mapOutcome(api.HealthEventOutcome value) {
    return switch (value) {
      api.HealthEventOutcome.improved => HealthEventOutcome.improved,
      api.HealthEventOutcome.unchanged => HealthEventOutcome.unchanged,
      api.HealthEventOutcome.worsened => HealthEventOutcome.worsened,
      api.HealthEventOutcome.unknownDefaultOpenApi => throw StateError(
        'Unknown health event outcome: $value',
      ),
    };
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
    throw StateError('Health event field "$fieldName" was not a string.');
  }
}
