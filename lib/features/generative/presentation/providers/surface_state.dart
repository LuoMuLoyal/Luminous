import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/genui/genui.dart';
import 'package:luminous/features/generative/domain/services/item_catalog.dart'
    show generativeFindingIds, generativeMetricKinds;
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/generative/data_scope.dart';

/// A2UI surface id：`generative.<surface>`。
///
/// 与 `genui.<surface>.surface` 这条**存储键**分开：前者是协议里 surface 的
/// 标识（会出现在消息里、进渲染引擎的内部表），后者是 `KvStore` 的键名。两者
/// 恰好同构，但用途不同，不要合并成一个常量。
String generativeA2uiSurfaceId(SurfaceId surface) =>
    'generative.${surface.wireValue}';

/// 当前正在渲染的 surface。
///
/// 由组件注册时的 `ProviderScope` 覆写（见 `presentation/components/catalog.dart`），
/// 默认值是 `today`：让脱离注册表单独使用这个 widget 的测试也能跑起来。
final generativeSurfaceIdProvider = Provider<SurfaceId>(
  (ref) => SurfaceId.today,
  name: 'generativeSurfaceId',
);

/// 该 surface 的渲染引擎接缝。
///
/// **为什么是 provider 而不是页面自己 new**：一份 `SurfaceController` 内部持有
/// 消息解析状态与 surface 表，必须是该 surface 的**唯一**实例——两个实例各建
/// 一棵树，重放就会重复渲染。`family` 让每个 surface 各有一份（计划 §7 第 2 问：
/// 每个 surface 一个），`keepAlive` 让切页面不丢已渲染的树。
final generativeTransportProvider =
    Provider.family<GenerativeTransport, SurfaceId>((ref, surface) {
      final transport = GenerativeTransport(
        catalog: ref.watch(generativeCatalogProvider(surface)),
      );
      ref.onDispose(transport.dispose);
      return transport;
    }, name: 'generativeTransport');

/// 该 surface 的 catalog。
///
/// 默认值是空 catalog（只有展示原语）：组合根会用带领域 item 的那份覆写它。
/// 这样 `core/` 与 feature 都不必知道 `CatalogItem` 怎么构造，而脱离组合根的
/// 测试也能跑起来。
final generativeCatalogProvider = Provider.family<GenerativeCatalog, SurfaceId>(
  (ref, surface) => GenerativeCatalog(domainItems: const []),
  name: 'generativeCatalog',
);

/// 该 surface 可引用的数据。
///
/// A7a 先声明 `review` 那张表能拿到的维度（首批领域 item 就落在 review）：
/// `catalog_policy` 用它判断 agent 写的引用键是否存在。A7b 接后端时这张表
/// 会随 `GET /layouts/:surface` 的能力声明一起下发。
///
/// 条目**由 [generativeMetricKinds] / [generativeFindingIds] 生成**而不是逐条
/// 手写：指标键与 finding id 是 policy 与 DataScope 共用的同一集合，手抄两份的
/// 话，往一边加就会让另一边开始拒绝本应放行的组件。每个维度的单位与说明由
/// [_metricPresentation] 提供。
///
/// **finding 条目必须在这里声明**：`findingPolicy` 把 `findingId` 声明为
/// `DataScopeKind.finding` 的引用键，而 `catalog_policy` 要求引用值存在于 scope
/// 里。少了这一组，任何合法的 `finding` 组件都会被判成「引用了不存在的 id」，
/// 整次生成失败。
final generativeDataScopeProvider = Provider.family<DataScope, SurfaceId>((
  ref,
  surface,
) {
  if (surface != SurfaceId.review) {
    return DataScope(surface: surface, entries: const []);
  }
  return DataScope(
    surface: SurfaceId.review,
    entries: [
      for (final key in generativeMetricKinds)
        DataScopeEntry(
          key: key,
          kind: DataScopeKind.metric,
          description:
              _metricPresentation[key]?.$1 ?? 'Metric "$key" over the range.',
          allowedRanges: const [RangeKey.last7Days, RangeKey.last30Days],
          unit: _metricPresentation[key]?.$2,
        ),
      // findings 按稳定 id 引用，不带 range：它们本身就是区间统计的结论。
      for (final id in generativeFindingIds)
        DataScopeEntry(
          key: id,
          kind: DataScopeKind.finding,
          description: 'A key finding, rendered verbatim from the backend.',
        ),
    ],
  );
}, name: 'generativeDataScope');

/// 每个指标键的（说明, 单位），只影响**给模型看的提示词**，不上屏。
const _metricPresentation = <String, (String, String?)>{
  'medication': ('Medication adherence over the selected range.', '%'),
  'water': ('Daily water intake over the selected range.', 'ml'),
  'sleep': ('Sleep duration over the selected range.', 'h'),
  'general': ('Overall status over the selected range.', null),
};
