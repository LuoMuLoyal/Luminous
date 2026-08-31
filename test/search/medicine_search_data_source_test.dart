import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/search/data/datasources/medicine_search.dart';

/// Adapter that returns a JSON response with configurable status/body.
///
/// A null [responseBody] is encoded as the JSON literal `null`, which the
/// generated client leaves as `response.data == null` — the empty-success-body
/// transport failure case.
class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter({
    this.responseBody,
    this.statusCode = 200,
    this.contentType = 'application/json',
    this.error,
  });

  Map<String, dynamic>? responseBody;
  int statusCode;
  String contentType;

  /// When set, [fetch] throws this object instead of returning a response.
  Object? error;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final e = error;
    if (e != null) {
      throw e;
    }
    final body = jsonEncode(responseBody);

    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [contentType],
      },
    );
  }
}

Map<String, dynamic> _searchBody({
  List<Map<String, dynamic>> items = const [],
}) {
  return {
    'items': items,
    'pagination': {
      'page': 1,
      'pageSize': 20,
      'total': items.length,
      'totalPages': items.isEmpty ? 0 : 1,
    },
  };
}

Map<String, dynamic> _item(String id, {String source = 'cn'}) {
  return {
    'id': id,
    'source': source,
    'name': 'Medicine $id',
    'subtitle': 'Subtitle $id',
    'summary': 'Summary $id',
    'tags': <String>[],
    'imageUrl': null,
    'matchedBy': <String>['name'],
  };
}

Map<String, dynamic> _detailBody() {
  return {
    'id': 'med-1',
    'source': 'cn',
    'name': 'Aspirin',
    'subtitle': 'Pain reliever',
    'detail': {
      'kind': '',
      'groups': <Object>[],
      'categories': <Object>[],
      'atcCodes': <Object>[],
      'synonyms': <Object>[],
      'foodInteractions': <Object>[],
    },
  };
}

/// A 404 Problem Details body served with `application/problem+json`.
Map<String, dynamic> _problemDetails404() {
  return {
    'type': 'https://api.lumos.example/problems/MEDICINE_NOT_FOUND',
    'title': 'Not found',
    'detail': '药品不存在或已下架',
    'code': 'MEDICINE_NOT_FOUND',
  };
}

void main() {
  group('MedicineSearchRemoteDataSource', () {
    late Dio dio;
    late MedicineSearchRemoteDataSource dataSource;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dataSource = MedicineSearchRemoteDataSource(api: MedicinesApi(dio));
    });

    group('search', () {
      test('returns the DTO on a valid 200 response', () async {
        dio.httpClientAdapter = _JsonAdapter(
          responseBody: _searchBody(items: [_item('med-1')]),
        );

        final response = await dataSource.search(source: 'cn', query: 'asp');

        expect(response.items, hasLength(1));
        expect(response.items.first.id, 'med-1');
        expect(response.pagination.total, 1);
      });

      test('returns an empty items list on 200 with no candidates', () async {
        dio.httpClientAdapter = _JsonAdapter(responseBody: _searchBody());

        final response = await dataSource.search(source: 'cn', query: 'x');

        expect(response.items, isEmpty);
      });

      test(
        'empty success body throws a network emptyResponse failure',
        () async {
          dio.httpClientAdapter = _JsonAdapter(responseBody: null);

          await expectLater(
            dataSource.search(source: 'cn', query: 'x'),
            throwsA(
              isA<LucentFailure>().having(
                (f) => f.networkErrorCode,
                'networkErrorCode',
                NetworkErrorCode.emptyResponse,
              ),
            ),
          );
        },
      );

      test('404 Problem Details propagates as a DioException', () async {
        dio.httpClientAdapter = _JsonAdapter(
          statusCode: 404,
          contentType: 'application/problem+json',
          responseBody: _problemDetails404(),
        );

        await expectLater(
          dataSource.search(source: 'cn', query: 'x'),
          throwsA(isA<DioException>()),
        );
      });

      test('network timeout propagates as a DioException', () async {
        dio.httpClientAdapter = _JsonAdapter(
          error: DioException(
            requestOptions: RequestOptions(path: '/api/v1/medicines'),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        await expectLater(
          dataSource.search(source: 'cn', query: 'x'),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('getDetail', () {
      test('returns the DTO on a valid 200 response', () async {
        dio.httpClientAdapter = _JsonAdapter(responseBody: _detailBody());

        final response = await dataSource.getDetail(id: 'med-1', source: 'cn');

        expect(response.id, 'med-1');
        expect(response.name, 'Aspirin');
      });

      test(
        'empty success body throws a network emptyResponse failure',
        () async {
          dio.httpClientAdapter = _JsonAdapter(responseBody: null);

          await expectLater(
            dataSource.getDetail(id: 'med-1', source: 'cn'),
            throwsA(
              isA<LucentFailure>().having(
                (f) => f.networkErrorCode,
                'networkErrorCode',
                NetworkErrorCode.emptyResponse,
              ),
            ),
          );
        },
      );

      test('404 Problem Details propagates as a DioException', () async {
        dio.httpClientAdapter = _JsonAdapter(
          statusCode: 404,
          contentType: 'application/problem+json',
          responseBody: _problemDetails404(),
        );

        await expectLater(
          dataSource.getDetail(id: 'med-missing', source: 'cn'),
          throwsA(isA<DioException>()),
        );
      });
    });
  });
}
