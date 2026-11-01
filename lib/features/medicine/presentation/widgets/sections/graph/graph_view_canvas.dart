import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:graphview/GraphView.dart';
import 'package:luminous/core/design/design.dart';

/// 图视图：把「药物 / 酶 / 靶点」的边列表画成分层图。
///
/// ## 为什么用 `graphview` 的 Sugiyama 分层
///
/// 药理关系天生是**有向、分层**的：药物作用于酶、酶代谢底物、靶点被药物命中。
/// Sugiyama 把节点按依赖层级排开、同类节点落在同一层，这正是读者需要的阅读顺序
/// （谁影响谁、影响经过几跳）。力导向布局在这里是错的——它按斥力散布节点，
/// 同一条通路每次打开位置都可能不同，而医学信息需要可重复的读法。
///
/// ## 与列表视图的分工
///
/// 列表适合扫读数（头两条、小屏、紧凑尺寸）；图适合看拓扑（四跳级联这种链，
/// 文本行要读者自己脑补结构）。两者是同一个组件的变体，由用户选择。
///
/// ## 降级
///
/// 本文件**只负责画**。数据是否可用来由调用方（`GraphQueryBody`）判断——
/// 图不可用时不会走到这里，所以这里不需要再处理三态。
class GraphViewCanvas extends StatelessWidget {
  const GraphViewCanvas({
    super.key,
    required this.nodes,
    required this.edges,
    this.height = 220,
  });

  /// 节点 id → 显示文案。
  ///
  /// 用 id 作键而不是直接传 Widget：同一节点在图中只应出现一次，而边列表里
  /// 它会重复出现多次（「CYP2C9」既是 A 的靶点又是 B 的酶）。
  final Map<String, String> nodes;

  /// 有向边，`from → to` + 边标签（如 `抑制` / `底物`）。
  final List<GraphEdgeSpec> edges;

  final double height;

  @override
  Widget build(BuildContext context) {
    // 只有一个节点时没有边可画，图视图退化成一句话——比一个孤零零的方框可读。
    if (nodes.length < 2 || edges.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.md),
        child: Text(
          nodes.isEmpty ? '' : nodes.values.first,
          style: context.theme.typography.body.xs,
        ),
      );
    }

    final graph = Graph();
    final nodeByKey = <String, Node>{};
    for (final id in nodes.keys) {
      final node = Node.Id(id);
      nodeByKey[id] = node;
      graph.addNode(node);
    }
    for (final edge in edges) {
      final from = nodeByKey[edge.from];
      final to = nodeByKey[edge.to];
      if (from == null || to == null) continue;
      graph.addEdge(from, to);
    }

    final config = SugiyamaConfiguration()
      ..nodeSeparation = 24
      ..levelSeparation = 40
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;

    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: context.theme.style.borderRadius.md,
        child: GraphView.builder(
          graph: graph,
          algorithm: SugiyamaAlgorithm(config),
          // 关掉动画：这些图来自一次查询结果，不是用户操作的过渡，
          // 逐帧动画只会让读的人在信息出现前多等一拍。
          animated: false,
          builder: (node) {
            // `Node.key` 在 graphview 里是可空的：用到的节点都是我们自己建并
            // 以 id 为键放进去的，取不到时退回空串而不是崩。
            final key = node.key?.value;
            final label = key == null ? '' : (nodes[key] ?? '$key');
            return _GraphNodeChip(label: label);
          },
        ),
      ),
    );
  }
}

/// 一条有向边。方向是语义，不能画反。
final class GraphEdgeSpec {
  const GraphEdgeSpec({
    required this.from,
    required this.to,
    this.label,
  });

  final String from;
  final String to;
  final String? label;
}

/// 图里一个节点。
///
/// 视觉取 Forui tokens 与 `SemanticColor`，与列表视图共用同一套颜色语义——
/// 同一个「酶」在两种视图里应该是同一个观感。
class _GraphNodeChip extends StatelessWidget {
  const _GraphNodeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: SemanticColor.primary.subtle(context),
        shape: RoundedSuperellipseBorder(
          borderRadius: context.theme.style.borderRadius.sm,
          side: BorderSide(color: SemanticColor.primary.border(context)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.theme.typography.body.xs.copyWith(
            color: context.theme.colors.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
