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
import 'package:luminous/features/shell/presentation/shell_tab.dart';
import 'package:luminous/features/shell/providers/shell_provider.dart';
import 'package:luminous/features/shell/providers/shell_sidebar_provider.dart';
import 'package:luminous/features/today/presentation/pages/today_page.dart';
import 'package:luminous/l10n/app_localizations.dart';

const _sidebarAnimationDuration = Duration(milliseconds: 200);
const _sidebarAnimationCurve = Curves.easeInOutCubic;
const _sidebarNarrowThreshold = 120.0;
const _sidebarBrandThreshold = 160.0;
const _sidebarFullThreshold = 200.0;

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
    const selectedNavColor = AppColorTokens.health;
    final unselectedNavColor = surface.body;
    final isDesktop = width >= AppBreakpoints.desktop;

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

    return Scaffold(
      backgroundColor: surface.canvasSoft,
      body: isDesktop
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacingTokens.md),
                child: Row(
                  children: [
                    _DesktopSidebar(
                      navigationShell: navigationShell,
                      surface: surface,
                    ),
                    const SizedBox(width: AppSpacingTokens.md),
                    Expanded(
                      child: RepaintBoundary(
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
                    ),
                  ],
                ),
              ),
            )
          : content,
      bottomNavigationBar: isDesktop
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

class _DesktopSidebar extends ConsumerStatefulWidget {
  const _DesktopSidebar({required this.navigationShell, required this.surface});

  final StatefulNavigationShell? navigationShell;
  final AppThemeSurface surface;

  @override
  ConsumerState<_DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends ConsumerState<_DesktopSidebar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _widthAnimation;
  late double _targetWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _sidebarAnimationDuration,
    );
    _targetWidth = ShellSidebarDimensions.expandedWidth;
    _widthAnimation = _alwaysTween(_targetWidth);
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

  void _onSelect(int index) {
    if (widget.navigationShell != null) {
      widget.navigationShell!.goBranch(index);
    } else {
      ref.read(shellProvider.notifier).selectTab(index);
    }
  }

  void _onSettings() => context.push('/settings');

  void _onHelp() => context.push('/assistant');

  void _onToggle() => ref.read(shellSidebarProvider.notifier).toggle();

  @override
  Widget build(BuildContext context) {
    final sidebarAsync = ref.watch(shellSidebarProvider);
    final sidebarState = sidebarAsync.value ?? const ShellSidebarState();
    final isCollapsed = sidebarState.collapsed;
    final targetWidth = sidebarState.width;
    final currentIndex =
        widget.navigationShell?.currentIndex ??
        ref.watch(shellProvider).currentIndex;
    final typography = AppTypographyTokens.desktop(
      Theme.of(context).colorScheme.onSurface,
    );
    final l10n = AppLocalizations.of(context);

    if (_targetWidth != targetWidth) {
      _targetWidth = targetWidth;
      _widthAnimation =
          Tween<double>(begin: _widthAnimation.value, end: targetWidth).animate(
            CurvedAnimation(parent: _controller, curve: _sidebarAnimationCurve),
          );
      _controller.forward(from: 0);
    }

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
              final width = constraints.maxWidth;
              final isNarrow = width < _sidebarNarrowThreshold;
              final showBrand = width >= _sidebarBrandThreshold;
              final horizontalPadding = isNarrow
                  ? AppSpacingTokens.xs
                  : AppSpacingTokens.md;
              final itemLabelOpacity = isNarrow
                  ? 0.0
                  : ((width - _sidebarNarrowThreshold) /
                            (_sidebarFullThreshold - _sidebarNarrowThreshold))
                        .clamp(0.0, 1.0);
              final brandOpacity = !showBrand
                  ? 0.0
                  : ((width - _sidebarBrandThreshold) /
                            (_sidebarFullThreshold - _sidebarBrandThreshold))
                        .clamp(0.0, 1.0);
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
                      collapsed: isCollapsed,
                      showBrand: showBrand,
                      brandOpacity: brandOpacity,
                      onToggle: _onToggle,
                    ),
                    const SizedBox(height: AppSpacingTokens.lg),
                    ...ShellTab.values.map(
                      (tab) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacingTokens.xs,
                        ),
                        child: _DesktopSidebarItem(
                          tab: tab,
                          selected: currentIndex == tab.index,
                          isNarrow: isNarrow,
                          labelOpacity: itemLabelOpacity,
                          label: tab.label(l10n),
                          onTap: () => _onSelect(tab.index),
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
                      labelOpacity: itemLabelOpacity,
                      onTap: _onSettings,
                      typography: typography,
                    ),
                    const SizedBox(height: AppSpacingTokens.xs),
                    _DesktopSidebarActionItem(
                      icon: Icons.help_outline_rounded,
                      label: l10n?.desktopSidebarHelp ?? '帮助',
                      isNarrow: isNarrow,
                      labelOpacity: itemLabelOpacity,
                      onTap: _onHelp,
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
    required this.labelOpacity,
    required this.onTap,
    required this.typography,
  });

  final IconData icon;
  final String label;
  final bool isNarrow;
  final double labelOpacity;
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
                      Expanded(
                        child: Opacity(
                          opacity: labelOpacity,
                          child: Text(
                            label,
                            style: typography.bodyMd.copyWith(
                              color: foreground,
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

class _DesktopSidebarBrand extends StatelessWidget {
  const _DesktopSidebarBrand({
    required this.collapsed,
    required this.showBrand,
    required this.brandOpacity,
    required this.onToggle,
  });

  final bool collapsed;
  final bool showBrand;
  final double brandOpacity;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final typography = AppTypographyTokens.desktop(
      Theme.of(context).colorScheme.onSurface,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: showBrand ? AppSpacingTokens.sm : 0,
        vertical: AppSpacingTokens.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.spa_rounded, size: 18, color: AppColorTokens.accent),
          if (showBrand) ...[
            const SizedBox(width: AppSpacingTokens.sm),
            Expanded(
              child: Opacity(
                opacity: brandOpacity,
                child: Text(
                  'Luminous',
                  overflow: TextOverflow.ellipsis,
                  style: typography.bodyMdStrong.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
                width: showBrand ? 32 : 24,
                height: showBrand ? 32 : 24,
                alignment: Alignment.center,
                child: AnimatedSwitcher(
                  duration: _sidebarAnimationDuration,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: Icon(
                    collapsed ? Icons.chevron_right : Icons.chevron_left,
                    key: ValueKey<bool>(collapsed),
                    size: 18,
                  ),
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
    required this.labelOpacity,
    required this.label,
    required this.onTap,
    required this.typography,
    required this.surface,
  });

  final ShellTab tab;
  final bool selected;
  final bool isNarrow;
  final double labelOpacity;
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
                        child: Opacity(
                          opacity: labelOpacity,
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
