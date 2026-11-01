import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/graph_view_mode.dart';
import 'package:luminous/features/medicine/domain/entities/relations.dart';
import 'package:luminous/features/medicine/presentation/providers/data_access.dart';
import 'package:luminous/features/medicine/presentation/providers/relations/graph.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/graph/graph_card.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/graph/graph_view_canvas.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 「这组药之间发生了什么」类组件：只依赖当前用药集合，无额外入参。
///
/// 五个组件（机制通路 / 共同靶点 / 级联 / 酶拮抗 / 组合概览）共享同一条取数链路：
/// `graphDrugSetProvider` → 可分析药集 → family provider。挂到多个 surface 时
/// family key 相同，只发一次请求。

/// 缺少可分析输入时的统一占位（不是错误，也不是「没有关系」）。
Widget _needsInputNote(String text) => Text(
  text,
  key: const Key('medicine-graph-needs-input'),
  style: const TextStyle(fontSize: 12),
);

/// 机制通路：`A ─INHIBITS→ 酶 ←SUBSTRATE_OF─ B`。
///
/// 支持**列表 / 图**两个变体（[mode]）：列表逐条读，图铺开拓扑。
class MechanismPathsSection extends ConsumerWidget {
  const MechanismPathsSection({
    super.key,
    required this.componentId,
    this.compact = false,
  });

  /// 组件自己的 id，用于读写它的变体偏好。
  final String componentId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      graphViewModesProvider.select((modes) {
        return modes[componentId] ?? const ListMode();
      }),
    );
    final l10n = AppLocalizations.of(context)!;
    final drugSet = ref.watch(graphDrugSetProvider).asData?.value;
    if (drugSet == null || !drugSet.hasPair) {
      return GraphCard(
        title: l10n.medicineGraphTitleMechanismPaths,
        child: _needsInputNote(l10n.medicineGraphNeedsTwoDrugs),
      );
    }
    final async = ref.watch(
      graphMechanismPathsProvider(drugSetKey(drugSet.drugbankIds)),
    );
    final result = async.asData?.value;
    if (result == null) {
      return GraphCard(
        title: l10n.medicineGraphTitleMechanismPaths,
        child: const _GraphLoading(),
      );
    }
    return GraphCard(
      title: l10n.medicineGraphTitleMechanismPaths,
      trailing: result.isAnswerable
          ? GraphCountBadge(
              label: l10n.medicineGraphCountPaths(result.safeItems.length),
            )
          : null,
      viewMode: mode,
      onToggleView: (next) =>
          ref.read(graphViewModesProvider.notifier).setMode(componentId, next),
      footer: GraphCoverageNote(
        covered: drugSet.drugbankIds.length,
        total: drugSet.totalMedicines,
        unresolvable: drugSet.unresolvableCount,
      ),
      child: GraphQueryBody<MechanismPath>(
        result: result,
        compact: compact,
        onRetry: () => ref.invalidate(
          graphMechanismPathsProvider(drugSetKey(drugSet.drugbankIds)),
        ),
        builder: (context, items) {
          // 图变体：药物 → 酶（每条通路的另一端药物是不可见的起点，
          // 所以以「另一端药物 + 酶」成对铺开）。
          if (mode.isGraph) {
            final nodes = <String, String>{};
            final edges = <GraphEdgeSpec>[];
            for (final path in items) {
              nodes[path.otherDrugName] = path.otherDrugName;
              nodes[path.enzymeGene] = path.enzymeGene;
              edges.add(
                GraphEdgeSpec(
                  from: path.otherDrugName,
                  to: path.enzymeGene,
                  label: _relationLabel(l10n, path.relation),
                ),
              );
            }
            return GraphViewCanvas(nodes: nodes, edges: edges);
          }
          final shown = compact ? items.take(2).toList() : items;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final path in shown)
                GraphRelationRow(
                  leading: path.otherDrugName,
                  relation: _relationLabel(l10n, path.relation),
                  target: path.enzymeGene,
                  trailing: path.enzymeName,
                  // 通路描述的是「另一端药物对酶做了什么」，方向从酶指向药物。
                  inverted: true,
                ),
            ],
          );
        },
      ),
    );
  }

  String _relationLabel(AppLocalizations l10n, String raw) {
    return switch (raw.toUpperCase()) {
      'INHIBITS' => l10n.medicineGraphRelationInhibits,
      'INDUCES' => l10n.medicineGraphRelationInduces,
      _ => raw,
    };
  }
}

