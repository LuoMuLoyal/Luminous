import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/features/generative/domain/repositories/generation.dart';
import 'package:luminous/features/generative/domain/services/catalog_policy.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';
import 'package:luminous/shared/domain/generative/data_scope.dart';

/// 一个 surface 的生成结果生命周期。
///
/// 应用层：不出现 `Ref` / `BuildContext`。状态机是四态（见 [GenerationState]），
/// 但**对外只有三种渲染结论**（计划 §7 第 2 问的结论）：
///
/// - 没有生成结果 → 渲染层返回 `null`，页面上不占位置。默认布局因此是干净的，
///   用户第一次生成之后才会看到它；
/// - 正在生成 → 渲染层给骨架；
/// - 有结果 → 渲染层重放消息序列。
///
/// 「失败」不是第四种渲染结论：失败时保留上一份结果（有的话），没有就回到
/// 「没有结果」——用户看到的是「还是原来的样子」，而不是一块错误占位。
///
/// 这是**纯逻辑**（可以直接单测的四态迁移），真正的持久化交给
/// [GenerationRepository]，渲染面在 presentation 层。
final class GenerationSession {
  GenerationSession({
    required this.surface,
    required this.repository,
    required this.scope,
    required this.policyVariants,
  });

  final SurfaceId surface;
  final DataScope scope;

  /// 领域 item 的准入规则变体，按 type 名索引。
  ///
  /// 一个 type 可能有多种合法形状（`trend_chart` 的 `kind` / `kinds`），校验
  /// 时取**能接受该组件的那个变体**：任一变体零违规即放行。
  final Map<String, List<CatalogItemPolicy>> policyVariants;

  /// 结果落盘 / 读取。公开而不是私有：组合根要能在恢复默认时直接清它。
  final GenerationRepository repository;

  GenerationState _state = const GenerationIdle();

  GenerationState get state => _state;

  /// 冷启动 / 进入页面时从缓存恢复。
  ///
  /// 缓存读失败**不抛**：它落成 [GenerationFailed]，而渲染层对「失败且没有上一份
  /// 结果」的处理与 Idle 相同（不渲染）。两者都不占页面空间，区别只在于前者
  /// 留了一条可诊断的错误。
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

  /// 一次生成的结果落地。
  ///
  /// [messages] 是本次生成产出的 A2UI 消息。**先校验再落地**：合法则写缓存
  /// 并进入 [GenerationReady]；有违规则整次生成失败、保留上一份结果。
  ///
  /// 为什么整次失败而不是「剔除坏组件继续渲染」：剔除等于替 agent 猜它想说什么，
  /// 而违规里最重的一类是「编造健康数值」——那条被悄悄删掉之后，页面上剩下的
  /// 内容会显得像是完整结论，比整块失败更危险。
  Future<GenerationState> commit(List<Map<String, Object?>> messages) async {
    final violations = _checkComponents(messages);

    if (violations.isNotEmpty) {
      _state = GenerationFailed(
        error: violations.first,
        document: _currentDocument,
      );
      return _state;
    }

    final document = GenerativeSurfaceDocument(
      surface: surface,
      messages: List.unmodifiable(messages),
      generatedAt: DateTime.now(),
    );

    // 写缓存失败不影响本次展示：结果已经在内存里，只是冷启动时会丢。所以
    // 两个分支进入同一个结论——这一轮的产物是有效的，只是可能不持久。
    await repository.write(document);
    _state = GenerationReady(document);
    return _state;
  }

  /// 生成过程中的错误（解析失败、网络失败）。
  ///
  /// 保留上一份结果：计划 §5 A7b「解析失败 = 本次生成失败，保留上一份 surface」。
  GenerationState fail(Object error) {
    _state = GenerationFailed(error: error, document: _currentDocument);
    return _state;
  }

  /// 恢复默认：清掉该 surface 的生成结果。
  ///
  /// 计划 §7 第 3 问的结论：没生成过的用户本来就不渲染，清不清对他们没区别；
  /// 对生成过的用户，恢复默认应当**连带清掉**，否则「恢复默认」之后页面上
  /// 还留着一块旧生成结果。
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

