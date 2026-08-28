import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_detail_remote.dart';
import 'package:luminous/features/medicine/domain/entities/medicine_detail.dart';
import 'package:mocktail/mocktail.dart';

class _MockMedicinesApi extends Mock implements MedicinesApi {}

void main() {
  late _MockMedicinesApi api;
  late MedicineDetailRemoteDataSource dataSource;

  setUp(() {
    api = _MockMedicinesApi();
    dataSource = MedicineDetailRemoteDataSource(api: api);
  });

  test('maps the direct resource to MedicineDetail', () async {
    when(
      () => api.medicinesControllerGetDetailV1(
        id: any(named: 'id'),
        source_: any(named: 'source_'),
      ),
    ).thenAnswer(
      (_) async => Response<MedicineDetailResponseDto>(
        data: MedicineDetailResponseDto(
          id: 'cn_1',
          source_: MedicineDetailResponseDtoSource_Enum.cn,
          name: '布洛芬片',
          subtitle: null,
          detail: MedicineDetailResponseDtoDetail(
            kind: 'cnProduct',
            groups: const [],
            categories: const [],
            atcCodes: const [],
            synonyms: const [],
            foodInteractions: const [],
            indications: '用于缓解轻至中度疼痛',
          ),
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
      () => api.medicinesControllerGetDetailV1(id: 'cn_1', source_: 'cn'),
    ).called(1);
  });

  test('throws empty response error when the resource is null', () async {
    when(
      () => api.medicinesControllerGetDetailV1(
        id: any(named: 'id'),
        source_: any(named: 'source_'),
      ),
    ).thenAnswer(
      (_) async => Response<MedicineDetailResponseDto>(
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
