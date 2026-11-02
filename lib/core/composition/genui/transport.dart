import 'dart:async';
import 'dart:convert';

import 'package:a2ui_core/a2ui_core.dart' as core;
import 'package:fpdart/fpdart.dart';
import 'package:genui/genui.dart';
import 'package:luminous/core/composition/genui/catalog.dart';
import 'package:luminous/shared/domain/generative/message_error.dart';

/// 把一个 surface 的 A2UI 消息流接进 `genui` 的渲染引擎。
///
/// 三条输入路径共用同一个 [SurfaceController]：
/// - [feedMessage]：一条已解析的 `a2ui_core.A2uiMessage`；
/// - [feedJsonLine]：一行 JSON（JSONL，A2UI 的标准线上形态）；
/// - [feedChunk]：LLM 文本流出片，内部增量解析（A2UI JSONL 可能跨 chunk
///   断开，交给 `genui` 的解析器处理）。
///
/// **为什么不用 `A2uiTransportAdapter` 做主力**：它主要服务「聊天式生成」，
/// 而我们还要支持「冷启动重放已存的消息序列」和「测试里喂手写消息」两种朴素
/// 路径。这里直接用 `SurfaceController.handleMessage`，三条路都通；只有
/// [feedChunk] 借助 adapter 的增量解析器。
final class GenerativeTransport {
  GenerativeTransport({required GenerativeCatalog catalog})
    : _catalog = catalog,
      controller = SurfaceController(catalogs: [catalog.toCatalog()]);

  final GenerativeCatalog _catalog;

  /// 渲染层用它取 `SurfaceContext`。
  final SurfaceController controller;

  A2uiTransportAdapter? _adapter;
  StreamSubscription<core.A2uiMessage>? _adapterSubscription;

  Catalog get catalog => controller.catalogs.first;

  /// 已注册的 type 名（调试 / 提示词摘要）。
  Set<String> get typeNames => _catalog.typeNames;

  /// 喂一条已解析消息。
  void feedMessage(core.A2uiMessage message) {
    controller.handleMessage(message);
  }

  /// 喂一条**已解码但尚未转成 A2UI 类型**的消息对象。
  ///
  /// 这是服务端 SSE `event: chunk` 的形态：Lucent 发来的 `data` 已经是一个
  /// 解析好的消息 JSON 对象，拿它去走 [feedJsonLine] 要先编码再解码、走
  /// [feedChunk] 则完全错——后者是给未解析的 LLM 文本做增量解析的。
  ///
  /// 形状不认识时返回 `Left`，与 [feedJsonLine] 同语义：调用方据此判断这一条
  /// 是否可用，而不是让页面停在半渲染状态。
  Either<GenerativeMessageError, void> feedMessageJson(
    Map<String, Object?> message,
  ) {
    if (message.isEmpty) {
      return const Left(GenerativeMessageError.notAnObject());
    }
    try {
      controller.handleMessage(core.A2uiMessage.fromJson(message));
    } on Object catch (error) {
      // `fromJson` 对不认识的形状抛异常（协议版本 / 变体名对不上）。那是输入
      // 数据的问题，不是程序错误，作为可返回的失败值交出去。
      return Left(GenerativeMessageError.malformedJson(error.toString()));
    }
    return const Right(null);
  }

  /// 喂一行 JSON（A2UI JSONL 的单行）。
  ///
  /// 形状不认识时返回 `Left`——调用方（重放、测试）据此判断这一行是否可用，
  /// 而不是让页面停在半渲染状态。空行是合法的（JSONL 允许），返回 `Right`。
  Either<GenerativeMessageError, void> feedJsonLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return const Right(null);

    final Object? decoded;
    try {
      decoded = jsonDecode(trimmed);
    } on FormatException catch (error) {
      // 只有「不是 JSON」这一种情况需要接住；这是输入数据的形状问题，
      // 不是程序错误，所以作为可返回的失败值。
      return Left(GenerativeMessageError.malformedJson(error.message));
    }
    if (decoded is! Map) {
      return const Left(GenerativeMessageError.notAnObject());
    }
    final map = <String, Object?>{
      for (final entry in decoded.entries) entry.key.toString(): entry.value,
    };
    controller.handleMessage(core.A2uiMessage.fromJson(map));
    return const Right(null);
  }

  /// 喂 LLM 文本流出片。
  ///
  /// 第一次调用时惰性建 [A2uiTransportAdapter]：它的解析器跨 chunk 保持状态，
  /// 所以中途不能换实例。
  void feedChunk(String chunk) {
    _ensureAdapter();
    _adapter!.addChunk(chunk);
  }

  /// 文本流结束：把解析器缓冲区里的剩余内容推完，并释放 adapter。
  Future<void> finishChunks() async {
    final adapter = _adapter;
    if (adapter == null) return;
    // `flush` 让解析器吐出最后一条消息，并等待消息流排空。
    await adapter.flush();
    await _adapterSubscription?.cancel();
    _adapterSubscription = null;
    _adapter = null;
  }

  void _ensureAdapter() {
    if (_adapter != null) return;
    final adapter = A2uiTransportAdapter();
    _adapter = adapter;
    _adapterSubscription = adapter.incomingMessages.listen(
      controller.handleMessage,
      onError: (Object error) {
        // 解析失败不抛到 UI 线程：这一次生成视作失败，保留上一份 surface。
        controller.reportError(error, StackTrace.current);
      },
    );
  }

  /// 当前活跃的 surface id。
  Iterable<String> get activeSurfaceIds => controller.activeSurfaceIds;

  /// 取某个 surface 的渲染上下文；未创建时返回 `null`。
  SurfaceContext? contextFor(String surfaceId) {
    if (!controller.activeSurfaceIds.contains(surfaceId)) return null;
    return controller.contextFor(surfaceId);
  }

  /// 删掉一个 surface（重新生成前用）。
  void deleteSurface(String surfaceId) {
    controller.handleMessage(
      core.A2uiMessage.fromJson({
        'version': 'v0.9',
        'deleteSurface': {'surfaceId': surfaceId},
      }),
    );
  }

  void dispose() {
    unawaited(_adapterSubscription?.cancel());
    controller.dispose();
  }
}
