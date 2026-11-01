import 'package:freezed_annotation/freezed_annotation.dart';

part 'relations.freezed.dart';

/// 一条关系查询的可用性。
///
/// 这是**整个 A5-1 组件的语义核心**：`ok` 之外的三态都表示「我们无法回答」，
/// 渲染层必须显示「暂时无法给出机理分析」，**不得**显示成「无相互作用」。
/// 把后者与空数组混同，是用药场景里最危险的静默降级
/// （与后端 `GraphQueryStatus` 一一对应，见 Lucent `dto/relations.ts`）。
enum GraphQueryStatus {
  ok,
  notConfigured,
  unavailable,
  timeout,

  /// 服务端新增了本客户端不认识的状态。按「无法回答」处理，而不是按 `ok`。
  unknown,
}

/// 图查询结果的信封。
///
/// 数据键在失败态下缺省，所以 `items` 只在该状态为 [GraphQueryStatus.ok] 时可信。
/// 用 `items == null` 与 `items.isEmpty` 区分「查不了」与「确实没有」。
@freezed
abstract class GraphQueryResult<T> with _$GraphQueryResult<T> {
  const factory GraphQueryResult({
    required GraphQueryStatus status,
    List<T>? items,
  }) = _GraphQueryResult<T>;

  const GraphQueryResult._();

  /// 我们是否拿到了一个可信的答案（可能是空的）。
  bool get isAnswerable => status == GraphQueryStatus.ok && items != null;

  /// 确认存在的条目；不可回答时为空表，调用方必须先看 [isAnswerable]。
  List<T> get safeItems => items ?? const [];

  bool get isEmptyAnswer => isAnswerable && safeItems.isEmpty;
}

/// `INHIBITS` / `INDUCES` × `SUBSTRATE_OF` 二跳通路。
@freezed
abstract class MechanismPath with _$MechanismPath {
  const factory MechanismPath({
    required String enzymeGene,
    required String enzymeName,
    required String otherDrugId,
    required String otherDrugName,

    /// 起始药对该酶的作用，`INHIBITS` / `INDUCES`。
    required String relation,
  }) = _MechanismPath;
}

/// 这组药在图上交汇的靶点。
@freezed
abstract class SharedTarget with _$SharedTarget {
  const factory SharedTarget({
    required String targetGene,
    required String targetName,
    required int drugCount,
    required List<String> drugIds,
    required List<String> drugNames,
  }) = _SharedTarget;
}

/// 4 跳代谢级联：A 抑制酶1 → C 是酶1底物且抑制酶2 → B 是酶2底物。
@freezed
abstract class CascadePath with _$CascadePath {
  const factory CascadePath({
    required String startDrug,
    required String enzymeOne,
    required String middleDrug,
    required String enzymeTwo,
    required String endDrug,
  }) = _CascadePath;
}

/// 结构性替代候选：不走指定酶、但作用于同一靶点。
///
/// 刻意不含「推荐」「更适合」字段——这是结构事实，不是处方建议。
@freezed
abstract class SubstituteCandidate with _$SubstituteCandidate {
  const factory SubstituteCandidate({
    required String drugbankId,
    required String name,
    String? sharedTarget,
  }) = _SubstituteCandidate;
}

/// 单药作用谱的一行。
@freezed
abstract class DrugAction with _$DrugAction {
  const factory DrugAction({
    required String targetGene,
    required String targetName,
    required String relation,
    required List<String> actions,
  }) = _DrugAction;
}

/// 两药之间的最短传播路径。
///
/// `pathNodes` 与 `pathRelations` 逐位对应，渲染层据此画出整条链。
@freezed
abstract class ShortestRoute with _$ShortestRoute {
  const factory ShortestRoute({
    required int stepCount,
    required List<String> pathNodes,
    required List<String> pathRelations,
  }) = _ShortestRoute;
}

/// 靶点视角的一行：某药作用于该靶点的方式。
@freezed
abstract class TargetDrug with _$TargetDrug {
  const factory TargetDrug({
    required String drugbankId,
    required String name,
    required String relation,
  }) = _TargetDrug;
}

/// 转运体路径。
///
/// [inverted] 为 true 表示边方向与「药物 → 转运体」相反（药物是终点）。
/// 展示时不得画成同向箭头——方向讲反与讲错结论一样危险。
@freezed
abstract class TransportRoute with _$TransportRoute {
  const factory TransportRoute({
    required String transporterGene,
    required String transporterName,
    required bool inverted,
  }) = _TransportRoute;
}

/// 酶诱导 × 底物拮抗：诱导剂让酶变多，底物药浓度下降。
@freezed
abstract class EnzymeDuel with _$EnzymeDuel {
  const factory EnzymeDuel({
    required String enzymeGene,
    required String inducerDrug,
    required String inhibitedSubstrate,
  }) = _EnzymeDuel;
}

/// 用药组合概览：同一成分几份、按来源如何分组。
///
/// 这是**现状描述**，不是判定；判级仍归 `/risk-check`。
@freezed
abstract class MedicationOverview with _$MedicationOverview {
  const factory MedicationOverview({
    required int totalMedicines,
    required int resolvableMedicines,
    required List<DuplicateIngredientGroup> duplicates,
    required List<SourceOverlap> sourceOverlaps,
  }) = _MedicationOverview;
}

@freezed
abstract class DuplicateIngredientGroup with _$DuplicateIngredientGroup {
  const factory DuplicateIngredientGroup({
    required String ingredientKey,
    required List<String> entryIds,
    required List<String> displayNames,

    /// `high`：三条以上共用该成分，或跨两个知识来源。
    required DuplicateSeverity severity,
  }) = _DuplicateIngredientGroup;
}

enum DuplicateSeverity { medium, high }

@freezed
abstract class SourceOverlap with _$SourceOverlap {
  const factory SourceOverlap({
    /// 健康事件 id；无法归属时为 `unattributed`。
    required String source,
    required int medicineCount,
    required List<String> displayNames,
  }) = _SourceOverlap;

  const SourceOverlap._();

  /// `unattributed` 是后端的显式取值，不是缺失——UI 要单独措辞。
  bool get isUnattributed => source == 'unattributed';
}
