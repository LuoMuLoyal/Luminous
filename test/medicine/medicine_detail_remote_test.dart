import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_detail_remote.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

/// A detail response carrying only the DrugBank family, exactly as the backend
/// serves `source=drugbank`: the CN package-insert keys are simply absent.
///
/// This is the shape that the generated `MedicineDetailResponse.detail`
/// wrapper cannot decode (it requires both families), so these fixtures are
/// what keeps that regression from silently returning as a permanent loading
/// state.
const _drugbankBody = <String, dynamic>{
  'id': 'DB00945',
  'source': 'drugbank',
  'name': 'Acetylsalicylic acid',
  'subtitle': null,
  'detail': <String, dynamic>{
    'kind': 'drugbank',
    'drugType': null,
    'state': null,
    'description': null,
    'indication': null,
    'mechanismOfAction': null,
    'pharmacodynamics': null,
    'toxicity': null,
    'metabolism': null,
    'absorption': null,
    'halfLife': null,
    'proteinBinding': null,
    'routeOfElimination': null,
    'volumeOfDistribution': null,
    'clearance': null,
    'groups': <String>[],
    'categories': <String>[],
    'atcCodes': <String>[],
    'synonyms': <String>[],
    'foodInteractions': <String>[],
    'drugInteractions': null,
    'targets': <dynamic>[],
    'externalIdentifiers': <dynamic>[],
    'externalLinks': <dynamic>[],
    'sequenceSummary': null,
    'structure': null,
  },
};

/// A detail response carrying only the CN package-insert family.
const _cnBody = <String, dynamic>{
  'id': '4dbb23eb3668d330',
  'source': 'cn',
  'name': '复方忍冬藤阿司匹林片',
  'subtitle': '0.3g*24片 / 长春新安药业有限公司',
  'detail': <String, dynamic>{
    'kind': 'cnProduct',
    'approvalNumber': '国药准字H22021959',
    'manufacturer': '长春新安药业有限公司',
    'packageSpec': '0.3g*24片',
    'brandName': null,
    'ingredients': null,
    'properties': null,
    'indications': '用于感冒引起的头痛',
    'dosage': null,
    'adverseReactions': null,
    'contraindications': null,
    'precautions': null,
    'pharmacologyToxicology': null,
    'pharmacokinetics': null,
    'overdose': null,
    'storage': null,
    'validityPeriod': null,
    'barcode': null,
    'nationalDrugCode': null,
    'sourceUrl': null,
    'imageUrl': null,
  },
};

void main() {
  late _MockDio dio;
  late MedicineDetailRemoteDataSource dataSource;

  setUp(() {
    dio = _MockDio();
    dataSource = MedicineDetailRemoteDataSource(
      api: MedicinesApi(dio),
      dio: dio,
    );
  });

  void stubDetail(Map<String, dynamic> body) {
    when(
      () => dio.request<dynamic>(
        any(),
        options: any(named: 'options'),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: jsonDecode(jsonEncode(body)),
        requestOptions: RequestOptions(path: '/api/v1/medicines/DB00945'),
        statusCode: 200,
      ),
    );
  }

  test('the generated union wrapper cannot decode a one-sided payload', () {
    // Documents *why* `fetchDetail` parses the body itself. The generator
    // emits `MedicineDetailResponseDetail` as a flat object requiring every
    // field of both `oneOf` variants (checked: true), while the response model
    // declares that wrapper for `detail`. A real payload only carries one
    // family, so the generated path throws for every medicine — this guards
    // against "simplifying" the data source back onto `api.getDetail`.
    expect(
      () => MedicineDetailResponse.fromJson(
        jsonDecode(jsonEncode(_drugbankBody)) as Map<String, dynamic>,
      ),
      throwsA(isA<CheckedFromJsonException>()),
    );
  });

  test('decodes a drugbank payload without the CN keys', () async {
    stubDetail(_drugbankBody);

    final result = await dataSource.fetchDetail(
      id: 'DB00945',
      source: 'drugbank',
    );

    expect(result.id, 'DB00945');
    expect(result.source, 'drugbank');
    expect(result.kind, 'drugbank');
    expect(result.name, 'Acetylsalicylic acid');
    // The absent CN family stays null rather than throwing.
    expect(result.approvalNumber, isNull);
    expect(result.manufacturer, isNull);
  });

  test('decodes a cn payload without the DrugBank keys', () async {
    stubDetail(_cnBody);

    final result = await dataSource.fetchDetail(
      id: '4dbb23eb3668d330',
      source: 'cn',
    );

    expect(result.id, '4dbb23eb3668d330');
    expect(result.source, 'cn');
    expect(result.kind, 'cnProduct');
    expect(result.name, '复方忍冬藤阿司匹林片');
    expect(result.approvalNumber, '国药准字H22021959');
    expect(result.manufacturer, '长春新安药业有限公司');
    expect(result.indications, '用于感冒引起的头痛');
    // The absent DrugBank family stays null.
    expect(result.mechanismOfAction, isNull);
    expect(result.targets, isEmpty);
  });

  test('throws empty response error when the body is not an object', () async {
    when(
      () => dio.request<dynamic>(
        any(),
        options: any(named: 'options'),
        queryParameters: any(named: 'queryParameters'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        data: null,
        requestOptions: RequestOptions(path: '/'),
      ),
    );

    await expectLater(
      dataSource.fetchDetail(id: 'cn_1', source: 'cn'),
      throwsA(
        isA<LucentFailure>()
            .having((e) => e.kind, 'kind', LucentFailureKind.network)
            .having(
              (e) => e.networkErrorCode,
              'networkErrorCode',
              NetworkErrorCode.emptyResponse,
            )
            .having((e) => e.message, 'message', contains('Empty')),
      ),
    );
  });

  test('rejects an unknown detail kind instead of guessing', () async {
    stubDetail(<String, dynamic>{
      'id': 'x',
      'source': 'cn',
      'name': 'n',
      'subtitle': null,
      'detail': <String, dynamic>{'kind': 'somethingElse'},
    });

    await expectLater(
      dataSource.fetchDetail(id: 'x', source: 'cn'),
      throwsA(
        isA<LucentFailure>().having(
          (e) => e.message,
          'message',
          contains('somethingElse'),
        ),
      ),
    );
  });
}
