import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/api_exception.dart';
import 'package:luminous/core/network/error_code.dart';
import 'package:luminous/features/medicine/data/datasources/risk_check_remote.dart';
import 'package:luminous/features/medicine/data/mappers/risk_check.dart';
import 'package:luminous/features/medicine/data/repositories/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:mocktail/mocktail.dart';

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

MedicineRiskCheckRecordDto _record() {
  return MedicineRiskCheckRecordDto(
    checkType: MedicineRiskCheckRecordDtoCheckTypeEnum.static_,
    result: _response(),
    riskScore: 0,
    riskLevel: MedicineRiskCheckRecordDtoRiskLevelEnum.safe,
    stale: false,
    createdAt: DateTime(2026, 7, 1),
    updatedAt: DateTime(2026, 7, 1),
  );
}

Response<T> _envelope<T>(T data) {
  return Response<T>(
    data: data,
    requestOptions: RequestOptions(path: '/api/v1/medicines/risk-check'),
    statusCode: 200,
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
    test('maps envelope data to records', () async {
      when(() => api.medicinesControllerGetRiskCheckV1()).thenAnswer(
        (_) async => _envelope(
          MedicineRiskCheckRecordsResponseDto(
            code: 0,
            message: 'ok',
            data: MedicineRiskCheckRecordsDto(static_: _record(), llm: null),
          ),
        ),
      );

      final records = await dataSource.fetchRecords();

      expect(records.staticRecord, isNotNull);
      expect(records.llmRecord, isNull);
      expect(records.isEmpty, isFalse);
      verify(() => api.medicinesControllerGetRiskCheckV1()).called(1);
    });

    test('throws empty response error when envelope data is null', () async {
      when(() => api.medicinesControllerGetRiskCheckV1()).thenAnswer(
        (_) async => Response<MedicineRiskCheckRecordsResponseDto>(
          data: null,
          requestOptions: RequestOptions(path: '/'),
        ),
      );

      await expectLater(
        dataSource.fetchRecords(),
        throwsA(
          isA<LucentApiException>()
              .having(
                (e) => e.networkErrorCode,
                'networkErrorCode',
                NetworkErrorCode.emptyResponse,
              )
              .having((e) => e.message, 'message', contains('响应体为空')),
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
      ).thenAnswer(
        (_) async => _envelope(
          MedicineRiskCheckRecordResponseDto(
            code: 0,
            message: 'ok',
            data: _record(),
          ),
        ),
      );

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
      ).thenAnswer(
        (_) async => _envelope(
          MedicineRiskCheckRecordResponseDto(
            code: 0,
            message: 'ok',
            data: _record(),
          ),
        ),
      );

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
          isA<LucentApiException>()
              .having(
                (e) => e.networkErrorCode,
                'networkErrorCode',
                NetworkErrorCode.emptyResponse,
              )
              .having((e) => e.message, 'message', contains('响应体为空')),
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
        ).thenAnswer(
          (_) async => _envelope(
            MedicineRiskCheckRecordResponseDto(
              code: 0,
              message: 'ok',
              data: _record(),
            ),
          ),
        );

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
      ).thenAnswer(
        (_) async => _envelope(
          MedicineRiskCheckRecordResponseDto(
            code: 0,
            message: 'ok',
            data: _record(),
          ),
        ),
      );

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
          isA<LucentApiException>()
              .having(
                (e) => e.networkErrorCode,
                'networkErrorCode',
                NetworkErrorCode.emptyResponse,
              )
              .having((e) => e.message, 'message', contains('响应体为空')),
        ),
      );
    });
  });

  group('LucentMedicineRiskCheckRepository', () {
    test('getRecords delegates to the data source', () async {
      when(() => api.medicinesControllerGetRiskCheckV1()).thenAnswer(
        (_) async => _envelope(
          MedicineRiskCheckRecordsResponseDto(
            code: 0,
            message: 'ok',
            data: MedicineRiskCheckRecordsDto(static_: null, llm: null),
          ),
        ),
      );

      final records = await repository.getRecords();
      expect(records.isEmpty, isTrue);
    });

    test('runCheck delegates to the data source', () async {
      when(
        () => api.medicinesControllerRunRiskCheckV1(
          runRiskCheckDto: any(named: 'runRiskCheckDto'),
        ),
      ).thenAnswer(
        (_) async => _envelope(
          MedicineRiskCheckRecordResponseDto(
            code: 0,
            message: 'ok',
            data: _record(),
          ),
        ),
      );

      final record = await repository.runCheck(MedicineRiskCheckType.static_);
      expect(record.riskScore, 0);
      expect(record.stale, isFalse);
    });

    test('runPrecheck delegates to the data source', () async {
      when(
        () => api.medicinesControllerRunRiskCheckV1(
          runRiskCheckDto: any(named: 'runRiskCheckDto'),
        ),
      ).thenAnswer(
        (_) async => _envelope(
          MedicineRiskCheckRecordResponseDto(
            code: 0,
            message: 'ok',
            data: _record(),
          ),
        ),
      );

      final result = await repository.runPrecheck(
        source: 'drugbank',
        sourceRefId: 'DB01050',
      );
      expect(result.checkedMedicineCount, 2);
    });
  });
}
