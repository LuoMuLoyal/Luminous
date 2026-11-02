import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:luminous/core/network/api.dart';
import 'package:luminous/core/network/client/sse.dart';
import 'package:luminous/core/network/map_utils.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';
import 'package:luminous/shared/domain/generative/data_scope.dart';

// Dart forbids private named parameters, so a `Dio` dependency cannot be
// declared as `required this._dio`; the initializer form is the only option
// here (same shape as `core/network/client/sse.dart`).
// ignore_for_file: prefer_initializing_formals

/// SSE 帧的事件名，与 Lucent `layouts.controller.ts` 写出的 `event:` 字段一一
/// 对应。
///
/// 收拢成常量而不是在 `switch` 里写字面量：它们是**跨仓契约**，改一处却漏改
/// 另一处的后果是「事件被静默跳过」——用户看到的是永远转圈。集中在这里后，
/// 契约漂移只有一个地方要核对。
abstract final class GenerativeSseEvents {
  /// 一条 A2UI 消息（增量）。
  static const chunk = 'chunk';

  /// 完整消息序列（权威）。
  static const result = 'result';

  /// 开流后的失败，data 是完整 Problem Details。
  static const error = 'error';

  /// 正常结束。
  static const done = 'done';
}

/// 远端生成数据源：消费 Lucent 的 `POST /layouts/:surface/generate`。
///
/// 契约（`Lucent/src/modules/layouts/`）——SSE，四个事件：
///
/// | event    | data                                              | 含义 |
/// | -------- | ------------------------------------------------- | ---- |
/// | `chunk`  | 一条 A2UI v0.9 消息对象（JSON）                    | 增量，已解析 |
/// | `result` | `{ surface, messages, usage }`                    | 完整序列，权威 |
/// | `error`  | 完整 Problem Details（含 `status`）                | 开流后的失败 |
/// | `done`   | `{}`                                              | 正常结束 |
///
/// **`chunk` 不是 LLM 文本流**。它是服务端解析好的一条消息 JSON，所以消费方
/// 要用 `GenerativeTransport.feedJsonLine`（或 `feedMessage`），**不能**用
/// `feedChunk`——后者是给未解析的文本做增量解析的，形状对不上会把整段当垃圾。
///
/// **为什么手写而不是用生成客户端**：`text/event-stream` 在 OpenAPI 3.0 里只能
/// 声明成 `type: string`，`openapi_retrofit_generator` 于是只能生成一个
/// `Future<Response<...>>`，拿不到逐帧事件。这与 assistant / today-analysis /
/// review 三处 SSE 的处置相同（见 `LucentApiPaths` 头注释）。
///
/// 开流前的校验（空 prompt / `tab_chrome` / 超长）是普通 HTTP 400/422，会在
/// `postJson` 里以 `DioException` 抛出，经 `LucentErrorMapper` 变成 failure；
/// 只有开流之后的失败才走 `event: error`。
abstract interface class GenerationRemote {
  /// 触发一次生成，返回事件流。
  ///
  /// 流本身不抛异常地成功/失败：网络与协议错误在流上以 [LucentFailure] 抛出，
  /// 由应用层捕获后落成「本次生成失败」。返回 `Stream` 而不是 `TaskEither`，
  /// 是因为增量 chunk 必须在生成过程中就被消费。
  Stream<GenerationRemoteEvent> stream({
    required SurfaceId surface,
    required String prompt,
    RangeKey? range,
  });
}

/// SSE 事件映射出的值类型。
sealed class GenerationRemoteEvent {
  const GenerationRemoteEvent();
}

/// 一条增量消息（`event: chunk`）。
final class GenerationRemoteChunk extends GenerationRemoteEvent {
  const GenerationRemoteChunk(this.message);

  /// 已解析的 A2UI 消息对象。**不校验**——准入规则在应用层。
  final Map<String, Object?> message;
}

/// 一次生成的完整结果（`event: result`）。
///
/// `messages` 是权威序列：`chunk` 只用于渐进反馈，最终落盘与重放都用这里，
/// 否则中途失败会在屏幕上留下半棵树。
final class GenerationRemoteResult extends GenerationRemoteEvent {
  const GenerationRemoteResult({required this.surface, required this.messages});

  final SurfaceId surface;
  final List<Map<String, Object?>> messages;
}

/// 走 `LucentSseClient` 的实现。
final class LucentGenerationRemote implements GenerationRemote {
  const LucentGenerationRemote({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Stream<GenerationRemoteEvent> stream({
    required SurfaceId surface,
    required String prompt,
    RangeKey? range,
  }) async* {
    final sse = LucentSseClient(dio: _dio);

    try {
      await for (final event in sse.postJson(
        LucentApiPaths.generativeSurface(surface.wireValue),
        body: <String, Object?>{
          'prompt': prompt,
          if (range != null) 'range': range.wireValue,
        },
      )) {
        switch (event.event) {
          case GenerativeSseEvents.chunk:
            yield GenerationRemoteChunk(requireMap(event.data));
          case GenerativeSseEvents.result:
            yield _readResult(requireMap(event.data), surface);
          case GenerativeSseEvents.error:
            throw mapSseStreamError(event.data);
          case GenerativeSseEvents.done:
            return;
          default:
            // 未知事件名跳过而不是失败：服务端新增事件不该让旧客户端崩掉，
            // 与 assistant / today-analysis 的 `default: break` 一致。
            break;
        }
      }
    } on DioException catch (error) {
      // 开流前的 400 / 422（空 prompt、`tab_chrome`、超长）就是这样到达的：
      // 它们没有机会变成 `event: error`，只能以 HTTP 错误抛出。映射必须在
      // `data/` 完成——上层拿到的要么是值，要么是 [LucentFailure]。
      final failure = LucentErrorMapper.fromObject(error);
      throw failure;
    }
  }

  /// `event: result` 的 data → [GenerationRemoteResult]。
  ///
  /// 形状错误的 result 必须变成 failure 而不是「空结果」：空结果会让页面
  /// 回到 Idle（不渲染），用户会以为生成成功了但什么都没生成。
  GenerationRemoteResult _readResult(
    Map<String, dynamic> data,
    SurfaceId requested,
  ) {
    final messages = _readMessages(data['messages']);
    if (messages == null) {
      final failure = LucentFailure.network(
        message: 'Generative surface result is missing a message sequence.',
        networkErrorCode: NetworkErrorCode.emptyResponse,
      );
      throw failure;
    }
    // 以请求时的 surface 为准：`result.surface` 是服务端回显，两边不一致说明
    // 串了请求，用回显值会把结果存到错误的键上。
    return GenerationRemoteResult(surface: requested, messages: messages);
  }

  List<Map<String, Object?>>? _readMessages(Object? raw) {
    if (raw is! List) return null;
    return [
      for (final entry in raw)
        if (entry is Map)
          <String, Object?>{
            for (final kv in entry.entries) kv.key.toString(): kv.value,
          },
    ];
  }
}

/// 把一条 A2UI 消息重新编码成 JSONL 单行。
///
/// 放在这里而不是调用点：`GenerativeTransport.feedJsonLine` 要的是字符串，
/// 而这个编码是一次性、无状态的转换，让它跟契约知识待在一处。
String encodeA2uiMessageLine(Map<String, Object?> message) =>
    jsonEncode(message);
