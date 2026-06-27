import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/medicine/presentation/pages/medicine_page.dart';
import 'package:luminous/features/mine/presentation/pages/mine_page.dart';
import 'package:luminous/features/record/presentation/pages/record_page.dart';
import 'package:luminous/features/report/presentation/pages/report_page.dart';
import 'package:luminous/features/shell/presentation/shell_branch.dart';
import 'package:luminous/features/shell/presentation/shell_tab.dart';
import 'package:luminous/features/shell/providers/shell_provider.dart';
import 'package:luminous/features/shell/providers/shell_sidebar_provider.dart';
import 'package:luminous/features/today/presentation/pages/today_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

const _sidebarAnimationDuration = Duration(milliseconds: 200);
const _sidebarAnimationCurve = Curves.easeOutCubic;
const _sidebarNarrowThreshold = 140.0;

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
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final l10n = AppLocalizations.of(context);
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);
    final isDesktop = width >= AppBreakpoints.desktop;
    const selectedNavColor = AppColorTokens.health;
    final unselectedNavColor = surface.body;
    final isHiddenBranch =
        navigationShell != null && currentIndex >= ShellTab.values.length;

    final sidebarAsync = ref.watch(shellSidebarProvider);
    final sidebarState = sidebarAsync.value ?? const ShellSidebarState();
    final isCollapsed = sidebarState.collapsed;
    final sidebarWidth = sidebarState.width;

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

    final content = navigationShell ?? _pages[currentIndex];

    void onSelectTab(int index) {
      if (navigationShell != null) {
        navigationShell!.goBranch(index);
      } else {
        legacyNotifier.selectTab(index);
      }
    }

    void onSettings() {
      if (navigationShell != null) {
        navigationShell!.goBranch(ShellBranch.settings.index);
      } else {
        context.push('/settings');
      }
    }

    void onHelp() {
      if (navigationShell != null) {
        navigationShell!.goBranch(ShellBranch.assistant.index);
      } else {
        context.push('/assistant');
      }
    }

    Future<void> onToggleSidebar() async {
      await ref.read(shellSidebarProvider.notifier).toggle();
    }

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
                      collapsed: isCollapsed,
                      targetWidth: sidebarWidth,
                      onSelect: onSelectTab,
                      onSettings: onSettings,
                      onHelp: onHelp,
                      onToggle: onToggleSidebar,
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
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: surface.canvasSoft,
                            ),
                            child: content,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : content,
      bottomNavigationBar: isDesktop || isHiddenBranch
          ? null
          : MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.2,
              child: NavigationBarTheme(
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
                      overflow: TextOverflow.ellipsis,
                    );
                  }),
                ),
                child: NavigationBar(
                  backgroundColor: surface.canvas.withValues(alpha: 0.96),
                  surfaceTintColor: Colors.transparent,
                  height: width < AppBreakpoints.mobile ? 70 : 76,
                  selectedIndex: currentIndex,
                  onDestinationSelected: onSelectTab,
                  destinations: destinations,
                ),
              ),
            ),
    );
  }
}

class _DesktopSidebar extends StatefulWidget {
  const _DesktopSidebar({
    required this.currentIndex,
    required this.collapsed,
    required this.targetWidth,
    required this.onSelect,
    required this.onSettings,
    required this.onHelp,
    required this.onToggle,
    required this.surface,
    required this.l10n,
  });

  final int currentIndex;
  final bool collapsed;
  final double targetWidth;
  final ValueChanged<int> onSelect;
  final VoidCallback onSettings;
  final VoidCallback onHelp;
  final VoidCallback onToggle;
  final AppThemeSurface surface;
  final AppLocalizations? l10n;

