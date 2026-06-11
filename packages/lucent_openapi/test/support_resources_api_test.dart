import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';


/// tests for SupportResourcesApi
void main() {
  final instance = LucentOpenapi().getSupportResourcesApi();

  group(SupportResourcesApi, () {
    // Get application metadata
    //
    //Future<AppInfoResponseDto> supportResourcesControllerGetAppInfoV1() async
    test('test supportResourcesControllerGetAppInfoV1', () async {
      // TODO
    });

    // Get static support resource entries
    //
    //Future<SupportResourceListResponseDto> supportResourcesControllerGetResourcesV1({ String scope }) async
    test('test supportResourcesControllerGetResourcesV1', () async {
      // TODO
    });

  });
}
