import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for LegalDocumentsApi
void main() {
  final instance = LucentApi().getLegalDocumentsApi();

  group(LegalDocumentsApi, () {
    // List all active legal documents
    //
    //Future<LegalDocumentListResponseDto> legalDocumentsControllerFindAllV1({ String lang }) async
    test('test legalDocumentsControllerFindAllV1', () async {
      // TODO
    });

    // Get a specific legal document by type
    //
    //Future<LegalDocumentDetailResponseDto> legalDocumentsControllerFindOneV1(String docType, { String lang }) async
    test('test legalDocumentsControllerFindOneV1', () async {
      // TODO
    });
  });
}
