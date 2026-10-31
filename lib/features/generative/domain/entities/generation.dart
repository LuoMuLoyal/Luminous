/// 生成式 UI 的值类型：一次生成的输入与产物。
///
/// 纯 Dart，无框架依赖：`domain/` 不能 import `genui`，所以这里存的都是
/// **协议形状的原始 JSON**（`Map<String, Object?>`），而不是渲染树。渲染树是
/// `genui` 的内部表示，进了 domain 就等于把 0.x 的 API 钉死在领域层。
library;

import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/generative/data_scope.dart';

/// 一次生成请求里用户说的话。
///
/// `prompt` 是**用户的原话**，不是模板化后的提示词：拼装规则属于应用层，
/// domain 只负责把它带着走，避免「用户说了什么」这一事实被改写后被遗忘。
final class GenerationPrompt {
  const GenerationPrompt({required this.text});

  final String text;

  /// 空指示不构成一次生成请求。
  bool get isUsable => text.trim().isNotEmpty;
}

/// 一次生成的产物：一条 A2UI 消息序列。
///
/// 存**序列**而不是渲染树，理由见 `core/composition/genui/store.dart`：
/// 序列是协议的稳定表示，`genui` 升级后重放仍能重建。
final class GenerativeSurfaceDocument {
  const GenerativeSurfaceDocument({
    required this.surface,
    required this.messages,
    required this.generatedAt,
  });

  final SurfaceId surface;

  /// A2UI JSONL：每条是一个消息对象的编码结果，按到达顺序。
  final List<Map<String, Object?>> messages;

  final DateTime generatedAt;

  /// 空文档等于「没生成过」：渲染层据此返回 null，页面因此保持干净。
  bool get isEmpty => messages.isEmpty;

  GenerativeSurfaceDocument copyWith({
    List<Map<String, Object?>>? messages,
    DateTime? generatedAt,
  }) {
    return GenerativeSurfaceDocument(
      surface: surface,
      messages: messages ?? this.messages,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }
}

/// 生成态。
///
/// 四态而不是 `AsyncValue`：`AsyncValue` 的 `isLoading` 与 `hasValue` 不互斥，
/// 生成式 UI 的语义是「没有结果 / 正在生成 / 有结果 / 失败」四选一，混在一起
/// 会让「第一次生成」和「重新生成」的渲染分支纠缠。
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

/// 有结果：渲染层把消息序列重放给渲染引擎。
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

/// 一个 surface 的可生成声明：它有什么数据、本次生成用哪份 scope。
final class GenerationRequest {
  const GenerationRequest({
    required this.surface,
    required this.prompt,
    required this.scope,
  });

  final SurfaceId surface;
  final GenerationPrompt prompt;
  final DataScope scope;
}
