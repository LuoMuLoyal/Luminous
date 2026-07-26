import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for ReminderDeliveriesApi
void main() {
  final instance = LucentApi().getReminderDeliveriesApi();

  group(ReminderDeliveriesApi, () {
    // List reminder delivery audit logs
    //
    //Future<ReminderDeliveryListResponseDto> reminderDeliveriesControllerListV1({ String date, String limit }) async
    test('test reminderDeliveriesControllerListV1', () async {
      // TODO
    });
  });
}
