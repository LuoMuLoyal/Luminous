import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_event.freezed.dart';

enum HealthEventStatus { active, ended }

enum HealthEventOutcome { improved, unchanged, worsened }

@freezed
abstract class HealthEvent with _$HealthEvent {
  const factory HealthEvent({
    required String id,
    required String title,
    required HealthEventStatus status,
    required String startedAt,
    String? endedAt,
    HealthEventOutcome? outcome,
    String? reasonRecordId,
    required List<String> currentMedicineIds,
    HealthEventCheckIn? checkIn,
    required HealthEventCoverage coverage,
  }) = _HealthEvent;
}

@freezed
abstract class HealthEventCheckIn with _$HealthEventCheckIn {
  const factory HealthEventCheckIn({
    required String id,
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
    required String createdAt,
    required String updatedAt,
  }) = _HealthEventCheckIn;
}

@freezed
abstract class HealthEventCoverage with _$HealthEventCoverage {
  const factory HealthEventCoverage({
    required int checkInCount,
    String? firstCheckInDate,
    String? lastCheckInDate,
  }) = _HealthEventCoverage;
}
