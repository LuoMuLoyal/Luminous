import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/contract/failure.dart';
import 'package:luminous/features/medicine/data/mappers/medicine_relations.dart';
import 'package:luminous/features/medicine/domain/entities/relations.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 药品关系图与用药全景的远端数据源。
///
/// Transport only：返回裸 `Future`、失败即抛，由 repository 边界统一经
/// `LucentErrorMapper.fromObject` 收敛成 `LucentFailure`。
///
/// ## 为什么要判空 body 而不是当成空结果
///
/// 空 body 是**传输层故障**（`emptyResponse`），不是「查到 0 条」。九条查询里
/// 「0 条」由信封的 `status: 'ok' + 空数组` 表达，两者在语义上完全相反。
class MedicineRelationsRemoteDataSource {
  const MedicineRelationsRemoteDataSource({
    required this.api,
    this.mapper = const MedicineRelationsMapper(),
  });

  final MedicinesApi api;
  final MedicineRelationsMapper mapper;

  Future<GraphQueryResult<MechanismPath>> mechanismPaths(
    List<String> drugbankIds,
  ) async {
    final response = await api.listMechanismPaths(
      drugbankIds: drugbankIds.join(','),
    );
    return mapper.mechanismPaths(_require(response.data, 'mechanism paths'));
  }

  Future<GraphQueryResult<SharedTarget>> sharedTargets(
    List<String> drugbankIds,
  ) async {
    final response = await api.listSharedTargets(
      drugbankIds: drugbankIds.join(','),
    );
    return mapper.sharedTargets(_require(response.data, 'shared targets'));
  }

  Future<GraphQueryResult<CascadePath>> cascadePaths(String drugbankId) async {
    final response = await api.listCascadePaths(drugbankId: drugbankId);
    return mapper.cascadePaths(_require(response.data, 'cascade paths'));
  }

  Future<GraphQueryResult<SubstituteCandidate>> substituteCandidates({
    required String drugbankId,
    required String enzymeGene,
  }) async {
    final response = await api.listSubstituteCandidates(
      drugbankId: drugbankId,
      enzymeGene: enzymeGene,
    );
    return mapper.substituteCandidates(
      _require(response.data, 'substitute candidates'),
    );
  }

  Future<GraphQueryResult<DrugAction>> drugActions(String drugbankId) async {
    final response = await api.listDrugActions(drugbankId: drugbankId);
    return mapper.drugActions(_require(response.data, 'drug actions'));
  }

  Future<GraphQueryResult<ShortestRoute>> shortestRoutes({
    required String fromDrugbankId,
    required String toDrugbankId,
  }) async {
    final response = await api.listShortestRoutes(
      fromDrugbankId: fromDrugbankId,
      toDrugbankId: toDrugbankId,
    );
    return mapper.shortestRoutes(_require(response.data, 'shortest routes'));
  }

  Future<GraphQueryResult<TargetDrug>> targetDrugs(String geneName) async {
    final response = await api.listTargetDrugs(geneName: geneName);
    return mapper.targetDrugs(_require(response.data, 'target drugs'));
  }

  Future<GraphQueryResult<TransportRoute>> transportRoutes(
    String drugbankId,
  ) async {
    final response = await api.listTransportRoutes(drugbankId: drugbankId);
    return mapper.transportRoutes(_require(response.data, 'transport routes'));
  }

  Future<GraphQueryResult<EnzymeDuel>> enzymeDuels(
    List<String> drugbankIds,
  ) async {
    final response = await api.listEnzymeDuels(
      drugbankIds: drugbankIds.join(','),
    );
    return mapper.enzymeDuels(_require(response.data, 'enzyme duels'));
  }

  Future<MedicationOverview> medicationOverview() async {
    final response = await api.getMedicationOverview();
    return mapper.medicationOverview(
      _require(response.data, 'medication overview'),
    );
  }

  T _require<T>(T? body, String what) {
    if (body == null) {
      throw LucentFailure.network(
        message: 'Empty $what response body',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
    }
    return body;
  }
}
