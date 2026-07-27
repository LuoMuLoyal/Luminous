import 'package:luminous/core/network/api.dart';
import 'package:luminous/features/medicine/data/mappers/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/repositories/risk_check.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'risk_check.g.dart';

/// Lucent-backed risk check repository.
///
/// Uses the generated [MedicinesApi] to call GET/POST /api/v1/medicines/risk-check
/// and maps the response DTOs to domain entities via [MedicineRiskCheckMapper].
class LucentMedicineRiskCheckRepository implements MedicineRiskCheckRepository {
  LucentMedicineRiskCheckRepository({required this.api, required this.mapper});

  final MedicinesApi api;
  final MedicineRiskCheckMapper mapper;

  @override
  Future<MedicineRiskCheckRecords> getRecords() async {
    final response = await api.medicinesControllerGetRiskCheckV1();
    return mapper.recordsDtoToDomain(response.data!);
  }

  @override
  Future<MedicineRiskCheckRecord> runCheck(MedicineRiskCheckType type) async {
    final dto = mapper.checkTypeToDto(type);
    final response = await api.medicinesControllerRunRiskCheckV1(
      runRiskCheckDto: dto,
    );
    return mapper.recordDtoToDomain(response.data!);
  }
}

@riverpod
MedicineRiskCheckRepository medicineRiskCheckRepository(Ref ref) {
  final client = ref.watch(lucentClientProvider);
  return LucentMedicineRiskCheckRepository(
    api: client.medicines,
    mapper: const MedicineRiskCheckMapper(),
  );
}
