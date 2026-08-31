import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/medicine/data/datasources/risk_check_remote.dart';
import 'package:luminous/features/medicine/data/mappers/risk_check.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/task_either.dart';

class _MockMedicinesApi extends Mock implements MedicinesApi {}

MedicineRiskCheckResponseDto _response() {
  return MedicineRiskCheckResponseDto(
    overallRiskLevel: MedicineRiskCheckResponseDtoOverallRiskLevelEnum.safe,
    overallRiskScore: 0,
    currentMedicineCount: 2,
    checkedMedicineCount: 2,
    findings: const [],
    coverageIssues: const [],
    redFlags: const [],
  );
}

MedicineRiskCheckRecordResponseDto _record() {
  return MedicineRiskCheckRecordResponseDto(
    checkType: MedicineRiskCheckRecordResponseDtoCheckTypeEnum.static_,
    result: _response(),
    riskScore: 0,
    riskLevel: MedicineRiskCheckRecordResponseDtoRiskLevelEnum.safe,
    stale: false,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 1),
  );
}

Response<T> _apiResponse<T>(T data) {
  return Response<T>(
    data: data,
    requestOptions: RequestOptions(path: '/api/v1/medicines/risk-check'),
    statusCode: 200,
  );
}

/// A 404 RFC 9457 Problem Details body served with
/// `application/problem+json` (server business failure).
DioException _problemDetails404({String code = 'RISK_CHECK_NOT_FOUND'}) {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/medicines/risk-check'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/api/v1/medicines/risk-check'),
      statusCode: 404,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['application/problem+json'],
      }),
      data: {
        'type': 'https://api.lumos.example/problems/$code',
        'title': 'Not found',
        'detail': '风险检查记录不存在',
        'code': code,
      },
    ),
  );
}

/// A 400 body that is not Problem Details (protocol invariant violation).
DioException _nonProblemBody400() {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/medicines/risk-check'),
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: RequestOptions(path: '/api/v1/medicines/risk-check'),
      statusCode: 400,
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['application/json'],
      }),
      data: {'error': 'oops'},
    ),
  );
}

