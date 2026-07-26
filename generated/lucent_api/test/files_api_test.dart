import 'package:test/test.dart';
import 'package:lucent_api/lucent_api.dart';

/// tests for FilesApi
void main() {
  final instance = LucentApi().getFilesApi();

  group(FilesApi, () {
    // Create a presigned upload URL for a file
    //
    //Future filesControllerCreateUploadV1(CreateFileUploadDto createFileUploadDto) async
    test('test filesControllerCreateUploadV1', () async {
      // TODO
    });
  });
}
