import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';


/// tests for EnvironmentApi
void main() {
  final instance = LucentOpenapi().getEnvironmentApi();

  group(EnvironmentApi, () {
    // Get static environment snapshot reference data
    //
    //Future<EnvironmentSnapshotResponseDto> environmentControllerGetSnapshotV1({ num lat, num lon }) async
    test('test environmentControllerGetSnapshotV1', () async {
      // TODO
    });

  });
}
