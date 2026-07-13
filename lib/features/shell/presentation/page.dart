import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';

const _shellInset = 16.0;

class ShellPage extends StatelessWidget {
  const ShellPage({super.key, required this.navigationShell});

  /// The navigation shell provided by [StatefulShellRoute].
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final width = MediaQuery.sizeOf(context).width;
    final l10n = AppLocalizations.of(context);
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
                  child: _DesktopSidebar(
                    currentIndex: currentIndex,
                    l10n: l10n,
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
        child: content,
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
  final AppLocalizations? l10n;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return FBottomNavigationBar(
      index: currentIndex,
      onChange: (index) {
        if (index != currentIndex) {
          HapticFeedback.selectionClick();
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

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.currentIndex,
    required this.l10n,
    required this.onSelectTab,
  });

  final int currentIndex;
  final AppLocalizations? l10n;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    FSidebarItem tabItem(ShellTab tab) {
      final selected = currentIndex == tab.index;
      return FSidebarItem(
        key: tab.testKey(),
        icon: Icon(selected ? tab.activeIcon : tab.icon),
        label: Text(tab.label(l10n)),
        selected: selected,
        onPress: () => onSelectTab(tab.index),
      );
    }

    return FSidebar(
      style: FSidebarStyle(
        decoration: BoxDecoration(color: theme.colors.background),
        groupStyle: theme.sidebarStyle.groupStyle,
      ),
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(
              FLucideIcons.heartPulse,
              size: 18,
              color: theme.colors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              l10n?.appTitle ?? 'Luminous',
              overflow: TextOverflow.ellipsis,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FSidebarItem(
            icon: const Icon(FLucideIcons.settings),
            label: Text(l10n?.desktopSidebarSettings ?? '设置'),
            onPress: () => context.push(AppRoutes.settings),
          ),
          FSidebarItem(
            icon: const Icon(FLucideIcons.circleHelp),
            label: Text(l10n?.desktopSidebarHelp ?? '帮助'),
            onPress: () => context.push(AppRoutes.assistant),
          ),
        ],
      ),
      children: [
        tabItem(ShellTab.today),
        tabItem(ShellTab.record),
        tabItem(ShellTab.medicine),
        tabItem(ShellTab.report),
        tabItem(ShellTab.mine),
      ],
    );
  }
}
