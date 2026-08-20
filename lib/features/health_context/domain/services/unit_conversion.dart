import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';

/// 单位制显示换算（仅展示换算，存储口径不变）。
///
/// `profile.unitSystem` 是档案存储字段（`metric` | `imperial`，未设置/未知时
/// 按公制处理），本工具只做 kg→lb、ml→fl oz 的**纯展示换算**：
///
/// - 不修改任何写入数据——接口与存储仍以公制（kg/ml）为准；
/// - metric / 未设置（null）/ 未知字符串一律按公制展示；
/// - 仅当 [isImperialUnitSystem] 返回 `true` 时才走英制换算。
///
/// 换算系数为精确常数，函数本身不取整；展示时的 round / 保留小数位由
/// 调用方按所在展示点的既有格式决定（体重与 kg 展示一致用 round()，
/// 饮水 fl oz 保留 1 位小数）。

/// kg → lb 精确换算系数（1 kg = 2.2046226218 lb）。
const double _kgToLbFactor = 2.2046226218;

/// ml → fl oz 精确换算系数（1 ml = 0.0338140227 fl oz）。
const double _mlToFlOzFactor = 0.0338140227;

/// 是否为英制单位制（imperial）。
///
/// [HealthUnitSystem.fromValue] 无法识别（null / 未知字符串）时视为公制。
bool isImperialUnitSystem(String? unitSystem) {
  return HealthUnitSystem.fromValue(unitSystem) == HealthUnitSystem.imperial;
}

/// 体重 kg → lb 换算。
///
/// 返回换算后的磅值（不取整）；展示时与 kg 展示一致调用 `round()`。
/// [kg] 为 null 时返回 null。
double? weightInLb(double? kg) {
  if (kg == null) return null;
  return kg * _kgToLbFactor;
}

/// 饮水 ml → fl oz 换算。
///
/// 展示时建议保留 1 位小数（如 "18.6"）。
double waterInFlOz(num ml) {
  return ml * _mlToFlOzFactor;
}
