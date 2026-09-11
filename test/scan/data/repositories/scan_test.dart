import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/scan/data/repositories/scan.dart';
import 'package:luminous/features/scan/domain/repositories/scan.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/task_either.dart';

class _MockMedicinesApi extends Mock implements MedicinesApi {}

class _MockFilesApi extends Mock implements FilesApi {}

class _MockDio extends Mock implements Dio {}

/// A 404 Problem Details body served with `application/problem+json`.
DioException _problemDetails404({String code = 'MEDICINE_NOT_FOUND'}) {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/medicines/recognize'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/api/v1/medicines/recognize'),
      statusCode: 404,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['application/problem+json'],
      }),
      data: {
        'type': 'https://api.lumos.example/problems/$code',
        'title': 'Not found',
        'detail': '药品不存在或已下架',
        'code': code,
      },
    ),
  );
}

/// A network timeout with no HTTP response.
DioException _connectionTimeout() {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/medicines/recognize'),
    type: DioExceptionType.connectionTimeout,
  );
}

/// A 400 body that is not Problem Details (protocol invariant violation).
DioException _nonProblemBody400() {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/medicines/recognize'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/api/v1/medicines/recognize'),
      statusCode: 400,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['application/json'],
      }),
      data: {'error': 'oops'},
    ),
  );
}

