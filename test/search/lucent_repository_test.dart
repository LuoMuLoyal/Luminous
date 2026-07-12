import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/features/search/data/datasources/medicine_search.dart';
import 'package:luminous/features/search/data/mappers/mapper.dart';
import 'package:luminous/features/search/data/repositories/lucent.dart';
import 'package:luminous/features/search/domain/entities/entities.dart';

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

MedicineSearchMetaDto _defaultMeta() => const MedicineSearchMetaDto(
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
  return MedicineSearchResponseDto(
    code: 0,
    message: '',
    data: items ?? [],
    meta: _defaultMeta(),
  );
}

MedicineDetailResponseDto _okDetailResponse({
  String name = 'Test Medicine',
  String? subtitle,
  Map<String, dynamic>? detailJson,
}) {
  return MedicineDetailResponseDto(
    code: 0,
    message: '',
    data: MedicineDetailDataDto(
      id: 'med-1',
      source: MedicineDetailDataDtoSourceSource.cn,
      name: name,
      subtitle: subtitle,
      detail: MedicineDetailDataDtoDetailDetail.fromJson(detailJson ?? {}),
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
          const MedicineSearchItemDto(
            id: 'med-1',
            source: MedicineSearchItemDtoSourceSource.cn,
            name: 'Aspirin',
            subtitle: 'Pain reliever',
            summary: 'NSAID',
            tags: ['pain', 'fever'],
            imageUrl: null,
            matchedBy: ['name'],
          ),
          const MedicineSearchItemDto(
            id: 'med-2',
            source: MedicineSearchItemDtoSourceSource.drugbank,
            name: 'Ibuprofen',
            subtitle: 'NSAID',
            summary: 'Anti-inflammatory',
            tags: [],
            imageUrl: null,
            matchedBy: ['ingredient'],
          ),
        ]);

        final results = await repo.search(
          query: 'asp',
          source: MedicineSearchSource.cn,
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

      test('returns empty list when response data is empty', () async {
        dataSource.searchResponse = _okSearchResponse([]);

        final results = await repo.search(
          query: 'nonexistent',
          source: MedicineSearchSource.cn,
        );

        expect(results, isEmpty);
      });

      test('throws on non-zero business code', () async {
        dataSource.searchResponse = MedicineSearchResponseDto(
          code: 1001,
          message: '参数错误',
          data: [],
          meta: _defaultMeta(),
        );

        expect(
          () => repo.search(query: 'test', source: MedicineSearchSource.cn),
          throwsA(isA<Exception>()),
        );
      });

      test(
        'throws with default message when response message is empty',
        () async {
          dataSource.searchResponse = MedicineSearchResponseDto(
            code: 500,
            message: '',
            data: [],
            meta: _defaultMeta(),
          );

          expect(
            () => repo.search(
              query: 'test',
              source: MedicineSearchSource.drugbank,
            ),
            throwsA(
              isA<Exception>().having(
                (e) => e.toString(),
                'toString',
                contains('500'),
              ),
            ),
          );
        },
      );

      test('passes source, query, page, pageSize to dataSource', () async {
        dataSource.searchResponse = _okSearchResponse();

        await repo.search(
          query: 'ibuprofen',
          source: MedicineSearchSource.drugbank,
          page: 2,
          pageSize: 50,
        );

        expect(dataSource.lastSearchSource, 'drugbank');
        expect(dataSource.lastSearchQuery, 'ibuprofen');
        expect(dataSource.lastSearchPage, 2);
        expect(dataSource.lastSearchPageSize, 50);
      });

      test('passes source name correctly for cn', () async {
        dataSource.searchResponse = _okSearchResponse();

        await repo.search(query: 'test', source: MedicineSearchSource.cn);

        expect(dataSource.lastSearchSource, 'cn');
      });

      test('uses default page and pageSize when not specified', () async {
        dataSource.searchResponse = _okSearchResponse();

        await repo.search(query: 'test', source: MedicineSearchSource.cn);

        expect(dataSource.lastSearchPage, 1);
        expect(dataSource.lastSearchPageSize, 20);
      });

      test('propagates dataSource errors', () async {
        dataSource.searchError = Exception('Network error');

        expect(
          () => repo.search(query: 'test', source: MedicineSearchSource.cn),
          throwsException,
        );
      });

      test('maps subtitle to empty string when null', () async {
        dataSource.searchResponse = _okSearchResponse([
          const MedicineSearchItemDto(
            id: 'med-1',
            source: MedicineSearchItemDtoSourceSource.cn,
            name: 'Test',
            subtitle: null,
            summary: null,
            tags: [],
            imageUrl: null,
            matchedBy: [],
          ),
        ]);

        final results = await repo.search(
          query: '',
          source: MedicineSearchSource.cn,
        );

        expect(results.first.subtitle, '');
        expect(results.first.summary, '');
      });
    });

    // ─── fetchDetail ─────────────────────────────────────────────────
    group('fetchDetail', () {
      test('returns MedicineSearchSafetyPreview on success', () async {
        dataSource.detailResponse = _okDetailResponse(
          name: 'Aspirin',
          subtitle: 'Pain reliever\nFever reducer',
        );

        final result = await repo.fetchDetail('med-1', MedicineSearchSource.cn);

        expect(result, isNotNull);
        expect(result!.title, 'Aspirin');
        expect(result.conditions, hasLength(2));
        expect(result.conditions[0], 'Pain reliever');
        expect(result.conditions[1], 'Fever reducer');
        expect(result.checklist, isEmpty);
      });

      test('returns null on non-zero business code', () async {
        dataSource.detailResponse = const MedicineDetailResponseDto(
          code: 1002,
          message: 'Not found',
          data: MedicineDetailDataDto(
            id: 'med-x',
            source: MedicineDetailDataDtoSourceSource.cn,
            name: '',
            subtitle: null,
            detail: MedicineDetailDataDtoDetailDetail({}),
          ),
        );

        final result = await repo.fetchDetail('med-x', MedicineSearchSource.cn);

        expect(result, isNull);
      });

      test('returns null when dataSource throws', () async {
        dataSource.detailError = Exception('Network error');

        final result = await repo.fetchDetail('med-1', MedicineSearchSource.cn);

        expect(result, isNull);
      });

      test('returns empty conditions when subtitle is null', () async {
        dataSource.detailResponse = _okDetailResponse(subtitle: null);

        final result = await repo.fetchDetail('med-1', MedicineSearchSource.cn);

        expect(result, isNotNull);
        expect(result!.conditions, isEmpty);
      });

      test('returns single empty condition when subtitle is empty', () async {
        dataSource.detailResponse = _okDetailResponse(subtitle: '');

        final result = await repo.fetchDetail('med-1', MedicineSearchSource.cn);

        expect(result, isNotNull);
        // ''.split('\n') produces [''] (a list with one empty string)
        expect(result!.conditions, hasLength(1));
        expect(result.conditions.first, isEmpty);
      });

      test('passes id and source name to dataSource', () async {
        dataSource.detailResponse = _okDetailResponse();

        await repo.fetchDetail('med-42', MedicineSearchSource.drugbank);

        expect(dataSource.lastDetailId, 'med-42');
        expect(dataSource.lastDetailSource, 'drugbank');
      });

      test('handles single-line subtitle', () async {
        dataSource.detailResponse = _okDetailResponse(
          subtitle: 'Single line subtitle',
        );

        final result = await repo.fetchDetail('med-1', MedicineSearchSource.cn);

        expect(result, isNotNull);
        expect(result!.conditions, hasLength(1));
        expect(result.conditions.first, 'Single line subtitle');
      });

      test('handles multi-line subtitle with empty lines', () async {
        dataSource.detailResponse = _okDetailResponse(
          subtitle: 'Line 1\n\nLine 2',
        );

        final result = await repo.fetchDetail('med-1', MedicineSearchSource.cn);

        expect(result, isNotNull);
        expect(result!.conditions, hasLength(3));
      });
    });
  });
}
