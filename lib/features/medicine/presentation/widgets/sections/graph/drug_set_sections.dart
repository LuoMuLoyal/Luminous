import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/relations.dart';
import 'package:luminous/features/medicine/presentation/providers/relations/graph.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/graph/graph_card.dart';
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
class MechanismPathsSection extends ConsumerWidget {
  const MechanismPathsSection({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              label: l10n.medicineGraphSharedTargetDrugs(
                result.safeItems.length,
              ),
            )
          : null,
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
              label: l10n.medicineGraphSharedTargetDrugs(
                result.safeItems.length,
              ),
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
                GraphRelationRow(
                  leading: target.targetGene,
                  relation: l10n.medicineGraphSharedTargetDrugs(
                    target.drugCount,
                  ),
                  // 靶点名优先，基因名作为标识已在 leading；这里展示药名清单。
                  target: target.drugNames.join(' · '),
                  trailing: compact ? null : target.targetName,
                ),
            ],
          );
        },
      ),
    );
  }
}

/// 级联传播：4 跳链，A 与 B 没有直接相互作用，但暴露量被间接改变。
class CascadePathsSection extends ConsumerWidget {
  const CascadePathsSection({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              label: l10n.medicineGraphSharedTargetDrugs(
                result.safeItems.length,
              ),
            )
          : null,
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
          final shown = compact ? items.take(1).toList() : items;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final cascade in shown)
                GraphRelationRow(
                  leading: cascade.startDrug,
                  relation: '⊣ ${cascade.enzymeOne} ⊸ ${cascade.middleDrug}',
                  target: '${cascade.enzymeTwo} ← ${cascade.endDrug}',
                ),
            ],
          );
        },
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
              label: l10n.medicineGraphSharedTargetDrugs(
                result.safeItems.length,
              ),
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
              for (final duel in shown)
                GraphRelationRow(
                  leading: duel.enzymeGene,
                  relation: l10n.medicineGraphEnzymeDuelExposureDown(
                    duel.inhibitedSubstrate,
                  ),
                  target: duel.inducerDrug,
                ),
            ],
          );
        },
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
