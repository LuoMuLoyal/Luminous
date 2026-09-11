import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:mocktail/mocktail.dart';

class _MockFilesApi extends Mock implements FilesApi {}

class _MockDio extends Mock implements Dio {}

/// The typed presign response now that `POST /files/upload` declares its 200
/// schema.
CreateFileUploadResponse _presign({
  String? publicUrl = 'https://cdn.example.com/object.jpg',
  Map<String, String> headers = const {'Content-Type': 'image/jpeg'},
}) {
  return CreateFileUploadResponse(
    provider: 's3',
    bucket: 'test-bucket',
    objectKey: 'files/user-1/object.jpg',
    uploadUrl: 'https://upload.example.com/presigned',
    headers: headers,
    publicUrl: publicUrl,
    expiresAt: '2026-01-01T00:00:00.000Z',
    maxSizeBytes: 10485760,
  );
}

void main() {
  late _MockFilesApi filesApi;
  late _MockDio dio;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(
      CreateUploadRequest(contentType: 'image/jpeg', sizeBytes: 1),
    );
  });

  setUp(() {
    filesApi = _MockFilesApi();
    dio = _MockDio();
  });

  group('presignFileUpload', () {
    test('maps the typed response into the transport shape', () async {
      when(
        () => filesApi.createUpload(
          createUploadRequest: any(named: 'createUploadRequest'),
        ),
      ).thenAnswer(
        (_) async => Response<CreateFileUploadResponse>(
          data: _presign(),
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/user/files/upload'),
        ),
      );

      final upload = await presignFileUpload(
        filesApi,
        contentType: 'image/jpeg',
        sizeBytes: 2048,
        fileName: 'photo.jpg',
      );

      expect(upload.provider, 's3');
      expect(upload.bucket, 'test-bucket');
      expect(upload.objectKey, 'files/user-1/object.jpg');
      expect(upload.uploadUrl, 'https://upload.example.com/presigned');
      expect(upload.publicUrl, 'https://cdn.example.com/object.jpg');
      expect(upload.maxSizeBytes, 10485760);

      final request =
          verify(
                () => filesApi.createUpload(
                  createUploadRequest: captureAny(named: 'createUploadRequest'),
                ),
              ).captured.single
              as CreateUploadRequest;
      expect(request.contentType, 'image/jpeg');
      expect(request.sizeBytes, 2048);
      expect(request.fileName, 'photo.jpg');
    });

    test('an empty success body is a network emptyResponse failure', () async {
      when(
        () => filesApi.createUpload(
          createUploadRequest: any(named: 'createUploadRequest'),
        ),
      ).thenAnswer(
        (_) async => Response<CreateFileUploadResponse>(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/user/files/upload'),
        ),
      );

      await expectLater(
        presignFileUpload(filesApi, contentType: 'image/jpeg', sizeBytes: 1),
        throwsA(
          isA<LucentFailure>()
              .having((f) => f.kind, 'kind', LucentFailureKind.network)
              .having(
                (f) => f.networkErrorCode,
                'networkErrorCode',
                NetworkErrorCode.emptyResponse,
              ),
        ),
      );
    });
  });

  group('putPresignedObject', () {
    test('PUTs to the signed URL without the session credentials', () async {
      when(
        () => dio.put(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          data: '',
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      await putPresignedObject(
        dio,
        upload: PresignedUpload.fromFileUpload(_presign()),
        bytes: Uint8List.fromList([1, 2, 3]),
        contentType: 'image/jpeg',
      );

      final captured = verify(
        () => dio.put(
          captureAny(),
          data: captureAny(named: 'data'),
          options: captureAny(named: 'options'),
        ),
      ).captured;
      expect(captured[0], 'https://upload.example.com/presigned');

      final options = captured[2] as Options;
      // Object storage is not the Lucent API.
      expect(options.extra?['skipAuthorization'], isTrue);
      expect(options.extra?['skipAuthRefresh'], isTrue);
      // The signed Content-Type from the presign response wins.
      expect(options.headers?['Content-Type'], 'image/jpeg');
      expect(options.headers?[Headers.contentLengthHeader], 3);
    });

    test('an explicit sizeBytes wins over the byte length', () async {
      when(
        () => dio.put(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          data: '',
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      await putPresignedObject(
        dio,
        upload: PresignedUpload.fromFileUpload(_presign()),
        bytes: Uint8List.fromList([1, 2, 3]),
        contentType: 'image/jpeg',
        sizeBytes: 99,
      );

      final options =
          verify(
                () => dio.put(
                  any(),
                  data: any(named: 'data'),
                  options: captureAny(named: 'options'),
                ),
              ).captured.single
              as Options;
      expect(options.headers?[Headers.contentLengthHeader], 99);
    });
  });

  group('requirePublicUrl', () {
    test('returns the configured public URL', () {
      final upload = PresignedUpload.fromFileUpload(_presign());

      expect(upload.requirePublicUrl(), 'https://cdn.example.com/object.jpg');
    });

    test('fails instead of handing back the write-only PUT URL', () {
      final upload = PresignedUpload.fromFileUpload(_presign(publicUrl: null));

      // The PUT signature cannot be fetched by anyone, so falling back to it
      // (as this path used to) would produce a URL that silently never loads.
      expect(
        upload.requirePublicUrl,
        throwsA(
          isA<LucentFailure>().having(
            (f) => f.message,
            'message',
            contains('public base URL'),
          ),
        ),
      );
    });
  });
}
