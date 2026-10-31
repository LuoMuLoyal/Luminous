import 'package:luminous/shared/domain/composition/surface.dart';

/// 一个 surface 能给生成式 UI 用哪些数据。
///
/// 这是**提示词的来源**：告诉 agent「这张表能拿到什么」，它才知道可以说什么。
/// 同时也是校验依据——`kind` 不在列表里的引用键会被拒绝，避免 agent 引用一个
/// 该 surface 根本不存在的维度。
///
/// 刻意保持纯数据（无 Riverpod、无 genui 类型）：它要能被 domain 层引用，
/// 也要能被序列化进提示词。
final class DataScope {
  const DataScope({required this.surface, required this.entries});

  final SurfaceId surface;
  final List<DataScopeEntry> entries;

  /// 该 scope 里所有可引用的键。
  Set<String> get keys => {for (final entry in entries) entry.key};

  /// 某类引用的可用取值。
  List<String> valuesOf(DataScopeKind kind) =>
      entries.where((entry) => entry.kind == kind).map((e) => e.key).toList();

  /// 渲染成提示词片段：只列「能展示什么」，不编造具体数值。
  String toPromptFragment() {
    final buffer = StringBuffer('Available data for this screen:\n');
    for (final entry in entries) {
      buffer.writeln('- ${entry.key}: ${entry.description}');
    }
    return buffer.toString();
  }
}

/// 一条可引用的数据。
final class DataScopeEntry {
  const DataScopeEntry({
    required this.key,
    required this.kind,
    required this.description,
    this.allowedRanges = const [],
    this.unit,
  });

  /// 引用键，例如 `water` / `medication` / `sleep`。
  final String key;
  final DataScopeKind kind;

  /// 给模型看的一句话说明（进提示词，不是 UI 文案）。
  final String description;

  /// 允许的时间范围；空表示不适用（如单条 findings）。
  final List<RangeKey> allowedRanges;

  /// 单位，供模型理解量级。
  final String? unit;
}

enum DataScopeKind {
  /// 时间序列指标，可绑 `range`。
  metric,

  /// 单条洞察 / 发现，按 id 引用。
  finding,

  /// 建议，按 id 引用。
  suggestion,
}

/// 时间范围引用键。
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
