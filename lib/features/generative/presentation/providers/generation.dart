import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/composition/generative/generation_repository.dart';
import 'package:luminous/core/composition/genui/genui.dart';
import 'package:luminous/core/network/app_log.dart';
import 'package:luminous/features/generative/application/orchestrators/generation_session.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/features/generative/domain/repositories/generation.dart';
import 'package:luminous/features/generative/domain/services/item_catalog.dart';
import 'package:luminous/features/generative/presentation/providers/surface_state.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/generative/data_scope.dart';

/// 一个 surface 的生成态，由 [GenerationSession] 驱动。
///
/// **不是 `family`**：每个 surface 已经由 `components/catalog.dart` 在注册时用
/// `ProviderScope(overrides: [generativeSurfaceIdProvider...])` 隔出一份独立的
/// 容器，所以这个 notifier read 到的 surface 就是当前那一份。用 family 会把
/// 「谁是当前 surface」表达两次（family 参数 + override），两处迟早对不上。
///
/// A7a 里这个 provider 恒为 [GenerationIdle]；A7b 之后它是页面上唯一推进生成
/// 态的东西：冷启动恢复缓存 → 重放进渲染引擎；用户触发生成 → 逐条喂 chunk →
/// 落 `result` → 写缓存。
///
/// **它同时负责「重放」**，这是最容易漏的一环：渲染层
/// （`GenerativeSurface`）靠 `transport.contextFor(surfaceId)` 取渲染上下文，
/// 消息序列没被喂进引擎，`contextFor` 就永远是 `null`，于是有结果也不渲染。
/// 所以「落地结果」与「喂给引擎」必须成对发生——缓存恢复时也一样。
final class GenerativeSurfaceNotifier extends Notifier<GenerationState> {
  /// 由 [build] 赋值；`Notifier` 保证 `build` 先于任何方法执行，所以不需要
  /// 「未初始化」分支。用 `late`（非 final）而不是 `late final`：provider 重建时
  /// `build` 会再跑一次并重新赋值。
  late GenerationSession _session;

  @override
  GenerationState build() {
    final surface = ref.watch(generativeSurfaceIdProvider);
    _session = GenerationSession(
      surface: surface,
      repository: ref.watch(generationRepositoryProvider),
      scope: ref.watch(generativeDataScopeProvider(surface)),
      policyVariants: buildPolicyVariants(),
    );

    // 冷启动恢复是异步的：先给 Idle（不占位），读到缓存后再推 Ready。
    // 用 microtask 而不是在 build 里 await：`Notifier.build` 必须同步返回。
    unawaited(_restore());
    return const GenerationIdle();
  }

  SurfaceId get _surface => ref.read(generativeSurfaceIdProvider);

  /// 读缓存并把已有结果重放进渲染引擎。
  Future<void> _restore() async {
    final restored = await _session.restore();
    // 恢复期间用户可能已经触发了新生成：此时不能让旧缓存覆盖进行中的状态。
    if (state is! GenerationIdle) return;
    _apply(restored);
  }

