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
    final relationKinds = <String>{};
    final outgoing = <String, List<String>>{};
    for (final edge in edges) {
      final from = nodeByKey[edge.from];
      final to = nodeByKey[edge.to];
      if (from == null || to == null) continue;
      graph.addEdge(from, to);
      (outgoing[edge.from] ??= <String>[]).add(edge.to);
      final label = edge.label;
      if (label != null && label.isNotEmpty) relationKinds.add(label);
    }

    final config = SugiyamaConfiguration()
      ..nodeSeparation = 24
      ..levelSeparation = 40
      ..orientation = SugiyamaConfiguration.ORIENTATION_TOP_BOTTOM;

    // 高度按图的**层数**自适应。
    //
    // 固定高度是这张图最显眼的毛病：三个节点的通路只占上面三分之一，下面留
    // 一大片空白。Sugiyama 是分层布局，画布需要的高度基本由层数决定，所以按
    // 最长路径的跳数估：每层约 55dp + 节点本身 50dp。
    final depth = _graphDepth(nodeByKey.keys, outgoing);
    final estimated = 50.0 + 55 * depth;
    final canvasHeight = estimated.clamp(120.0, height);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: canvasHeight,
          child: ClipRRect(
            borderRadius: context.theme.style.borderRadius.md,
            child: GraphView.builder(
              graph: graph,
              algorithm: SugiyamaAlgorithm(config),
              // `graphview` 的默认边样式是 1px 纯黑，和这套设计语言不搭；
              // 用主色的细线，视觉权重与列表里的箭头一致。
              paint: Paint()
                ..color = SemanticColor.primary.solid(context)
                ..strokeWidth = 1.2
                ..style = PaintingStyle.stroke,
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
        ),
        // 边上写不下关系词（Sugiyama 的默认边渲染没有标签位），但「这条边是
        // 抑制还是诱导」是这张图**全部的信息价值**——丢了它，图只剩拓扑，
        // 而拓扑在列表里已经有。所以用图例补回来。
        if (relationKinds.isNotEmpty) ...[
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final kind in relationKinds)
                Text(
                  '→ $kind',
                  style: context.theme.typography.body.xs.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// 图的最长路径跳数（层数），用于估算画布高度。
///
/// 有环保护：真实数据里理论上不会成环（药物 → 酶是单向语义），但上游数据
/// 一旦出现环，这里不能死循环——用「已访问集合」截断。
int _graphDepth(
  Iterable<String> allNodes,
  Map<String, List<String>> outgoing,
) {
  final memo = <String, int>{};
  int depthOf(String node, Set<String> visiting) {
    final cached = memo[node];
    if (cached != null) return cached;
    if (!visiting.add(node)) return 0;
    var best = 0;
    for (final next in outgoing[node] ?? const <String>[]) {
      final candidate = 1 + depthOf(next, visiting);
      if (candidate > best) best = candidate;
    }
    visiting.remove(node);
    memo[node] = best;
    return best;
  }

  var maxDepth = 0;
  for (final node in allNodes) {
    final depth = depthOf(node, <String>{});
    if (depth > maxDepth) maxDepth = depth;
  }
  // 至少两层：只有一个节点的图不走这条路（上层已判空）。
  return maxDepth < 1 ? 1 : maxDepth;
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
