import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for MedicinesApi
void main() {
  final instance = LucentApi().getMedicinesApi();

  group(MedicinesApi, () {
    // Get medicine detail from a selected knowledge source
    //
    //Future<MedicineDetailResponseDto> medicinesControllerGetDetailV1(String id, { String source_, String xBypassCache }) async
    test('test medicinesControllerGetDetailV1', () async {
      // TODO
    });

    // Get random medication safety tips
    //
    //Future<List<MedicineSafetyTipResponseDto>> medicinesControllerGetSafetyTipsV1({ List<String> exclude }) async
    test('test medicinesControllerGetSafetyTipsV1', () async {
      // TODO
    });

    // Enqueue async medicine box image recognition
    //
    //Future<MedicinesControllerRecognizeAsyncV1200Response> medicinesControllerRecognizeAsyncV1(RecognizeMedicineDto recognizeMedicineDto) async
    test('test medicinesControllerRecognizeAsyncV1', () async {
      // TODO
    });

    // Poll async medicine recognition status
    //
    //Future medicinesControllerRecognizeStatusV1(String jobId) async
    test('test medicinesControllerRecognizeStatusV1', () async {
      // TODO
    });

    // AI recognize medicine box image and extract medicine info
    //
    //Future medicinesControllerRecognizeV1(RecognizeMedicineDto recognizeMedicineDto) async
    test('test medicinesControllerRecognizeV1', () async {
      // TODO
    });

    // Search medicines from a selected knowledge source
    //
    //Future<MedicineSearchResponseDto> medicinesControllerSearchV1({ String source_, String q, num page, num pageSize, String xBypassCache }) async
    test('test medicinesControllerSearchV1', () async {
      // TODO
    });
  });
}