/// 共同靶点：这组药在图上交汇的地方。
class SharedTargetsSection extends ConsumerWidget {
  const SharedTargetsSection({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final drugSet = ref.watch(graphDrugSetProvider).asData?.value;
    if (drugSet == null || !drugSet.hasPair) {
      return GraphCard(
        title: l10n.medicineGraphTitleSharedTargets,
        child: _needsInputNote(l10n.medicineGraphNeedsTwoDrugs),
      );
    }
    final key = drugSetKey(drugSet.drugbankIds);
    final result = ref.watch(graphSharedTargetsProvider(key)).asData?.value;
    if (result == null) {
      return GraphCard(
        title: l10n.medicineGraphTitleSharedTargets,
        child: const _GraphLoading(),
      );
    }
    return GraphCard(
      title: l10n.medicineGraphTitleSharedTargets,
      trailing: result.isAnswerable
          ? GraphCountBadge(
              label: l10n.medicineGraphCountTargets(result.safeItems.length),
            )
          : null,
      footer: GraphCoverageNote(
        covered: drugSet.drugbankIds.length,
        total: drugSet.totalMedicines,
        unresolvable: drugSet.unresolvableCount,
      ),
      child: GraphQueryBody<SharedTarget>(
        result: result,
        compact: compact,
        onRetry: () => ref.invalidate(graphSharedTargetsProvider(key)),
        builder: (context, items) {
          final shown = compact ? items.take(2).toList() : items;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final target in shown)
                _SharedTargetRow(target: target, compact: compact),
            ],
          );
        },
      ),
    );
  }
}

/// 一个共同靶点：基因 + 药物数 + 药名清单 + 靶点名。
///
/// 用三行而不是一行 `Wrap`：靶点名（如「前列腺素内过氧化物合酶 1」）很长，
/// 与药名清单挤在同一条 `Wrap` 里时会被折到下一行，视觉上变成一条独立信息，
/// 读起来像有两个靶点。分行之后层级是明确的：标识 → 涉及哪些药 → 这是什么。
class _SharedTargetRow extends StatelessWidget {
  const _SharedTargetRow({required this.target, required this.compact});

  final SharedTarget target;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    final muted = SemanticColor.neutral.solid(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: Spacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                target.targetGene,
                style: typography.body.xs.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l10n.medicineGraphSharedTargetDrugs(target.drugCount),
                style: typography.body.xs.copyWith(color: muted),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            target.drugNames.join(' · '),
            style: typography.body.xs,
          ),
          if (!compact && target.targetName.isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              target.targetName,
              style: typography.body.xs.copyWith(color: muted),
            ),
          ],
        ],
      ),
    );
  }
}

/// 级联传播：4 跳链，A 与 B 没有直接相互作用，但暴露量被间接改变。
///
/// 支持**列表 / 图**两个变体：这是图视图收益最大的组件。
class CascadePathsSection extends ConsumerWidget {
  const CascadePathsSection({
    super.key,
    required this.componentId,
    this.compact = false,
  });

