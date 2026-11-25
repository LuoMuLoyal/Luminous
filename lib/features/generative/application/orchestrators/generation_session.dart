import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/features/generative/domain/repositories/generation.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 一个 surface 的生成结果生命周期。
///
/// 应用层：不出现 `Ref` / `BuildContext`。状态机是四态（见 `GenerationState`），
/// 但**对外只有三种渲染结论**：
///
/// - 没有生成结果 → 渲染层返回 `null`，页面上不占位置；
/// - 正在生成 → 渲染层给骨架；
/// - 有结果 → 渲染层渲染该 surface。
///
/// 「失败」不是第四种渲染结论：失败时保留上一份结果（有的话），没有就回到
/// 「没有结果」——用户看到的是「还是原来的样子」，而不是一块错误占位。
///
/// 这是**纯逻辑**（可以直接单测的四态迁移），真正的持久化交给
/// [GenerationRepository]，渲染面在 presentation 层。
///
/// ## A2UI 1.0：不再校验内容
///
/// 旧版在 `commit` 里跑 `catalog_policy`（禁数值、禁写动作）。1.0 起那套规则
/// 整个删掉：结构合法性由 `a2ui_core` 的消息校验负责，业务约束写在组件 schema
/// 的 enum 里，越界消息会被处理器拒绝并通过 `onError` 上报。
final class GenerationSession {
  GenerationSession({required this.surface, required this.repository});

  final SurfaceId surface;

  /// 结果落盘 / 读取。公开而不是私有：组合根要能在恢复默认时直接清它。
  final GenerationRepository repository;

  GenerationState _state = const GenerationIdle();

  GenerationState get state => _state;

  /// 冷启动 / 进入页面时从缓存恢复。
  ///
  /// 缓存读失败**不抛**：它落成 [GenerationFailed]，而渲染层对「失败且没有上一份
  /// 结果」的处理与 Idle 相同（不渲染）。
  Future<GenerationState> restore() async {
    final result = await repository.read(surface);
    return result.match(
      (failure) {
        _state = GenerationFailed(error: failure);
        return _state;
      },
      (document) {
        _state = document == null || document.isEmpty
            ? const GenerationIdle()
            : GenerationReady(document);
        return _state;
      },
    );
  }

  /// 一次生成的开始：进入 [GenerationInFlight]。
  void begin() {
    _state = const GenerationInFlight();
  }

  /// 一次生成 / 交互的结果落地。
  ///
  /// [messages] 是这一轮的**完整**消息序列（服务端每次都返回重建整棵树所需的
  /// 全部消息）：覆盖而不是追加，否则交互回合会不断叠加旧组件。
  Future<GenerationState> commit(
    List<Map<String, Object?>> messages, {
    Map<String, Object?>? dataModel,
  }) async {
    final document = GenerativeSurfaceDocument(
      surface: surface,
      messages: List.unmodifiable(messages),
      dataModel: dataModel,
      generatedAt: DateTime.now(),
    );

    // 写缓存失败不影响本次展示：结果已经在内存里，只是冷启动时会丢。
    await repository.write(document);
    _state = GenerationReady(document);
    return _state;
  }

  /// 生成过程中的错误（解析失败、网络失败）。
  ///
  /// 保留上一份结果：解析失败 = 本次生成失败，保留上一份 surface。
  GenerationState fail(Object error) {
    _state = GenerationFailed(error: error, document: _currentDocument);
    return _state;
  }

  /// 恢复默认：清掉该 surface 的生成结果。
  ///
  /// 对生成过的用户，恢复默认应当**连带清掉**，否则「恢复默认」之后页面上还
  /// 留着一块旧生成结果。
  Future<GenerationState> reset() async {
    await repository.clear(surface);
    _state = const GenerationIdle();
    return _state;
  }

  GenerativeSurfaceDocument? get _currentDocument => switch (_state) {
    GenerationReady(:final document) => document,
    GenerationFailed(:final document) => document,
    GenerationIdle() || GenerationInFlight() => null,
  };
}

/// 「恢复默认」对生成结果的影响。
///
/// 单独一个纯函数而不是直接写在 customizer 里：customizer 属于另一个 feature，
/// 它只该看到一个 `bool` 结论（要不要清），不该知道生成式 UI 的内部布局。
bool shouldClearGeneratedSurfaceAfterReset() => true;

/// 把生成结果转成「清 / 不清」的决策，供调用方在恢复默认时执行。
Future<void> clearGeneratedSurfaceOnReset({
  required GenerationRepository repository,
  required SurfaceId surface,
}) async {
  if (!shouldClearGeneratedSurfaceAfterReset()) return;
  // 清失败可以忽略：下一次生成会覆盖它，而用户此刻关心的是布局回到默认。
  final Either<LucentFailure, Unit> _ = await repository.clear(surface);
}
