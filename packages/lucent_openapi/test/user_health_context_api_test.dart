import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';


/// tests for UserHealthContextApi
void main() {
  final instance = LucentOpenapi().getUserHealthContextApi();

  group(UserHealthContextApi, () {
    // Get the current user health context aggregate
    //
    //Future<HealthContextResponseDto> userHealthContextControllerGetMeHealthContextV1() async
    test('test userHealthContextControllerGetMeHealthContextV1', () async {
      // TODO
    });

  });
}
