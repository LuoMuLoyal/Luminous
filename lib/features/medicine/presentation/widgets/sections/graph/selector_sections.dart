import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/relations.dart';
import 'package:luminous/features/medicine/presentation/providers/relations/graph.dart';
import 'package:luminous/features/medicine/presentation/widgets/sections/graph/graph_card.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 需要一个额外选择才能查询的组件。
///
/// 这类查询的入参（要避开的酶 / 起止药 / 靶点基因）**无法从当前用药自动派生**：
/// 「你对哪个酶敏感」不是病历里的事实，「从 A 到 B」也是用户临时的问题。
/// 所以它们进目录但不进默认布局，由用户自行添加后通过组件内的选择器指定。

/// 单药选择器：从可分析药集里选一味药，驱动单药类查询。
class _DrugPicker extends StatelessWidget {
  const _DrugPicker({
    required this.label,
    required this.ids,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final List<String> ids;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _GraphPicker(
      label: label,
      value: selected,
      options: ids,
      onChanged: onChanged,
    );
  }
}

/// 通用下拉选择器，视觉走 Forui 的 `FSelect`。
class _GraphPicker extends StatelessWidget {
  const _GraphPicker({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: context.theme.typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          FSelect<String>.rich(
            key: ValueKey('medicine-graph-picker-$label'),
            control: FSelectControl.lifted(
              value: value,
              onChange: (selected) {
                if (selected != null) onChanged(selected);
              },
            ),
            hint: label,
            format: (item) => item,
            children: [
              for (final option in options)
                FSelectItem.item(title: Text(option), value: option),
            ],
          ),
        ],
      ),
    );
  }
}

