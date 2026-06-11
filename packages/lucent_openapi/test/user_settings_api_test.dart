import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';


/// tests for UserSettingsApi
void main() {
  final instance = LucentOpenapi().getUserSettingsApi();

  group(UserSettingsApi, () {
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

  });
}
