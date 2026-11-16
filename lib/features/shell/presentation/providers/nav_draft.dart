import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/shell/domain/entities/nav_config.dart';
import 'package:luminous/features/shell/domain/services/nav_rules.dart';
import 'package:luminous/features/shell/presentation/providers/nav_config.dart';
import 'package:luminous/features/shell/presentation/tab.dart';

/// 编排页的**草稿**：编辑 → 校验 → 提交 / 丢弃。
///
/// 与已保存配置分开的理由和组件编排页一致：「取消」要能一键回到进来时的状态，
/// 而每次改动立即写 KV 会让取消变成「再写一次」——两次写之间进程被杀，用户就
/// 回不到原样了。草稿只活在内存里，退出即丢。
///
/// 校验是**逐次生效**的：非法编辑被拒绝并返回 `NavRuleViolation`，草稿保持原样。
/// 这样用户拖出第 6 个可见 tab 时立刻看到提示，而不是在点「完成」时才发现，
/// 那时他已经不记得是哪一步坏的。
class NavDraftController extends Notifier<NavConfig?> {
  /// null = 草稿未开始（页面还没进，或者已经提交/丢弃）。
  @override
  NavConfig? build() => null;

  /// 进入编排页：以当前已保存配置为起点。
  ///
  /// 起始值用 `completeNavConfig` 补全过的配置——直接拿 `NavConfig` 会让
  /// 「配置里只存了 3 项」的用户一进来就看到 3 行，点完成才补回来，中间那几行
  /// 凭空出现显得像 bug。
  void begin() {
    final saved = ref.read(navConfigProvider);
    final completed = completeNavConfig(saved, shellTabDefaultOrder);
    state = NavConfig(tabs: completed);
  }

  /// 丢弃草稿。
  void discard() => state = null;

  /// 提交草稿；被拒绝时返回原因，草稿与已保存配置都不变。
  NavResolution commit() {
    final draft = state;
    if (draft == null) {
      return NavResolution.accept(ref.read(navConfigProvider));
    }
    final resolution = ref.read(navConfigProvider.notifier).commit(draft);
    if (resolution.isAccepted) state = null;
    return resolution;
  }

  /// 恢复默认并结束草稿。
  Future<void> restoreDefaults() async {
    state = null;
    await ref.read(navConfigProvider.notifier).reset();
  }

  /// 把 [tabId] 在草稿里移动 [delta] 位（负数上移）。
  ///
  /// 越界移动是**无操作**而不是拒绝：用户在第一项上点「上移」不该看到错误提示，
  /// 那是按钮可用性该处理的事。
  NavResolution move(TabId tabId, int delta) {
    final tabs = state?.tabs;
    if (tabs == null) {
      return NavResolution.accept(ref.read(navConfigProvider));
    }
    final from = tabs.indexWhere((t) => t.tabId == tabId);
    if (from < 0) {
      return NavResolution.accept(state!);
    }
    final to = from + delta;
    if (to < 0 || to >= tabs.length) {
      return NavResolution.accept(state!);
    }

    final reordered = [...tabs];
    final moved = reordered.removeAt(from);
    reordered.insert(to, moved);
    return _apply(reordered);
  }

  /// 设置自定义名称；`null` 表示回到 ARB 默认文案。
  NavResolution rename(TabId tabId, String? label) {
    final validation = validateTabLabel(label);
    if (!validation.isAccepted) {
      return NavResolution.reject(
        state ?? const NavConfig(),
        NavRuleViolation.invalidLabel,
      );
    }
    return _update(
      tabId,
      (tab) => validation.value == null
          ? tab.copyWith(clearCustomLabel: true)
          : tab.copyWith(customLabel: validation.value),
    );
  }

  /// 设置图标；`null` 表示回到注册表默认图标。
  NavResolution setIcon(TabId tabId, String? iconName) {
    if (iconName != null && !isKnownTabIcon(iconName)) {
      return NavResolution.reject(
        state ?? const NavConfig(),
        NavRuleViolation.unknownIcon,
      );
    }
    return _update(
      tabId,
      (tab) => iconName == null
          ? tab.copyWith(clearIconName: true)
          : tab.copyWith(iconName: iconName),
    );
  }

  /// 切换可见性。
  NavResolution setVisible(TabId tabId, bool isVisible) {
    final tabs = state?.tabs;
    if (tabs == null) {
      return NavResolution.accept(ref.read(navConfigProvider));
    }
    final next = [
      for (final tab in tabs)
        tab.tabId == tabId ? tab.copyWith(isVisible: isVisible) : tab,
    ];
    return _apply(next);
  }

  NavResolution _update(
    TabId tabId,
    TabPlacement Function(TabPlacement tab) update,
  ) {
    final tabs = state?.tabs;
    if (tabs == null) {
      return NavResolution.accept(ref.read(navConfigProvider));
    }
    return _apply([
      for (final tab in tabs) tab.tabId == tabId ? update(tab) : tab,
    ]);
  }

  /// 校验并落进草稿；被拒绝时草稿不变。
  NavResolution _apply(List<TabPlacement> tabs) {
    // order 必须在校验前归一：用户连续上移会把 order 撑成 0,-1,-2 之类，
    // 而规则只关心「可见几个、首页在不在」，不该被顺序数值卡住。
    final normalized = [
      for (var i = 0; i < tabs.length; i++)
        TabPlacement(
          tabId: tabs[i].tabId,
          order: i,
          customLabel: tabs[i].customLabel,
          iconName: tabs[i].iconName,
          isVisible: tabs[i].isVisible,
        ),
    ];
    final candidate = NavConfig(tabs: normalized);
    final resolution = validateNavConfig(
      candidate,
      knownTabIds: shellTabIds,
      isKnownIcon: isKnownTabIcon,
    );
    if (resolution.isAccepted) {
      state = candidate;
    }
    return resolution;
  }
}

final navDraftProvider = NotifierProvider<NavDraftController, NavConfig?>(
  NavDraftController.new,
);

/// 草稿解析成的可渲染行；草稿未开始（null）时回退到已保存配置。
final navDraftRowsProvider = Provider<List<ResolvedTab>>((ref) {
  final draft = ref.watch(navDraftProvider);
  if (draft == null) return ref.watch(resolvedNavProvider);
  return resolveTabs(completeNavConfig(draft, shellTabDefaultOrder));
});