  @override
  State<_DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<_DesktopSidebar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _sidebarAnimationDuration,
    );
    _widthAnimation = _alwaysTween(widget.targetWidth);
  }

  @override
  void didUpdateWidget(covariant _DesktopSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetWidth != widget.targetWidth) {
      _widthAnimation =
          Tween<double>(
            begin: _widthAnimation.value,
            end: widget.targetWidth,
          ).animate(
            CurvedAnimation(parent: _controller, curve: _sidebarAnimationCurve),
          );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _alwaysTween(double value) =>
      Tween<double>(begin: value, end: value).animate(
        CurvedAnimation(parent: _controller, curve: _sidebarAnimationCurve),
      );

  @override
  Widget build(BuildContext context) {
    final typography = AppTypographyTokens.desktop(
      Theme.of(context).colorScheme.onSurface,
    );
    final l10n = AppLocalizations.of(context);

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.15,
      child: AnimatedBuilder(
        animation: _widthAnimation,
        builder: (context, child) =>
            SizedBox(width: _widthAnimation.value, child: child),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
            border: Border.all(color: widget.surface.hairline),
            boxShadow: AppShadowTokens.level1,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < _sidebarNarrowThreshold;
              final horizontalPadding = isNarrow
                  ? AppSpacingTokens.xs
                  : AppSpacingTokens.md;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  AppSpacingTokens.md,
                  horizontalPadding,
                  AppSpacingTokens.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DesktopSidebarBrand(
                      collapsed: widget.collapsed,
                      isNarrow: isNarrow,
                      onToggle: widget.onToggle,
                    ),
                    const SizedBox(height: AppSpacingTokens.lg),
                    ...ShellTab.values.map(
                      (tab) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacingTokens.xs,
                        ),
                        child: _DesktopSidebarItem(
                          tab: tab,
                          selected: widget.currentIndex == tab.index,
                          isNarrow: isNarrow,
                          label: tab.label(l10n),
                          onTap: () => widget.onSelect(tab.index),
                          typography: typography,
                          surface: widget.surface,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _DesktopSidebarActionItem(
                      icon: Icons.settings_outlined,
                      label: l10n?.desktopSidebarSettings ?? '设置',
                      isNarrow: isNarrow,
                      onTap: widget.onSettings,
                      typography: typography,
                    ),
                    const SizedBox(height: AppSpacingTokens.xs),
                    _DesktopSidebarActionItem(
                      icon: Icons.help_outline_rounded,
                      label: l10n?.desktopSidebarHelp ?? '帮助',
                      isNarrow: isNarrow,
                      onTap: widget.onHelp,
                      typography: typography,
                    ),
                  ],
                ),
              );
            },
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
    required this.isNarrow,
    required this.onTap,
    required this.typography,
  });

  final IconData icon;
  final String label;
  final bool isNarrow;
  final VoidCallback onTap;
  final AppTypographyScale typography;

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurface;
    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? AppSpacingTokens.xs : AppSpacingTokens.md,
              vertical: AppSpacingTokens.md,
            ),
            child: isNarrow
                ? Center(child: Icon(icon, size: 18, color: foreground))
                : Row(
                    children: [
                      Icon(icon, size: 18, color: foreground),
                      const SizedBox(width: AppSpacingTokens.md),
                      Text(
                        label,
                        style: typography.bodyMd.copyWith(color: foreground),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (isNarrow) {
      return Tooltip(message: label, child: child);
    }
    return child;
  }
}

class _DesktopSidebarBrand extends StatelessWidget {
  const _DesktopSidebarBrand({
    required this.collapsed,
    required this.isNarrow,
    required this.onToggle,
  });

  final bool collapsed;
  final bool isNarrow;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypographyTokens.desktop(
      Theme.of(context).colorScheme.onSurface,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 0 : AppSpacingTokens.sm,
        vertical: AppSpacingTokens.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.spa_rounded, size: 18, color: AppColorTokens.accent),
          if (!isNarrow) ...[
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Text(
                'Luminous',
                overflow: TextOverflow.ellipsis,
                style: typography.bodyMdStrong.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          Tooltip(
            message: collapsed ? '展开侧边栏' : '收起侧边栏',
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
              child: Container(
                width: isNarrow ? 24 : 32,
                height: isNarrow ? 24 : 32,
                alignment: Alignment.center,
                child: Icon(
                  collapsed ? Icons.chevron_right : Icons.chevron_left,
                  size: 18,
                ),
              ),
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
    required this.isNarrow,
    required this.label,
    required this.onTap,
    required this.typography,
    required this.surface,
  });

  final ShellTab tab;
  final bool selected;
  final bool isNarrow;
  final String label;
  final VoidCallback onTap;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final foreground = Theme.of(context).colorScheme.onSurface;

    final child = Material(
      color: selected
          ? AppColorTokens.healthSoft.withValues(alpha: 0.5)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? AppSpacingTokens.xs : AppSpacingTokens.md,
              vertical: AppSpacingTokens.md,
            ),
            child: isNarrow
                ? Center(
                    child: Icon(
                      selected ? tab.activeIcon : tab.icon,
                      size: 18,
                      color: selected ? AppColorTokens.health : foreground,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        selected ? tab.activeIcon : tab.icon,
                        size: 18,
                        color: selected ? AppColorTokens.health : foreground,
                      ),
                      const SizedBox(width: AppSpacingTokens.md),
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: isNarrow ? 0 : 1,
                          duration: _sidebarAnimationDuration,
                          curve: _sidebarAnimationCurve,
                          child: Text(
                            label,
                            style: typography.bodyMd.copyWith(
                              color: selected
                                  ? AppColorTokens.health
                                  : foreground,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );

    if (isNarrow) {
      return Tooltip(message: label, child: child);
    }
    return child;
  }
}
