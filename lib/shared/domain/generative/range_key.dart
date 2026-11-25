/// 时间范围引用键（纯值类型，无框架依赖）。
///
/// A2UI 1.0 起客户端不再向服务端声明「这个 surface 能引用哪些数据」——组件
/// schema 里带着 enum，词汇表随 catalog 文档一起下发。所以原来那份 `DataScope`
/// 只剩时间范围这一个值还用得上。
library;

enum RangeKey {
  last7Days('7d'),
  last30Days('30d');

  const RangeKey(this.wireValue);

  final String wireValue;

  static RangeKey? fromWire(Object? raw) {
    for (final value in RangeKey.values) {
      if (value.wireValue == raw) return value;
    }
    return null;
  }
}
