/// 症状目录码 —— 与每日记录 payload `symptom` 的线上取值一一对应。
///
/// 目录的最终来源是 Lucent 的症状目录端点；这份清单同时充当离线/拉取失败时的
/// 兜底副本，因此码必须与后端保持一致。
enum SymptomCode {
  headache,
  stomachache,
  dizzy,
  fever;

  /// payload `symptom` 的线上取值。
  String get wireValue => name;

  /// 解析 payload `symptom`；未知码返回 null（调用方按「无码」处理，不要猜测）。
  static SymptomCode? fromWire(Object? value) {
    if (value is! String) return null;
    for (final code in SymptomCode.values) {
      if (code.wireValue == value) return code;
    }
    return null;
  }
}

/// 症状严重度码 —— 与 payload `severity` 的线上取值一一对应。
///
/// 词汇刻意与 health_context 的过敏严重度相同（`mild` / `moderate` / `severe` /
/// `unknown`），不另造枚举。`unknown` 表示用户明确判断不了：它**不参与趋势判定**
/// （服务端跳过该条，而不是回落成最小严重度），因此不能与 `mild` 混同。
enum SymptomSeverity {
  mild,
  moderate,
  severe,
  unknown;

  /// payload `severity` 的线上取值。
  String get wireValue => name;

  /// 解析 payload `severity`；未知值返回 null。
  static SymptomSeverity? fromWire(Object? value) {
    if (value is! String) return null;
    for (final severity in SymptomSeverity.values) {
      if (severity.wireValue == value) return severity;
    }
    return null;
  }

  /// 严重度选择（设置项与快录弹窗）的展示顺序。
  static const ordered = <SymptomSeverity>[mild, moderate, severe, unknown];
}
