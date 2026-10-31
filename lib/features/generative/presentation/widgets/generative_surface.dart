import 'package:flutter/widgets.dart';
import 'package:luminous/core/composition/genui/genui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';

/// 生成式 surface 的渲染入口。
///
/// 三种结论，与计划 §7 第 2 问的结论一一对应：
///
/// - **没有生成结果** → 返回 `null`（[SizedBox.shrink]），页面上不占位置。
///   默认布局因此保持干净，用户第一次生成之后才会看到它；
/// - **正在生成** → 骨架；
/// - **有结果** → 交给 `genui` 重放消息序列。
///
/// 之所以自己判 `null` 而不是把「没有结果」也画成空态：空态是一个**声明**
/// （「这里本该有东西」），而「从没生成过」不该在默认页面上声明任何东西。
final class GenerativeSurface extends StatelessWidget {
  const GenerativeSurface({
    super.key,
    required this.state,
    required this.transport,
    required this.surfaceId,
  });

  /// 当前生成态。失败时若带上一份文档，照样渲染它。
  final GenerationState state;

  /// 该 surface 专用的渲染引擎接缝（组合根装配）。
  final GenerativeTransport transport;

  /// A2UI surface id，`generative.<surface>`。
  final String surfaceId;

  @override
  Widget build(BuildContext context) {
    final document = switch (state) {
      GenerationReady(:final document) => document,
      GenerationFailed(:final document) => document,
      GenerationIdle() || GenerationInFlight() => null,
    };

    if (document == null) {
      // 正在生成且还没有任何结果 → 骨架；其余 → 不渲染。
      return state is GenerationInFlight
          ? const _GenerativeSkeleton()
          : const SizedBox.shrink();
    }

    final surfaceContext = transport.contextFor(surfaceId);
    if (surfaceContext == null) {
      // 文档在手但引擎里没有这个 surface：说明消息序列没被喂进去（重放尚未
      // 执行）。此时仍然不渲染，而不是给骨架——骨架会让人以为正在生成。
      return const SizedBox.shrink();
    }

    return GenerativeSurfaceRenderer(surfaceContext: surfaceContext);
  }
}

/// 生成中的骨架：三行占位，高度接近一张卡片，避免结果落地时页面跳一跳。
class _GenerativeSkeleton extends StatelessWidget {
  const _GenerativeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      key: Key('generative-surface-skeleton'),
      padding: EdgeInsets.symmetric(vertical: Spacing.md),
      child: SkeletonShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InlineSkeletonBlock(height: 18, widthFactor: 0.5),
            SizedBox(height: Spacing.md),
            InlineSkeletonBlock(height: 96),
            SizedBox(height: Spacing.sm),
            InlineSkeletonBlock(height: 14, widthFactor: 0.72),
          ],
        ),
      ),
    );
  }
}
