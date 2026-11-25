import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/composition/a2ui/a2ui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/feedback/skeleton.dart';
import 'package:luminous/features/generative/domain/entities/generation.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 生成式 surface 的渲染入口。
///
/// 三种结论：
///
/// - **没有生成结果** → 返回 `null`（[SizedBox.shrink]），页面上不占位置。
///   默认布局因此保持干净，用户第一次生成之后才会看到它；
/// - **正在生成** → 骨架；
/// - **有结果** → 交给渲染端重放。
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

  /// 该 surface 专用的渲染端（组合根装配）。
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
      // 正在生成且还没有任何结果 → 骨架；其余 → 什么都不显示（触发入口自己
      // 决定是否给空态说明）。
      return state is GenerationInFlight
          ? const _GenerativeSkeleton()
          : const SizedBox.shrink();
    }

    final hasSurface = transport.surfaceFor(surfaceId) != null;
    if (!hasSurface) {
      // 文档在手但渲染端没有这个 surface：说明序列还没被应用（重放尚未执行）。
      // 此时仍然不渲染，而不是给骨架——骨架会让人以为正在生成。
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 失败且仍有上一份结果时给一行提示：用户看到的是「还是原来的样子」，
        // 但需要知道刚才那次没有生效，否则会以为点了没反应。
        if (state case GenerationFailed(:final document) when document != null)
          _GenerativeFailureNotice(),
        GenerativeSurfaceRenderer(transport: transport, surfaceId: surfaceId),
      ],
    );
  }
}

/// 生成失败、但仍保留上一份结果时的一行提示。
///
/// 用文案而不是错误详情：`GenerationFailed.error` 是**诊断信息**（Problem
/// Details 的 detail 字段明确写着 not for UI copy），上屏只会让用户困惑。
class _GenerativeFailureNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    return Padding(
      key: const Key('generative-surface-failure-notice'),
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Text(
        l10n.generativeFailedMessage,
        style: typography.body.xs.copyWith(
          color: SemanticColor.neutral.solid(context),
        ),
      ),
    );
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
