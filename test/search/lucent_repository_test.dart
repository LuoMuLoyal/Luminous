import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/features/search/data/datasources/medicine_search.dart';
import 'package:luminous/features/search/data/mappers/medicine_search.dart';
import 'package:luminous/features/search/data/repositories/lucent.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';

import '../helpers/task_either.dart';

class _FakeSearchDataSource implements MedicineSearchRemoteDataSource {
  _FakeSearchDataSource();

  MedicineSearchResponseDto? searchResponse;
  MedicineDetailResponseDto? detailResponse;
  Object? searchError;
  Object? detailError;
  String? lastSearchQuery;
  String? lastSearchSource;
  int? lastSearchPage;
  int? lastSearchPageSize;
  String? lastDetailId;
  String? lastDetailSource;

  @override
  Future<MedicineSearchResponseDto> search({
    required String source,
    String? query,
    int page = 1,
    int pageSize = 20,
  }) async {
    lastSearchSource = source;
    lastSearchQuery = query;
    lastSearchPage = page;
    lastSearchPageSize = pageSize;
    if (searchError != null) throw searchError!;
    return searchResponse!;
  }

  @override
  Future<MedicineDetailResponseDto> getDetail({
    required String id,
    required String source,
  }) async {
    lastDetailId = id;
    lastDetailSource = source;
    if (detailError != null) throw detailError!;
    return detailResponse!;
  }
}

MedicineSearchResponseDto _defaultData([List<MedicineSearchItemDto>? items]) =>
    MedicineSearchResponseDto(
      items: items ?? [],
      pagination: MedicinePaginationDto(
        page: 1,
        pageSize: 20,
        total: 0,
        totalPages: 0,
      ),
    );

MedicineSearchResponseDto _okSearchResponse([
  List<MedicineSearchItemDto>? items,
]) {
  return _defaultData(items);
}

MedicineDetailResponseDtoDetail _minimalDetail() =>
    MedicineDetailResponseDtoDetail(
      kind: '',
      groups: [],
      categories: [],
      atcCodes: [],
      synonyms: [],
      foodInteractions: [],
    );

MedicineDetailResponseDto _okDetailResponse({
  String name = 'Test Medicine',
  String? subtitle,
}) {
  return MedicineDetailResponseDto(
    id: 'med-1',
    source_: MedicineDetailResponseDtoSource_Enum.cn,
    name: name,
    subtitle: subtitle,
    detail: _minimalDetail(),
  );
}

/// A 404 Problem Details body served with `application/problem+json`.
DioException _problemDetails404({String code = 'MEDICINE_NOT_FOUND'}) {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/medicines/med-1'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/api/v1/medicines/med-1'),
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
    requestOptions: RequestOptions(path: '/api/v1/medicines'),
    type: DioExceptionType.connectionTimeout,
  );
}

/// A 400 body that is not Problem Details (protocol invariant violation).
DioException _nonProblemBody400() {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/medicines'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/api/v1/medicines'),
      statusCode: 400,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['application/json'],
      }),
      data: {'error': 'oops'},
    ),
  );
}

