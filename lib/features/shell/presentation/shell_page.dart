import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_page.dart';
import 'package:luminous/features/mine/presentation/pages/mine_page.dart';
import 'package:luminous/features/record/presentation/pages/record_page.dart';
import 'package:luminous/features/report/presentation/pages/report_page.dart';
import 'package:luminous/features/shell/presentation/shell_tab.dart';
import 'package:luminous/features/shell/providers/shell_provider.dart';
import 'package:luminous/features/today/presentation/pages/today_page.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/l10n/app_localizations.dart';

const _shellInset = 16.0;

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
      final shell = navigationShell;
      if (shell != null) {
        shell.goBranch(index);
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
        child: isDesktop
            ? SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    _shellInset / 2,
                    _shellInset,
                    _shellInset,
                    _shellInset,
                  ),
                  child: Column(
                    children: [
                      _DesktopBreadcrumb(
                        l10n: l10n,
                        currentIndex: currentIndex,
                        onSelectTab: onSelectTab,
                      ),
                      const SizedBox(height: _shellInset),
                      Expanded(child: content),
                    ],
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
            children: [
              FSidebarItem(
                label: Text(l10n?.sidebarSettingsNotifications ?? '通知设置'),
                onPress: () => context.push(AppRoutes.settingsNotifications),
              ),
              FSidebarItem(
                label: Text(l10n?.sidebarSettingsTheme ?? '主题外观'),
                onPress: () => context.push(AppRoutes.settingsTheme),
              ),
              FSidebarItem(
                label: Text(l10n?.sidebarSettingsLanguage ?? '语言'),
                onPress: () => context.push(AppRoutes.settingsLanguage),
              ),
              FSidebarItem(
                label: Text(l10n?.sidebarSettingsAccessibility ?? '无障碍'),
                onPress: () => context.push(AppRoutes.settingsAccessibility),
              ),
              FSidebarItem(
                label: Text(l10n?.sidebarSettingsAi ?? 'AI 设置'),
                onPress: () => context.push(AppRoutes.settingsAi),
              ),
              FSidebarItem(
                label: Text(l10n?.sidebarSettingsExport ?? '数据导出'),
                onPress: () => context.push(AppRoutes.settingsExport),
              ),
              FSidebarItem(
                label: Text(l10n?.settingsDataStorageTitle ?? '数据与存储'),
                onPress: () => context.push(AppRoutes.settingsDataStorage),
              ),
              FSidebarItem(
                label: Text(l10n?.sidebarSettingsSecurityPin ?? '安全锁'),
                onPress: () => context.push(AppRoutes.settingsSecurityPin),
              ),
              FSidebarItem(
                label: Text(l10n?.sidebarSettingsAbout ?? '关于'),
                onPress: () => context.push(AppRoutes.settingsAbout),
              ),
            ],
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
        FSidebarItem(
          key: ShellTab.record.testKey(),
          icon: Icon(
            currentIndex == ShellTab.record.index
                ? ShellTab.record.activeIcon
                : ShellTab.record.icon,
          ),
          label: Text(ShellTab.record.label(l10n)),
          selected: currentIndex == ShellTab.record.index,
          onPress: () => onSelectTab(ShellTab.record.index),
          children: [
            FSidebarItem(
              label: Text(l10n?.sidebarRecordCreate ?? '新建记录'),
              onPress: () => context.push(AppRoutes.recordCreate),
            ),
          ],
        ),
        FSidebarItem(
          key: ShellTab.medicine.testKey(),
          icon: Icon(
            currentIndex == ShellTab.medicine.index
                ? ShellTab.medicine.activeIcon
                : ShellTab.medicine.icon,
          ),
          label: Text(ShellTab.medicine.label(l10n)),
          selected: currentIndex == ShellTab.medicine.index,
          onPress: () => onSelectTab(ShellTab.medicine.index),
          children: [
            FSidebarItem(
              label: Text(l10n?.sidebarMedicineSearch ?? '药品搜索'),
              onPress: () => context.push(AppRoutes.medicineSearch),
            ),
            FSidebarItem(
              label: Text(l10n?.sidebarMedicineRiskCheck ?? '安全检查'),
              onPress: () => context.push(AppRoutes.medicineRiskCheck),
            ),
            FSidebarItem(
              label: Text(l10n?.sidebarMedicineReminders ?? '用药提醒'),
              onPress: () => context.push(AppRoutes.medicineRemindersNew),
            ),
          ],
        ),
        tabItem(ShellTab.report),
        FSidebarItem(
          key: ShellTab.mine.testKey(),
          icon: Icon(
            currentIndex == ShellTab.mine.index
                ? ShellTab.mine.activeIcon
                : ShellTab.mine.icon,
          ),
          label: Text(ShellTab.mine.label(l10n)),
          selected: currentIndex == ShellTab.mine.index,
          onPress: () => onSelectTab(ShellTab.mine.index),
          children: [
            FSidebarItem(
              label: Text(l10n?.sidebarMineProfile ?? '个人资料'),
              onPress: () => context.push(AppRoutes.mineProfileEdit),
            ),
            FSidebarItem(
              label: Text(l10n?.sidebarMineAllergy ?? '过敏史'),
              onPress: () => context.push(AppRoutes.mineAllergyNew),
            ),
            FSidebarItem(
              label: Text(l10n?.sidebarMineCondition ?? '健康状况'),
              onPress: () => context.push(AppRoutes.mineConditionNew),
            ),
            FSidebarItem(
              label: Text(l10n?.sidebarMineMedicine ?? '用药档案'),
              onPress: () => context.push(AppRoutes.mineMedicineNew),
            ),
          ],
        ),
      ],
    );
  }
}

class _DesktopBreadcrumb extends StatelessWidget {
  const _DesktopBreadcrumb({
    required this.l10n,
    required this.currentIndex,
    required this.onSelectTab,
  });

  final AppLocalizations? l10n;
  final int currentIndex;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final currentTab = ShellTab.values[currentIndex];

    return FBreadcrumb(
      children: [
        FBreadcrumbItem(
          onPress: () => onSelectTab(0),
          child: Text(l10n?.appTitle ?? 'Luminous'),
        ),
        FBreadcrumbItem(current: true, child: Text(currentTab.label(l10n))),
      ],
    );
  }
}
