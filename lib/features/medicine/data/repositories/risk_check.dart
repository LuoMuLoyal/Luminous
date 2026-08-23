import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/errors/lucent_failure.dart';
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
///
/// Repository boundary: every expected recoverable failure (network, server
/// business failure) is a `TaskEither` Left produced via
/// `LucentErrorMapper.fromObject`. A legal empty records set stays a Right.
class LucentMedicineRiskCheckRepository implements MedicineRiskCheckRepository {
  LucentMedicineRiskCheckRepository({required this.remoteDataSource});

  final MedicineRiskCheckRemoteDataSource remoteDataSource;

  @override
  TaskEither<LucentFailure, MedicineRiskCheckRecords> getRecords() {
    return TaskEither.tryCatch(
      remoteDataSource.fetchRecords,
      (error, stackTrace) => LucentErrorMapper.fromObject(error),
    );
  }

  @override
  TaskEither<LucentFailure, MedicineRiskCheckRecord> runCheck(
    MedicineRiskCheckType type,
  ) {
    return TaskEither.tryCatch(
      () => remoteDataSource.runCheck(type),
      (error, stackTrace) => LucentErrorMapper.fromObject(error),
    );
  }

  @override
  TaskEither<LucentFailure, MedicineRiskCheckResult> runPrecheck({
    required String source,
    required String sourceRefId,
  }) {
    return TaskEither.tryCatch(
      () => remoteDataSource.runPrecheck(
        source: source,
        sourceRefId: sourceRefId,
      ),
      (error, stackTrace) => LucentErrorMapper.fromObject(error),
    );
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
