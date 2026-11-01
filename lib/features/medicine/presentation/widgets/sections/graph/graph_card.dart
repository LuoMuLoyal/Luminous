import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/relations.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 关系图组件的公共外壳与三态渲染。
///
/// ## 为什么降级态不交给 `build` 返回 `null`
///
/// `ComponentHost` 把 `null` 当作「此刻没什么可显示」，连间距一起移除。对关系图
/// 组件这是**错误**的：区块消失会被读成「本来就没有相互作用」，而这正是
/// 用药场景里最危险的静默降级。所以降级在这里渲染成一张**占位卡**，
/// 并显式写出「这不是『没有相互作用』」。
///
/// 三态在此一处收口，十个组件不各写一遍：
/// 1. [GraphQueryStatus.ok] + 有数据 → 正常内容；
/// 2. [GraphQueryStatus.ok] + 空数组 → 「没有发现相关关系」（中性，不是警告）；
/// 3. 其余状态 → 「暂时无法给出机理分析」（警告色，带原因与重试）。
class GraphCard extends StatelessWidget {
  const GraphCard({
    super.key,
    required this.title,
    this.trailing,
    this.footer,
    required this.child,
  });

  /// 组件标题，已是本地化文案。
  final String title;

  /// 正常内容。
  final Widget child;

  /// 标题行右侧（通常是计数徽章）。
  final Widget? trailing;

  /// 卡片底部补充说明（覆盖度、免责说明）。
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: typography.body.sm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: Spacing.md),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: Spacing.md),
            child,
            if (footer != null) ...[
              const SizedBox(height: Spacing.md),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

/// 把 [GraphQueryStatus] 渲染成对应的三态。
///
/// [builder] 只在「可回答且有数据」时被调用；[emptyText] 是「查到了但为空」的
/// 中性文案（默认用通用的 [AppLocalizations.medicineGraphEmpty]）。
class GraphQueryBody<T> extends StatelessWidget {
  const GraphQueryBody({
    super.key,
    required this.result,
    required this.builder,
    this.emptyText,
    this.onRetry,
    this.compact = false,
  });

  final GraphQueryResult<T> result;
  final Widget Function(BuildContext context, List<T> items) builder;
  final String? emptyText;
  final VoidCallback? onRetry;

  /// 紧凑尺寸：只显示计数与首两条，细节交给展开。
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (result.isAnswerable) {
      final items = result.safeItems;
      if (items.isEmpty) {
        return _GraphEmptyNote(text: emptyText ?? l10n.medicineGraphEmpty);
      }
      return builder(context, items);
    }
    return GraphUnavailableNote(
      status: result.status,
      onRetry: onRetry,
      compact: compact,
    );
  }
}

/// 「我们无法回答」的降级卡。
///
/// 文案的核心是**否定误读**：必须写明「这不是『没有相互作用』」。`notConfigured`
/// 与其余失败分开措辞——前者重试无用（要配置知识库），后者才值得给重试按钮。
class GraphUnavailableNote extends StatelessWidget {
  const GraphUnavailableNote({
    super.key,
    required this.status,
    this.onRetry,
    this.compact = false,
  });

  final GraphQueryStatus status;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    final isNotConfigured = status == GraphQueryStatus.notConfigured;
    // 未配置是「要配」而不是「要等」，重试对它没有意义。
    final showRetry = onRetry != null && !isNotConfigured;

    return DecoratedBox(
      key: const Key('medicine-graph-unavailable'),
      decoration: ShapeDecoration(
        color: SemanticColor.warning.subtle(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: context.theme.style.borderRadius.md,
          side: BorderSide(color: SemanticColor.warning.border(context)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  SemanticIcons.statusError,
                  color: SemanticColor.warning.solid(context),
                  size: IconSizeTokens.md,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    compact
                        ? l10n.medicineGraphUnavailableShort
                        : l10n.medicineGraphUnavailable,
                    style: typography.body.xs.copyWith(
                      color: colors(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (!compact) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                isNotConfigured
                    ? l10n.medicineGraphUnavailableNotConfiguredBody
                    : l10n.medicineGraphUnavailableBody,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.neutral.solid(context),
                ),
              ),
              if (showRetry) ...[
                const SizedBox(height: Spacing.sm),
                FButton(
                  variant: .outline,
                  size: .sm,
                  onPress: onRetry,
                  child: Text(l10n.medicineGraphRetry),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color colors(BuildContext context) => context.theme.colors.foreground;
}

/// 「查到了，但结果为空」的中性说明。
///
/// 与 [GraphUnavailableNote] 必须视觉上可分：这里是**真的没有**，不该用警告色。
class _GraphEmptyNote extends StatelessWidget {
  const _GraphEmptyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('medicine-graph-empty'),
      children: [
        Icon(
          SemanticIcons.statusDone,
          color: SemanticColor.neutral.solid(context),
          size: IconSizeTokens.md,
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Text(
            text,
            style: context.theme.typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ),
      ],
    );
  }
}

/// 覆盖度脚注：只有带 DrugBank id 的药参与图查询。
///
/// 没有这条说明时，「N 种药」与「无相互作用」的组合会让用户以为结论覆盖了全部
/// 用药，而实际只覆盖了其中一部分。
class GraphCoverageNote extends StatelessWidget {
  const GraphCoverageNote({
    super.key,
    required this.covered,
    required this.total,
    required this.unresolvable,
  });

  final int covered;
  final int total;
  final int unresolvable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (total <= 0) return const SizedBox.shrink();
    return Text(
      unresolvable > 0
          ? l10n.medicineGraphCoverageNoteWithRest(covered, total, unresolvable)
          : l10n.medicineGraphCoverageNote(covered, total),
      style: context.theme.typography.body.xs.copyWith(
        color: SemanticColor.neutral.solid(context),
      ),
    );
  }
}

/// 计数徽章。
class GraphCountBadge extends StatelessWidget {
  const GraphCountBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return FBadge(
      style: .delta(
        decoration: .shapeDelta(
          color: SemanticColor.neutral.muted(context),
          shape: RoundedSuperellipseBorder(
            borderRadius: context.theme.style.borderRadius.xs,
            side: BorderSide(color: SemanticColor.neutral.border(context)),
          ),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.theme.typography.body.xs.copyWith(
          color: context.theme.colors.foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 一行「药 — 关系 → 酶」的排版单元。
///
/// 方向在这里是**语义**，不是装饰：`SUBSTRATE_OF` 箭头指向酶，而药物是终点。
class GraphRelationRow extends StatelessWidget {
  const GraphRelationRow({
    super.key,
    required this.leading,
    required this.relation,
    required this.target,
    this.trailing,
    this.inverted = false,
  });

  final String leading;
  final String relation;
  final String target;
  final String? trailing;

  /// 方向与「主体 → 目标」相反时画反向箭头。
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    final trailingValue = trailing;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            leading,
            style: typography.body.xs.copyWith(fontWeight: FontWeight.w700),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 方向用字形而不是图标：`→` / `←` 表达的是「谁作用于谁」，
              // 反过来画会把 SUBSTRATE_OF 讲反，而讲反方向与讲错结论一样危险。
              Text(
                inverted ? '←' : '→',
                style: typography.body.xs.copyWith(
                  color: SemanticColor.primary.solid(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                relation,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.primary.solid(context),
                ),
              ),
            ],
          ),
          Text(
            target,
            style: typography.body.xs.copyWith(
              color: context.theme.colors.foreground,
            ),
          ),
          if (trailingValue != null)
            Text(
              trailingValue,
              style: typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
        ],
      ),
    );
  }
}
