import 'package:fpdart/fpdart.dart';
import 'package:luminous/app/composition/health_context/health_context.dart';
import 'package:luminous/core/network/contract/failure.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/relations.dart';
import 'package:luminous/features/medicine/domain/repositories/relations.dart';
import 'package:luminous/features/medicine/domain/services/graph_drug_set.dart';
import 'package:luminous/features/medicine/presentation/providers/data_access.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'graph.g.dart';

/// 当前用药里可参与药理分析的 DrugBank 集合。
///
/// 直接读 health_context 的快照——那是药箱的唯一事实源（medicine 不本地存药箱）。
/// 这里只做纯派生，不发请求。
///
/// ## 先读缓存、必要时才 await
///
/// 只看 `.future` 会让这组组件的首帧强制等一次快照请求（最长 5s），而这些卡片
/// 只是**补充信息**：药箱、今日计划、风险检查才是这页的主干，不该被一张知识库卡
/// 拖住。所以先用 `asData` 取已有快照；没有在途/已完成的值时才订阅 future。
///
/// 这个顺序也决定了测试里的行为：没有快照时就停在这里等，不会自己去打网络。
@riverpod
Future<GraphDrugSet> graphDrugSet(Ref ref) async {
  final cached = ref.watch(healthContextSnapshotProvider).asData?.value;
  if (cached != null) return _derive(cached.currentMedicines);

  final snapshot = await ref.watch(healthContextSnapshotProvider.future);
  return _derive(snapshot.currentMedicines);
}

/// 跨 feature 的字段映射放在 provider 而不是 domain 规则里：
/// `domain/` 只能 import 本 feature 的 domain（clean-layers R1/R2）。
GraphDrugSet _derive(List<CurrentMedicineItem> medicines) {
  return deriveGraphDrugSet(
    medicines.map(
      (item) => GraphDrugEntry(
        sourceRefId: item.sourceRefId,
        isCurrent: item.isCurrent,
        // 药名一起带进派生结果：图组件要显示「阿司匹林肠溶片」而不是 `DB00945`，
        // 而派生之后就拿不到 `CurrentMedicineItem` 了。
        displayName: item.displayName,
      ),
    ),
  );
}

// ── 图查询 ────────────────────────────────────────────────────
//
// 每个查询按入参做 family：同一个组件挂到两个 surface 时，family key 相同，
// 只发一次请求（A4 验收项）。入参在进入 family 之前已排序，避免「同样的药
// 换个顺序」被当成新 key 而重查。
//
// 失败语义：`Left`（传输故障）→ AsyncError；`notConfigured` / `unavailable` /
// `timeout` 是成功的答案，照常返回结果对象，由组件渲染降级态。

/// 每个查询的失败都立刻进 error，不走 riverpod 默认的指数退避。
///
/// 图查询失败时「一直在转」比「暂时无法分析」更难理解；而默认重试会在用户
/// 什么也没做的情况下反复打图库。
Duration? _noGraphRetry(int retryCount, Object error) => null;

@Riverpod(keepAlive: true, retry: _noGraphRetry)
Future<GraphQueryResult<MechanismPath>> graphMechanismPaths(
  Ref ref,
  String drugbankIdsKey,
) {
  return _relate(
    ref,
    (repository) => repository.mechanismPaths(drugbankIdsKey.split(',')),
  );
}

@Riverpod(keepAlive: true, retry: _noGraphRetry)
Future<GraphQueryResult<SharedTarget>> graphSharedTargets(
  Ref ref,
  String drugbankIdsKey,
) {
  return _relate(
    ref,
    (repository) => repository.sharedTargets(drugbankIdsKey.split(',')),
  );
}

@Riverpod(keepAlive: true, retry: _noGraphRetry)
Future<GraphQueryResult<CascadePath>> graphCascadePaths(
  Ref ref,
  String drugbankId,
) {
  return _relate(ref, (repository) => repository.cascadePaths(drugbankId));
}

@Riverpod(keepAlive: true, retry: _noGraphRetry)
Future<GraphQueryResult<DrugAction>> graphDrugActions(
  Ref ref,
  String drugbankId,
) {
  return _relate(ref, (repository) => repository.drugActions(drugbankId));
}

@Riverpod(keepAlive: true, retry: _noGraphRetry)
Future<GraphQueryResult<EnzymeDuel>> graphEnzymeDuels(
  Ref ref,
  String drugbankIdsKey,
) {
  return _relate(
    ref,
    (repository) => repository.enzymeDuels(drugbankIdsKey.split(',')),
  );
}

@Riverpod(keepAlive: true, retry: _noGraphRetry)
Future<GraphQueryResult<TransportRoute>> graphTransportRoutes(
  Ref ref,
  String drugbankId,
) {
  return _relate(ref, (repository) => repository.transportRoutes(drugbankId));
}

/// 替代候选：需要「被替换的药」与「要避开的酶」两个入参。
@Riverpod(keepAlive: true, retry: _noGraphRetry)
Future<GraphQueryResult<SubstituteCandidate>> graphSubstituteCandidates(
  Ref ref,
  ({String drugbankId, String enzymeGene}) query,
) {
  return _relate(
    ref,
    (repository) => repository.substituteCandidates(
      drugbankId: query.drugbankId,
      enzymeGene: query.enzymeGene,
    ),
  );
}

/// 最短传播路径：需要起止两药。
@Riverpod(keepAlive: true, retry: _noGraphRetry)
Future<GraphQueryResult<ShortestRoute>> graphShortestRoutes(
  Ref ref,
  ({String from, String to}) query,
) {
  return _relate(
    ref,
    (repository) => repository.shortestRoutes(
      fromDrugbankId: query.from,
      toDrugbankId: query.to,
    ),
  );
}

/// 靶点视角：某基因上的所有药。
@Riverpod(keepAlive: true, retry: _noGraphRetry)
Future<GraphQueryResult<TargetDrug>> graphTargetDrugs(
  Ref ref,
  String geneName,
) {
  return _relate(ref, (repository) => repository.targetDrugs(geneName));
}

/// 用药组合概览（需登录，描述用户自己的用药集合）。
@Riverpod(keepAlive: true, retry: _noGraphRetry)
Future<MedicationOverview> medicationOverview(Ref ref) async {
  final repository = ref.watch(medicineRelationsRepositoryProvider);
  final result = await repository.medicationOverview();
  return result.fold((failure) => throw failure, (value) => value);
}

Future<T> _relate<T>(
  Ref ref,
  Future<Either<LucentFailure, T>> Function(
    MedicineRelationsRepository repository,
  )
  run,
) async {
  final repository = ref.watch(medicineRelationsRepositoryProvider);
  final result = await run(repository);
  return result.fold((failure) => throw failure, (value) => value);
}

/// 便于组件把同一组药拼成 family key。
String drugSetKey(List<String> drugbankIds) => drugbankIds.join(',');
