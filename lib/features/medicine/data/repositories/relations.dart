import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/contract/failure.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_relations_remote.dart';
import 'package:luminous/features/medicine/domain/entities/relations.dart';
import 'package:luminous/features/medicine/domain/repositories/relations.dart';
import 'package:luminous/shared/domain/failure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'relations.g.dart';

/// Lucent-backed 关系图 repository。
///
/// 边界只做一件事：把传输失败折成 `Left`。图不可用的三态由数据源映射成
/// `GraphQueryResult.status`，照常是 `Right`——见接口注释。
class LucentMedicineRelationsRepository implements MedicineRelationsRepository {
  const LucentMedicineRelationsRepository({required this.remote});

  final MedicineRelationsRemoteDataSource remote;

  @override
  Future<Either<LucentFailure, GraphQueryResult<MechanismPath>>> mechanismPaths(
    List<String> drugbankIds,
  ) => _guard(() => remote.mechanismPaths(drugbankIds));

  @override
  Future<Either<LucentFailure, GraphQueryResult<SharedTarget>>> sharedTargets(
    List<String> drugbankIds,
  ) => _guard(() => remote.sharedTargets(drugbankIds));

  @override
  Future<Either<LucentFailure, GraphQueryResult<CascadePath>>> cascadePaths(
    String drugbankId,
  ) => _guard(() => remote.cascadePaths(drugbankId));

  @override
  Future<Either<LucentFailure, GraphQueryResult<SubstituteCandidate>>>
  substituteCandidates({
    required String drugbankId,
    required String enzymeGene,
  }) => _guard(
    () => remote.substituteCandidates(
      drugbankId: drugbankId,
      enzymeGene: enzymeGene,
    ),
  );

  @override
  Future<Either<LucentFailure, GraphQueryResult<DrugAction>>> drugActions(
    String drugbankId,
  ) => _guard(() => remote.drugActions(drugbankId));

  @override
  Future<Either<LucentFailure, GraphQueryResult<ShortestRoute>>>
  shortestRoutes({
    required String fromDrugbankId,
    required String toDrugbankId,
  }) => _guard(
    () => remote.shortestRoutes(
      fromDrugbankId: fromDrugbankId,
      toDrugbankId: toDrugbankId,
    ),
  );

  @override
  Future<Either<LucentFailure, GraphQueryResult<TargetDrug>>> targetDrugs(
    String geneName,
  ) => _guard(() => remote.targetDrugs(geneName));

  @override
  Future<Either<LucentFailure, GraphQueryResult<TransportRoute>>>
  transportRoutes(String drugbankId) =>
      _guard(() => remote.transportRoutes(drugbankId));

  @override
  Future<Either<LucentFailure, GraphQueryResult<EnzymeDuel>>> enzymeDuels(
    List<String> drugbankIds,
  ) => _guard(() => remote.enzymeDuels(drugbankIds));

  @override
  Future<Either<LucentFailure, MedicationOverview>> medicationOverview() =>
      _guard(remote.medicationOverview);

  Future<Either<LucentFailure, T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Right(await run());
    } catch (error) {
      return Left(LucentErrorMapper.fromObject(error));
    }
  }
}

@riverpod
MedicineRelationsRepository medicineRelationsRepository(Ref ref) {
  final client = ref.watch(lucentClientProvider);
  return LucentMedicineRelationsRepository(
    remote: MedicineRelationsRemoteDataSource(api: client.medicines),
  );
}
