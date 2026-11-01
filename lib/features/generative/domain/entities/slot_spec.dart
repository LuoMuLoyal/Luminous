/// 用户自定义生成式区块的**声明**：标题 + 让 agent 渲染什么。
///
/// 与「生成结果」分开存，这是刻意的：
///
/// - 声明是用户投入的认知成本（他想让这块地方长期显示什么），必须能在
///   恢复默认布局、清空生成结果之后仍然留下——否则每次进编排页都要重打一遍；
/// - 结果是 agent 的一次产出，可以重新生成、也可以丢弃，但它不该带着用户的
///   标题一起消失。
///
/// 所以声明存在 `genui.<surface>.spec`，结果存在 `genui.<surface>.surface`
/// （后者的键由 `GenerativeMessageCache` 拥有，本类型不碰）。
///
/// 纯 Dart：这里只描述值，存取在 `data/datasources/`。
final class GenerativeSlotSpec {
  const GenerativeSlotSpec({required this.title, required this.prompt});

  /// 编排页上显示的名字，同时是页面里那块区块的标题。
  final String title;

  /// 交给 agent 的指示（用户原话，不在这里做模板化）。
  final String prompt;

  /// 空标题或空指示都不构成一份可用的声明。
  bool get isUsable => title.trim().isNotEmpty && prompt.trim().isNotEmpty;

  Map<String, Object?> toJson() => {'title': title, 'prompt': prompt};

  static GenerativeSlotSpec? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final title = raw['title'];
    final prompt = raw['prompt'];
    if (title is! String || prompt is! String) return null;
    final spec = GenerativeSlotSpec(title: title, prompt: prompt);
    return spec.isUsable ? spec : null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenerativeSlotSpec &&
          other.title == title &&
          other.prompt == prompt;

  @override
  int get hashCode => Object.hash(title, prompt);

  @override
  String toString() => 'GenerativeSlotSpec($title)';
}
