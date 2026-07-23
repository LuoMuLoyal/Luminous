import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/features/scan/data/repositories/scan.dart';
import 'package:luminous/features/scan/domain/repositories/scan.dart';
import 'package:mocktail/mocktail.dart';

class _MockMedicinesApi extends Mock implements MedicinesApi {}

class _MockFilesApi extends Mock implements FilesApi {}

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockMedicinesApi mockApi;
  late _MockDio mockDio;
  late _MockFilesApi mockFilesApi;
  late ScanRepository repo;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
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

  group('LucentScanRepository.search', () {
    test('returns response data from API', () async {
      final items = [
        const MedicineSearchItemDto(
          id: 'med-1',
          source: MedicineSearchItemDtoSourceSource.cn,
          name: '阿莫西林胶囊',
          subtitle: '抗生素',
          summary: '用于敏感菌所致感染',
          tags: ['抗生素'],
          imageUrl: null,
          matchedBy: ['name'],
        ),
      ];
      final searchResponse = MedicineSearchResponseDto(
        code: 0,
        message: 'ok',
        data: items,
        meta: const MedicineSearchMetaDto(
          pagination: MedicinePaginationDto(
            page: 1,
            pageSize: 20,
            total: 1,
            totalPages: 1,
          ),
        ),
      );

      when(
        () => mockApi.medicinesControllerSearchV1(
          source: any(named: 'source'),
          q: any(named: 'q'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => searchResponse);

      final result = await repo.search('阿莫西林');

      expect(result, hasLength(1));
      expect(result.first.id, 'med-1');
      expect(result.first.name, '阿莫西林胶囊');
      expect(result.first.subtitle, '抗生素');

      verify(
        () => mockApi.medicinesControllerSearchV1(
          source: Source.cn,
          q: '阿莫西林',
          page: 1,
          pageSize: 20,
        ),
      ).called(1);
    });

    test('returns empty list when API returns empty data', () async {
      const emptyResponse = MedicineSearchResponseDto(
        code: 0,
        message: 'ok',
        data: [],
        meta: MedicineSearchMetaDto(
          pagination: MedicinePaginationDto(
            page: 1,
            pageSize: 20,
            total: 0,
            totalPages: 0,
          ),
        ),
      );

      when(
        () => mockApi.medicinesControllerSearchV1(
          source: any(named: 'source'),
          q: any(named: 'q'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((_) async => emptyResponse);

      final result = await repo.search('nonexistent');

      expect(result, isEmpty);
    });

    test('propagates API errors', () async {
      when(
        () => mockApi.medicinesControllerSearchV1(
          source: any(named: 'source'),
          q: any(named: 'q'),
          page: any(named: 'page'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/api/v1/medicines/search'),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(() => repo.search('test'), throwsA(isA<DioException>()));
    });
  });

  group('LucentScanRepository.uploadImage', () {
    test('returns publicUrl from presign response', () async {
      const presignData = {
        'uploadUrl': 'https://upload.example.com/presigned',
        'publicUrl': 'https://cdn.example.com/image.jpg',
        'headers': {'Content-Type': 'image/jpeg'},
      };

      when(
        () => mockDio.post<Object>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response<Object>(
          data: {'code': 0, 'message': 'ok', 'data': presignData},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/user/files/upload'),
        ),
      );

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

      final result = await repo.uploadImage(
        bytes: [1, 2, 3],
        contentType: 'image/jpeg',
      );

      expect(result, 'https://cdn.example.com/image.jpg');
    });

    test('falls back to uploadUrl when publicUrl is null', () async {
      const presignData = {
        'uploadUrl': 'https://upload.example.com/presigned',
        'headers': {},
      };

      when(
        () => mockDio.post<Object>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response<Object>(
          data: {'code': 0, 'message': 'ok', 'data': presignData},
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/user/files/upload'),
        ),
      );

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

      final result = await repo.uploadImage(
        bytes: [1, 2, 3],
        contentType: 'image/png',
      );

      expect(result, 'https://upload.example.com/presigned');
    });

    test('uses sizeBytes from parameter when provided', () async {
      when(
        () => mockDio.post<Object>(any(), data: any(named: 'data')),
      ).thenAnswer((invocation) async {
        final data = invocation.namedArguments[#data] as Map<String, Object?>;
        expect(data['sizeBytes'], 999);
        return Response<Object>(
          data: {
            'code': 0,
            'message': 'ok',
            'data': {
              'uploadUrl': 'https://upload.example.com',
              'publicUrl': 'https://cdn.example.com/img.jpg',
              'headers': {},
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/user/files/upload'),
        );
      });

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

      await repo.uploadImage(
        bytes: [1, 2, 3],
        contentType: 'image/jpeg',
        sizeBytes: 999,
      );
    });

    test('includes fileName in presign request when provided', () async {
      when(
        () => mockDio.post<Object>(any(), data: any(named: 'data')),
      ).thenAnswer((invocation) async {
        final data = invocation.namedArguments[#data] as Map<String, Object?>;
        expect(data['fileName'], 'test.jpg');
        return Response<Object>(
          data: {
            'code': 0,
            'message': 'ok',
            'data': {
              'uploadUrl': 'https://upload.example.com',
              'publicUrl': 'https://cdn.example.com/img.jpg',
              'headers': {},
            },
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/user/files/upload'),
        );
      });

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

      await repo.uploadImage(
        bytes: [1, 2, 3],
        contentType: 'image/jpeg',
        fileName: 'test.jpg',
      );
    });

    test('throws when presign response is empty', () async {
      when(
        () => mockDio.post<Object>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response<Object>(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/user/files/upload'),
        ),
      );

      expect(
        () => repo.uploadImage(bytes: [1, 2, 3], contentType: 'image/jpeg'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('LucentScanRepository.recognizeMedicine', () {
    test('returns recognized data', () async {
      final responseData = {
        'code': 0,
        'message': 'ok',
        'data': {'name': '布洛芬缓释胶囊', 'approvalNumber': '国药准字H20044321'},
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

      final result = await repo.recognizeMedicine(
        'https://cdn.example.com/img.jpg',
      );

      expect(result.name, '布洛芬缓释胶囊');
      expect(result.approvalNumber, '国药准字H20044321');
    });

    test('throws when response is empty', () async {
      when(
        () => mockDio.post<Object>(any(), data: any(named: 'data')),
      ).thenAnswer(
        (_) async => Response<Object>(
          data: null,
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/medicines/recognize'),
        ),
      );

      expect(
        () => repo.recognizeMedicine('https://cdn.example.com/img.jpg'),
        throwsA(isA<Exception>()),
      );
    });

    test('sends imageUrl in request body', () async {
      when(
        () => mockDio.post<Object>(any(), data: any(named: 'data')),
      ).thenAnswer((invocation) async {
        final data = invocation.namedArguments[#data] as Map<String, Object?>;
        expect(data['imageUrl'], 'https://cdn.example.com/img.jpg');
        return Response<Object>(
          data: {
            'code': 0,
            'message': 'ok',
            'data': {'name': 'Test'},
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/api/v1/medicines/recognize'),
        );
      });

      await repo.recognizeMedicine('https://cdn.example.com/img.jpg');
    });
  });
}
