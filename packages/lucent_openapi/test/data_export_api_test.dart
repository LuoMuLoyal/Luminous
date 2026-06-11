import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';


/// tests for DataExportApi
void main() {
  final instance = LucentOpenapi().getDataExportApi();

  group(DataExportApi, () {
    // Create a new data export request
    //
    //Future<DataExportRequestResponseDto> dataExportControllerCreateRequestV1() async
    test('test dataExportControllerCreateRequestV1', () async {
      // TODO
    });

    // Get the latest data export request
    //
    //Future<DataExportLatestResponseDto> dataExportControllerGetLatestRequestV1() async
    test('test dataExportControllerGetLatestRequestV1', () async {
      // TODO
    });

  });
}
