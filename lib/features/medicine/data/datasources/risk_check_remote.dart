import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/features/medicine/data/mappers/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';

/// Remote data source for medicine risk check records.
///
/// Calls the generated [MedicinesApi] to interact with
/// GET/POST `/api/v1/medicines/risk-check` and maps the response DTOs to
/// domain entities via [MedicineRiskCheckMapper].
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
    return mapper.recordsDtoToDomain(response.data!.data);
  }

  /// POST — manually triggers a risk check of the given [type].
  Future<MedicineRiskCheckRecord> runCheck(MedicineRiskCheckType type) async {
    final dto = mapper.checkTypeToDto(type);
    final response = await api.medicinesControllerRunRiskCheckV1(
      runRiskCheckDto: dto,
    );
    return mapper.recordDtoToDomain(response.data!.data);
  }
}
