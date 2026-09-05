import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/legal/data/repositories/lucent.dart';
import 'package:luminous/features/legal/domain/entities/doc_type.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/task_either.dart';

class _MockLegalDocumentsApi extends Mock implements LegalDocumentsApi {}

/// A network-class error without a response (no HTTP status).
DioException _networkException() {
  return DioException(requestOptions: RequestOptions(path: '/test'));
}

/// An RFC 9457 Problem Details body served with
/// `application/problem+json` (server business failure).
DioException _problemDetails({required int statusCode, required String code}) {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/legal-documents'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/api/v1/legal-documents'),
      statusCode: statusCode,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['application/problem+json'],
      }),
      data: {
        'type': 'https://api.lumos.example/problems/$code',
        'title': 'Legal error',
        'detail': '法律文档请求失败',
        'code': code,
      },
    ),
  );
}

/// A 500 error body served as `text/html` — not Problem Details (protocol
/// invariant violation) — so `.run()` propagates `FormatException`.
DioException _nonProblemHtml500() {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/legal-documents'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/api/v1/legal-documents'),
      statusCode: 500,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['text/html'],
      }),
      data: '<html><body>Internal Server Error</body></html>',
    ),
  );
}

Response<T> _response<T>(T data) => Response<T>(
  data: data,
  requestOptions: RequestOptions(path: ''),
  statusCode: 200,
);

