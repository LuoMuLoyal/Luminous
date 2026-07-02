import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_page.dart';
import 'package:luminous/features/mine/presentation/pages/mine_page.dart';
import 'package:luminous/features/record/presentation/pages/record_page.dart';
import 'package:luminous/features/report/presentation/pages/report_page.dart';
import 'package:luminous/features/shell/presentation/shell_tab.dart';
import 'package:luminous/features/shell/providers/shell_provider.dart';
import 'package:luminous/features/shell/providers/shell_sidebar_provider.dart';
import 'package:luminous/features/today/presentation/pages/today_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

const _shellInset = 16.0;
const _sidebarAnimationDuration = Duration(milliseconds: 200);

class ShellPage extends ConsumerWidget {
  const ShellPage({super.key, this.navigationShell});

  /// The navigation shell provided by [StatefulShellRoute]. When `null` the
  /// page falls back to the legacy [shellProvider] behaviour, which is still
  /// useful for unit tests that render [ShellPage] in isolation.
  final StatefulNavigationShell? navigationShell;

  static const _pages = <Widget>[
    TodayPage(),
    RecordPage(),
    MedicinePage(),
    ReportPage(),
    MinePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legacyIndex = ref.watch(shellProvider).currentIndex;
    final legacyNotifier = ref.read(shellProvider.notifier);
    final currentIndex = navigationShell?.currentIndex ?? legacyIndex;
    final width = MediaQuery.sizeOf(context).width;
    final l10n = AppLocalizations.of(context);
    final isDesktop = width >= AppBreakpoints.desktop;
    final content = navigationShell ?? _pages[currentIndex];

    void onSelectTab(int index) {
      if (navigationShell != null) {
        navigationShell!.goBranch(index);
      } else {
        legacyNotifier.selectTab(index);
      }
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
                    0,
                    _shellInset,
                  ),
                  child: _DesktopSidebar(
                    navigationShell: navigationShell,
                    currentIndex: currentIndex,
                    l10n: l10n,
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
        child: isDesktop
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(_shellInset),
                  child: FCard.raw(
                    clipBehavior: Clip.antiAlias,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: context.theme.colors.background,
                      ),
                      child: content,
                    ),
                  ),
                ),
              )
            : content,
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
      onChange: onSelectTab,
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

class _DesktopSidebar extends ConsumerWidget {
  const _DesktopSidebar({
    required this.navigationShell,
    required this.currentIndex,
    required this.l10n,
  });

  final StatefulNavigationShell? navigationShell;
  final int currentIndex;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarState =
        ref.watch(shellSidebarProvider).value ?? const ShellSidebarState();
    final collapsed = sidebarState.collapsed;
    final targetWidth = sidebarState.width;
    final theme = context.theme;
    final sidebarStyle = FSidebarStyle(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border.all(
          color: theme.colors.border,
          width: theme.style.borderWidth,
        ),
        borderRadius: theme.style.borderRadius.xl,
      ),
      backgroundFilter: theme.sidebarStyle.backgroundFilter,
      constraints: BoxConstraints.tightFor(width: targetWidth),
      groupStyle: theme.sidebarStyle.groupStyle,
      headerPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      footerPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    );

    void onSelect(int index) {
      if (navigationShell != null) {
        navigationShell!.goBranch(index);
      } else {
        ref.read(shellProvider.notifier).selectTab(index);
      }
    }

    return AnimatedContainer(
      duration: _sidebarAnimationDuration,
      curve: Curves.easeInOutCubic,
      width: targetWidth,
      child: FSidebar(
        style: sidebarStyle,
        header: _DesktopSidebarHeader(
          collapsed: collapsed,
          onToggle: () => ref.read(shellSidebarProvider.notifier).toggle(),
          title: l10n?.appTitle ?? 'Luminous',
        ),
        footer: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DesktopSidebarActionItem(
              collapsed: collapsed,
              icon: FLucideIcons.settings,
              label: l10n?.desktopSidebarSettings ?? '设置',
              onPress: () => context.push('/settings'),
            ),
            const SizedBox(height: 4),
            _DesktopSidebarActionItem(
              collapsed: collapsed,
              icon: FLucideIcons.circleHelp,
              label: l10n?.desktopSidebarHelp ?? '帮助',
              onPress: () => context.push('/assistant'),
            ),
          ],
        ),
        children: [
          for (final tab in ShellTab.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _DesktopSidebarTabItem(
                tab: tab,
                collapsed: collapsed,
                label: tab.label(l10n),
                selected: currentIndex == tab.index,
                onPress: () => onSelect(tab.index),
              ),
            ),
        ],
      ),
    );
  }
}

class _DesktopSidebarHeader extends StatelessWidget {
  const _DesktopSidebarHeader({
    required this.collapsed,
    required this.onToggle,
    required this.title,
  });

  final bool collapsed;
  final VoidCallback onToggle;
  final String title;

  @override
  Widget build(BuildContext context) {
    final toggle = Tooltip(
      message: collapsed ? '展开侧边栏' : '收起侧边栏',
      child: SizedBox.square(
        dimension: 24,
        child: FButton.icon(
          onPress: onToggle,
          variant: FButtonVariant.ghost,
          size: FButtonSizeVariant.xs,
          child: Icon(
            collapsed ? FLucideIcons.chevronRight : FLucideIcons.chevronLeft,
            key: ValueKey<bool>(collapsed),
            size: 18,
          ),
        ),
      ),
    );

    if (collapsed) {
      return Row(
        children: [
          Icon(
            FLucideIcons.heartPulse,
            size: 18,
            color: context.theme.colors.primary,
          ),
          const Spacer(),
          toggle,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              FLucideIcons.heartPulse,
              size: 18,
              color: context.theme.colors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: context.theme.typography.body.sm.copyWith(
                  color: context.theme.colors.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(alignment: Alignment.centerRight, child: toggle),
      ],
    );
  }
}

class _DesktopSidebarTabItem extends StatelessWidget {
  const _DesktopSidebarTabItem({
    required this.tab,
    required this.collapsed,
    required this.label,
    required this.selected,
    required this.onPress,
  });

  final ShellTab tab;
  final bool collapsed;
  final String label;
  final bool selected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final item = FSidebarItem(
      key: tab.testKey(),
      selected: selected,
      icon: Icon(selected ? tab.activeIcon : tab.icon),
      label: collapsed ? null : Text(label),
      onPress: onPress,
    );

    if (collapsed) {
      return Tooltip(message: label, child: item);
    }

    return item;
  }
}

class _DesktopSidebarActionItem extends StatelessWidget {
  const _DesktopSidebarActionItem({
    required this.collapsed,
    required this.icon,
    required this.label,
    required this.onPress,
  });

  final bool collapsed;
  final IconData icon;
  final String label;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final item = FSidebarItem(
      icon: Icon(icon),
      label: collapsed ? null : Text(label),
      onPress: onPress,
    );

    if (collapsed) {
      return Tooltip(message: label, child: item);
    }

    return item;
  }
}
