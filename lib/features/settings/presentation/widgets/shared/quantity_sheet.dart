import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:luminous/core/widgets/common/dialog/edit_sheet.dart';
import 'package:luminous/features/health_context/domain/services/unit_conversion.dart';

/// 身高滚轮选值 sheet body:按保存的单位展示(公制 cm 单轮 / 英制 ft+in 双轮),
/// [slot] 始终承载公制 cm;提交时由调用方取整写入。[suffixes] 与滚轮一一对应
/// (公制 ['cm'],英制 ['ft','in']),拼进每一项文字里标注单位。
class HeightPickerSheetBody extends StatefulWidget {
  const HeightPickerSheetBody({
    super.key,
    required this.slot,
    required this.imperial,
    required this.suffixes,
  });

  final SheetValueSlot<double> slot;
  final bool imperial;
  final List<String> suffixes;

  @override
  State<HeightPickerSheetBody> createState() => _HeightPickerSheetBodyState();
}

class _HeightPickerSheetBodyState extends State<HeightPickerSheetBody> {
  static const _minCm = 50;
  static const _maxCm = 250;
  static const _maxFeet = 8;

  late final List<int> _indexes = _initialIndexes();

  /// `imperial` 在 sheet 打开后视为不可变:滚轮项数、单位后缀与换算方向都按它
  /// 生成,中途切换需要重建滚轮并重算索引。真要支持切换,走 `didUpdateWidget`
  /// 重建 `_indexes`,不要就地改这个 late final。
  List<int> _initialIndexes() {
    if (widget.imperial) {
      final converted = cmToFeetInches(widget.slot.value);
      final feet = converted.feet.clamp(1, _maxFeet);
      // 旧数据可能超出滚轮范围(如 260cm 够 9ft),显示已 clamp 到边界;此时
      // 必须把 slot 一并写成边界值,否则用户不动滚轮直接确认会把越界值原样
      // 回写。仅越界才回写:滚轮英寸取整,无条件回写会让每次打开 sheet 都
      // 轻微改写身高。
      if (feet != converted.feet) {
        widget.slot.value = feetInchesToCm(feet, converted.inches);
      }
      return [feet - 1, converted.inches];
    }
    final cm = widget.slot.value.round().clamp(_minCm, _maxCm);
    // 同上:厘米分支边界为 250,超出时确认会回写越界值。
    if (cm.toDouble() != widget.slot.value) {
      widget.slot.value = cm.toDouble();
    }
    return [cm - _minCm];
  }

  void _onChange(List<int> indexes) {
    widget.slot.value = widget.imperial
        ? feetInchesToCm(indexes[0] + 1, indexes[1])
        : (_minCm + indexes[0]).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    // sheet 骨架把 body 包在纵向 SingleChildScrollView 里,FPicker(ListWheel)
    // 需要有界高度,这里固定滚轮高度。
    return SizedBox(
      height: 160,
      child: FPicker(
        key: const Key('quantity-sheet-picker'),
        control: FPickerControl.lifted(indexes: _indexes, onChange: _onChange),
        children: widget.imperial
            ? [
                FPickerWheel(
                  children: [
                    for (var feet = 1; feet <= _maxFeet; feet++)
                      Text('$feet ${widget.suffixes[0]}'),
                  ],
                ),
                FPickerWheel(
                  loop: true,
                  children: [
                    for (var inch = 0; inch < 12; inch++)
                      Text('$inch ${widget.suffixes[1]}'),
                  ],
                ),
              ]
            : [
                FPickerWheel(
                  children: [
                    for (var cm = _minCm; cm <= _maxCm; cm++)
                      Text('$cm ${widget.suffixes[0]}'),
                  ],
                ),
              ],
      ),
    );
  }
}

/// 体重滚轮选值 sheet body:按保存的单位展示(kg / lb 单轮),[slot] 始终承载
/// 公制 kg;提交时由调用方取整写入。[suffixes] 单项,拼进每一项文字里标注单位。
class WeightPickerSheetBody extends StatefulWidget {
  const WeightPickerSheetBody({
    super.key,
    required this.slot,
    required this.imperial,
    required this.suffixes,
  });

  final SheetValueSlot<double> slot;
  final bool imperial;
  final List<String> suffixes;

  @override
  State<WeightPickerSheetBody> createState() => _WeightPickerSheetBodyState();
}

class _WeightPickerSheetBodyState extends State<WeightPickerSheetBody> {
  static const _minKg = 1;
  static const _maxKg = 500;
  static const _minLb = 1;
  static const _maxLb = 1100;

  late final List<int> _indexes = _initialIndexes();

  /// `imperial` 在 sheet 打开后视为不可变(同身高 body 的说明)。
  List<int> _initialIndexes() {
    if (widget.imperial) {
      final lb = kgToLb(widget.slot.value).round().clamp(_minLb, _maxLb);
      // 见身高 body:仅当取值真的越界(clamp 命中)才同步 slot。滚轮按整数磅
      // 取值,若在此无条件回写,光是打开 sheet 就会把 60kg 变成 59.87kg。
      if (lb == _minLb || lb == _maxLb) {
        widget.slot.value = lbToKg(lb.toDouble());
      }
      return [lb - _minLb];
    }
    final kg = widget.slot.value.round().clamp(_minKg, _maxKg);
    if (kg.toDouble() != widget.slot.value) {
      widget.slot.value = kg.toDouble();
    }
    return [kg - _minKg];
  }

  void _onChange(List<int> indexes) {
    widget.slot.value = widget.imperial
        ? lbToKg((_minLb + indexes[0]).toDouble())
        : (_minKg + indexes[0]).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    // 同身高 body:固定滚轮高度,避免在 sheet 的纵向滚动里拿无界高度。
    return SizedBox(
      height: 160,
      child: FPicker(
        key: const Key('quantity-sheet-picker'),
        control: FPickerControl.lifted(indexes: _indexes, onChange: _onChange),
        children: [
          FPickerWheel(
            children: [
              if (widget.imperial)
                for (var lb = _minLb; lb <= _maxLb; lb++)
                  Text('$lb ${widget.suffixes[0]}')
              else
                for (var kg = _minKg; kg <= _maxKg; kg++)
                  Text('$kg ${widget.suffixes[0]}'),
            ],
          ),
        ],
      ),
    );
  }
}