  /// 触发一次生成。
  ///
  /// 失败**不抛**：它落成 [GenerationFailed]，渲染层据此保留上一份结果（没有
  /// 就回到不渲染）。用户看到的应该是「还是原来的样子」，不是一块错误占位。
  Future<void> generate({required String prompt, RangeKey? range}) async {
    final surface = _surface;
    final request = GenerationRequest(
      surface: surface,
      prompt: GenerationPrompt(text: prompt),
      scope: ref.read(generativeDataScopeProvider(surface)),
      range: range,
    );

    // 空指示不构成一次请求，也不该发出网络调用。这不是「失败」：状态不变，
    // 调用方（UI）负责拦住空输入。
    if (!request.prompt.isUsable) return;

    // `begin` 只迁移 session 内部状态、不返回值，所以先把 session 推进到
    // InFlight，再把它的状态同步给 provider。
    _session.begin();
    state = _session.state;

    // 重新生成前先清掉引擎里那棵树：不清的话旧 surface 与新的消息会叠在
    // 一起（`createSurface` 会重建，但先删更明确，也避免残留组件）。
    final transport = ref.read(generativeTransportProvider(surface));
    transport.deleteSurface(generativeA2uiSurfaceId(surface));

    try {
      var sawResult = false;
      await for (final event in _session.repository.generate(request)) {
        switch (event) {
          case GenerationStreamChunk(:final message):
            _feed(transport, message);
          case GenerationStreamResult(:final messages):
            sawResult = true;
            _apply(await _session.commit(messages));
        }
      }

      // 流正常结束却没收到 `result`：服务端中途关了连接。这不是成功——
      // 若不显式失败，页面会停在 InFlight 的骨架上永远转圈。
      if (!sawResult) _apply(_session.fail(const _StreamEndedWithoutResult()));
    } on Object catch (error) {
      // `event: error` 与开流的 HTTP 错误都在这里汇合，都是「本次生成失败」，
      // 保留上一份结果（`GenerationSession.fail` 的语义）。
      appLog.warning('Generative surface generation failed: $error');
      _apply(_session.fail(error));
    }
  }

  /// 恢复默认：清掉该 surface 的生成结果，并移除引擎里的树。
  Future<void> reset() async {
    final surface = _surface;
    ref
        .read(generativeTransportProvider(surface))
        .deleteSurface(generativeA2uiSurfaceId(surface));
    _apply(await _session.reset());
  }

  /// 把一条增量消息喂进渲染引擎。
  ///
  /// 形状不认识的消息**跳过而不是中止**：`chunk` 是渐进反馈，`result` 才是
  /// 权威序列，后者会重新完整重放一次；因为一条坏 chunk 就中止整次生成，
  /// 会把本可成功的请求判死。
  void _feed(GenerativeTransport transport, Map<String, Object?> message) {
    transport
        .feedMessageJson(message)
        .match(
          (error) => appLog.warning('Skipped unusable A2UI chunk: $error'),
          (_) {},
        );
  }

  /// 应用一次状态迁移，并在有文档时把序列重放给引擎。
  void _apply(GenerationState next) {
    state = next;

    final document = switch (next) {
      GenerationReady(:final document) => document,
      // 失败但带着上一份结果：那份结果需要保持渲染。
      GenerationFailed(:final document) => document,
      GenerationIdle() || GenerationInFlight() => null,
    };
    if (document == null || document.isEmpty) return;

    _replay(document.messages);
  }

  /// 把一份已有的消息序列重放进渲染引擎。
  ///
  /// 只在尚未建立该 surface 时重放，避免重复 `createSurface`：`transport` 按
  /// surface 常驻，切页面回来时树还在引擎里。
  void _replay(List<Map<String, Object?>> messages) {
    final surface = _surface;
    final transport = ref.read(generativeTransportProvider(surface));
    if (transport.contextFor(generativeA2uiSurfaceId(surface)) != null) return;
    for (final message in messages) {
      _feed(transport, message);
    }
  }
}

/// 该 surface 的当前生成态。
///
/// A7a 里它恒为 [GenerationIdle]；A7b 之后由 [GenerativeSurfaceNotifier] 推进。
/// 名字沿用 A7a 的消费方预期（`components/catalog.dart`、测试），实现换成
/// notifier。
final generativeStateProvider =
    NotifierProvider<GenerativeSurfaceNotifier, GenerationState>(
      GenerativeSurfaceNotifier.new,
      name: 'generativeState',
    );

/// 生成动作的入口，给 UI 调用。
///
/// 单独一个 provider 而不是让页面直接 `ref.read(generativeStateProvider.notifier)`：
/// 页面上同时有「生成」和「恢复默认」两个动作，从同一个 notifier 上取两次
/// 会让调用点重复知道 notifier 的类型。
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
