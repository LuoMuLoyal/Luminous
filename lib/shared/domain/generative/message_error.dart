/// 生成式界面消息的失败词汇（纯值类型，无框架依赖）。
///
/// 为什么是值而不是 exception：A2UI 消息来自模型，形状不可信——「这一行不是
/// 合法 JSON」是**预期的输入问题**，不是程序错误。调用方（重放、生成流）需要
/// 逐行判断跳过还是中止，用 `Either` 表达就能在类型上强制处理。
library;

/// 一条 A2UI 消息无法被接受的原因。
final class GenerativeMessageError {
  const GenerativeMessageError._({required this.kind, this.detail});

  /// 这一行不是合法 JSON。
  const GenerativeMessageError.malformedJson([String? detail])
    : this._(kind: GenerativeMessageErrorKind.malformedJson, detail: detail);

  /// JSON 合法，但不是对象（A2UI 消息必须是对象）。
  const GenerativeMessageError.notAnObject()
    : this._(kind: GenerativeMessageErrorKind.notAnObject);

  /// 是对象，但没有 A2UI 需要的消息键（`createSurface` 等）。
  const GenerativeMessageError.unknownShape([String? detail])
    : this._(kind: GenerativeMessageErrorKind.unknownShape, detail: detail);

  final GenerativeMessageErrorKind kind;

  /// 开发者诊断信息；不面向用户。
  final String? detail;

  /// 能否跳过这一行继续处理后面的消息。
  ///
  /// 三种情况都是「这一行坏了」，剩下的消息仍然有效——A2UI 的渐进构建本来就
  /// 允许部分失败。调用方通常应该记日志后继续。
  bool get isSkippable => true;

  @override
  String toString() =>
      'GenerativeMessageError(${kind.name}${detail == null ? '' : ': $detail'})';
}

enum GenerativeMessageErrorKind {
  malformedJson,
  notAnObject,
  unknownShape,
}
