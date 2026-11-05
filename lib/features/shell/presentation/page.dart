import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/feedback/connectivity_banner.dart';
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
    final currentIndex = navigationShell.currentIndex;
    final width = MediaQuery.sizeOf(context).width;
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = width >= Breakpoints.desktop;
    final content = navigationShell;

    void onSelectTab(int index) {
      navigationShell.goBranch(index);
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
                    currentIndex: currentIndex,
                    onSelectTab: onSelectTab,
                  ),
                ),
              )
            : null,
        footer: isDesktop
            ? null
            : _MobileBottomNavigationBar(
                currentIndex: currentIndex,
                l10n: l10n,
                onSelectTab: onSelectTab,
              ),
        child: Column(
          children: [
            const ConnectivityBanner(),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}

class _MobileBottomNavigationBar extends StatelessWidget {
  const _MobileBottomNavigationBar({
    required this.currentIndex,
    required this.l10n,
    required this.onSelectTab,
  });

  final int currentIndex;
  final AppLocalizations l10n;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return FBottomNavigationBar(
      index: currentIndex,
      onChange: (index) {
        if (index != currentIndex) {
          unawaited(HapticFeedback.selectionClick());
        }
        onSelectTab(index);
      },
      safeAreaBottom: true,
      children: [
        for (final tab in ShellTab.values)
          FBottomNavigationBarItem(
            key: tab.testKey(),
            icon: Icon(currentIndex == tab.index ? tab.activeIcon : tab.icon),
            label: Text(tab.label(l10n)),
          ),
      ],
    );
  }
}
