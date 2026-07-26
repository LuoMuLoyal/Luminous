import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for UserDevicesApi
void main() {
  final instance = LucentApi().getUserDevicesApi();

  group(UserDevicesApi, () {
    // List registered devices
    //
    //Future<DeviceListResponseDto> userDevicesControllerListV1() async
    test('test userDevicesControllerListV1', () async {
      // TODO
    });

    // Register or update a device for push notifications
    //
    //Future<DeviceResponseDto> userDevicesControllerRegisterV1(RegisterDeviceDto registerDeviceDto) async
    test('test userDevicesControllerRegisterV1', () async {
      // TODO
    });

    // Unregister a device
    //
    //Future userDevicesControllerRemoveV1(String id) async
    test('test userDevicesControllerRemoveV1', () async {
      // TODO
    });
  });
}