void main() {
  late _MockMedicinesApi mockApi;
  late _MockDio mockDio;
  late _MockFilesApi mockFilesApi;
  late ScanRepository repo;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
    registerFallbackValue(
      CreateUploadRequest(contentType: 'image/jpeg', sizeBytes: 1),
    );
  });

  setUp(() {
    mockApi = _MockMedicinesApi();
    mockDio = _MockDio();
    mockFilesApi = _MockFilesApi();
    repo = LucentScanRepository(
      api: mockApi,
      dio: mockDio,
      filesApi: mockFilesApi,
    );
  });

  Response<T> searchResponse<T>(T data) => Response<T>(
    data: data,
    statusCode: 200,
    requestOptions: RequestOptions(path: ''),
  );

  group('LucentScanRepository.search', () {
    test('returns response data from API', () async {
      final items = [
        MedicineSearchResponseItems(
          id: 'med-1',
          source_: MedicineSearchResponseItemsSource_Enum.cn,
          name: '阿莫西林胶囊',
          subtitle: '抗生素',
          summary: '用于敏感菌所致感染',
          tags: ['抗生素'],
          imageUrl: null,
          matchedBy: ['name'],
        ),
      ];
      final searchDto = MedicineSearchResponse(
        items: items,
        pagination: MedicineSearchResponsePagination(
          page: 1,
          pageSize: 20,
          total: 1,
          totalPages: 1,
        ),
      );

      when(
        () => mockApi.search(
          source_: any(named: 'source_'),
          q: any(named: 'q'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => searchResponse(searchDto));

      final result = await expectTaskRight(repo.search('阿莫西林'));

      expect(result, hasLength(1));
      expect(result.first.id, 'med-1');
      expect(result.first.name, '阿莫西林胶囊');
      expect(result.first.subtitle, '抗生素');

      verify(
        () => mockApi.search(source_: 'cn', q: '阿莫西林', page: 1, pageSize: 20),
      ).called(1);
    });

    test(
      'returns empty list as a legal Right when API returns no data',
      () async {
        final emptyResponse = MedicineSearchResponse(
          items: [],
          pagination: MedicineSearchResponsePagination(
            page: 1,
            pageSize: 20,
            total: 0,
            totalPages: 0,
          ),
        );

        when(
          () => mockApi.search(
            source_: any(named: 'source_'),
            q: any(named: 'q'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer((_) async => searchResponse(emptyResponse));

        final result = await expectTaskRight(repo.search('nonexistent'));

        expect(result, isEmpty);
      },
    );

    test(
      'empty success response body maps to Left(network, emptyResponse)',
      () async {
        when(
          () => mockApi.search(
            source_: any(named: 'source_'),
            q: any(named: 'q'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer(
          (_) async => Response<MedicineSearchResponse>(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final failure = await expectTaskLeft(repo.search('test'));

        expect(failure.kind, LucentFailureKind.network);
        expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
      },
    );

    test('404 Problem Details keeps code and status as a Left', () async {
      when(
        () => mockApi.search(
          source_: any(named: 'source_'),
          q: any(named: 'q'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenThrow(_problemDetails404(code: 'MEDICINE_NOT_FOUND'));

      final failure = await expectTaskLeft(repo.search('x'));

      expect(failure.code, 'MEDICINE_NOT_FOUND');
      expect(failure.statusCode, 404);
      expect(failure.kind, LucentFailureKind.business);
    });

    test('network timeout maps to a network connectivity Left', () async {
      when(
        () => mockApi.search(
          source_: any(named: 'source_'),
          q: any(named: 'q'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenThrow(_connectionTimeout());

      final failure = await expectTaskLeft(repo.search('x'));

      expect(failure.isNetworkConnectivityError, isTrue);
      expect(failure.kind, LucentFailureKind.network);
    });

    test(
      'non-Problem Details error body propagates FormatException from run()',
      () async {
        when(
          () => mockApi.search(
            source_: any(named: 'source_'),
            q: any(named: 'q'),
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenThrow(_nonProblemBody400());

        await expectLater(
          repo.search('x').run(),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test('plain unexpected exception maps to a Left(unknown)', () async {
      when(
        () => mockApi.search(
          source_: any(named: 'source_'),
          q: any(named: 'q'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenThrow(Exception('unexpected'));

      final failure = await expectTaskLeft(repo.search('x'));

      expect(failure.kind, LucentFailureKind.unknown);
    });
  });

  group('LucentScanRepository.uploadImage', () {
    /// The presign response is a typed DTO now that
    /// `POST /files/upload` declares its 200 schema.
    CreateFileUploadResponse presign({
      String uploadUrl = 'https://upload.example.com/presigned',
      String? publicUrl = 'https://cdn.example.com/image.jpg',
      Map<String, String> headers = const {'Content-Type': 'image/jpeg'},
    }) {
      return CreateFileUploadResponse(
        provider: 's3',
        bucket: 'test-bucket',
        objectKey: 'files/user-1/object.jpg',
        uploadUrl: uploadUrl,
        headers: headers,
        publicUrl: publicUrl,
        expiresAt: '2026-01-01T00:00:00.000Z',
        maxSizeBytes: 10485760,
      );
    }

    void stubPresign(CreateFileUploadResponse response) {
      when(
        () => mockFilesApi.createUpload(
          createUploadRequest: any(named: 'createUploadRequest'),
        ),
      ).thenAnswer(
        (_) async => Response<CreateFileUploadResponse>(
          data: response,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/user/files/upload'),
        ),
      );
    }

    void stubPut() {
      when(
        () => mockDio.put(
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
    }

    test('returns publicUrl from presign response', () async {
      stubPresign(presign());
      stubPut();

      final result = await expectTaskRight(
        repo.uploadImage(bytes: [1, 2, 3], contentType: 'image/jpeg'),
      );

      expect(result, 'https://cdn.example.com/image.jpg');
    });

    test('uploads to the presigned URL without the session bearer', () async {
      stubPresign(presign(uploadUrl: 'https://upload.example.com/presigned'));
      stubPut();

      await expectTaskRight(
        repo.uploadImage(bytes: [1, 2, 3], contentType: 'image/jpeg'),
      );

      final options =
          verify(
                () => mockDio.put(
                  captureAny(),
                  data: any(named: 'data'),
                  options: captureAny(named: 'options'),
                ),
              ).captured
              as List<Object?>;
      expect(options[0], 'https://upload.example.com/presigned');
      final requestOptions = options[1] as Options;
      // Object storage is not the Lucent API: the bearer token must not leak
      // to it, and a storage 401/403 must not spend the single-use refresh
      // token.
      expect(requestOptions.extra?['skipAuthorization'], isTrue);
      expect(requestOptions.extra?['skipAuthRefresh'], isTrue);
      expect(requestOptions.headers?['Content-Type'], 'image/jpeg');
      // Dio's own constant, so the assertion cannot drift from the map key.
      expect(requestOptions.headers?[Headers.contentLengthHeader], 3);
    });

    test('fails when the deployment exposes no public URL', () async {
      // `uploadUrl` is a write-only signature: the recognition endpoint fetches
      // the returned URL server-side, so handing it the PUT URL would produce
      // an image URL that can never load.
      stubPresign(presign(publicUrl: null));
      stubPut();

      final failure = await expectTaskLeft(
        repo.uploadImage(bytes: [1, 2, 3], contentType: 'image/png'),
      );

      expect(failure.kind, LucentFailureKind.unknown);
      expect(failure.message, contains('public base URL'));
    });

    test('uses sizeBytes from parameter when provided', () async {
      stubPresign(presign());
      stubPut();

      await expectTaskRight(
        repo.uploadImage(
          bytes: [1, 2, 3],
          contentType: 'image/jpeg',
          sizeBytes: 999,
        ),
      );

      final request =
          verify(
                () => mockFilesApi.createUpload(
                  createUploadRequest: captureAny(named: 'createUploadRequest'),
                ),
              ).captured.single
              as CreateUploadRequest;
      expect(request.sizeBytes, 999);
    });

    test('includes fileName in presign request when provided', () async {
      stubPresign(presign());
      stubPut();

      await expectTaskRight(
        repo.uploadImage(
          bytes: [1, 2, 3],
          contentType: 'image/jpeg',
          fileName: 'test.jpg',
        ),
      );

      final request =
          verify(
                () => mockFilesApi.createUpload(
                  createUploadRequest: captureAny(named: 'createUploadRequest'),
                ),
              ).captured.single
              as CreateUploadRequest;
      expect(request.fileName, 'test.jpg');
    });

    test(
      'empty presign response body maps to Left(network, emptyResponse)',
      () async {
        when(
          () => mockFilesApi.createUpload(
            createUploadRequest: any(named: 'createUploadRequest'),
          ),
        ).thenAnswer(
          (_) async => Response<CreateFileUploadResponse>(
            data: null,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/v1/user/files/upload'),
          ),
        );

        final failure = await expectTaskLeft(
          repo.uploadImage(bytes: [1, 2, 3], contentType: 'image/jpeg'),
        );

        expect(failure.kind, LucentFailureKind.network);
        expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
      },
    );

    test('404 Problem Details keeps code and status as a Left', () async {
      when(
        () => mockFilesApi.createUpload(
          createUploadRequest: any(named: 'createUploadRequest'),
        ),
      ).thenThrow(_problemDetails404(code: 'FILE_UPLOAD_REJECTED'));

      final failure = await expectTaskLeft(
        repo.uploadImage(bytes: [1, 2, 3], contentType: 'image/jpeg'),
      );

      expect(failure.code, 'FILE_UPLOAD_REJECTED');
      expect(failure.statusCode, 404);
      expect(failure.kind, LucentFailureKind.business);
    });

    test(
      'network timeout on presign maps to a network connectivity Left',
      () async {
        when(
          () => mockFilesApi.createUpload(
            createUploadRequest: any(named: 'createUploadRequest'),
          ),
        ).thenThrow(_connectionTimeout());

        final failure = await expectTaskLeft(
          repo.uploadImage(bytes: [1, 2, 3], contentType: 'image/jpeg'),
        );

        expect(failure.isNetworkConnectivityError, isTrue);
        expect(failure.kind, LucentFailureKind.network);
      },
    );
  });

  group('LucentScanRepository.recognizeMedicine', () {
    test('returns recognized data', () async {
      final responseData = {
        'name': '布洛芬缓释胶囊',
        'approvalNumber': '国药准字H20044321',
      };

      when(
        () => mockDio.post<Object>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response<Object>(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/medicines/recognize'),
        ),
      );

      final result = await expectTaskRight(
        repo.recognizeMedicine('https://cdn.example.com/img.jpg'),
      );

      expect(result.name, '布洛芬缓释胶囊');
      expect(result.approvalNumber, '国药准字H20044321');
    });

    test('empty response body maps to Left(network, emptyResponse)', () async {
      when(
        () => mockDio.post<Object>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response<Object>(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/medicines/recognize'),
        ),
      );

      final failure = await expectTaskLeft(
        repo.recognizeMedicine('https://cdn.example.com/img.jpg'),
      );

      expect(failure.kind, LucentFailureKind.network);
      expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
    });

    test('non-string name maps to Left(unknown) protocol violation', () async {
      when(
        () => mockDio.post<Object>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response<Object>(
          data: const {'name': 42, 'approvalNumber': 'x'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/medicines/recognize'),
        ),
      );

      final failure = await expectTaskLeft(
        repo.recognizeMedicine('https://cdn.example.com/img.jpg'),
      );

      expect(failure.kind, LucentFailureKind.unknown);
      expect(failure.cause, isA<FormatException>());
    });

    test(
      'non-string approvalNumber maps to Left(unknown) protocol violation',
      () async {
        when(
          () => mockDio.post<Object>(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Response<Object>(
            data: const {'name': '布洛芬', 'approvalNumber': 123},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/api/v1/medicines/recognize'),
          ),
        );

        final failure = await expectTaskLeft(
          repo.recognizeMedicine('https://cdn.example.com/img.jpg'),
        );

        expect(failure.kind, LucentFailureKind.unknown);
        expect(failure.cause, isA<FormatException>());
      },
    );

    test('sends imageUrl in request body', () async {
      when(
        () => mockDio.post<Object>(any(), data: any(named: 'data')),
      ).thenAnswer((invocation) async {
        final data = invocation.namedArguments[#data] as Map<String, Object?>;
        expect(data['imageUrl'], 'https://cdn.example.com/img.jpg');
        return Response<Object>(
          data: {'name': 'Test'},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/medicines/recognize'),
        );
      });

      await expectTaskRight(
        repo.recognizeMedicine('https://cdn.example.com/img.jpg'),
      );
    });

    test('404 Problem Details keeps code and status as a Left', () async {
      when(
        () => mockDio.post<Object>(any(), data: any(named: 'data')),
      ).thenThrow(_problemDetails404(code: 'RECOGNIZE_FAILED'));

      final failure = await expectTaskLeft(
        repo.recognizeMedicine('https://cdn.example.com/img.jpg'),
      );

      expect(failure.code, 'RECOGNIZE_FAILED');
      expect(failure.statusCode, 404);
      expect(failure.kind, LucentFailureKind.business);
    });

    test('network timeout maps to a network connectivity Left', () async {
      when(
        () => mockDio.post<Object>(any(), data: any(named: 'data')),
      ).thenThrow(_connectionTimeout());

      final failure = await expectTaskLeft(
        repo.recognizeMedicine('https://cdn.example.com/img.jpg'),
      );

      expect(failure.isNetworkConnectivityError, isTrue);
      expect(failure.kind, LucentFailureKind.network);
    });
  });
}
