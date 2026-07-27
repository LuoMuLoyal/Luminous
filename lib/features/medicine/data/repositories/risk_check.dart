import 'package:luminous/core/network/api.dart';
import 'package:luminous/features/medicine/data/datasources/risk_check_remote.dart';
import 'package:luminous/features/medicine/data/mappers/risk_check.dart';
import 'package:luminous/features/medicine/domain/entities/risk_check.dart';
import 'package:luminous/features/medicine/domain/repositories/risk_check.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'risk_check.g.dart';

/// Lucent-backed risk check repository.
///
/// Thin wrapper around [MedicineRiskCheckRemoteDataSource] — all API calls and
/// DTO-to-domain mapping live in the data source; the repository only exposes
/// the domain-facing [MedicineRiskCheckRepository] interface.
class LucentMedicineRiskCheckRepository implements MedicineRiskCheckRepository {
  LucentMedicineRiskCheckRepository({required this.remoteDataSource});

  final MedicineRiskCheckRemoteDataSource remoteDataSource;

  @override
  Future<MedicineRiskCheckRecords> getRecords() {
    return remoteDataSource.fetchRecords();
  }

  @override
  Future<MedicineRiskCheckRecord> runCheck(MedicineRiskCheckType type) {
    return remoteDataSource.runCheck(type);
  }
}

@riverpod
MedicineRiskCheckRepository medicineRiskCheckRepository(Ref ref) {
  final client = ref.watch(lucentClientProvider);
  final remoteDataSource = MedicineRiskCheckRemoteDataSource(
    api: client.medicines,
    mapper: const MedicineRiskCheckMapper(),
  );
  return LucentMedicineRiskCheckRepository(remoteDataSource: remoteDataSource);
}
