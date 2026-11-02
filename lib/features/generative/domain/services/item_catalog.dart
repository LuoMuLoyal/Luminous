import 'package:luminous/features/generative/domain/services/catalog_policy.dart';
import 'package:luminous/shared/domain/generative/data_scope.dart';

/// 首批领域 item 的 type 名。
///
/// 计划 §4.1：agent 只能声明**引用键**，渲染时从 Riverpod 取真值。
abstract final class GenerativeItemNames {
  static const metricCard = 'metric_card';
  static const trendChart = 'trend_chart';
  static const finding = 'finding';
}

/// 时间范围的允许取值，与 `RangeKey.wireValue` 同源。
final generativeRangeWireValues = <String>{
  for (final range in RangeKey.values) range.wireValue,
};

/// 指标卡的可用维度。
///
/// **由组合根注入**，不从 `ReviewDataKind` 直接映射：`domain/` 不能 import
/// 别的 feature 的 domain（`domain_purity`），而「可用的指标键」本身是
/// **本 surface 的数据声明**，属于装配知识。注入也让测试能用一份假的键集合。
/// 组合根那里用 `ReviewDataKind.values` 生成，保证与 review 实际提供的维度一致。
final generativeMetricKinds = <String>{
  'medication',
  'water',
  'sleep',
  'general',
};

/// 后端 findings 的**稳定规则标识**。
///
/// 与 Lucent `dashboard-presenter.ts` 的 `FINDING_IDS` 一一对应：findings 由
/// 固定规则生成，每条规则一个 id（`hydration_low` / `medication_stable` /
/// `sleep_insufficient`）。
///
/// **这不是「当前有哪些 findings」**——某个用户此刻有没有触发某条规则是运行期
/// 事实，由 `GET /reports/dashboard` 决定；这里声明的是**词表**，即 agent 可能
/// 引用的 id 集合，`catalog_policy` 用它做准入。
///
/// 为什么手写而非从契约生成：生成客户端里 `kind` 是枚举，但 `id` 在契约里是
/// 自由字符串（服务端从规则名生成），没有可生成的枚举。所以这份清单需要与后端
/// 对账——`test/generative/catalog_policy_test.dart` 断言它的形状（ASCII、
/// 下划线命名），后端那边 `generative-vocabulary.e2e-spec.ts` 做跨仓对账。
final generativeFindingIds = <String>{
  'hydration_low',
  'medication_stable',
  'sleep_insufficient',
};

/// 首批领域 item 的准入规则。
///
/// 三条规则对应计划 §4.1 的三行表格。共同点：
/// - `allowedKeys` 是白名单（`additionalProperties: false` 的等价物）——agent
///   自创的字段一律不认；
/// - `requiredKeys` 缺一不可；
/// - 真正的安全线是「**不允许任何数值属性**」：`value` / `data` / `amount`
///   这些名字根本不在白名单里，而进了白名单的引用键必须是 scope 里存在的
///   字符串。`checkComponent` 对任何数值属性一律拒绝。
///
/// `metric_card` 与 `trend_chart` 只差单维 / 多维：指标卡回答「这个指标现在
/// 多少」，趋势图可单可多，所以趋势图拆成两条 policy（`kind` 与 `kinds`），
/// 调用方按 agent 实际给出的形状选择用哪条校验。
final metricCardPolicy = CatalogItemPolicy(
  name: GenerativeItemNames.metricCard,
  allowedKeys: {'kind', 'range'},
  requiredKeys: {'kind'},
  referenceKeys: {'kind': DataScopeKind.metric},
  enumValues: {'range': generativeRangeWireValues},
);

/// 趋势图（单维）。
final trendChartSinglePolicy = CatalogItemPolicy(
  name: GenerativeItemNames.trendChart,
  allowedKeys: {'kind', 'range'},
  requiredKeys: {'kind'},
  referenceKeys: {'kind': DataScopeKind.metric},
  enumValues: {'range': generativeRangeWireValues},
);

/// 趋势图（多维）。
///
/// 不做成「两个都允许、都不强制」：那样 agent 可能两个都不给，渲染时只能
/// 替它猜，而猜错等于显示错的指标。
final trendChartMultiPolicy = CatalogItemPolicy(
  name: GenerativeItemNames.trendChart,
  allowedKeys: {'kinds', 'range'},
  requiredKeys: {'kinds'},
  referenceListKeys: {'kinds': DataScopeKind.metric},
  enumValues: {'range': generativeRangeWireValues},
);

/// `finding` 是安全边界的关键：医学结论文案必须原样呈现，agent 只能选展示
/// 哪一条，**不能改写**。
///
/// 所以它只有一个属性 `findingId`，且必须是后端 findings 里真实存在的 id。
/// 没有任何文案属性进白名单——agent 想写「你的睡眠很差」这类结论，规则层
/// 直接拒绝。
const findingPolicy = CatalogItemPolicy(
  name: GenerativeItemNames.finding,
  allowedKeys: {'findingId'},
  requiredKeys: {'findingId'},
  referenceKeys: {'findingId': DataScopeKind.finding},
);

/// 组装首批领域 item 的 policy 表，按 type 名索引。
///
/// `trend_chart` 有两种形状，单值表里装**所有变体合并后的宽规则**：必需键取
/// 交集（空），允许键取并集。宽规则只负责形状无关的检查（数值 / DataScope
/// 引用 / 枚举）；「`kind` 与 `kinds` 必须给其一」由
/// [buildPolicyVariants] 的变体在应用层断言。直接用宽规则做唯一校验会放过
/// 两个都不给的组件，那会让渲染层只能替 agent 猜。
Map<String, CatalogItemPolicy> buildGenerativePolicies() {
  return {
    metricCardPolicy.name: metricCardPolicy,
    trendChartSinglePolicy.name: _mergeVariants([
      trendChartSinglePolicy,
      trendChartMultiPolicy,
    ]),
    findingPolicy.name: findingPolicy,
  };
}

/// 把同一 type 的多个变体合并成一条宽规则。
///
/// 必需键取**交集**：只有每个变体都要求的键才算合并后的必需键。`trend_chart`
/// 单维要 `kind`、多维要 `kinds`，交集为空——这正是想要的：宽规则不替 agent
/// 决定形状，形状由变体在那一步判断。
CatalogItemPolicy _mergeVariants(List<CatalogItemPolicy> variants) {
  final allRequired = {for (final v in variants) ...v.requiredKeys};
  final required = {
    for (final key in allRequired)
      if (variants.every((v) => v.requiredKeys.contains(key))) key,
  };
  return CatalogItemPolicy(
    name: variants.first.name,
    allowedKeys: {for (final v in variants) ...v.allowedKeys},
    requiredKeys: required,
    referenceKeys: {for (final v in variants) ...v.referenceKeys},
    referenceListKeys: {for (final v in variants) ...v.referenceListKeys},
    enumValues: {for (final v in variants) ...v.enumValues},
  );
}

/// 该类型名的所有合法 policy 变体。
///
/// 校验一条组件时按实际属性选择对应变体：同时给了 `kind` 与 `kinds` 的组件
/// 两条都对不上（各自的 requiredKeys 会报缺键），这正是想要的——形状含糊的
/// 定义不该被猜着渲染。
Map<String, List<CatalogItemPolicy>> buildPolicyVariants() {
  return {
    metricCardPolicy.name: [metricCardPolicy],
    trendChartSinglePolicy.name: [
      trendChartSinglePolicy,
      trendChartMultiPolicy,
    ],
    findingPolicy.name: [findingPolicy],
  };
}
