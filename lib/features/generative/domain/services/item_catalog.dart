import 'package:luminous/shared/domain/generative/range_key.dart';

/// 领域组件的 type 名与可用取值。
///
/// 这些是**组件 schema 的词汇**，不是准入规则：A2UI 1.0 取消了内容准入，
/// schema 里的 enum 只决定 agent 能选哪些键，写错了由 `a2ui_core` 在渲染前
/// 校验并报错，不会静默丢弃。
///
/// 计划 §4.1：领域组件从本仓 Riverpod 取真值，agent 只给引用键。
abstract final class GenerativeItemNames {
  static const metricCard = 'metric_card';
  static const trendChart = 'trend_chart';
  static const finding = 'finding';
}

/// 时间范围的允许取值，与 [RangeKey.wireValue] 同源。
final generativeRangeWireValues = <String>{
  for (final range in RangeKey.values) range.wireValue,
};

/// 指标卡的可用维度。
///
/// **由组合根注入**，不从 `ReviewDataKind` 直接映射：`domain/` 不能 import
/// 别的 feature 的 domain（`domain_purity`），而「可用的指标键」本身是
/// **本 surface 的数据声明**，属于装配知识。注入也让测试能用一份假的键集合。
final generativeMetricKinds = <String>{
  'medication',
  'water',
  'sleep',
  'general',
};

/// 后端 findings 的**稳定规则标识**。
///
/// 与 Lucent `dashboard-presenter.ts` 的 `FINDING_IDS` 一一对应：findings 由固定
/// 规则生成，每条规则一个 id（`hydration_low` / `medication_stable` /
/// `sleep_insufficient`）。
///
/// **这不是「当前有哪些 findings」**——某个用户此刻有没有触发某条规则是运行期
/// 事实，由 `GET /reports/dashboard` 决定；这里声明的是**词表**，即 agent 可能
/// 引用的 id 集合，直接进 `finding` 组件的 schema enum。
///
/// 为什么手写而非从契约生成：生成客户端里 `kind` 是枚举，但 `id` 在契约里是
/// 自由字符串（服务端从规则名生成），没有可生成的枚举。
final generativeFindingIds = <String>{
  'hydration_low',
  'medication_stable',
  'sleep_insufficient',
};
