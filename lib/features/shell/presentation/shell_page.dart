import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_page.dart';
import 'package:luminous/features/mine/presentation/mine_page.dart';
import 'package:luminous/features/record/presentation/record_page.dart';
import 'package:luminous/features/report/presentation/pages/report_page.dart';
import 'package:luminous/features/shell/presentation/shell_tab.dart';
import 'package:luminous/features/shell/providers/shell_provider.dart';
import 'package:luminous/features/today/presentation/pages/today_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ShellPage extends ConsumerWidget {
  const ShellPage({super.key});

  static const _pages = <Widget>[
    TodayPage(),
    RecordPage(),
    MedicinePage(),
    ReportPage(),
    MinePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(shellProvider).currentIndex;
    final notifier = ref.read(shellProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final l10n = AppLocalizations.of(context);
    final typography = width < 600
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);
    final isDesktop = width >= AppBreakpoints.desktop;
    const selectedNavColor = AppColorTokens.health;
    final unselectedNavColor = surface.body;

    final destinations = ShellTab.values
        .map(
          (tab) => NavigationDestination(
            key: tab.testKey(),
            icon: Icon(tab.icon),
            selectedIcon: Icon(tab.activeIcon),
            label: tab.label(l10n),
          ),
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: surface.canvasSoft,
      body: isDesktop
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacingTokens.md),
                child: Row(
                  children: [
                    _DesktopSidebar(
                      currentIndex: currentIndex,
                      onSelect: notifier.selectTab,
                      surface: surface,
                      l10n: l10n,
                    ),
                    const SizedBox(width: AppSpacingTokens.md),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: surface.canvas,
                          borderRadius: BorderRadius.circular(
                            AppRadiusTokens.xl,
                          ),
                          border: Border.all(color: surface.hairline),
                          boxShadow: AppShadowTokens.level1,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppRadiusTokens.xl,
                          ),
                          child: IndexedStack(
                            index: currentIndex,
                            children: _pages
                                .map((page) {
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: surface.canvasSoft,
                                    ),
                                    child: page,
                                  );
                                })
                                .toList(growable: false),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorColor: AppColorTokens.healthSoft,
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    color: selected ? selectedNavColor : unselectedNavColor,
                    size: 24,
                  );
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return typography.caption.copyWith(
                    color: selected ? selectedNavColor : scheme.onSurface,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0,
                  );
                }),
              ),
              child: NavigationBar(
                backgroundColor: surface.canvas.withValues(alpha: 0.96),
                surfaceTintColor: Colors.transparent,
                height: width < 600 ? 70 : 76,
                selectedIndex: currentIndex,
                onDestinationSelected: notifier.selectTab,
                destinations: destinations,
              ),
            ),
    );
  }
}

class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.currentIndex,
    required this.onSelect,
    required this.surface,
    required this.l10n,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final AppThemeSurface surface;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypographyTokens.desktop(
      Theme.of(context).colorScheme.onSurface,
    );
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: 232,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface.canvas,
          borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
          border: Border.all(color: surface.hairline),
          boxShadow: AppShadowTokens.level1,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacingTokens.md,
            AppSpacingTokens.md,
            AppSpacingTokens.md,
            AppSpacingTokens.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _DesktopSidebarBrand(),
              const SizedBox(height: AppSpacingTokens.lg),
              ...ShellTab.values.map(
                (tab) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacingTokens.xs),
                  child: _DesktopSidebarItem(
                    tab: tab,
                    selected: currentIndex == tab.index,
                    label: tab.label(l10n),
                    onTap: () => onSelect(tab.index),
                    typography: typography,
                    surface: surface,
                  ),
                ),
              ),
              const Spacer(),
              _DesktopSidebarActionItem(
                icon: Icons.settings_outlined,
                label: l10n?.desktopSidebarSettings ?? '设置',
                onTap: () => context.push('/settings'),
                typography: typography,
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              _DesktopSidebarActionItem(
                icon: Icons.help_outline_rounded,
                label: l10n?.desktopSidebarHelp ?? '帮助',
                onTap: () => AppToast.show(
                  context,
                  l10n?.desktopSidebarHelpToast ?? '会打开帮助与支持。',
                ),
                typography: typography,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopSidebarActionItem extends StatelessWidget {
  const _DesktopSidebarActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.typography,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.md,
            vertical: AppSpacingTokens.md,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: AppSpacingTokens.md),
              Text(label, style: typography.bodyMd.copyWith(color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopSidebarBrand extends StatelessWidget {
  const _DesktopSidebarBrand();

  @override
  Widget build(BuildContext context) {
    final typography = AppTypographyTokens.desktop(
      Theme.of(context).colorScheme.onSurface,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.sm,
        vertical: AppSpacingTokens.xs,
      ),
      child: Row(
        children: [
          const Icon(Icons.spa_rounded, size: 18, color: Color(0xFF159B55)),
          const SizedBox(width: AppSpacingTokens.sm),
          Text(
            'Luminous',
            style: typography.bodyMdStrong.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopSidebarItem extends StatelessWidget {
  const _DesktopSidebarItem({
    required this.tab,
    required this.selected,
    required this.label,
    required this.onTap,
    required this.typography,
    required this.surface,
  });

  final ShellTab tab;
  final bool selected;
  final String label;
  final VoidCallback onTap;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF159B55);
    final foreground = selected
        ? accent
        : Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF8EE) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(
              color: selected ? const Color(0xFFCDEBD8) : Colors.transparent,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacingTokens.md,
              vertical: AppSpacingTokens.md,
            ),
            child: Row(
              children: [
                Icon(
                  selected ? tab.activeIcon : tab.icon,
                  size: 18,
                  color: foreground,
                ),
                const SizedBox(width: AppSpacingTokens.md),
                Text(
                  label,
                  style: typography.bodyMdStrong.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
