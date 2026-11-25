import 'dart:async';

import 'package:a2ui_core/a2ui_core.dart' show SurfaceModel;
import 'package:a2ui_flutter/a2ui_flutter.dart' show ComponentImplementation;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/composition/generative/generation_repository.dart';
import 'package:luminous/core/composition/a2ui/a2ui.dart';
import 'package:luminous/core/network/app_log.dart';
import 'package:luminous/features/generative/application/orchestrators/generation_session.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/features/generative/domain/repositories/generation.dart';
import 'package:luminous/features/generative/presentation/providers/surface_state.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/generative/range_key.dart';

/// 一个 surface 的生成态，由 [GenerationSession] 驱动。
///
/// **不是 `family`**：每个 surface 已经由 `components/catalog.dart` 在注册时用
/// `ProviderScope(overrides: [generativeSurfaceIdProvider...])` 隔出一份独立的
/// 容器，所以这个 notifier 读到的 surface 就是当前那一份。
///
/// 它同时负责**三件事**：推进生成态、把消息喂给渲染端、把渲染端的上行动作送回
/// agent。三者必须成对发生——消息没进处理器，渲染层拿不到 surface；上行动作没
/// 被接住，用户点按钮就没有任何反应。
final class GenerativeSurfaceNotifier extends Notifier<GenerationState> {
  late GenerationSession _session;
  StreamSubscription<Map<String, Object?>>? _outbound;
  bool _turnInFlight = false;

  @override
  GenerationState build() {
    final surface = ref.watch(generativeSurfaceIdProvider);
    _session = GenerationSession(
      surface: surface,
      repository: ref.watch(generationRepositoryProvider),
    );

    // 渲染端的上行动作（action / callAgentFunction / error）→ 一个交互回合。
    final transport = ref.watch(generativeTransportProvider(surface));
    _outbound = transport.outbound.listen(
      (message) => unawaited(_runTurn(message)),
      onError: (Object error) =>
          appLog.warning('Generative outbound failed: $error'),
    );
    ref.onDispose(() => unawaited(_outbound?.cancel()));

    // 冷启动恢复是异步的：先给 Idle（不占位），读到缓存后再推 Ready。
    unawaited(_restore());
    return const GenerationIdle();
  }

  SurfaceId get _surface => ref.read(generativeSurfaceIdProvider);

  GenerativeTransport get _transport =>
      ref.read(generativeTransportProvider(_surface));

  /// 读缓存并把已有结果重放进渲染端。
  Future<void> _restore() async {
    final restored = await _session.restore();
    // 恢复期间用户可能已经触发了新生成：此时不能让旧缓存覆盖进行中的状态。
    if (state is! GenerationIdle) return;
    _apply(restored);
  }

  /// 触发一次生成。
  ///
  /// 失败**不抛**：它落成 [GenerationFailed]，渲染层据此保留上一份结果。
  Future<void> generate({required String prompt, RangeKey? range}) async {
    final surface = _surface;
    final request = GenerationRequest(
      surface: surface,
      prompt: GenerationPrompt(text: prompt),
      range: range,
      capabilities: _transport.capabilitiesDocument(),
    );

    // 空指示不构成一次请求，也不该发出网络调用。
    if (!request.prompt.isUsable) return;

    _session.begin();
    state = _session.state;

    // 重新生成前先清掉渲染端里那棵树：不清的话旧 surface 与新的消息会叠在
    // 一起。`deleteSurface` 对不存在的 surface 是幂等的。
    final transport = _transport;
    transport.deleteSurface(generativeA2uiSurfaceId(surface));

    try {
      var sawResult = false;
      await for (final event in _session.repository.generate(request)) {
        switch (event) {
          case GenerationStreamChunk(:final message):
            _feed(message);
          case GenerationStreamResult(:final messages, :final dataModel):
            sawResult = true;
            _apply(await _session.commit(messages, dataModel: dataModel));
        }
      }

      // 流正常结束却没收到 `result`：服务端中途关了连接。这不是成功——
      // 若不显式失败，页面会停在 InFlight 的骨架上永远转圈。
      if (!sawResult) _apply(_session.fail(const _StreamEndedWithoutResult()));
    } on Object catch (error) {
      appLog.warning('Generative surface generation failed: $error');
      _apply(_session.fail(error));
    }
  }

  /// 恢复默认：清掉该 surface 的生成结果，并移除渲染端里的树。
  Future<void> reset() async {
    final surface = _surface;
    _transport.deleteSurface(generativeA2uiSurfaceId(surface));
    _apply(await _session.reset());
  }

