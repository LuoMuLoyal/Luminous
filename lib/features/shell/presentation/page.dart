import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/feedback/connectivity_banner.dart';
import 'package:luminous/features/shell/presentation/providers/nav_config.dart';
import 'package:luminous/features/shell/presentation/sidebar/desktop.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 桌面外壳四周的留白。侧边栏卡片与内容区共用这一档，二者之间才留得住
/// 视觉缝隙；侧边栏的右边缘不再另加内边距——卡片自己就是边界。
const _shellInset = 16.0;

class ShellPage extends ConsumerWidget {
  const ShellPage({super.key, required this.navigationShell});

  /// The navigation shell provided by [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = width >= Breakpoints.desktop;

    // 渲染顺序来自用户配置，**branch 结构不变**：visibleTabs 只决定底栏
    // 第 i 格显示哪个 tab，切换时经 branchIndex 翻译回 go_router 的分支。
    // 这就是留在 go_router 也能做「顺序可配」的关键——顺序是数据层的事。
    final tabs = ref.watch(visibleNavProvider);

    // FBottomNavigationBar 的选中态按"在可见列表里的位置"算；
    // branch 的当前下标要先翻译过来，否则用户调整顺序后高亮会错位。
    final activeVisibleIndex = _activeVisibleIndex(tabs);

    void onSelectTab(int index) {
      if (index < 0 || index >= tabs.length) return;
      navigationShell.goBranch(tabs[index].branchIndex);
    }

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: isDesktop ? 1.15 : 1.2,
      child: FScaffold(
        childPad: false,
        resizeToAvoidBottomInset: false,
        sidebar: isDesktop
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    _shellInset,
                    _shellInset,
                    _shellInset / 2,
                    _shellInset,
                  ),
                  child: DesktopSidebar(
                    tabs: tabs,
                    activeBranchIndex: navigationShell.currentIndex,
                    onSelectTab: onSelectTab,
                  ),
                ),
              )
            : null,
        footer: isDesktop
            ? null
            : _MobileBottomNavigationBar(
                tabs: tabs,
                activeIndex: activeVisibleIndex,
                l10n: l10n,
                onSelectTab: onSelectTab,
              ),
        child: Column(
          children: [
            const ConnectivityBanner(),
            Expanded(child: navigationShell),
          ],
        ),
      ),
    );
  }

  /// 把 branch 的当前下标翻译成「在可见 tab 列表里的位置」。
  ///
  /// 返回 -1 表示**当前 branch 对应的 tab 已被用户隐藏**（编排页里关掉它，而导航栈
  /// 仍停在它上面）。底栏的 `index` 非空且必须落在 `[0, length)`，所以渲染时会夹到
  /// 0——高亮第一格，而不是渲染一个不合法的 index。
  int _activeVisibleIndex(List<ResolvedTab> tabs) {
    final branchIndex = navigationShell.currentIndex;
    for (var i = 0; i < tabs.length; i++) {
      if (tabs[i].branchIndex == branchIndex) return i;
    }
    return -1;
  }
}

class _MobileBottomNavigationBar extends StatelessWidget {
  const _MobileBottomNavigationBar({
    required this.tabs,
    required this.activeIndex,
    required this.l10n,
    required this.onSelectTab,
  });

  final List<ResolvedTab> tabs;
  final int activeIndex;
  final AppLocalizations l10n;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) return const SizedBox.shrink();

    // activeIndex 为 -1 表示"当前 branch 对应的 tab 被用户隐藏了"（编排页里
    // 关掉它，而导航栈仍停在它上面）。forui 的 index 非空且必须落在
    // [0, length)，所以夹到范围内——此时不高亮任何一格视觉上无法表达，
    // 退而求其次高亮第一格，避免运行期断言。
    final safeIndex = activeIndex >= 0 ? activeIndex : 0;

    return FBottomNavigationBar(
      index: safeIndex,
      onChange: (index) {
        if (index != activeIndex) {
          unawaited(HapticFeedback.selectionClick());
        }
        onSelectTab(index);
      },
      safeAreaBottom: true,
      children: [
        for (var i = 0; i < tabs.length; i++)
          FBottomNavigationBarItem(
            key: tabs[i].testKey(),
            icon: Icon(i == safeIndex ? tabs[i].activeIcon() : tabs[i].icon()),
            label: Text(tabs[i].label(l10n)),
          ),
      ],
    );
  }
}
