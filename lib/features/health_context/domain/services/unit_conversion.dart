import 'package:luminous/features/health_context/domain/entities/write_inputs.dart';
import 'package:units_converter/units_converter.dart';

/// 单位制显示换算（仅展示换算，存储口径不变）。
///
/// `profile.unitSystem` 是用户在个人信息页保存的展示设置（`metric` |
/// `imperial`，未设置/未知时按公制处理），本工具只做**纯展示换算**：
///
/// - 不修改任何写入数据——接口与存储仍以公制（kg / cm）为准；
/// - metric / 未设置（null）/ 未知字符串一律按公制展示；
/// - 仅当 [isImperialUnitSystem] 返回 `true` 时才走英制换算。
///
/// 换算由 `units_converter` 提供（精确系数），函数本身不取整；展示时的
/// round / 保留小数位由调用方按所在展示点的既有格式决定（体重与 kg 展示
/// 一致用 round()，饮水 fl oz 保留 1 位小数）。包返回 null 时回退到本地
/// 精确常数，正常情况下不会触发。

/// kg → lb 回退系数（1 kg = 2.2046226218 lb）。
const double _kgToLbFactor = 2.2046226218;

/// ml → fl oz 精确换算系数（1 ml = 0.0338140227 fl oz）。
const double _mlToFlOzFactor = 0.0338140227;

/// 1 inch = 2.54 cm（回退用）。
const double _cmPerInch = 2.54;

/// 是否为英制单位制（imperial）。
///
/// [HealthUnitSystem.fromValue] 无法识别（null / 未知字符串）时视为公制。
bool isImperialUnitSystem(String? unitSystem) {
  return HealthUnitSystem.fromValue(unitSystem) == HealthUnitSystem.imperial;
}

/// 体重 kg → lb 换算。
///
/// 返回换算后的磅值（不取整）；展示时与 kg 展示一致调用 `round()`。
double kgToLb(double kg) {
  return kg.convertFromTo(MASS.kilograms, MASS.pounds) ?? kg * _kgToLbFactor;
}

/// 旧接口别名：档案区既有调用点。
double? weightInLb(double? kg) => kg == null ? null : kgToLb(kg);

/// 体重 lb → kg 换算（编辑 sheet 英制输入回写公制存储用，不取整）。
double lbToKg(double lb) {
  return lb.convertFromTo(MASS.pounds, MASS.kilograms) ?? lb / _kgToLbFactor;
}

/// 身高 cm → (feet, inches)，inches 0–11（进位已归一）。
({int feet, int inches}) cmToFeetInches(double cm) {
  final totalInches =
      cm.convertFromTo(LENGTH.centimeters, LENGTH.inches) ?? cm / _cmPerInch;
  var feet = totalInches ~/ 12;
  var inches = (totalInches - feet * 12).round();
  if (inches == 12) {
    feet += 1;
    inches = 0;
  }
  return (feet: feet, inches: inches);
}

/// 身高 (feet, inches) → cm（编辑 sheet 英制输入回写公制存储用，不取整）。
double feetInchesToCm(int feet, int inches) {
  final totalFeet = feet + inches / 12;
  return totalFeet.convertFromTo(LENGTH.feet, LENGTH.centimeters) ??
      totalFeet * 12 * _cmPerInch;
}

/// 饮水 ml → fl oz 换算。
///
/// 展示时建议保留 1 位小数（如 "18.6"）。
double waterInFlOz(num ml) {
  return ml * _mlToFlOzFactor;
}