  /// 组件自己的 id，用于读写它的变体偏好。
  final String componentId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      graphViewModesProvider.select((modes) {
        return modes[componentId] ?? const ListMode();
      }),
    );

    final l10n = AppLocalizations.of(context)!;
    final drugSet = ref.watch(graphDrugSetProvider).asData?.value;
    if (drugSet == null || drugSet.drugbankIds.isEmpty) {
      return GraphCard(
        title: l10n.medicineGraphTitleCascadePaths,
        child: _needsInputNote(l10n.medicineGraphNeedsTwoDrugs),
      );
    }
    // 级联按单药起点查询：用可分析集合里的第一个药作为起点。
    // 选第一个而不是让用户选，是因为级联的语义是「从我的某个药出发能传到哪」，
    // 换起点是另一种问法，留给后续变体（A3 sealed config）。
    final start = drugSet.drugbankIds.first;
    final result = ref.watch(graphCascadePathsProvider(start)).asData?.value;
    if (result == null) {
      return GraphCard(
        title: l10n.medicineGraphTitleCascadePaths,
        child: const _GraphLoading(),
      );
    }
    return GraphCard(
      title: l10n.medicineGraphTitleCascadePaths,
      trailing: result.isAnswerable
          ? GraphCountBadge(
              label: l10n.medicineGraphCountCascades(result.safeItems.length),
            )
          : null,
      viewMode: mode,
      onToggleView: (next) =>
          ref.read(graphViewModesProvider.notifier).setMode(componentId, next),
      footer: GraphCoverageNote(
        covered: drugSet.drugbankIds.length,
        total: drugSet.totalMedicines,
        unresolvable: drugSet.unresolvableCount,
      ),
      child: GraphQueryBody<CascadePath>(
        result: result,
        compact: compact,
        onRetry: () => ref.invalidate(graphCascadePathsProvider(start)),
        builder: (context, items) {
          // 图变体：四跳链正是图视图最有价值的地方——文本行要读者自己
          // 把「A ⊣ 酶1 ⊸ C ⊣ 酶2 ⊸ B」脑补成一条链。
          if (mode.isGraph) {
            final nodes = <String, String>{};
            final edges = <GraphEdgeSpec>[];
            for (final cascade in items) {
              nodes[cascade.startDrug] = cascade.startDrug;
              nodes[cascade.enzymeOne] = cascade.enzymeOne;
              nodes[cascade.middleDrug] = cascade.middleDrug;
              nodes[cascade.enzymeTwo] = cascade.enzymeTwo;
              nodes[cascade.endDrug] = cascade.endDrug;
              edges
                ..add(
                  GraphEdgeSpec(
                    from: cascade.startDrug,
                    to: cascade.enzymeOne,
                    label: l10n.medicineGraphRelationInhibits,
                  ),
                )
                ..add(
                  GraphEdgeSpec(
                    from: cascade.middleDrug,
                    to: cascade.enzymeOne,
                  ),
                )
                ..add(
                  GraphEdgeSpec(
                    from: cascade.middleDrug,
                    to: cascade.enzymeTwo,
                    label: l10n.medicineGraphRelationInhibits,
                  ),
                )
                ..add(
                  GraphEdgeSpec(from: cascade.endDrug, to: cascade.enzymeTwo),
                );
            }
            return GraphViewCanvas(nodes: nodes, edges: edges, height: 260);
          }
          final shown = compact ? items.take(1).toList() : items;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final cascade in shown) _CascadeChain(cascade: cascade),
            ],
          );
        },
      ),
    );
  }
}

/// 级联链的列表形态：四跳逐行铺开。
///
/// 早先版本用 `⊣` / `⊸` 两个数学符号压缩成一行，但这两个码位不在 CJK 字体
/// 覆盖面内，真机上渲染成豆腐块（截图里能看到两个方框）。这里改用
/// 「箭头 + 关系词」，逐行串成链——读者按行的顺序就能读出传播方向，
/// 不依赖任何特殊字形。
class _CascadeChain extends StatelessWidget {
  const _CascadeChain({required this.cascade});

  final CascadePath cascade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    final muted = SemanticColor.neutral.solid(context);

    Widget step(String text, {bool arrow = true, String? note}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: Spacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (arrow)
              Text(
                '→ ',
                style: typography.body.xs.copyWith(
                  color: SemanticColor.primary.solid(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            Flexible(
              child: Text(
                note == null ? text : '$text（$note）',
                style: typography.body.xs.copyWith(
                  fontWeight: arrow ? FontWeight.w700 : FontWeight.w400,
                  color: note == null ? null : muted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          step(cascade.startDrug, arrow: false),
          step(
            cascade.enzymeOne,
            note: l10n.medicineGraphRelationInhibits,
          ),
          step(cascade.middleDrug),
          step(cascade.enzymeTwo, note: l10n.medicineGraphRelationInhibits),
          step(cascade.endDrug, note: l10n.medicineGraphCascadeEnd),
        ],
      ),
    );
  }
}

/// 酶诱导 × 底物：方向相反，平铺关系表看不出。
class EnzymeDuelsSection extends ConsumerWidget {
  const EnzymeDuelsSection({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final drugSet = ref.watch(graphDrugSetProvider).asData?.value;
    if (drugSet == null || !drugSet.hasPair) {
      return GraphCard(
        title: l10n.medicineGraphTitleEnzymeDuels,
        child: _needsInputNote(l10n.medicineGraphNeedsTwoDrugs),
      );
    }
    final key = drugSetKey(drugSet.drugbankIds);
    final result = ref.watch(graphEnzymeDuelsProvider(key)).asData?.value;
    if (result == null) {
      return GraphCard(
        title: l10n.medicineGraphTitleEnzymeDuels,
        child: const _GraphLoading(),
      );
    }
    return GraphCard(
      title: l10n.medicineGraphTitleEnzymeDuels,
      trailing: result.isAnswerable
          ? GraphCountBadge(
              label: l10n.medicineGraphCountDuels(result.safeItems.length),
            )
          : null,
      footer: GraphCoverageNote(
        covered: drugSet.drugbankIds.length,
        total: drugSet.totalMedicines,
        unresolvable: drugSet.unresolvableCount,
      ),
      child: GraphQueryBody<EnzymeDuel>(
        result: result,
        compact: compact,
        onRetry: () => ref.invalidate(graphEnzymeDuelsProvider(key)),
        builder: (context, items) {
          final shown = compact ? items.take(2).toList() : items;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final duel in shown) _EnzymeDuelRow(duel: duel),
            ],
          );
        },
      ),
    );
  }
}

/// 酶诱导 × 底物的一条：诱导剂 → 酶，以及谁的暴露量下降。
///
/// 方向必须显式读得出来：这张卡的价值正是「诱导剂让酶变多、底物药浓度下降」
/// 这种**方向相反**的间接作用。挤在一条 `Wrap` 里时语序会变成
/// 「CYP3A4 → 底物 暴露量下降 诱导剂」，读者要自己还原谁作用了谁。
class _EnzymeDuelRow extends StatelessWidget {
  const _EnzymeDuelRow({required this.duel});

