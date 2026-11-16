import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/app/composition/shell/nav_config_sync.dart';
import 'package:luminous/features/shell/domain/entities/nav_config.dart';
import 'package:luminous/features/shell/domain/services/nav_rules.dart';
import 'package:luminous/features/shell/presentation/providers/data_access.dart';
import 'package:luminous/features/shell/presentation/tab.dart';

/// 用户导航配置的当前值。
///
/// 同步 `Notifier` 而不是 `AsyncNotifier`：`KvStore` 是内存 box，同步读没有
/// I/O 代价，而配置在首帧就要用——异步会让冷启动先渲染一帧默认底栏，
/// 再跳成用户底栏（可见闪烁）。读不出来时 `CachedNavConfigRepository`
/// 已经回退默认，所以这里不存在"加载中"状态。
class NavConfigController extends Notifier<NavConfig> {
  @override
  NavConfig build() => ref.read(navConfigRepositoryProvider).read();

  /// 提交一次编辑。
  ///
  /// 非法编辑**返回原配置**并给出拒绝原因，不抛、不存半成品——调用方
  /// （编排 UI）拿 `resolution.rejection` 出提示即可，不需要自己回滚。
  NavResolution commit(NavConfig next) {
    final resolution = validateNavConfig(
      // 校验的是"新配置是否合法"，被拒绝时回退到"当前配置"。
      next,
      knownTabIds: shellTabIds,
      isKnownIcon: isKnownTabIcon,
    );
    if (!resolution.isAccepted) {
      return NavResolution.reject(state, resolution.rejection!);
    }
    state = next;
    // 乐观写：先改内存态让界面立刻响应，落盘失败也只影响下次启动。
    unawaited(ref.read(navConfigRepositoryProvider).write(next));
    // 远端同步是旁路：本地已生效，推不上去就进离线队列。
    unawaited(ref.read(navConfigSyncProvider).push(next));
    return resolution;
  }

  /// 采纳一份来自远端的配置（登录后 / 跨设备拉取）。
  ///
  /// 不经过 `commit`：远端文档已经过服务端 `schemaVersion` 区间校验，但仍是
  /// 客户端写的，所以本地再跑一次补全——注册表可能多了 tab。
  void adoptRemote(NavConfig remote) {
    state = remote;
    unawaited(ref.read(navConfigRepositoryProvider).write(remote));
  }

  /// 恢复默认配置。
  Future<void> reset() async {
    state = state.resetToDefault();
    await ref.read(navConfigRepositoryProvider).write(state);
    unawaited(ref.read(navConfigSyncProvider).push(state));
  }
}

final navConfigProvider = NotifierProvider<NavConfigController, NavConfig>(
  NavConfigController.new,
);

/// 解析后的 tab 列表（默认外观已合并好，可直接渲染）。
///
/// 页面与侧栏都消费这一条，不各自去查注册表——两处各查一遍就会出现
/// "底栏换了顺序、侧栏还是旧顺序"这类只有真机才看得见的偏差。
final resolvedNavProvider = Provider<List<ResolvedTab>>((ref) {
  final config = ref.watch(navConfigProvider);
  final completed = completeNavConfig(config, shellTabDefaultOrder);
  return resolveTabs(completed);
});

/// 底栏 / 侧栏实际渲染的可见 tab。
final visibleNavProvider = Provider<List<ResolvedTab>>((ref) {
  return [
    for (final tab in ref.watch(resolvedNavProvider))
      if (tab.isVisible) tab,
  ];
});