  /// 一个交互回合：把渲染端产出的消息交给 agent，把它续写的消息叠加回来。
  ///
  /// 串行化：一次只跑一个回合。连点按钮会排队而不是并发——服务端无状态，
  /// 每次带的是「当前文档」，并发两回合会用同一份旧文档各生成一份，结果互相
  /// 覆盖。
  Future<void> _runTurn(Map<String, Object?> message) async {
    if (_turnInFlight) {
      appLog.warning('Skipped A2UI action: a turn is already in flight.');
      return;
    }
    final document = switch (state) {
      GenerationReady(:final document) => document,
      GenerationFailed(:final document) => document,
      GenerationIdle() || GenerationInFlight() => null,
    };
    if (document == null) {
      // 界面上根本没有渲染出来的树，就不可能有点击；到这里说明状态不一致，
      // 丢掉这一条比发给服务端让它报错更安静。
      appLog.warning('Skipped A2UI action: no rendered document.');
      return;
    }

    _turnInFlight = true;
    try {
      final turn = GenerationTurn(
        surface: _surface,
        messages: [message],
        document: document,
        capabilities: _transport.capabilitiesDocument(),
      );
      await for (final event in _session.repository.turn(turn)) {
        switch (event) {
          case GenerationStreamChunk(:final message):
            _feed(message);
          case GenerationStreamResult(:final messages, :final dataModel):
            _apply(await _session.commit(messages, dataModel: dataModel));
        }
      }
    } on Object catch (error) {
      appLog.warning('Generative turn failed: $error');
      // 交互失败不把页面打成错误态：界面上仍是那份还能点的树，用户可以重试。
      _apply(_session.fail(error));
    } finally {
      _turnInFlight = false;
    }
  }

  /// 把一条增量消息喂进渲染端。
  ///
  /// 形状不认识的消息**跳过而不是中止**：`chunk` 是渐进反馈，`result` 才是
  /// 权威序列，后者会重新完整应用一次。
  void _feed(Map<String, Object?> message) {
    _transport
        .processMessages(message)
        .match(
          (error) => appLog.warning('Skipped unusable A2UI chunk: $error'),
          (_) {},
        );
  }

  /// 应用一次状态迁移，并在有文档时把序列重放给渲染端。
  void _apply(GenerationState next) {
    state = next;

    final document = switch (next) {
      GenerationReady(:final document) => document,
      // 失败但带着上一份结果：那份结果需要保持渲染。
      GenerationFailed(:final document) => document,
      GenerationIdle() || GenerationInFlight() => null,
    };
    if (document == null || document.isEmpty) return;

    _replay(document);
  }

  /// 把一份已有的消息序列重放进渲染端。
  ///
  /// 只在尚未建立该 surface 时重放，避免重复 `createSurface`。
  void _replay(GenerativeSurfaceDocument document) {
    final surfaceId = generativeA2uiSurfaceId(_surface);
    if (_transport.surfaceFor(surfaceId) != null) return;
    _transport.processMessages(document.messages);
  }

  /// 该 surface 的渲染模型，渲染层直接用它画。
  SurfaceModel<ComponentImplementation>? surfaceModel() =>
      _transport.surfaceFor(generativeA2uiSurfaceId(_surface));
}

/// 该 surface 的当前生成态。
final generativeStateProvider =
    NotifierProvider<GenerativeSurfaceNotifier, GenerationState>(
      GenerativeSurfaceNotifier.new,
      name: 'generativeState',
    );

/// 生成动作的入口，给 UI 调用。
///
/// 单独一个 provider 而不是让页面直接 `ref.read(generativeStateProvider.notifier)`：
/// 页面上同时有「生成」和「恢复默认」两个动作。
final generativeActionsProvider = Provider<GenerativeActions>(
  (ref) => GenerativeActions(ref),
  dependencies: [generativeStateProvider],
  name: 'generativeActions',
);

/// 生成式 UI 的动作集合：触发生成、恢复默认。
final class GenerativeActions {
  const GenerativeActions(this._ref);

  final Ref _ref;

  /// 触发一次生成；返回 `false` 表示指示为空、没有发起请求。
  Future<bool> generate({required String prompt, RangeKey? range}) {
    if (prompt.trim().isEmpty) return Future.value(false);
    return _ref
        .read(generativeStateProvider.notifier)
        .generate(prompt: prompt, range: range)
        .then((_) => true);
  }

  /// 清掉当前 surface 的生成结果。
  Future<void> reset() => _ref.read(generativeStateProvider.notifier).reset();
}

/// 流在收到 `result` 之前就结束了。
///
/// 单独一个具名守卫而不是 `StateError`：它是**协议的失败**（服务端中途关连接），
/// 不是程序错误，且要被渲染层当作一次普通生成失败处理。
final class _StreamEndedWithoutResult implements Exception {
  const _StreamEndedWithoutResult();

  @override
  String toString() => 'Generation stream ended before a result arrived.';
}
