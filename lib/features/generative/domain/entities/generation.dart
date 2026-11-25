/// 生成式 UI 的值类型：一次生成的输入与产物。
///
/// 纯 Dart，无框架依赖：`domain/` 不能 import `a2ui_core`，所以这里存的都是
/// **协议形状的原始 JSON**（`Map<String, Object?>`），而不是渲染树。渲染树是
/// 包内表示，进了 domain 就等于把 0.x 的 API 钉死在领域层。
library;

import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/generative/range_key.dart';

/// 一次生成请求里用户说的话。
///
/// `prompt` 是**用户的原话**，不是模板化后的提示词：拼装规则属于应用层，
/// domain 只负责把它带着走。
final class GenerationPrompt {
  const GenerationPrompt({required this.text});

  final String text;

  /// 空指示不构成一次生成请求。
  bool get isUsable => text.trim().isNotEmpty;
}

/// 一次生成的产物：一条 A2UI 消息序列 + 渲染端的数据模型。
///
/// 存**序列**而不是渲染树：序列是协议的稳定表示，包升级后重放仍能重建。
///
/// `dataModel` 是交互态（表单填了什么、滑块滑到哪）。它必须一起存，否则冷启动
/// 重放出正确的界面、但输入框全空——用户会以为自己的填写丢了。
final class GenerativeSurfaceDocument {
  const GenerativeSurfaceDocument({
    required this.surface,
    required this.messages,
    required this.generatedAt,
    this.dataModel,
  });

  final SurfaceId surface;

  /// A2UI 消息序列，按到达顺序。
  final List<Map<String, Object?>> messages;

  /// 各 surface 的数据模型快照（`{surfaceId: {...}}`）。
  ///
  /// 只有 agent 在 `createSurface.sendDataModel` 里要求回传时才有内容。
  final Map<String, Object?>? dataModel;

  final DateTime generatedAt;

  /// 空文档等于「没生成过」：渲染层据此返回 null，页面因此保持干净。
  bool get isEmpty => messages.isEmpty;

  GenerativeSurfaceDocument copyWith({
    List<Map<String, Object?>>? messages,
    Map<String, Object?>? dataModel,
    DateTime? generatedAt,
  }) {
    return GenerativeSurfaceDocument(
      surface: surface,
      messages: messages ?? this.messages,
      dataModel: dataModel ?? this.dataModel,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}

/// 生成态。
///
/// 四态而不是 `AsyncValue`：`AsyncValue` 的 `isLoading` 与 `hasValue` 不互斥，
/// 生成式 UI 的语义是「没有结果 / 正在生成 / 有结果 / 失败」四选一。
sealed class GenerationState {
  const GenerationState();
}

/// 没有生成结果：渲染层返回 `null`，页面上不占位置。
final class GenerationIdle extends GenerationState {
  const GenerationIdle();
}

/// 正在生成：渲染层给骨架。
final class GenerationInFlight extends GenerationState {
  const GenerationInFlight();
}

/// 有结果：渲染层显示该 surface 的渲染模型。
final class GenerationReady extends GenerationState {
  const GenerationReady(this.document);

  final GenerativeSurfaceDocument document;
}

/// 生成失败：[document] 是上一次成功的结果（可能为 null），渲染层保留它。
final class GenerationFailed extends GenerationState {
  const GenerationFailed({required this.error, this.document});

  final Object error;
  final GenerativeSurfaceDocument? document;
}

/// 一次生成请求。
final class GenerationRequest {
  const GenerationRequest({
    required this.surface,
    required this.prompt,
    this.range,
    this.capabilities = const {},
  });

  final SurfaceId surface;
  final GenerationPrompt prompt;

  /// 用户偏好的时间范围。
  ///
  /// 可选且**只是偏好**：它进提示词，不参与校验——模型忽略它不该变成一次失败。
  final RangeKey? range;

  /// 渲染端能力文档（catalog 的完整描述）。
  ///
  /// 服务端不存第二份词汇表，提示词由这份文档生成。为空表示客户端没有能力
  /// 声明（老版本 / 测试），服务端会退回它自己的兜底词表。
  final Map<String, Object?> capabilities;
}

/// 一次交互回合：渲染端把用户动作送回 agent，agent 续写同一棵树。
final class GenerationTurn {
  const GenerationTurn({
    required this.surface,
    required this.messages,
    required this.document,
    this.capabilities = const {},
  });

  final SurfaceId surface;

  /// 渲染端产出的消息（`action` / `callAgentFunction` /
  /// `rendererFunctionResponse` / `error`）。
  final List<Map<String, Object?>> messages;

  /// 当前完整消息序列：服务端无状态，每次带上。
  final GenerativeSurfaceDocument document;

  final Map<String, Object?> capabilities;
}