void main() {
  late _MockMedicinesApi api;
  late MedicineRiskCheckRemoteDataSource dataSource;
  late LucentMedicineRiskCheckRepository repository;

  setUp(() {
    api = _MockMedicinesApi();
    dataSource = MedicineRiskCheckRemoteDataSource(
      api: api,
      mapper: const MedicineRiskCheckMapper(),
    );
    repository = LucentMedicineRiskCheckRepository(
      remoteDataSource: dataSource,
    );
    registerFallbackValue(
      RunRiskCheckDto(type: RunRiskCheckDtoTypeEnum.static_),
    );
  });

  group('MedicineRiskCheckRemoteDataSource — fetchRecords', () {
    test('maps the direct resource to records', () async {
      when(() => api.medicinesControllerGetRiskCheckV1()).thenAnswer(
        (_) async => _apiResponse(
          MedicineRiskCheckRecordsResponseDto(
            static_: MedicineRiskCheckRecordDto.fromJson(_record().toJson()),
            llm: null,
          ),
        ),
      );

      final records = await dataSource.fetchRecords();

      expect(records.staticRecord, isNotNull);
      expect(records.llmRecord, isNull);
      expect(records.isEmpty, isFalse);
      verify(() => api.medicinesControllerGetRiskCheckV1()).called(1);
    });

    test('throws empty response error when the resource is null', () async {
      when(() => api.medicinesControllerGetRiskCheckV1()).thenAnswer(
        (_) async => Response<MedicineRiskCheckRecordsResponseDto>(
          data: null,
          requestOptions: RequestOptions(path: '/'),
        ),
      );

      await expectLater(
        dataSource.fetchRecords(),
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
  });

  group('MedicineRiskCheckRemoteDataSource — runCheck', () {
    test('maps record response to domain', () async {
      when(
        () => api.medicinesControllerRunRiskCheckV1(
          runRiskCheckDto: any(named: 'runRiskCheckDto'),
        ),
      ).thenAnswer((_) async => _apiResponse(_record()));

      final record = await dataSource.runCheck(MedicineRiskCheckType.static_);

      expect(record.checkType, MedicineRiskCheckType.static_);
      verify(
        () => api.medicinesControllerRunRiskCheckV1(
          runRiskCheckDto: any(named: 'runRiskCheckDto'),
        ),
      ).called(1);
    });

    test('maps llm check type to request dto', () async {
      when(
        () => api.medicinesControllerRunRiskCheckV1(
          runRiskCheckDto: any(named: 'runRiskCheckDto'),
        ),
      ).thenAnswer((_) async => _apiResponse(_record()));

      await dataSource.runCheck(MedicineRiskCheckType.llm);

      final captured =
          verify(
                () => api.medicinesControllerRunRiskCheckV1(
                  runRiskCheckDto: captureAny(named: 'runRiskCheckDto'),
                ),
              ).captured.single
              as RunRiskCheckDto;
      expect(captured.type, RunRiskCheckDtoTypeEnum.llm);
    });

    test('throws empty response error when run result is null', () async {
      when(
        () => api.medicinesControllerRunRiskCheckV1(
          runRiskCheckDto: any(named: 'runRiskCheckDto'),
        ),
      ).thenAnswer(
        (_) async => Response<MedicineRiskCheckRecordResponseDto>(
          data: null,
          requestOptions: RequestOptions(path: '/'),
        ),
      );

      await expectLater(
        dataSource.runCheck(MedicineRiskCheckType.static_),
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
  });

  group('MedicineRiskCheckRemoteDataSource — runPrecheck', () {
    test(
      'posts static precheck with candidate source/id and maps result',
      () async {
        when(
          () => api.medicinesControllerRunRiskCheckV1(
            runRiskCheckDto: any(named: 'runRiskCheckDto'),
          ),
        ).thenAnswer((_) async => _apiResponse(_record()));

        final result = await dataSource.runPrecheck(
          source: 'cn',
          sourceRefId: '__mock_cn_ibuprofen__',
        );

        final captured =
            verify(
                  () => api.medicinesControllerRunRiskCheckV1(
                    runRiskCheckDto: captureAny(named: 'runRiskCheckDto'),
                  ),
                ).captured.single
                as RunRiskCheckDto;
        expect(captured.type, RunRiskCheckDtoTypeEnum.static_);
        expect(captured.candidate, isNotNull);
        expect(
          captured.candidate!.source_,
          RiskCheckCandidateDtoSource_Enum.cn,
        );
        expect(captured.candidate!.id, '__mock_cn_ibuprofen__');
        expect(result.currentMedicineCount, 2);
        expect(result.checkedMedicineCount, 2);
        expect(result.findings, isEmpty);
      },
    );

    test('maps drugbank candidate source', () async {
      when(
        () => api.medicinesControllerRunRiskCheckV1(
          runRiskCheckDto: any(named: 'runRiskCheckDto'),
        ),
      ).thenAnswer((_) async => _apiResponse(_record()));

      await dataSource.runPrecheck(source: 'drugbank', sourceRefId: 'DB01050');

      final captured =
          verify(
                () => api.medicinesControllerRunRiskCheckV1(
                  runRiskCheckDto: captureAny(named: 'runRiskCheckDto'),
                ),
              ).captured.single
              as RunRiskCheckDto;
      expect(
        captured.candidate!.source_,
        RiskCheckCandidateDtoSource_Enum.drugbank,
      );
      expect(captured.candidate!.id, 'DB01050');
    });

    test('throws empty response error when precheck result is null', () async {
      when(
        () => api.medicinesControllerRunRiskCheckV1(
          runRiskCheckDto: any(named: 'runRiskCheckDto'),
        ),
      ).thenAnswer(
        (_) async => Response<MedicineRiskCheckRecordResponseDto>(
          data: null,
          requestOptions: RequestOptions(path: '/'),
        ),
      );

      await expectLater(
        dataSource.runPrecheck(source: 'cn', sourceRefId: 'id-1'),
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
  });

  group('LucentMedicineRiskCheckRepository', () {
    test('getRecords delegates to the data source', () async {
      when(() => api.medicinesControllerGetRiskCheckV1()).thenAnswer(
        (_) async => _apiResponse(
          MedicineRiskCheckRecordsResponseDto(static_: null, llm: null),
        ),
      );

      final records = await expectTaskRight(repository.getRecords());
      expect(records.isEmpty, isTrue);
    });

    test('runCheck delegates to the data source', () async {
      when(
        () => api.medicinesControllerRunRiskCheckV1(
          runRiskCheckDto: any(named: 'runRiskCheckDto'),
        ),
      ).thenAnswer((_) async => _apiResponse(_record()));

      final record = await expectTaskRight(
        repository.runCheck(MedicineRiskCheckType.static_),
      );
      expect(record.riskScore, 0);
      expect(record.stale, isFalse);
    });

    test('runPrecheck delegates to the data source', () async {
      when(
        () => api.medicinesControllerRunRiskCheckV1(
          runRiskCheckDto: any(named: 'runRiskCheckDto'),
        ),
      ).thenAnswer((_) async => _apiResponse(_record()));

      final result = await expectTaskRight(
        repository.runPrecheck(source: 'drugbank', sourceRefId: 'DB01050'),
      );
      expect(result.checkedMedicineCount, 2);
    });

    test('404 Problem Details keeps code and status as a Left', () async {
      when(
        () => api.medicinesControllerGetRiskCheckV1(),
      ).thenThrow(_problemDetails404(code: 'RISK_CHECK_NOT_FOUND'));

      final failure = await expectTaskLeft(repository.getRecords());

      expect(failure.code, 'RISK_CHECK_NOT_FOUND');
      expect(failure.statusCode, 404);
      expect(failure.kind, LucentFailureKind.business);
    });

    test(
      'non-Problem Details error body propagates FormatException from run()',
      () async {
        when(
          () => api.medicinesControllerGetRiskCheckV1(),
        ).thenThrow(_nonProblemBody400());

        await expectLater(
          repository.getRecords().run(),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}
