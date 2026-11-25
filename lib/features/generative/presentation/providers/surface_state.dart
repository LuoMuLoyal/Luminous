import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/a2ui/a2ui.dart';
import 'package:luminous/core/i18n/locale.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

/// A2UI surface id：`generative.<surface>`。
///
/// 与 `a2ui.<surface>.document` 这条**存储键**分开：前者是协议里 surface 的
/// 标识（会出现在消息里、进渲染引擎的内部表），后者是 `KvStore` 的键名。
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

/// 该 surface 的渲染端。
///
/// **为什么是 provider 而不是页面自己 new**：一个 surface 的渲染状态必须唯一
/// ——`MessageProcessor` 内部持有 surface 表与数据模型，两个实例各建一棵树，
/// 重放就会重复渲染、动作也会发两遍。
final generativeTransportProvider =
    Provider.family<GenerativeTransport, SurfaceId>((ref, surface) {
      // 不加 `keepAlive`：生命周期跟随所在的 `ProviderScope`（每个 surface 各
      // 开一个），否则某个 surface 先建的实例会被另一个读到，表现为「切 tab 后
      // 生成内容串位」。
      final transport = GenerativeTransport(
        catalog: ref.watch(generativeCatalogProvider(surface)),
      );
      ref.onDispose(transport.dispose);
      return transport;
    }, name: 'generativeTransport');

/// 该 surface 的 catalog。
///
/// 默认是空的领域组件表（只有 basic catalog）；组合根会覆写成带领域组件的那份。
/// 这样 `core/` 与 feature 都不必知道组件怎么构造，而脱离组合根的测试也能跑。
final generativeCatalogProvider = Provider.family<GenerativeCatalog, SurfaceId>(
  (ref, surface) => GenerativeCatalog(domainComponents: const []),
  name: 'generativeCatalog',
);

/// basic catalog 的语言：数字、日期与 `formatString` 的格式跟界面走。
///
/// 不能吃 `basicCatalog()` 默认的 `en-US`——中文界面里 agent 拼出来的日期和
/// 金额会是英文格式。用 `Localizations.localeOf` 不可行（这里没有 `BuildContext`），
/// 所以读应用级的语言 provider。
final generativeCatalogLocaleProvider = Provider<String>((ref) {
  final locale = ref.watch(localeControllerProvider).asData?.value;
  return switch (locale) {
    AppLocale.zhCn => 'zh-CN',
    AppLocale.en || AppLocale.system || null => 'en-US',
  };
}, name: 'generativeCatalogLocale');
