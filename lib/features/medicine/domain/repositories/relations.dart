import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/medicine/domain/entities/relations.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 药品关系图与用药全景的读取接口。
///
/// ## 「无法回答」为什么不是 `Left`
///
/// 图不可用（`notConfigured` / `unavailable` / `timeout`）是服务端**成功返回的
/// 一个答案**：它对用户的意义是「暂时无法给出机理分析」，而不是「加载失败请重试」。
/// 因此它以 [GraphQueryResult] 的 `status` 表达，落在 `Right` 里；只有真正的传输
/// 故障才是 `Left`。
///
/// 若把前者也做成 `Left`，界面上它们会长成同一个错误卡，而「重试」对
/// `notConfigured` 毫无意义。
abstract interface class MedicineRelationsRepository {
  Future<Either<LucentFailure, GraphQueryResult<MechanismPath>>> mechanismPaths(
    List<String> drugbankIds,
  );

  Future<Either<LucentFailure, GraphQueryResult<SharedTarget>>> sharedTargets(
    List<String> drugbankIds,
  );

  Future<Either<LucentFailure, GraphQueryResult<CascadePath>>> cascadePaths(
    String drugbankId,
  );

  Future<Either<LucentFailure, GraphQueryResult<SubstituteCandidate>>>
  substituteCandidates({
    required String drugbankId,
    required String enzymeGene,
  });

  Future<Either<LucentFailure, GraphQueryResult<DrugAction>>> drugActions(
    String drugbankId,
  );

  Future<Either<LucentFailure, GraphQueryResult<ShortestRoute>>>
  shortestRoutes({
    required String fromDrugbankId,
    required String toDrugbankId,
  });

  Future<Either<LucentFailure, GraphQueryResult<TargetDrug>>> targetDrugs(
    String geneName,
  );

  Future<Either<LucentFailure, GraphQueryResult<TransportRoute>>>
  transportRoutes(String drugbankId);

  Future<Either<LucentFailure, GraphQueryResult<EnzymeDuel>>> enzymeDuels(
    List<String> drugbankIds,
  );

  /// 用药组合概览。需要登录——它描述的是**用户自己的**用药集合。
  Future<Either<LucentFailure, MedicationOverview>> medicationOverview();
}
