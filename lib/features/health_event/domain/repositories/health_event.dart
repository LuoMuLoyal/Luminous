import 'package:luminous/features/health_event/domain/entities/health_event.dart';

abstract interface class HealthEventRepository {
  Future<HealthEvent?> fetchActive();

  Future<HealthEvent?> fetchById(String eventId);

  Future<List<HealthEvent>> fetchHistory();

  Future<HealthEvent> create({
    required String title,
    String? reasonRecordId,
    List<String> currentMedicineIds = const [],
  });

  Future<HealthEvent> checkIn({
    required String eventId,
    required String date,
    required HealthEventOutcome outcome,
  });

  Future<HealthEvent> end({
    required String eventId,
    required HealthEventOutcome outcome,
  });
}
