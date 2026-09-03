import 'package:luminous/core/errors/lucent_failure.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/contract/error_code.dart';
import 'package:luminous/features/medicine/data/mappers/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';

/// Remote data source for medicine risk check records.
///
/// Calls the generated [MedicinesApi] to interact with
/// GET/POST `/api/v1/medicines/risk-check` and maps the response DTOs to
/// domain entities via [MedicineRiskCheckMapper].
///
/// Transport only: returns a plain `Future` and throws — an empty success
/// body is a [LucentFailure.network] (auth `_requireBody` precedent); the
/// repository boundary maps every failure via `LucentErrorMapper.fromObject`.
class MedicineRiskCheckRemoteDataSource {
  const MedicineRiskCheckRemoteDataSource({
    required this.api,
    required this.mapper,
  });

  final MedicinesApi api;
  final MedicineRiskCheckMapper mapper;

  /// GET — reads existing records from the database (static + llm).
  Future<MedicineRiskCheckRecords> fetchRecords() async {
    final response = await api.medicinesControllerGetRiskCheckV1();
    final dto = response.data;
    if (dto == null) {
      throw LucentFailure.network(
        message: 'Empty risk check records response body',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return mapper.recordsDtoToDomain(dto);
  }

  /// POST — manually triggers a risk check of the given [type].
  Future<MedicineRiskCheckRecord> runCheck(MedicineRiskCheckType type) async {
    final dto = mapper.checkTypeToDto(type);
    final response = await api.medicinesControllerRunRiskCheckV1(
      medicinesControllerRunRiskCheckV1Request: dto,
    );
    final resp = response.data;
    if (resp == null) {
      throw LucentFailure.network(
        message: 'Empty risk check run result response body',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return mapper.recordDtoToDomain(resp);
  }

  /// POST — runs an immediate static pre-check for a candidate medicine from
  /// a trusted drug-library source ([source] is 'cn' / 'drugbank',
  /// [sourceRefId] the candidate id). The server checks the current box plus
  /// the candidate on the fly without persisting a record, so the record's
  /// [MedicineRiskCheckResult] is returned directly as the preview.
  Future<MedicineRiskCheckResult> runPrecheck({
    required String source,
    required String sourceRefId,
  }) async {
    final dto = mapper.precheckToDto(source: source, sourceRefId: sourceRefId);
    final response = await api.medicinesControllerRunRiskCheckV1(
      medicinesControllerRunRiskCheckV1Request: dto,
    );
    final resp = response.data;
    if (resp == null) {
      throw LucentFailure.network(
        message: 'Empty risk check precheck result response body',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return mapper.recordDtoToDomain(resp).result;
  }
}
