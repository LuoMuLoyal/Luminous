import 'dart:async';
import 'dart:convert';

import 'package:a2ui_core/a2ui_core.dart';
import 'package:a2ui_flutter/a2ui_flutter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/composition/a2ui/catalog.dart';
import 'package:luminous/shared/domain/generative/message_error.dart';

/// A2UI v1.0 渲染端：一个 surface 一个 [MessageProcessor]。
///
/// ## 三条输入路径
///
/// - [processMessages]：服务端 SSE `event: chunk` 的一条消息，或 `result` 的
///   整段序列；
/// - [processJson]：冷启动重放时从缓存读回的单个消息对象；
/// - [processRaw]：直接交给 processor 的原始 payload（数组 / `{messages: []}`）。
///
/// ## 一条输出路径
///
/// [outbound]：渲染端发给 agent 的消息，已编码成 JSON。
/// v1.0 有四种（`action` / `callAgentFunction` / `rendererFunctionResponse` /
/// `error`），统一走 `outboundListener`——本仓不需要按类型分流，服务端按
/// `messages[]` 里的信封键自己分派。
///
/// ## 为什么是薄封装而不是直接用 MessageProcessor
///
/// `a2ui_core` 是 0.x，`MessageProcessor` 的构造与回调形态还会变。调用方
/// （`features/generative/`）只面对这个方法集，升级时改这一处。
final class GenerativeTransport {
  GenerativeTransport({
    required GenerativeCatalog catalog,
    this.surfaceIdPrefix,
  }) : _catalog = catalog {
    // `outboundListener` 是实例方法，初始化列表里 `this` 还不可用，所以在构造
    // 体里建 processor。
    _processor = MessageProcessor<ComponentImplementation>(
      catalogs: [catalog.catalog],
      defaultVersion: A2uiProtocolVersion.v1_0,
      unifiedOutbound: true,
      outboundListener: _outboundSink,
    );
  }

  final GenerativeCatalog _catalog;
  late final MessageProcessor<ComponentImplementation> _processor;

  /// surface id 前缀，用于把本仓的 `generative.<surface>` 与包内 id 隔开。
  ///
  /// 只影响日志与调试：真正的 surface id 来自消息本身（`createSurface`），
  /// 本类不参与命名。
  final String? surfaceIdPrefix;

  final _outbound = StreamController<Map<String, Object?>>.broadcast();

  /// 渲染端发给 agent 的消息流（JSON 信封）。
  Stream<Map<String, Object?>> get outbound => _outbound.stream;

  /// 已注册的组件 type 名（调试 / 能力摘要）。
  Set<String> get typeNames => _catalog.typeNames;

  /// 各 surface 的当前数据模型快照，随上行动作一起发给 agent。
  ///
  /// 只有 `createSurface.sendDataModel` 为 true 的 surface 会出现——这是协议
  /// 的规定，不是本仓的选择：agent 没要求回传就不回传。
  Map<String, Object?>? dataModelSnapshot() =>
      _processor.getRendererDataModel(version: A2uiProtocolVersion.v1_0);

  /// 渲染端能力描述。服务端据此决定能下发哪些组件。
  ///
  /// `includeInlineCatalogs: true` 让文档里带上完整 catalog——服务端不存第二份
  /// 词汇表，提示词直接由它生成。
  Map<String, Object?> capabilitiesDocument() => _processor
      .getRendererCapabilities(
        const CapabilitiesOptions(
          versions: [A2uiProtocolVersion.v1_0],
          includeInlineCatalogs: true,
        ),
      )
      .toJson();

  /// 当前活跃的 surface id。
  Iterable<String> get activeSurfaceIds =>
      _processor.model.allSurfaces.map((surface) => surface.id);

  /// 取某个 surface 的渲染模型；不存在时 `null`。
  SurfaceModel<ComponentImplementation>? surfaceFor(String surfaceId) =>
      _processor.model.getSurface(surfaceId);

  /// 应用一段消息（SSE `chunk` 或 `result` 的整段序列）。
  ///
  /// 返回 `Left` 表示这段 payload 整体不可用（形状不认识 / 校验失败）。
  /// **一条坏消息不会污染后续**：processor 逐条校验，坏的被拒绝并写进
  /// [lastErrors]，好的照常应用——这符合 A2UI 渐进构建的语义。
  Either<GenerativeMessageError, void> processMessages(Object payload) {
    final errors = _processor.processMessagesWithErrors(payload);
    if (errors.isEmpty) return const Right(null);
    _lastErrors = errors;
    // 只在整个 payload 都没能被解析时算失败；部分失败仍然有效。
    if (_surfacesUnchangedAfter(payload)) {
      return Left(GenerativeMessageError.unknownShape(_describe(errors)));
    }
    return const Right(null);
  }

  List<ErrorMessage> _lastErrors = const [];

  /// 上一次处理的失败消息（诊断用；不面向用户）。
  List<ErrorMessage> get lastErrors => _lastErrors;

  /// 删掉一个 surface（重新生成前用）。
  ///
  /// surface 已不存在时静默通过：`deleteSurface` 是幂等意图，调用方不该先
  /// 查一遍再删。
  void deleteSurface(String surfaceId) {
    _processor.model.deleteSurface(surfaceId);
  }

  /// 当前 surface 的 JSON 快照，写缓存用。
  ///
  /// 只有消息序列是权威可重放的表示；渲染树依赖包内模型，升级后会失效。
  /// 本类不缓存消息——那由调用方（`features/generative/data/`）做，因为缓存
  /// 要碰 `KvStore`。
  void dispose() {
    unawaited(_outbound.close());
    _processor.dispose();
  }

  // ── 内部 ──────────────────────────────────────────────────────────────

  /// `outboundListener` 的落点。
  ///
  /// 统一成 JSON 再入流：调用方不该看见 `a2ui_core` 的消息类型，否则 0.x 的
  /// API 变更会漏到 `features/`。
  void _outboundSink(RendererToAgentMessage message) {
    if (_outbound.isClosed) return;
    try {
      _outbound.add(message.toJson());
    } on Object catch (error) {
      // 编码失败只丢这一条：上行动作丢失不该让渲染端崩掉。
      _outbound.add({
        'version': A2uiProtocolVersion.v1_0.jsonValue,
        'error': {'message': 'Failed to encode outbound message: $error'},
      });
    }
  }

  bool _surfacesUnchangedAfter(Object payload) {
    // 极端情况下的兜底：payload 连一条消息都没解析出来。真实判断在 processor
    // 里，这里只看「处理完有没有任何 surface」。
    final _ = payload;
    return _processor.model.allSurfaces.isEmpty;
  }

  String _describe(List<ErrorMessage> errors) =>
      errors.map((error) => error.error.message).join('; ');
}

/// 把一条消息编码成 JSONL 单行（缓存 / 调试输出用）。
String encodeA2uiMessageLine(Map<String, Object?> message) =>
    jsonEncode(message);