  final EnzymeDuel duel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: Spacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                duel.inducerDrug,
                style: typography.body.xs.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                l10n.medicineGraphRelationInduces,
                style: typography.body.xs.copyWith(
                  color: SemanticColor.primary.solid(context),
                ),
              ),
              Text(
                duel.enzymeGene,
                style: typography.body.xs.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            l10n.medicineGraphEnzymeDuelExposureDown(duel.inhibitedSubstrate),
            style: typography.body.xs.copyWith(
              color: SemanticColor.neutral.solid(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// 组合概览：成分重复与来源分组。**描述现状，不做判定。**
class MedicationOverviewSection extends ConsumerWidget {
  const MedicationOverviewSection({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(medicationOverviewProvider);
    final overview = async.asData?.value;

    if (overview == null) {
      return GraphCard(
        title: l10n.medicineGraphTitleMedicationOverview,
        child: async.hasError
            ? Text(
                l10n.medicineGraphUnavailableShort,
                style: const TextStyle(fontSize: 12),
              )
            : const _GraphLoading(),
      );
    }

    if (overview.totalMedicines == 0) {
      return GraphCard(
        title: l10n.medicineGraphTitleMedicationOverview,
        child: _needsInputNote(l10n.medicineGraphOverviewEmpty),
      );
    }

    final duplicates = overview.duplicates;
    final typography = Theme.of(context).textTheme.bodySmall;

    return GraphCard(
      title: l10n.medicineGraphTitleMedicationOverview,
      trailing: GraphCountBadge(
        label: l10n.medicineGraphSharedTargetDrugs(overview.totalMedicines),
      ),
      footer: GraphCoverageNote(
        covered: overview.resolvableMedicines,
        total: overview.totalMedicines,
        unresolvable: overview.totalMedicines - overview.resolvableMedicines,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 重复成分是这张卡的核心：重复用药是最常见的自我叠加风险。
          if (duplicates.isEmpty)
            Text(l10n.medicineGraphOverviewNoDuplicates, style: typography)
          else ...[
            Text(
              l10n.medicineGraphOverviewDuplicates(duplicates.length),
              style: typography?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: Spacing.sm),
            for (final group in compact ? duplicates.take(1) : duplicates)
              _DuplicateGroupRow(group: group, l10n: l10n),
          ],
          if (!compact && overview.sourceOverlaps.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            Text(
              l10n.medicineGraphOverviewSources,
              style: typography?.copyWith(fontWeight: FontWeight.w700),
            ),
            for (final overlap in overview.sourceOverlaps.take(4))
              Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: GraphRelationRow(
                  leading: overlap.isUnattributed
                      ? l10n.medicineGraphOverviewUnattributed
                      : overlap.source,
                  relation: l10n.medicineGraphSharedTargetDrugs(
                    overlap.medicineCount,
                  ),
                  target: overlap.displayNames.join(' · '),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _DuplicateGroupRow extends StatelessWidget {
  const _DuplicateGroupRow({required this.group, required this.l10n});

  final DuplicateIngredientGroup group;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isHigh = group.severity == DuplicateSeverity.high;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isHigh ? SemanticIcons.severityHigh : SemanticIcons.severityMedium,
            size: IconSizeTokens.md,
            color: isHigh
                ? SemanticColor.warning.solid(context)
                : SemanticColor.neutral.solid(context),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              '${group.ingredientKey} · ${group.displayNames.join(' / ')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// 首帧占位。
///
/// 刻意**不**用骨架屏：这几个组件的数据是「有/没有」一跳就到的低频查询，
/// 骨架会把一次几百毫秒的空窗画成「内容即将到达」，而实际上常常是降级态。
class _GraphLoading extends StatelessWidget {
  const _GraphLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: Spacing.xl4,
      child: Center(child: FCircularProgress.loader()),
    );
  }
}
