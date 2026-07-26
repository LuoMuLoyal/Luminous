import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for UserSettingsApi
void main() {
  final instance = LucentApi().getUserSettingsApi();

  group(UserSettingsApi, () {
    // Change Security PIN
    //
    //Future<UserSettingsResponseDto> userSettingsControllerChangeSecurityPinV1(ChangeSecurityPinDto changeSecurityPinDto) async
    test('test userSettingsControllerChangeSecurityPinV1', () async {
      // TODO
    });

    // Disable Security PIN
    //
    //Future<UserSettingsResponseDto> userSettingsControllerDisableSecurityPinV1(DisableSecurityPinDto disableSecurityPinDto) async
    test('test userSettingsControllerDisableSecurityPinV1', () async {
      // TODO
    });

    // Enable Security PIN
    //
    //Future<UserSettingsResponseDto> userSettingsControllerEnableSecurityPinV1(EnableSecurityPinDto enableSecurityPinDto) async
    test('test userSettingsControllerEnableSecurityPinV1', () async {
      // TODO
    });

    // Get authenticated user settings
    //
    //Future<UserSettingsResponseDto> userSettingsControllerGetSettingsV1() async
    test('test userSettingsControllerGetSettingsV1', () async {
      // TODO
    });

    // Update authenticated user settings
    //
    //Future<UserSettingsResponseDto> userSettingsControllerUpdateSettingsV1(UpdateUserSettingsDto updateUserSettingsDto) async
    test('test userSettingsControllerUpdateSettingsV1', () async {
      // TODO
    });

    // Verify Security PIN and receive elevation token
    //
    //Future<SecurityPinElevationResponseDto> userSettingsControllerVerifySecurityPinV1(VerifySecurityPinDto verifySecurityPinDto) async
    test('test userSettingsControllerVerifySecurityPinV1', () async {
      // TODO
    });
  });
}
