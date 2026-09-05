import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_detail_remote.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';
import 'package:mocktail/mocktail.dart';

class _MockMedicinesApi extends Mock implements MedicinesApi {}

/// Builds a zod detail DTO whose full required-nullable surface defaults to
/// null so tests only set the fields they assert on.
MedicineDetailResponseDetail _detail({
  String kind = 'cnProduct',
  List<String> groups = const [],
  List<String> categories = const [],
  List<String> atcCodes = const [],
  List<String> synonyms = const [],
  List<String> foodInteractions = const [],
  List<MedicineDetailResponseDrugInteractions>?
  drugInteractions,
  String? approvalNumber,
  String? manufacturer,
  String? packageSpec,
  String? brandName,
  String? ingredients,
  String? properties,
  String? indications,
  String? dosage,
  String? adverseReactions,
  String? contraindications,
  String? precautions,
  String? pharmacologyToxicology,
  String? pharmacokinetics,
  String? overdose,
  String? storage,
  String? validityPeriod,
  String? drugType,
  String? state,
  String? description,
  String? indication,
  String? mechanismOfAction,
  String? pharmacodynamics,
  String? toxicity,
  String? metabolism,
  String? absorption,
  String? halfLife,
  String? proteinBinding,
  String? routeOfElimination,
  String? volumeOfDistribution,
  String? clearance,
  Object? externalIdentifiers,
  Object? externalLinks,
  String? barcode,
  String? nationalDrugCode,
  String? sourceUrl,
  String? imageUrl,
}) {
  return MedicineDetailResponseDetail(
    kind: kind,
    groups: groups,
    categories: categories,
    atcCodes: atcCodes,
    synonyms: synonyms,
    foodInteractions: foodInteractions,
    drugInteractions: drugInteractions,
    approvalNumber: approvalNumber,
    manufacturer: manufacturer,
    packageSpec: packageSpec,
    brandName: brandName,
    ingredients: ingredients,
    properties: properties,
    indications: indications,
    dosage: dosage,
    adverseReactions: adverseReactions,
    contraindications: contraindications,
    precautions: precautions,
    pharmacologyToxicology: pharmacologyToxicology,
    pharmacokinetics: pharmacokinetics,
    overdose: overdose,
    storage: storage,
    validityPeriod: validityPeriod,
    drugType: drugType,
    state: state,
    description: description,
    indication: indication,
    mechanismOfAction: mechanismOfAction,
    pharmacodynamics: pharmacodynamics,
    toxicity: toxicity,
    metabolism: metabolism,
    absorption: absorption,
    halfLife: halfLife,
    proteinBinding: proteinBinding,
    routeOfElimination: routeOfElimination,
    volumeOfDistribution: volumeOfDistribution,
    clearance: clearance,
    externalIdentifiers: externalIdentifiers,
    externalLinks: externalLinks,
    barcode: barcode,
    nationalDrugCode: nationalDrugCode,
    sourceUrl: sourceUrl,
    imageUrl: imageUrl,
  );
}

void main() {
  late _MockMedicinesApi api;
  late MedicineDetailRemoteDataSource dataSource;

  setUp(() {
    api = _MockMedicinesApi();
    dataSource = MedicineDetailRemoteDataSource(api: api);
  });

  test('maps the direct resource to MedicineDetail', () async {
    when(
      () => api.getDetail(
        id: any(named: 'id'),
        source_: any(named: 'source_'),
      ),
    ).thenAnswer(
      (_) async => Response<MedicineDetailResponse>(
        data: MedicineDetailResponse(
          id: 'cn_1',
          source_: MedicineDetailResponseSource_Enum.cn,
          name: '布洛芬片',
          subtitle: null,
          detail: _detail(indications: '用于缓解轻至中度疼痛'),
        ),
        requestOptions: RequestOptions(path: '/api/v1/medicines/cn_1'),
        statusCode: 200,
      ),
    );

    final result = await dataSource.fetchDetail(id: 'cn_1', source: 'cn');

    expect(result, isA<MedicineDetail>());
    expect(result.id, 'cn_1');
    expect(result.name, '布洛芬片');
    expect(result.indications, '用于缓解轻至中度疼痛');

    verify(
      () => api.getDetail(id: 'cn_1', source_: 'cn'),
    ).called(1);
  });

  test('throws empty response error when the resource is null', () async {
    when(
      () => api.getDetail(
        id: any(named: 'id'),
        source_: any(named: 'source_'),
      ),
    ).thenAnswer(
      (_) async => Response<MedicineDetailResponse>(
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
}