void main() {
  group('LucentLegalRepository', () {
    late _MockLegalDocumentsApi api;
    late LucentLegalRepository repo;

    setUp(() {
      api = _MockLegalDocumentsApi();
      repo = LucentLegalRepository(api: api, localeResolver: () => 'zh');
    });

    group('findAll', () {
      test('maps API items to LegalDocumentSummary list as Right', () async {
        final response = _response(
          LegalDocumentListResponse(
            items: [
              LegalDocumentListResponseItems(
                docType: 'terms',
                title: '服务条款',
                updatedAt: '2026-07-01T00:00:00Z',
              ),
              LegalDocumentListResponseItems(
                docType: 'privacy',
                title: '隐私政策',
                updatedAt: '2026-07-02T00:00:00Z',
              ),
            ],
            updatedAt: '2026-07-02T00:00:00Z',
          ),
        );

        when(
          () => api.listLegalDocuments(lang: any(named: 'lang')),
        ).thenAnswer((_) async => response);

        final result = await expectTaskRight(repo.findAll());

        expect(result, hasLength(2));
        expect(result[0].docType, LegalDocType.terms);
        expect(result[0].title, '服务条款');
        expect(result[0].updatedAt, '2026-07-01T00:00:00Z');
        expect(result[1].docType, LegalDocType.privacy);
        expect(result[1].title, '隐私政策');
      });

      test('defaults to terms for unknown docType', () async {
        final response = _response(
          LegalDocumentListResponse(
            items: [
              LegalDocumentListResponseItems(
                docType: 'unknown-type',
                title: 'Unknown',
                updatedAt: '',
              ),
            ],
            updatedAt: '',
          ),
        );

        when(
          () => api.listLegalDocuments(lang: any(named: 'lang')),
        ).thenAnswer((_) async => response);

        final result = await expectTaskRight(repo.findAll());

        expect(result, hasLength(1));
        expect(result[0].docType, LegalDocType.terms);
      });

      test('returns empty list when API returns no items', () async {
        final response = _response(
          LegalDocumentListResponse(items: [], updatedAt: ''),
        );

        when(
          () => api.listLegalDocuments(lang: any(named: 'lang')),
        ).thenAnswer((_) async => response);

        final result = await expectTaskRight(repo.findAll());

        expect(result, isEmpty);
      });

      test('maps a network error to Left(network)', () async {
        when(
          () => api.listLegalDocuments(lang: any(named: 'lang')),
        ).thenThrow(_networkException());

        final failure = await expectTaskLeft(repo.findAll());
        expect(failure.kind, LucentFailureKind.network);
      });

      test('keeps 500 Problem Details code/status as Left(server)', () async {
        when(
          () => api.listLegalDocuments(lang: any(named: 'lang')),
        ).thenThrow(_problemDetails(statusCode: 500, code: 'LEGAL_SERVER_ERR'));

        final failure = await expectTaskLeft(repo.findAll());
        expect(failure.kind, LucentFailureKind.server);
        expect(failure.code, 'LEGAL_SERVER_ERR');
        expect(failure.statusCode, 500);
      });

      test(
        'keeps 403 Problem Details code/status as Left(authentication)',
        () async {
          when(
            () =>
                api.listLegalDocuments(lang: any(named: 'lang')),
          ).thenThrow(
            _problemDetails(statusCode: 403, code: 'LEGAL_FORBIDDEN'),
          );

          // 403 按共享失败模型归 authentication（401/403 同档），但仍是 Left、
          // code/status 保留，不被 404 fallback 吞掉。
          final failure = await expectTaskLeft(repo.findAll());
          expect(failure.kind, LucentFailureKind.authentication);
          expect(failure.code, 'LEGAL_FORBIDDEN');
          expect(failure.statusCode, 403);
        },
      );

      test('non-Problem Details error body propagates FormatException '
          'from run()', () async {
        when(
          () => api.listLegalDocuments(lang: any(named: 'lang')),
        ).thenThrow(_nonProblemHtml500());

        // 协议违反（500 + text/html 而非 problem+json）保持 mapper 抛出的
        // FormatException 从 .run() 传播，而不是映射成 Left。
        await expectLater(
          repo.findAll().run(),
          throwsA(isA<FormatException>()),
        );
      });

      test('empty success body is Left(network/emptyResponse)', () async {
        when(
          () => api.listLegalDocuments(lang: any(named: 'lang')),
        ).thenAnswer(
          (_) async => Response<LegalDocumentListResponse>(
            data: null,
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ),
        );

        final failure = await expectTaskLeft(repo.findAll());
        expect(failure.kind, LucentFailureKind.network);
        expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
      });

      test(
        'maps an unexpected exception to Left(unknown) with cause',
        () async {
          when(
            () =>
                api.listLegalDocuments(lang: any(named: 'lang')),
          ).thenThrow(StateError('boom'));

          final failure = await expectTaskLeft(repo.findAll());
          expect(failure.kind, LucentFailureKind.unknown);
          expect(failure.cause, isA<StateError>());
        },
      );

      test('uses localeResolver for lang parameter', () async {
        var resolvedLang = 'zh';
        repo = LucentLegalRepository(
          api: api,
          localeResolver: () => resolvedLang,
        );

        final response = _response(
          LegalDocumentListResponse(items: [], updatedAt: ''),
        );

        when(
          () => api.listLegalDocuments(lang: any(named: 'lang')),
        ).thenAnswer((_) async => response);

        resolvedLang = 'en';
        await repo.findAll().run();

        verify(
          () => api.listLegalDocuments(lang: 'en'),
        ).called(1);
      });
    });

    group('findOne', () {
      test('maps API response to LegalDocument as Right', () async {
        final response = _response(
          LegalDocumentDetailResponse(
            docType: 'terms',
            title: '服务条款',
            content: '# 服务条款\n\n正文内容',
            updatedAt: '2026-07-01T00:00:00Z',
          ),
        );

        when(
          () => api.getLegalDocument(
            docType: any(named: 'docType'),
            lang: any(named: 'lang'),
          ),
        ).thenAnswer((_) async => response);

        final result = await expectTaskRight(repo.findOne(LegalDocType.terms));

        expect(result.docType, LegalDocType.terms);
        expect(result.title, '服务条款');
        expect(result.content, '# 服务条款\n\n正文内容');
        expect(result.updatedAt, '2026-07-01T00:00:00Z');
      });

      test('passes correct pathSegment for each docType', () async {
        for (final type in LegalDocType.values) {
          final response = _response(
            LegalDocumentDetailResponse(
              docType: type.pathSegment,
              title: 'T',
              content: 'C',
              updatedAt: '',
            ),
          );

          when(
            () => api.getLegalDocument(
              docType: any(named: 'docType'),
              lang: any(named: 'lang'),
            ),
          ).thenAnswer((_) async => response);

          await expectTaskRight(repo.findOne(type));

          verify(
            () => api.getLegalDocument(
              docType: type.pathSegment,
              lang: any(named: 'lang'),
            ),
          ).called(1);

          reset(api);
        }
      });

      test('maps a network error to Left(network)', () async {
        when(
          () => api.getLegalDocument(
            docType: any(named: 'docType'),
            lang: any(named: 'lang'),
          ),
        ).thenThrow(_networkException());

        final failure = await expectTaskLeft(
          repo.findOne(LegalDocType.privacy),
        );
        expect(failure.kind, LucentFailureKind.network);
      });

      test('keeps 500 Problem Details code/status as Left(server)', () async {
        when(
          () => api.getLegalDocument(
            docType: any(named: 'docType'),
            lang: any(named: 'lang'),
          ),
        ).thenThrow(_problemDetails(statusCode: 500, code: 'LEGAL_SERVER_ERR'));

        final failure = await expectTaskLeft(
          repo.findOne(LegalDocType.privacy),
        );
        expect(failure.kind, LucentFailureKind.server);
        expect(failure.code, 'LEGAL_SERVER_ERR');
        expect(failure.statusCode, 500);
      });

      test('empty success body is Left(network/emptyResponse)', () async {
        when(
          () => api.getLegalDocument(
            docType: any(named: 'docType'),
            lang: any(named: 'lang'),
          ),
        ).thenAnswer(
          (_) async => Response<LegalDocumentDetailResponse>(
            data: null,
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ),
        );

        final failure = await expectTaskLeft(repo.findOne(LegalDocType.terms));
        expect(failure.kind, LucentFailureKind.network);
        expect(failure.networkErrorCode, NetworkErrorCode.emptyResponse);
      });
    });

    group('404 fallback (documented product contract)', () {
      test('findAll falls back to bundled assets on 404', () async {
        // The test environment has no real asset bundle, so rootBundle
        // will throw. The fallback catches this per document and returns
        // whatever assets loaded — here an empty Right list.
        when(
          () => api.listLegalDocuments(lang: any(named: 'lang')),
        ).thenThrow(_problemDetails(statusCode: 404, code: 'LEGAL_NOT_FOUND'));

        final result = await expectTaskRight(repo.findAll());

        // Assets aren't loaded in unit tests, so fallback returns empty list.
        expect(result, isEmpty);
      });

      test('findOne 404 with missing bundled asset is Left(unknown)', () async {
        when(
          () => api.getLegalDocument(
            docType: any(named: 'docType'),
            lang: any(named: 'lang'),
          ),
        ).thenThrow(_problemDetails(statusCode: 404, code: 'LEGAL_NOT_FOUND'));

        // In unit tests rootBundle.loadString fails because the binding
        // is not initialized → the missing fallback asset surfaces as a
        // Left(unknown) with the original cause preserved.
        final failure = await expectTaskLeft(repo.findOne(LegalDocType.terms));
        expect(failure.kind, LucentFailureKind.unknown);
        expect(failure.cause, isNotNull);
      });
    });
  });

  group('LucentLegalRepository — English locale', () {
    late _MockLegalDocumentsApi api;
    late LucentLegalRepository repo;

    setUp(() {
      api = _MockLegalDocumentsApi();
      repo = LucentLegalRepository(api: api, localeResolver: () => 'en');
    });

    test("passes 'en' to findAll", () async {
      final response = _response(
        LegalDocumentListResponse(items: [], updatedAt: ''),
      );

      when(
        () => api.listLegalDocuments(lang: any(named: 'lang')),
      ).thenAnswer((_) async => response);

      await expectTaskRight(repo.findAll());

      verify(() => api.listLegalDocuments(lang: 'en')).called(1);
    });

    test("passes 'en' to findOne", () async {
      final response = _response(
        LegalDocumentDetailResponse(
          docType: 'privacy',
          title: 'Privacy Policy',
          content: '# Privacy',
          updatedAt: '',
        ),
      );

      when(
        () => api.getLegalDocument(
          docType: any(named: 'docType'),
          lang: any(named: 'lang'),
        ),
      ).thenAnswer((_) async => response);

      await expectTaskRight(repo.findOne(LegalDocType.privacy));

      verify(
        () => api.getLegalDocument(
          docType: 'privacy',
          lang: 'en',
        ),
      ).called(1);
    });
  });
}