void main() {
  group('LucentMedicineSearchRepository', () {
    late _FakeSearchDataSource dataSource;
    late MedicineSearchMapper mapper;
    late LucentMedicineSearchRepository repo;

    setUp(() {
      dataSource = _FakeSearchDataSource();
      mapper = MedicineSearchMapper();
      repo = LucentMedicineSearchRepository(
        dataSource: dataSource,
        mapper: mapper,
      );
    });

    // ─── search ──────────────────────────────────────────────────────
    group('search', () {
      test('returns mapped results on success', () async {
        dataSource.searchResponse = _okSearchResponse([
          MedicineSearchItemDto(
            id: 'med-1',
            source_: MedicineSearchItemDtoSource_Enum.cn,
            name: 'Aspirin',
            subtitle: 'Pain reliever',
            summary: 'NSAID',
            tags: ['pain', 'fever'],
            imageUrl: null,
            matchedBy: ['name'],
          ),
          MedicineSearchItemDto(
            id: 'med-2',
            source_: MedicineSearchItemDtoSource_Enum.drugbank,
            name: 'Ibuprofen',
            subtitle: 'NSAID',
            summary: 'Anti-inflammatory',
            tags: [],
            imageUrl: null,
            matchedBy: ['ingredient'],
          ),
        ]);

        final results = await expectTaskRight(
          repo.search(query: 'asp', source: MedicineSearchSource.cn),
        );

        expect(results, hasLength(2));
        expect(results[0].id, 'med-1');
        expect(results[0].name, 'Aspirin');
        expect(results[0].source, MedicineSearchSource.cn);
        expect(results[0].matchType, MedicineSearchMatchType.name);

        expect(results[1].id, 'med-2');
        expect(results[1].source, MedicineSearchSource.drugbank);
        expect(results[1].matchType, MedicineSearchMatchType.ingredient);
      });

      test(
        'returns empty list as a legal Right when no candidates match',
        () async {
          dataSource.searchResponse = _okSearchResponse([]);

          final results = await expectTaskRight(
            repo.search(query: 'nonexistent', source: MedicineSearchSource.cn),
          );

          expect(results, isEmpty);
        },
      );

      test('passes source, query, page, pageSize to dataSource', () async {
        dataSource.searchResponse = _okSearchResponse();

        await expectTaskRight(
          repo.search(
            query: 'ibuprofen',
            source: MedicineSearchSource.drugbank,
            page: 2,
            pageSize: 50,
          ),
        );

        expect(dataSource.lastSearchSource, 'drugbank');
        expect(dataSource.lastSearchQuery, 'ibuprofen');
        expect(dataSource.lastSearchPage, 2);
        expect(dataSource.lastSearchPageSize, 50);
      });

      test('passes source name correctly for cn', () async {
        dataSource.searchResponse = _okSearchResponse();

        await expectTaskRight(
          repo.search(query: 'test', source: MedicineSearchSource.cn),
        );

        expect(dataSource.lastSearchSource, 'cn');
      });

      test('uses default page and pageSize when not specified', () async {
        dataSource.searchResponse = _okSearchResponse();

        await expectTaskRight(
          repo.search(query: 'test', source: MedicineSearchSource.cn),
        );

        expect(dataSource.lastSearchPage, 1);
        expect(dataSource.lastSearchPageSize, 20);
      });

      test('maps subtitle to empty string when null', () async {
        dataSource.searchResponse = _okSearchResponse([
          MedicineSearchItemDto(
            id: 'med-1',
            source_: MedicineSearchItemDtoSource_Enum.cn,
            name: 'Test',
            subtitle: null,
            summary: null,
            tags: [],
            imageUrl: null,
            matchedBy: [],
          ),
        ]);

        final results = await expectTaskRight(
          repo.search(query: '', source: MedicineSearchSource.cn),
        );

        expect(results.first.subtitle, '');
        expect(results.first.summary, '');
      });
    });

    // ─── search failure branches ─────────────────────────────────────
    group('search failure branches', () {
      test('404 Problem Details keeps code and status as a Left', () async {
        dataSource.searchError = _problemDetails404(code: 'MEDICINE_NOT_FOUND');

        final failure = await expectTaskLeft(
          repo.search(query: 'x', source: MedicineSearchSource.cn),
        );

        expect(failure.code, 'MEDICINE_NOT_FOUND');
        expect(failure.statusCode, 404);
        expect(failure.kind, LucentFailureKind.business);
      });

      test('network timeout maps to a network connectivity Left', () async {
        dataSource.searchError = _connectionTimeout();

        final failure = await expectTaskLeft(
          repo.search(query: 'x', source: MedicineSearchSource.cn),
        );

        expect(failure.isNetworkConnectivityError, isTrue);
        expect(failure.kind, LucentFailureKind.network);
      });

      test(
        'non-Problem Details error body propagates FormatException from run()',
        () async {
          dataSource.searchError = _nonProblemBody400();

          await expectLater(
            repo.search(query: 'x', source: MedicineSearchSource.cn).run(),
            throwsA(isA<FormatException>()),
          );
        },
      );

      test('plain unexpected exception maps to a Left(unknown)', () async {
        dataSource.searchError = Exception('unexpected');

        final failure = await expectTaskLeft(
          repo.search(query: 'x', source: MedicineSearchSource.cn),
        );

        expect(failure.kind, LucentFailureKind.unknown);
      });
    });

    // ─── fetchDetail ─────────────────────────────────────────────────
    group('fetchDetail', () {
      test('returns MedicineSearchSafetyPreview on success', () async {
        dataSource.detailResponse = _okDetailResponse(
          name: 'Aspirin',
          subtitle: 'Pain reliever\nFever reducer',
        );

        final result = await expectTaskRight(
          repo.fetchDetail('med-1', MedicineSearchSource.cn),
        );

        expect(result, isNotNull);
        expect(result!.title, 'Aspirin');
        expect(result.conditions, hasLength(2));
        expect(result.conditions[0], 'Pain reliever');
        expect(result.conditions[1], 'Fever reducer');
        expect(result.checklist, isEmpty);
      });

      test('returns empty conditions when subtitle is null', () async {
        dataSource.detailResponse = _okDetailResponse(subtitle: null);

        final result = await expectTaskRight(
          repo.fetchDetail('med-1', MedicineSearchSource.cn),
        );

        expect(result, isNotNull);
        expect(result!.conditions, isEmpty);
      });

      test('returns single empty condition when subtitle is empty', () async {
        dataSource.detailResponse = _okDetailResponse(subtitle: '');

        final result = await expectTaskRight(
          repo.fetchDetail('med-1', MedicineSearchSource.cn),
        );

        expect(result, isNotNull);
        // ''.split('\n') produces [''] (a list with one empty string)
        expect(result!.conditions, hasLength(1));
        expect(result.conditions.first, isEmpty);
      });

      test('passes id and source name to dataSource', () async {
        dataSource.detailResponse = _okDetailResponse();

        await expectTaskRight(
          repo.fetchDetail('med-42', MedicineSearchSource.drugbank),
        );

        expect(dataSource.lastDetailId, 'med-42');
        expect(dataSource.lastDetailSource, 'drugbank');
      });

      test('handles single-line subtitle', () async {
        dataSource.detailResponse = _okDetailResponse(
          subtitle: 'Single line subtitle',
        );

        final result = await expectTaskRight(
          repo.fetchDetail('med-1', MedicineSearchSource.cn),
        );

        expect(result, isNotNull);
        expect(result!.conditions, hasLength(1));
        expect(result.conditions.first, 'Single line subtitle');
      });

      test('handles multi-line subtitle with empty lines', () async {
        dataSource.detailResponse = _okDetailResponse(
          subtitle: 'Line 1\n\nLine 2',
        );

        final result = await expectTaskRight(
          repo.fetchDetail('med-1', MedicineSearchSource.cn),
        );

        expect(result, isNotNull);
        expect(result!.conditions, hasLength(3));
      });
    });

    // ─── fetchDetail failure branches ────────────────────────────────
    group('fetchDetail failure branches', () {
      test('404 Problem Details is a Left, not a swallowed null', () async {
        dataSource.detailError = _problemDetails404(code: 'MEDICINE_NOT_FOUND');

        final failure = await expectTaskLeft(
          repo.fetchDetail('med-missing', MedicineSearchSource.cn),
        );

        expect(failure.code, 'MEDICINE_NOT_FOUND');
        expect(failure.statusCode, 404);
        expect(failure.kind, LucentFailureKind.business);
      });

      test('network timeout maps to a network connectivity Left', () async {
        dataSource.detailError = _connectionTimeout();

        final failure = await expectTaskLeft(
          repo.fetchDetail('med-1', MedicineSearchSource.cn),
        );

        expect(failure.isNetworkConnectivityError, isTrue);
        expect(failure.kind, LucentFailureKind.network);
      });

      test(
        'non-Problem Details error body propagates FormatException from run()',
        () async {
          dataSource.detailError = _nonProblemBody400();

          await expectLater(
            repo.fetchDetail('med-1', MedicineSearchSource.cn).run(),
            throwsA(isA<FormatException>()),
          );
        },
      );

      test('plain unexpected exception maps to a Left(unknown)', () async {
        dataSource.detailError = Exception('unexpected');

        final failure = await expectTaskLeft(
          repo.fetchDetail('med-1', MedicineSearchSource.cn),
        );

        expect(failure.kind, LucentFailureKind.unknown);
      });
    });
  });
}
