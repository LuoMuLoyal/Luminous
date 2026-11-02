/// 图查询的入参：从用户当前用药里挑出可参与药理分析的 DrugBank id。
///
/// 这是**纯值 + 纯规则**，放在 `domain/` 不依赖任何别的 feature。它与
/// `CurrentMedicineItem` 解耦：调用方只交出「每个药的 (sourceRefId, 是否在册)」，
/// 本文件不知道 health_context 的存在。
///
/// ## 为什么不能直接拿「当前用药」全量
///
/// 后端关系图端点的入参是 **DrugBank id**（`DB` + 5 位数字，2–10 个），而用药条目
/// 里只有 DrugBank 来源才带这种编号；中药、商品名、自定义录入都没有。
///
/// 这带来一个必须在 UI 上说清楚的事实：**「你有 5 种药」不等于「5 种药都参与了
/// 药理分析」**。若把两者混为一谈，用户看到「无相互作用」会误以为是全量结论，
/// 而实际只覆盖了其中 2 种。所以这里同时给出「总药数 / 可分析药数」。
library;

/// 多药查询的入参上限，与后端 `multiDrugQuerySchema` 一致。
const int graphMaxDrugIds = 10;

/// `DB` + 5 位数字。
final RegExp _drugbankIdPattern = RegExp(r'^DB\d{5}$');

/// 一条用药条目里与图查询相关的部分。
final class GraphDrugEntry {
  const GraphDrugEntry({
    required this.sourceRefId,
    required this.isCurrent,
    this.displayName,
  });

  /// 来源编号；只有 DrugBank 来源会形如 `DB00682`。
  final String? sourceRefId;

  /// 是否在册（历史用药不构成当下的组合风险）。
  final bool isCurrent;

  /// 用户可读的药名（如「阿司匹林肠溶片」）。
  ///
  /// `DB00331` 这种编号对用户没有意义：选择器里只能显示名字。药名与 id 一起
  /// 从上游带下来，因为派生之后就拿不到 `CurrentMedicineItem` 了。
  /// 允许为空——历史数据可能只有编号没有名字，此时退回显示 id。
  final String? displayName;
}

/// 派生结果。
final class GraphDrugSet {
  const GraphDrugSet({
    required this.drugbankIds,
    required this.totalMedicines,
    this.names = const {},
  });

  /// 去重后的 DrugBank id，按字典序稳定排序。
  ///
  /// 排序是为了让「同一组药」得到同一个 provider key：换一次顺序不该触发重新查询，
  /// 否则用户拖动一下布局就会重新打一遍图库。
  final List<String> drugbankIds;

  /// 当前在册药品总数（含不可解析的）。
  final int totalMedicines;

  /// DrugBank id → 药名。选择器显示用；缺项时调用方退回显示 id。
  final Map<String, String> names;

  /// [drugbankId] 的可读名字，没有名字时退回 id 本身。
  String labelOf(String drugbankId) {
    final name = names[drugbankId]?.trim();
    return (name == null || name.isEmpty) ? drugbankId : name;
  }

  /// 端点要求至少两个药才有「两两关系」。
  bool get hasPair => drugbankIds.length >= 2;

  /// 不能参与药理分析的药数。
  int get unresolvableCount {
    final rest = totalMedicines - drugbankIds.length;
    return rest > 0 ? rest : 0;
  }

  static const GraphDrugSet empty = GraphDrugSet(
    drugbankIds: <String>[],
    totalMedicines: 0,
  );
}

/// 从用药条目派生图查询入参。
GraphDrugSet deriveGraphDrugSet(Iterable<GraphDrugEntry> entries) {
  var total = 0;
  final ids = <String>{};
  final names = <String, String>{};
  for (final entry in entries) {
    if (!entry.isCurrent) continue;
    total += 1;
    final ref = entry.sourceRefId?.trim();
    if (ref == null || ref.isEmpty) continue;
    // 只看形态，不校验 source 字段：上游把 DrugBank id 记在别的 source 名下是
    // 可能的，而 `DB\\d{5}` 本身已经足够唯一。
    if (!_drugbankIdPattern.hasMatch(ref)) continue;
    ids.add(ref);
    final name = entry.displayName?.trim();
    // 同一 id 可能对应多条记录（换过规格等）；先到先得，但空名字不覆盖已有名字。
    if (name != null && name.isNotEmpty && !names.containsKey(ref)) {
      names[ref] = name;
    }
  }

  final sorted = ids.toList()..sort();
  final kept = sorted.length > graphMaxDrugIds
      ? sorted.sublist(0, graphMaxDrugIds)
      : sorted;
  return GraphDrugSet(
    drugbankIds: kept,
    totalMedicines: total,
    names: {
      for (final id in kept)
        if (names[id] != null) id: names[id]!,
    },
  );
}
