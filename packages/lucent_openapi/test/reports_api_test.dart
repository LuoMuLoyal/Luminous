import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';


/// tests for ReportsApi
void main() {
  final instance = LucentOpenapi().getReportsApi();

  group(ReportsApi, () {
    // Get authenticated user report dashboard
    //
    //Future<ReportDashboardResponseDto> reportsControllerGetDashboardV1({ String range }) async
    test('test reportsControllerGetDashboardV1', () async {
      // TODO
    });

  });
}
