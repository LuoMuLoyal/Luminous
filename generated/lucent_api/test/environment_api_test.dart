import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for EnvironmentApi
void main() {
  final instance = LucentApi().getEnvironmentApi();

  group(EnvironmentApi, () {
    // Get static environment snapshot reference data
    //
    //Future<EnvironmentSnapshotResponseDto> environmentControllerGetSnapshotV1({ num lat, num lon }) async
    test('test environmentControllerGetSnapshotV1', () async {
      // TODO
    });
  });
}
