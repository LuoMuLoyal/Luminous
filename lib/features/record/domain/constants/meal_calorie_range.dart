/// 餐食热量区间的展示粗化口径。
///
/// 「详情页的粗化区间」与「列表角标的粗化区间」必须是同一个口径:两处各自实现
/// 一份私有副本时,改动精度(比如从 100 改成 50)只改一边就会让同一个记录在两个
/// 页面显示不同的区间。这里集中定义,两个消费方都调它。
library;

/// 把热量数值粗化到百位(四舍五入),负数钳到 0。
///
/// 负值按 0 处理而不是保留符号:热量区间是展示用的量级提示,出现负值只可能是
/// 上流数据异常,钳到 0 比显示「-100–300」更不容易被误读。
int roundToHundreds(int value) {
  final rounded = (value / 100).round() * 100;
  return rounded < 0 ? 0 : rounded;
}

/// 粗化后的区间文案,例如 `500–800`。
///
/// 用 en dash(U+2013)而不是 ASCII 连字符,与设计稿的区间写法一致。
String formatCoarseCalorieRange({required int min, required int max}) =>
    '${roundToHundreds(min)}–${roundToHundreds(max)}';