/// 药物作用谱：单药作用于哪些靶点、以什么方式。
class DrugActionsSection extends ConsumerStatefulWidget {
  const DrugActionsSection({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<DrugActionsSection> createState() => _DrugActionsSectionState();
}

class _DrugActionsSectionState extends ConsumerState<DrugActionsSection> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final drugSet = ref.watch(graphDrugSetProvider).asData?.value;
    if (drugSet == null || drugSet.drugbankIds.isEmpty) {
      return GraphCard(
        title: l10n.medicineGraphTitleDrugActions,
        child: Text(
          l10n.medicineGraphNeedsTwoDrugs,
          style: context.theme.typography.body.xs,
        ),
      );
    }
    final ids = drugSet.drugbankIds;
    final selected = _selected ?? ids.first;
    final result = ref.watch(graphDrugActionsProvider(selected)).asData?.value;

    return GraphCard(
      title: l10n.medicineGraphTitleDrugActions,
      trailing: result != null && result.isAnswerable
          ? GraphCountBadge(
              label: l10n.medicineGraphSharedTargetDrugs(
                result.safeItems.length,
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.compact && ids.length > 1)
            _DrugPicker(
              label: l10n.medicineGraphSelectDrug,
              ids: ids,
              selected: selected,
              onChanged: (value) => setState(() => _selected = value),
            ),
          if (result == null)
            const _Pending()
          else
            GraphQueryBody<DrugAction>(
              result: result,
              compact: widget.compact,
              onRetry: () => ref.invalidate(graphDrugActionsProvider(selected)),
              builder: (context, items) {
                final shown = widget.compact ? items.take(2).toList() : items;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final action in shown)
                      GraphRelationRow(
                        leading: action.relation
                            .replaceAll('_', ' ')
                            .toLowerCase(),
                        relation: '→',
                        target: action.targetGene,
                        trailing: widget.compact ? null : action.targetName,
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

/// 转运体路径：外排/摄取。方向是语义。
class TransportRoutesSection extends ConsumerStatefulWidget {
  const TransportRoutesSection({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<TransportRoutesSection> createState() =>
      _TransportRoutesSectionState();
}

class _TransportRoutesSectionState
    extends ConsumerState<TransportRoutesSection> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final drugSet = ref.watch(graphDrugSetProvider).asData?.value;
    if (drugSet == null || drugSet.drugbankIds.isEmpty) {
      return GraphCard(
        title: l10n.medicineGraphTitleTransportRoutes,
        child: Text(
          l10n.medicineGraphNeedsTwoDrugs,
          style: context.theme.typography.body.xs,
        ),
      );
    }
    final ids = drugSet.drugbankIds;
    final selected = _selected ?? ids.first;
    final result = ref
        .watch(graphTransportRoutesProvider(selected))
        .asData
        ?.value;

    return GraphCard(
      title: l10n.medicineGraphTitleTransportRoutes,
      trailing: result != null && result.isAnswerable
          ? GraphCountBadge(
              label: l10n.medicineGraphSharedTargetDrugs(
                result.safeItems.length,
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.compact && ids.length > 1)
            _DrugPicker(
              label: l10n.medicineGraphSelectDrug,
              ids: ids,
              selected: selected,
              onChanged: (value) => setState(() => _selected = value),
            ),
          if (result == null)
            const _Pending()
          else
            GraphQueryBody<TransportRoute>(
              result: result,
              compact: widget.compact,
              onRetry: () =>
                  ref.invalidate(graphTransportRoutesProvider(selected)),
              builder: (context, items) {
                final shown = widget.compact ? items.take(2).toList() : items;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final route in shown)
                      GraphRelationRow(
                        leading: selected,
                        relation: route.inverted ? '←' : '→',
                        target: route.transporterGene,
                        // 方向讲反与讲错结论一样危险：逆向时显式标注。
                        trailing: route.inverted
                            ? l10n.medicineGraphTransportInverted
                            : (widget.compact ? null : route.transporterName),
                        inverted: route.inverted,
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

/// 替代候选：不走指定酶的结构性候选。**不是处方建议。**
class SubstitutesSection extends ConsumerStatefulWidget {
  const SubstitutesSection({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<SubstitutesSection> createState() => _SubstitutesSectionState();
}

class _SubstitutesSectionState extends ConsumerState<SubstitutesSection> {
  String? _drug;
  String? _enzyme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final drugSet = ref.watch(graphDrugSetProvider).asData?.value;
    if (drugSet == null || drugSet.drugbankIds.isEmpty) {
      return GraphCard(
        title: l10n.medicineGraphTitleSubstitutes,
        child: Text(
          l10n.medicineGraphNeedsTwoDrugs,
          style: context.theme.typography.body.xs,
        ),
      );
    }
    final ids = drugSet.drugbankIds;
    final drug = _drug ?? ids.first;
    final enzyme = _enzyme;

    // 酶没选之前不发请求：端点要求 enzymeGene 必填，空串只会换来 400。
    final result = enzyme == null
        ? null
        : ref
              .watch(
                graphSubstituteCandidatesProvider((
                  drugbankId: drug,
                  enzymeGene: enzyme,
                )),
              )
              .asData
              ?.value;

    return GraphCard(
      title: l10n.medicineGraphTitleSubstitutes,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.compact) ...[
            _DrugPicker(
              label: l10n.medicineGraphSelectDrug,
              ids: ids,
              selected: drug,
              onChanged: (value) => setState(() => _drug = value),
            ),
            _EnzymeInput(
              label: l10n.medicineGraphSelectEnzyme,
              initial: _enzyme,
              onSubmit: (value) => setState(() => _enzyme = value),
            ),
          ],
          if (enzyme == null)
            Text(
              l10n.medicineGraphNeedsEnzyme,
              style: context.theme.typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            )
          else if (result == null)
            const _Pending()
          else
            GraphQueryBody<SubstituteCandidate>(
              result: result,
              compact: widget.compact,
              onRetry: () => ref.invalidate(
                graphSubstituteCandidatesProvider((
                  drugbankId: drug,
                  enzymeGene: enzyme,
                )),
              ),
              builder: (context, items) {
                final shown = widget.compact ? items.take(2).toList() : items;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final candidate in shown)
                      GraphRelationRow(
                        leading: candidate.name,
                        relation: '≠ $enzyme',
                        target: candidate.sharedTarget == null
                            ? candidate.drugbankId
                            : l10n.medicineGraphSubstituteSharedTarget(
                                candidate.sharedTarget!,
                              ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

/// 酶的文本输入。基因符号是受控词表之外的自由值（`CYP2C9` 之类），
/// 用输入框而不是选择器：靶点基因数量太大，列全不现实。
class _EnzymeInput extends StatefulWidget {
  const _EnzymeInput({
    required this.label,
    required this.initial,
    required this.onSubmit,
  });

  final String label;
  final String? initial;
  final ValueChanged<String> onSubmit;

  @override
  State<_EnzymeInput> createState() => _EnzymeInputState();
}

class _EnzymeInputState extends State<_EnzymeInput> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: FTextField(
        control: .managed(controller: _controller),
        label: Text(widget.label),
        hint: 'CYP2C9',
        onSubmit: (value) {
          final trimmed = value.trim();
          if (trimmed.isNotEmpty) widget.onSubmit(trimmed);
        },
      ),
    );
  }
}

/// 靶点用药：作用于某一靶点基因的所有药。
class TargetDrugsSection extends ConsumerStatefulWidget {
  const TargetDrugsSection({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<TargetDrugsSection> createState() => _TargetDrugsSectionState();
}

class _TargetDrugsSectionState extends ConsumerState<TargetDrugsSection> {
  String? _gene;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gene = _gene;
    final result = gene == null
        ? null
        : ref.watch(graphTargetDrugsProvider(gene)).asData?.value;

    return GraphCard(
      title: l10n.medicineGraphTitleTargetDrugs,
      trailing: result != null && result.isAnswerable
          ? GraphCountBadge(
              label: l10n.medicineGraphSharedTargetDrugs(
                result.safeItems.length,
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.compact)
            _EnzymeInput(
              label: l10n.medicineGraphSelectGene,
              initial: _gene,
              onSubmit: (value) => setState(() => _gene = value),
            ),
          if (gene == null)
            Text(
              l10n.medicineGraphSelectGene,
              style: context.theme.typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            )
          else if (result == null)
            const _Pending()
          else
            GraphQueryBody<TargetDrug>(
              result: result,
              compact: widget.compact,
              onRetry: () => ref.invalidate(graphTargetDrugsProvider(gene)),
              builder: (context, items) {
                final shown = widget.compact ? items.take(2).toList() : items;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final drug in shown)
                      GraphRelationRow(
                        leading: drug.name,
                        relation: drug.relation
                            .replaceAll('_', ' ')
                            .toLowerCase(),
                        target: gene,
                        trailing: widget.compact ? null : drug.drugbankId,
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

/// 最短路径：两药之间的传播链，节点与边逐位对应。
class ShortestRoutesSection extends ConsumerStatefulWidget {
  const ShortestRoutesSection({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<ShortestRoutesSection> createState() =>
      _ShortestRoutesSectionState();
}

class _ShortestRoutesSectionState extends ConsumerState<ShortestRoutesSection> {
  String? _from;
  String? _to;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final drugSet = ref.watch(graphDrugSetProvider).asData?.value;
    if (drugSet == null || !drugSet.hasPair) {
      return GraphCard(
        title: l10n.medicineGraphTitleShortestRoutes,
        child: Text(
          l10n.medicineGraphNeedsTwoDrugsForRoute,
          style: context.theme.typography.body.xs,
        ),
      );
    }
    final ids = drugSet.drugbankIds;
    final from = _from;
    final to = _to;
    final ready = from != null && to != null && from != to;

    final result = !ready
        ? null
        : ref
              .watch(graphShortestRoutesProvider((from: from, to: to)))
              .asData
              ?.value;

    return GraphCard(
      title: l10n.medicineGraphTitleShortestRoutes,
      trailing: result != null && result.isAnswerable
          ? GraphCountBadge(
              label: l10n.medicineGraphSharedTargetDrugs(
                result.safeItems.length,
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.compact) ...[
            _DrugPicker(
              label: l10n.medicineGraphSelectFromDrug,
              ids: ids,
              selected: from ?? ids.first,
              onChanged: (value) => setState(() => _from = value),
            ),
            _DrugPicker(
              label: l10n.medicineGraphSelectToDrug,
              ids: ids,
              selected: to ?? ids.last,
              onChanged: (value) => setState(() => _to = value),
            ),
          ],
          if (!ready)
            Text(
              l10n.medicineGraphNeedsTwoDrugsForRoute,
              style: context.theme.typography.body.xs.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            )
          else if (result == null)
            const _Pending()
          else
            GraphQueryBody<ShortestRoute>(
              result: result,
              compact: widget.compact,
              onRetry: () => ref.invalidate(
                graphShortestRoutesProvider((from: from, to: to)),
              ),
              builder: (context, items) {
                final shown = widget.compact ? items.take(1).toList() : items;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final route in shown)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Spacing.xs),
                        child: Text(
                          route.pathNodes.join(' → '),
                          style: context.theme.typography.body.xs,
                        ),
                      ),
                    for (final route in shown)
                      Text(
                        l10n.medicineGraphStepCount(route.stepCount),
                        style: context.theme.typography.body.xs.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

/// 请求在途的占位。
class _Pending extends StatelessWidget {
  const _Pending();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: Spacing.xl4,
      child: Center(child: FCircularProgress.loader()),
    );
  }
}
