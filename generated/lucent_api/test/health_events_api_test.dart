import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for HealthEventsApi
void main() {
  final instance = LucentApi().getHealthEventsApi();

  group(HealthEventsApi, () {
    // Get the current active health event
    //
    //Future<HealthEventNullableResponseDto> healthEventsControllerActiveV1({ String date }) async
    test('test healthEventsControllerActiveV1', () async {
      // TODO
    });

    // Start a user-confirmed health event
    //
    //Future<HealthEventResponseDto> healthEventsControllerCreateV1(CreateHealthEventDto createHealthEventDto) async
    test('test healthEventsControllerCreateV1', () async {
      // TODO
    });

    // End a health event with an explicit outcome
    //
    //Future<HealthEventResponseDto> healthEventsControllerEndV1(String id, EndHealthEventDto endHealthEventDto) async
    test('test healthEventsControllerEndV1', () async {
      // TODO
    });

    // Get one user health event
    //
    //Future<HealthEventResponseDto> healthEventsControllerGetV1(String id, { String date }) async
    test('test healthEventsControllerGetV1', () async {
      // TODO
    });

    // List the user health event history
    //
    //Future<HealthEventListResponseDto> healthEventsControllerListV1({ String date }) async
    test('test healthEventsControllerListV1', () async {
      // TODO
    });

    // Upsert a user-confirmed daily event check-in
    //
    //Future<HealthEventResponseDto> healthEventsControllerUpsertCheckInV1(String id, String date, UpsertHealthEventCheckInDto upsertHealthEventCheckInDto) async
    test('test healthEventsControllerUpsertCheckInV1', () async {
      // TODO
    });
  });
}
