import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/auth/data/services/avatar_uploader.dart';
import 'package:mocktail/mocktail.dart';

class _MockFilesApi extends Mock implements FilesApi {}

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockFilesApi filesApi;
  late _MockDio dio;

  setUpAll(() {
    registerFallbackValue(
      CreateUploadRequest(contentType: 'image/jpeg', sizeBytes: 1),
    );
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    filesApi = _MockFilesApi();
    dio = _MockDio();
  });

  test(
    'uploads with a private avatar object prefix and returns public URL',
    () async {
      when(
        () => filesApi.createUpload(
          createUploadRequest: any(named: 'createUploadRequest'),
        ),
      ).thenAnswer(
        (_) async => Response<CreateFileUploadResponse>(
          requestOptions: RequestOptions(path: '/files/upload'),
          data: CreateFileUploadResponse(
            provider: 's3',
            bucket: 'avatars',
            objectKey: 'avatars/user-1/server-key.jpg',
            uploadUrl: 'https://upload.example.com/signed',
            headers: const {'Content-Type': 'image/jpeg'},
            publicUrl: 'https://cdn.example.com/avatar.jpg',
            expiresAt: '2026-01-01T00:00:00Z',
            maxSizeBytes: 100,
          ),
        ),
      );
      when(
        () => dio.put<dynamic>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async =>
            Response<dynamic>(requestOptions: RequestOptions(path: '')),
      );

      final url = await AvatarUploader(filesApi: filesApi, dio: dio).upload(
        userId: 'user-1',
        bytes: Uint8List.fromList(const [1, 2, 3]),
        contentType: 'image/jpeg',
        fileName: 'photo.jpg',
      );

      expect(url, 'https://cdn.example.com/avatar.jpg');
      final captured =
          verify(
                () => filesApi.createUpload(
                  createUploadRequest: captureAny(named: 'createUploadRequest'),
                ),
              ).captured.single
              as CreateUploadRequest;
      expect(captured.fileName, startsWith('avatars/user-1/avatar-'));
      expect(captured.fileName, endsWith('.jpg'));
    },
  );
}
