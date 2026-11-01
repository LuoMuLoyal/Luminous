import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/features/medicine/domain/entities/relations.dart';

/// Maps the generated relation DTOs to domain entities.
///
/// 九个图查询端点的信封字段布局一致（`status` + 一个数据键），但每个端点的
/// status 枚举、数据键类型都是**独立生成的类型族**，没有公共基类。因此这里对
/// 每个端点写一层薄映射，把 wire 枚举值收敛到共享的 [GraphQueryStatus]。
///
/// 空数组与「查不了」的区别在信封上就分开了：失败态下 `dto.<dataKey>` 为 null，
/// 映射结果 `items` 也为 null —— 交叉点处不做 `?? const []`，否则就把知识缺口
/// 变成了「没有相互作用」。
class MedicineRelationsMapper {
  const MedicineRelationsMapper();

  GraphQueryResult<MechanismPath> mechanismPaths(
    MedicineMechanismPathsResponse dto,
  ) {
    return GraphQueryResult<MechanismPath>(
      status: _status(dto.status.value),
      items: dto.paths
          ?.map(
            (item) => MechanismPath(
              enzymeGene: item.enzymeGene,
              enzymeName: item.enzymeName,
              otherDrugId: item.otherDrugId,
              otherDrugName: item.otherDrugName,
              relation: item.relation,
            ),
          )
          .toList(growable: false),
    );
  }

  GraphQueryResult<SharedTarget> sharedTargets(
    MedicineSharedTargetsResponse dto,
  ) {
    return GraphQueryResult<SharedTarget>(
      status: _status(dto.status.value),
      items: dto.targets
          ?.map(
            (item) => SharedTarget(
              targetGene: item.targetGene,
              targetName: item.targetName,
              drugCount: item.drugCount,
              drugIds: List<String>.unmodifiable(item.drugIds),
              drugNames: List<String>.unmodifiable(item.drugNames),
            ),
          )
          .toList(growable: false),
    );
  }

  GraphQueryResult<CascadePath> cascadePaths(MedicineCascadePathsResponse dto) {
    return GraphQueryResult<CascadePath>(
      status: _status(dto.status.value),
      items: dto.cascades
          ?.map(
            (item) => CascadePath(
              startDrug: item.startDrug,
              enzymeOne: item.enzymeOne,
              middleDrug: item.middleDrug,
              enzymeTwo: item.enzymeTwo,
              endDrug: item.endDrug,
            ),
          )
          .toList(growable: false),
    );
  }

  GraphQueryResult<SubstituteCandidate> substituteCandidates(
    MedicineSubstituteCandidatesResponse dto,
  ) {
    return GraphQueryResult<SubstituteCandidate>(
      status: _status(dto.status.value),
      items: dto.candidates
          ?.map(
            (item) => SubstituteCandidate(
              drugbankId: item.drugbankId,
              name: item.name,
              sharedTarget: item.sharedTarget,
            ),
          )
          .toList(growable: false),
    );
  }

  GraphQueryResult<DrugAction> drugActions(MedicineDrugActionsResponse dto) {
    return GraphQueryResult<DrugAction>(
      status: _status(dto.status.value),
      items: dto.actions
          ?.map(
            (item) => DrugAction(
              targetGene: item.targetGene,
              targetName: item.targetName,
              relation: item.relation,
              actions: List<String>.unmodifiable(item.actions),
            ),
          )
          .toList(growable: false),
    );
  }

  GraphQueryResult<ShortestRoute> shortestRoutes(
    MedicineShortestRoutesResponse dto,
  ) {
    return GraphQueryResult<ShortestRoute>(
      status: _status(dto.status.value),
      items: dto.routes
          ?.map(
            (item) => ShortestRoute(
              stepCount: item.stepCount,
              pathNodes: List<String>.unmodifiable(item.pathNodes),
              pathRelations: List<String>.unmodifiable(item.pathRelations),
            ),
          )
          .toList(growable: false),
    );
  }

  GraphQueryResult<TargetDrug> targetDrugs(MedicineTargetDrugsResponse dto) {
    return GraphQueryResult<TargetDrug>(
      status: _status(dto.status.value),
      items: dto.drugs
          ?.map(
            (item) => TargetDrug(
              drugbankId: item.drugbankId,
              name: item.name,
              relation: item.relation,
            ),
          )
          .toList(growable: false),
    );
  }

  GraphQueryResult<TransportRoute> transportRoutes(
    MedicineTransportRoutesResponse dto,
  ) {
    return GraphQueryResult<TransportRoute>(
      status: _status(dto.status.value),
      items: dto.routes
          ?.map(
            (item) => TransportRoute(
              transporterGene: item.transporterGene,
              transporterName: item.transporterName,
              inverted: item.inverted,
            ),
          )
          .toList(growable: false),
    );
  }

  GraphQueryResult<EnzymeDuel> enzymeDuels(MedicineEnzymeDuelsResponse dto) {
    return GraphQueryResult<EnzymeDuel>(
      status: _status(dto.status.value),
      items: dto.duels
          ?.map(
            (item) => EnzymeDuel(
              enzymeGene: item.enzymeGene,
              inducerDrug: item.inducerDrug,
              inhibitedSubstrate: item.inhibitedSubstrate,
            ),
          )
          .toList(growable: false),
    );
  }

  MedicationOverview medicationOverview(MedicationOverviewResponse dto) {
    return MedicationOverview(
      totalMedicines: dto.totalMedicines,
      resolvableMedicines: dto.resolvableMedicines,
      duplicates: dto.duplicates
          .map(
            (item) => DuplicateIngredientGroup(
              ingredientKey: item.ingredientKey,
              entryIds: List<String>.unmodifiable(item.entryIds),
              displayNames: List<String>.unmodifiable(item.displayNames),
              severity: _severity(item.severity.value),
            ),
          )
          .toList(growable: false),
      sourceOverlaps: dto.sourceOverlaps
          .map(
            (item) => SourceOverlap(
              // 生成器把 `source` 落成 `source_`（`source` 与 Dart 的注解/字段名
              // 冲突，openapi-generator 统一加尾下划线）。
              source: item.source_,
              medicineCount: item.medicineCount,
              displayNames: List<String>.unmodifiable(item.displayNames),
            ),
          )
          .toList(growable: false),
    );
  }

  /// 服务端状态 → 领域状态。
  ///
  /// 用字符串比对而不是 switch 枚举：九个端点各自有独立的 status 枚举类，
  /// 且生成器给每个都带了 `unknownDefaultOpenApi`。按 value 归一，新增端点不用改这里。
  GraphQueryStatus _status(String value) {
    return switch (value) {
      'ok' => GraphQueryStatus.ok,
      'notConfigured' => GraphQueryStatus.notConfigured,
      'unavailable' => GraphQueryStatus.unavailable,
      'timeout' => GraphQueryStatus.timeout,
      _ => GraphQueryStatus.unknown,
    };
  }

  DuplicateSeverity _severity(String value) {
    return switch (value) {
      'high' => DuplicateSeverity.high,
      // medium 与任何未知取值都按 medium 呈现：这条分支只影响徽章颜色，
      // 不像 status 那样决定「能不能下结论」，因此不需要 unknown 态。
      _ => DuplicateSeverity.medium,
    };
  }
}
