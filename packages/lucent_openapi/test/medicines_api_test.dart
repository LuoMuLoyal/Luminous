import 'package:test/test.dart';
import 'package:lucent_openapi/lucent_openapi.dart';


/// tests for MedicinesApi
void main() {
  final instance = LucentOpenapi().getMedicinesApi();

  group(MedicinesApi, () {
    // Get medicine detail from a selected knowledge source
    //
    //Future<MedicineDetailResponseDto> medicinesControllerGetDetailV1(String id, { String source_ }) async
    test('test medicinesControllerGetDetailV1', () async {
      // TODO
    });

    // Search medicines from a selected knowledge source
    //
    //Future<MedicineSearchResponseDto> medicinesControllerSearchV1({ String source_, String q, Object page, Object pageSize }) async
    test('test medicinesControllerSearchV1', () async {
      // TODO
    });

  });
}
