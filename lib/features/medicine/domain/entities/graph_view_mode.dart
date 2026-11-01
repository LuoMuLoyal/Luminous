/// 关系图组件的**展示变体**：同一份数据，列表还是图。
///
/// ## 为什么是变体而不是两个组件 id
///
/// 「机制通路」这个组件回答的是同一个问题，列表和图只是**读法**不同：
/// 列表适合快速扫读数（紧凑尺寸、小屏、只关心头两条）；图画铺开拓扑
/// （级联这种四跳链，文本行要读者自己脑补）。
///
/// 拆成 `dose.mechanism_paths.list` / `.graph` 两个 id 的代价：
/// 用户的布局里会出现两个看似重复的条目，跨表面复用时也要各挂一次；
/// 而组件 id 一旦发布就永不改名。变体则让「换一种看法」变成一次配置修改。
///
/// 这与计划 §2.2 的 `SummaryConfig` 同一形态：sealed 类型保证穷尽，
/// 持久化只存一个可读的字符串键。
library;

/// 组件展示变体。
sealed class GraphViewMode {
  const GraphViewMode();

  /// 持久化用的 wire 值。
  String get wireValue;

  /// 从持久化配置解码；无法识别时返回 [GraphViewMode.list]。
  ///
  /// 回退到**列表**而不是图：图需要布局算法与更大的空间，在无法确定用户
  /// 意图时，列表是那个「一定能读」的形态。
  static GraphViewMode fromWire(Object? raw) {
    return switch (raw) {
      'graph' => const GraphMode(),
      _ => const ListMode(),
    };
  }
}

/// 列表视图：文本行，信息密度高。
final class ListMode extends GraphViewMode {
  const ListMode();

  @override
  String get wireValue => 'list';
}

/// 图视图：节点 + 边，用分层布局展示拓扑。
final class GraphMode extends GraphViewMode {
  const GraphMode();

  @override
  String get wireValue => 'graph';
}

/// 关系图组件的配置。
///
/// 目前只有一个维度（变体），但仍用类而不是裸字段：
/// A3 后续要给每个组件加强类型选项（区间、指标），届时在这里加字段即可，
/// 不需要再改 descriptor 的签名。
final class GraphComponentConfig {
  const GraphComponentConfig({this.mode = const ListMode()});

  final GraphViewMode mode;

  /// 是否走图视图。
  bool get isGraph => mode is GraphMode;

  Map<String, Object?> encode() => {'view': mode.wireValue};

  /// 解码失败回退默认（列表），与 [ComponentDescriptor.decode] 的约定一致。
  static GraphComponentConfig decode(Map<String, Object?> config) {
    return GraphComponentConfig(
      mode: GraphViewMode.fromWire(config['view']),
    );
  }

  static const GraphComponentConfig defaultConfig = GraphComponentConfig();

  GraphComponentConfig copyWith({GraphViewMode? mode}) {
    return GraphComponentConfig(mode: mode ?? this.mode);
  }
}
