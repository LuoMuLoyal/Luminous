import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/config/pref_keys.dart';
import 'package:luminous/core/storage/kv_store.dart';
import 'package:luminous/features/medicine/domain/entities/graph_view_mode.dart';

/// 药品关系图组件的**显示变体偏好**（列表 / 图），按组件 id 分别记住。
///
/// ## 为什么是组件偏好，不是布局配置
///
/// 变体是「我怎么读这张卡」，不是「这一页由哪些卡组成」。把它写进
/// `SurfaceLayout` 的 placement 配置有两个后果：每次切换都要走一次布局写入
/// （远端 `PUT /layouts` + 版本冲突语义），而它其实只是本机的阅读习惯；
/// 并且换设备时这个偏好会跟着布局同步，与用户的预期无关。
///
/// 走 KV 偏好与 `quickEntryPreferences` 同一模式：本机、即时、不参与同步。
/// 代价是换设备不跟随，对一个阅读偏好来说这是可接受的。
const String _kViewModePrefix = PrefKeys.medicineGraphViewModePrefix;

/// 读取某个组件的变体；未设置时返回列表。
GraphViewMode graphViewModeOf(String componentId) {
  final raw = KvStore.instance.getOrNull<String>('$_kViewModePrefix$componentId');
  return GraphViewMode.fromWire(raw);
}

/// 当前所有组件的变体偏好。
///
/// 组件在 build 里 `ref.watch` 它来取自己的变体；切换后 `set` 触发重建。
/// 不是 AsyncNotifier：`KvStore` 在启动时已就绪，这里读的是同步值，
/// 让组件首帧就能拿到正确的变体，避免先画列表再跳成图。
final graphViewModesProvider =
    NotifierProvider<GraphViewModesNotifier, Map<String, GraphViewMode>>(
      GraphViewModesNotifier.new,
      name: 'graphViewModes',
    );

class GraphViewModesNotifier extends Notifier<Map<String, GraphViewMode>> {
  @override
  Map<String, GraphViewMode> build() {
    final store = KvStore.instance;
    final modes = <String, GraphViewMode>{};
    for (final entry in _knownComponentIds) {
      final raw = store.getOrNull<String>('$_kViewModePrefix$entry');
      if (raw != null) modes[entry] = GraphViewMode.fromWire(raw);
    }
    return modes;
  }

  GraphViewMode modeOf(String componentId) =>
      state[componentId] ?? const ListMode();

  Future<void> setMode(String componentId, GraphViewMode mode) async {
    state = {...state, componentId: mode};
    await KvStore.instance.set('$_kViewModePrefix$componentId', mode.wireValue);
  }
}

/// 已知支持变体的组件 id。
///
/// 显式列出而不是遍历 registry：`build()` 时 registry 可能尚未装配，
/// 而且只有拓扑型组件参与偏好，列出来更清楚。
const List<String> _knownComponentIds = [
  'dose.mechanism_paths',
  'dose.cascade_paths',
];