  /// 从消息序列里挑出组件定义。
  ///
  /// A2UI 的组件在 `updateComponents.components` 里；`createSurface` 没有组件，
  /// `updateDataModel` 是数据不是组件，都不参与校验。
  Iterable<Object?> _domainComponents(
    List<Map<String, Object?>> messages,
  ) sync* {
    for (final message in messages) {
      final update = message['updateComponents'];
      if (update is! Map) continue;
      final components = update['components'];
      if (components is! List) continue;
      yield* components;
    }
  }

  /// 校验消息序列里所有组件定义，返回违规列表（空 = 全部放行）。
  ///
  /// 每个组件按它的 type 取变体：**任一变体零违规即放行**。这样
  /// `trend_chart` 的 `kind` / `kinds` 两种形状各走对应的必需键，而同时给了
  /// 两个的组件两条都过不了（各自报缺键 / 多余键），正是想要的——形状含糊
  /// 的定义不该被猜着渲染。
  List<CatalogViolation> _checkComponents(List<Map<String, Object?>> messages) {
    final violations = <CatalogViolation>[];
    for (final component in _domainComponents(messages)) {
      final name = component is Map ? component['component'] : null;
      final variants = name is String ? policyVariants[name] : null;
      if (variants == null) {
        // 不在领域 item 白名单里的 type：展示原语由 genui 的 schema 管，
        // 未知 type 由渲染层的 FallbackWidget 降级。这里不重复报。
        continue;
      }

      // 任一变体零违规即放行；否则报违规最少的那组（给调用方最有用的信息，
      // 而不是两遍互相矛盾的「缺 kind」+「缺 kinds」）。
      violations.addAll(_minimalViolations(component, variants));
    }
    return violations;
  }

  /// 取能接受该组件的那个变体；没有变体能接受时，报违规最少的那一组。
  ///
  /// 先按「任一变体零违规即放行」判定，再挑代表错误——这两步顺序不能反：
  /// 直接把所有变体的错误合并会把「合法的 `kind` 形式」也判成「缺 `kinds`」。
  List<CatalogViolation> _minimalViolations(
    Object? component,
    List<CatalogItemPolicy> variants,
  ) {
    var best = <CatalogViolation>[];
    for (final variant in variants) {
      final errors = checkComponent(
        component: component,
        policies: {variant.name: variant},
        scope: scope,
      );
      if (errors.isEmpty) return const [];
      if (best.isEmpty || errors.length < best.length) best = errors;
    }
    return best;
  }
}

/// 「恢复默认」对生成结果的影响。
///
/// 单独一个纯函数而不是直接写在 customizer 里：customizer 属于另一个 feature，
/// 它只该看到一个 `bool` 结论（要不要清），不该知道生成式 UI 的内部布局。
///
/// **A7a 结论**：恢复默认一律清生成结果。两个理由：
/// 1. 没生成过的用户本来就不渲染，清不清对他们没有可观察差异；
/// 2. 生成过的用户点「恢复默认」时，期待的是「回到我刚装好时的样子」——如果
///    页面上还挂着一块旧生成结果，那就不叫默认了。
bool shouldClearGeneratedSurfaceAfterReset() => true;

/// 把生成结果转成「清 / 不清」的决策，供调用方在恢复默认时执行。
///
/// 保留成函数而不是常量，是为了 A7b 之后如果出现「生成结果算不算默认布局的一部分」
/// 的分歧，只有一个地方要改。
Future<void> clearGeneratedSurfaceOnReset({
  required GenerationRepository repository,
  required SurfaceId surface,
}) async {
  if (!shouldClearGeneratedSurfaceAfterReset()) return;
  // 清失败可以忽略：下一次生成会覆盖它，而用户此刻关心的是布局回到默认。
  final Either<LucentFailure, Unit> _ = await repository.clear(surface);
}
