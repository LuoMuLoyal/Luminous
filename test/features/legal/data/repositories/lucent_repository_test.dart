import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/api/export.dart';
import 'package:luminous/features/legal/data/repositories/lucent.dart';
import 'package:luminous/features/legal/domain/entities/legal_doc_type.dart';
import 'package:mocktail/mocktail.dart';

class _MockLegalDocumentsApi extends Mock implements LegalDocumentsApi {}

DioException _dioException({int? statusCode}) {
  return DioException(
    requestOptions: RequestOptions(path: '/test'),
    response: statusCode != null
        ? Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: statusCode,
          )
        : null,
  );
}

void main() {
  group('LucentLegalRepository', () {
    late _MockLegalDocumentsApi api;
    late LucentLegalRepository repo;

    setUp(() {
      api = _MockLegalDocumentsApi();
      repo = LucentLegalRepository(api: api, localeResolver: () => Lang.zh);
    });

    group('findAll', () {
      test('maps API items to LegalDocumentSummary list', () async {
        final response = const LegalDocumentListResponseDto(
          code: 0,
          message: 'ok',
          data: LegalDocumentListDataDto(
            items: [
              LegalDocumentListItemDto(
                docType: 'terms',
                title: '服务条款',
                updatedAt: '2026-07-01T00:00:00Z',
              ),
              LegalDocumentListItemDto(
                docType: 'privacy',
                title: '隐私政策',
                updatedAt: '2026-07-02T00:00:00Z',
              ),
            ],
            updatedAt: '2026-07-02T00:00:00Z',
          ),
        );

        when(
          () => api.legalDocumentsControllerFindAllV1(lang: any(named: 'lang')),
        ).thenAnswer((_) async => response);

        final result = await repo.findAll();

        expect(result, hasLength(2));
        expect(result[0].docType, LegalDocType.terms);
        expect(result[0].title, '服务条款');
        expect(result[0].updatedAt, '2026-07-01T00:00:00Z');
        expect(result[1].docType, LegalDocType.privacy);
        expect(result[1].title, '隐私政策');
      });

      test('defaults to terms for unknown docType', () async {
        final response = const LegalDocumentListResponseDto(
          code: 0,
          message: 'ok',
          data: LegalDocumentListDataDto(
            items: [
              LegalDocumentListItemDto(
                docType: 'unknown-type',
                title: 'Unknown',
                updatedAt: '',
              ),
            ],
            updatedAt: '',
          ),
        );

        when(
          () => api.legalDocumentsControllerFindAllV1(lang: any(named: 'lang')),
        ).thenAnswer((_) async => response);

        final result = await repo.findAll();

        expect(result, hasLength(1));
        expect(result[0].docType, LegalDocType.terms);
      });

      test('returns empty list when API returns no items', () async {
        final response = const LegalDocumentListResponseDto(
          code: 0,
          message: 'ok',
          data: LegalDocumentListDataDto(items: [], updatedAt: ''),
        );

        when(
          () => api.legalDocumentsControllerFindAllV1(lang: any(named: 'lang')),
        ).thenAnswer((_) async => response);

        final result = await repo.findAll();

        expect(result, isEmpty);
      });

      test('rethrows non-404 DioException', () async {
        when(
          () => api.legalDocumentsControllerFindAllV1(lang: any(named: 'lang')),
        ).thenThrow(_dioException(statusCode: 500));

        expect(() => repo.findAll(), throwsA(isA<DioException>()));
      });

      test('rethrows non-DioException', () async {
        when(
          () => api.legalDocumentsControllerFindAllV1(lang: any(named: 'lang')),
        ).thenThrow(Exception('unexpected'));

        expect(() => repo.findAll(), throwsA(isA<Exception>()));
      });

      test('uses localeResolver for lang parameter', () async {
        var resolvedLang = Lang.zh;
        repo = LucentLegalRepository(
          api: api,
          localeResolver: () => resolvedLang,
        );

        final response = const LegalDocumentListResponseDto(
          code: 0,
          message: 'ok',
          data: LegalDocumentListDataDto(items: [], updatedAt: ''),
        );

        when(
          () => api.legalDocumentsControllerFindAllV1(lang: any(named: 'lang')),
        ).thenAnswer((_) async => response);

        resolvedLang = Lang.en;
        await repo.findAll();

        verify(
          () => api.legalDocumentsControllerFindAllV1(lang: Lang.en),
        ).called(1);
      });
    });

    group('findOne', () {
      test('maps API response to LegalDocument', () async {
        final response = const LegalDocumentDetailResponseDto(
          code: 0,
          message: 'ok',
          data: LegalDocumentDetailDto(
            docType: 'terms',
            title: '服务条款',
            content: '# 服务条款\n\n正文内容',
            updatedAt: '2026-07-01T00:00:00Z',
          ),
        );

        when(
          () => api.legalDocumentsControllerFindOneV1(
            docType: any(named: 'docType'),
            lang: any(named: 'lang'),
          ),
        ).thenAnswer((_) async => response);

        final result = await repo.findOne(LegalDocType.terms);

        expect(result.docType, LegalDocType.terms);
        expect(result.title, '服务条款');
        expect(result.content, '# 服务条款\n\n正文内容');
        expect(result.updatedAt, '2026-07-01T00:00:00Z');
      });

      test('passes correct pathSegment for each docType', () async {
        for (final type in LegalDocType.values) {
          final response = LegalDocumentDetailResponseDto(
            code: 0,
            message: 'ok',
            data: LegalDocumentDetailDto(
              docType: type.pathSegment,
              title: 'T',
              content: 'C',
              updatedAt: '',
            ),
          );

          when(
            () => api.legalDocumentsControllerFindOneV1(
              docType: any(named: 'docType'),
              lang: any(named: 'lang'),
            ),
          ).thenAnswer((_) async => response);

          await repo.findOne(type);

          verify(
            () => api.legalDocumentsControllerFindOneV1(
              docType: type.pathSegment,
              lang: any(named: 'lang'),
            ),
          ).called(1);

          reset(api);
        }
      });

      test('rethrows non-404 DioException', () async {
        when(
          () => api.legalDocumentsControllerFindOneV1(
            docType: any(named: 'docType'),
            lang: any(named: 'lang'),
          ),
        ).thenThrow(_dioException(statusCode: 403));

        expect(
          () => repo.findOne(LegalDocType.privacy),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('404 fallback', () {
      test('findAll falls back to bundled assets on 404', () async {
        // The test environment has no real asset bundle, so rootBundle
        // will throw. The fallback catches this and returns an empty list.
        when(
          () => api.legalDocumentsControllerFindAllV1(lang: any(named: 'lang')),
        ).thenThrow(_dioException(statusCode: 404));

        final result = await repo.findAll();

        // Assets aren't loaded in unit tests, so fallback returns empty list.
        expect(result, isEmpty);
      });

      test('findOne throws on 404 when asset is not found', () async {
        when(
          () => api.legalDocumentsControllerFindOneV1(
            docType: any(named: 'docType'),
            lang: any(named: 'lang'),
          ),
        ).thenThrow(_dioException(statusCode: 404));

        // In unit tests rootBundle.loadString fails because the binding
        // is not initialized → exception propagates.
        expect(() => repo.findOne(LegalDocType.terms), throwsA(isA<Object>()));
      });
    });
  });

  group('LucentLegalRepository — English locale', () {
    late _MockLegalDocumentsApi api;
    late LucentLegalRepository repo;

    setUp(() {
      api = _MockLegalDocumentsApi();
      repo = LucentLegalRepository(api: api, localeResolver: () => Lang.en);
    });

    test('passes Lang.en to findAll', () async {
      final response = const LegalDocumentListResponseDto(
        code: 0,
        message: 'ok',
        data: LegalDocumentListDataDto(items: [], updatedAt: ''),
      );

      when(
        () => api.legalDocumentsControllerFindAllV1(lang: any(named: 'lang')),
      ).thenAnswer((_) async => response);

      await repo.findAll();

      verify(
        () => api.legalDocumentsControllerFindAllV1(lang: Lang.en),
      ).called(1);
    });

    test('passes Lang.en to findOne', () async {
      final response = const LegalDocumentDetailResponseDto(
        code: 0,
        message: 'ok',
        data: LegalDocumentDetailDto(
          docType: 'privacy',
          title: 'Privacy Policy',
          content: '# Privacy',
          updatedAt: '',
        ),
      );

      when(
        () => api.legalDocumentsControllerFindOneV1(
          docType: any(named: 'docType'),
          lang: any(named: 'lang'),
        ),
      ).thenAnswer((_) async => response);

      await repo.findOne(LegalDocType.privacy);

      verify(
        () => api.legalDocumentsControllerFindOneV1(
          docType: 'privacy',
          lang: Lang.en,
        ),
      ).called(1);
    });
  });
}
