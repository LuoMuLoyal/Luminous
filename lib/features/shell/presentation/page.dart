import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/providers/sidebar_preference.dart';
import 'package:luminous/core/theme/preference.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/notification/data/providers/unread_count.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';

const _shellInset = 16.0;
const _collapsedSidebarWidth = 64.0;

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
  final AppLocalizations l10n;
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

class _DesktopSidebar extends ConsumerWidget {
  const _DesktopSidebar({
    required this.currentIndex,
    required this.l10n,
    required this.onSelectTab,
  });

  final int currentIndex;
  final AppLocalizations l10n;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final collapsed =
        ref.watch(sidebarPreferenceProvider).asData?.value ?? false;
    final session = ref.watch(authSessionProvider);

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

    return AnimatedContainer(
      duration: DurationTokens.widgetQuick,
      curve: Curves.easeOut,
      width: collapsed ? _collapsedSidebarWidth : null,
      child: FSidebar(
        style: FSidebarStyle(
          decoration: BoxDecoration(color: theme.colors.background),
          groupStyle: theme.sidebarStyle.groupStyle,
        ),
        header: _WindowTitleBar(collapsed: collapsed, session: session),
        footer: _SidebarFooter(collapsed: collapsed),
        children: [
          tabItem(ShellTab.today),
          tabItem(ShellTab.record),
          tabItem(ShellTab.medicine),
          tabItem(ShellTab.report),
          tabItem(ShellTab.mine),
        ],
      ),
    );
  }
}

/// Window title bar that wraps the sidebar header.
///
/// On desktop, this widget:
/// - Wraps the header content with [DragToMoveArea] so the user can drag
///   the sidebar header to move the window.
/// - On Windows/Linux, renders custom min/max/close buttons at the top.
/// - On macOS, the system renders the traffic-light buttons automatically;
///   we add left padding so the header content doesn't overlap them.
class _WindowTitleBar extends StatefulWidget {
  const _WindowTitleBar({required this.collapsed, required this.session});

  final bool collapsed;
  final AuthSessionState session;

  @override
  State<_WindowTitleBar> createState() => _WindowTitleBarState();
}

class _WindowTitleBarState extends State<_WindowTitleBar> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkMaximized();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    if (mounted && !_isMaximized) {
      setState(() => _isMaximized = true);
    }
  }

  @override
  void onWindowUnmaximize() {
    if (mounted && _isMaximized) {
      setState(() => _isMaximized = false);
    }
  }

  Future<void> _checkMaximized() async {
    if (!Platform.isWindows && !Platform.isLinux) return;
    final maximized = await windowManager.isMaximized();
    if (mounted && maximized != _isMaximized) {
      setState(() => _isMaximized = maximized);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Build the header content (logo or user info).
    final headerContent = _SidebarHeaderContent(
      collapsed: widget.collapsed,
      session: widget.session,
    );

    // On macOS, the traffic lights are at the top-left and overlap the
    // sidebar. Add left padding so the header content is not hidden.
    final isMacOS = Platform.isMacOS;
    final macPadding = isMacOS
        ? const EdgeInsets.only(left: 70)
        : EdgeInsets.zero;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Window control buttons (Windows/Linux only).
        if (Platform.isWindows || Platform.isLinux)
          _WindowControlButtons(
            isMaximized: _isMaximized,
            l10n: l10n,
            onMinimize: () => windowManager.minimize(),
            onMaximizeToggle: () async {
              if (_isMaximized) {
                await windowManager.unmaximize();
              } else {
                await windowManager.maximize();
              }
              await _checkMaximized();
            },
            onClose: () => windowManager.close(),
          ),
        // Draggable header area.
        DragToMoveArea(
          child: Padding(padding: macPadding, child: headerContent),
        ),
        // Listen for window state changes (maximize/unmaximize).
        // Using a Listener to detect focus changes which triggers re-check.
      ],
    );
  }
}

/// Window control buttons for Windows/Linux (min/max/close).
class _WindowControlButtons extends StatelessWidget {
  const _WindowControlButtons({
    required this.isMaximized,
    required this.l10n,
    required this.onMinimize,
    required this.onMaximizeToggle,
    required this.onClose,
  });

  final bool isMaximized;
  final AppLocalizations l10n;
  final VoidCallback onMinimize;
  final VoidCallback onMaximizeToggle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final iconColor = theme.colors.mutedForeground;

    return Padding(
      padding: const EdgeInsets.only(right: 4, top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _WindowButton(
            icon: FLucideIcons.minus,
            tooltip: l10n.desktopWindowMinimize,
            iconColor: iconColor,
            onPressed: onMinimize,
          ),
          _WindowButton(
            icon: isMaximized ? FLucideIcons.copy : FLucideIcons.square,
            iconSize: 14,
            tooltip: isMaximized
                ? l10n.desktopWindowRestore
                : l10n.desktopWindowMaximize,
            iconColor: iconColor,
            onPressed: onMaximizeToggle,
          ),
          _WindowButton(
            icon: FLucideIcons.x,
            tooltip: l10n.desktopWindowClose,
            iconColor: iconColor,
            hoverColor: theme.colors.destructive,
            hoverIconColor: theme.colors.background,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

/// A single window control button.
class _WindowButton extends StatefulWidget {
  const _WindowButton({
    required this.icon,
    required this.tooltip,
    required this.iconColor,
    required this.onPressed,
    this.iconSize = 16,
    this.hoverColor,
    this.hoverIconColor,
  });

  final IconData icon;
  final String tooltip;
  final Color iconColor;
  final VoidCallback onPressed;
  final double iconSize;
  final Color? hoverColor;
  final Color? hoverIconColor;

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveHoverColor =
        widget.hoverColor ?? SemanticColor.neutral.muted(context);
    final effectiveHoverIconColor = widget.hoverIconColor ?? widget.iconColor;

    return FTooltip(
      tipBuilder: (context, controller) => Text(widget.tooltip),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: DurationTokens.widgetQuick,
            width: 36,
            height: 28,
            decoration: BoxDecoration(
              color: _isHovered ? effectiveHoverColor : Colors.transparent,
              borderRadius: BorderRadius.circular(RadiusTokens.level1),
            ),
            child: Center(
              child: Icon(
                widget.icon,
                size: widget.iconSize,
                color: _isHovered ? effectiveHoverIconColor : widget.iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The sidebar header content (logo or user info), extracted from the
/// original _SidebarHeader for reuse inside _WindowTitleBar.
class _SidebarHeaderContent extends StatelessWidget {
  const _SidebarHeaderContent({required this.collapsed, required this.session});

  final bool collapsed;
  final AuthSessionState session;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context)!;

    if (collapsed) {
      // Collapsed: just the logo icon, centered.
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.level2),
        child: Center(
          child: Icon(
            FLucideIcons.heartPulse,
            size: 18,
            color: theme.colors.primary,
          ),
        ),
      );
    }

    // Expanded: user info row if authenticated, otherwise logo + app title.
    if (session.isAuthenticated && session.user != null) {
      final user = session.user!;
      final displayName = user.nickname ?? user.email ?? '';
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: GestureDetector(
          onTap: () => context.push(Routes.mine),
          child: Row(
            children: [
              FAvatar.raw(
                size: 28,
                child: const Icon(FLucideIcons.userRound, size: 16),
              ),
              const SizedBox(width: Spacing.level2),
              Expanded(
                child: Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(FLucideIcons.heartPulse, size: 18, color: theme.colors.primary),
          const SizedBox(width: Spacing.level2),
          Expanded(
            child: Text(
              l10n.appTitle,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sidebar footer with settings, help, theme toggle, notifications, and
/// collapse/expand button.
class _SidebarFooter extends ConsumerWidget {
  const _SidebarFooter({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = context.theme;
    final themePref = ref
        .watch(themeControllerProvider)
        .maybeWhen(data: (p) => p, orElse: () => const ThemePreference());
    final unreadAsync = ref.watch(notificationUnreadCountProvider);
    final hasUnread =
        unreadAsync.whenOrNull(data: (count) => count > 0) ?? false;

    // Determine the next theme mode for the quick toggle.
    final nextMode = switch (themePref.mode) {
      AppThemeModePreference.system => AppThemeModePreference.light,
      AppThemeModePreference.light => AppThemeModePreference.dark,
      AppThemeModePreference.dark => AppThemeModePreference.system,
    };
    final themeIcon = switch (themePref.mode) {
      AppThemeModePreference.system => FLucideIcons.monitor,
      AppThemeModePreference.light => FLucideIcons.sun,
      AppThemeModePreference.dark => FLucideIcons.moon,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!collapsed) ...[
          // Expanded: show full sidebar items.
          FTooltip(
            tipBuilder: (context, controller) =>
                Text(l10n.desktopSidebarNotifications),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                FSidebarItem(
                  icon: const Icon(FLucideIcons.bell),
                  label: Text(l10n.desktopSidebarNotifications),
                  onPress: () => context.push(Routes.notifications),
                ),
                if (hasUnread)
                  Positioned(
                    right: Spacing.level4,
                    top: Spacing.level3,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colors.destructive,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox.square(dimension: Spacing.level2),
                    ),
                  ),
              ],
            ),
          ),
          FSidebarItem(
            icon: Icon(themeIcon),
            label: Text(l10n.desktopSidebarThemeToggle),
            onPress: () =>
                ref.read(themeControllerProvider.notifier).setMode(nextMode),
          ),
          FSidebarItem(
            icon: const Icon(FLucideIcons.settings),
            label: Text(l10n.desktopSidebarSettings),
            onPress: () => context.push(Routes.settings),
          ),
          FSidebarItem(
            icon: const Icon(FLucideIcons.circleHelp),
            label: Text(l10n.desktopSidebarHelp),
            onPress: () => context.push(Routes.assistant),
          ),
          _CollapseToggleButton(collapsed: collapsed),
        ] else ...[
          // Collapsed: icon-only items with tooltips.
          _SidebarIconAction(
            icon: FLucideIcons.bell,
            tooltip: l10n.desktopSidebarNotifications,
            showBadge: hasUnread,
            badgeColor: theme.colors.destructive,
            onPress: () => context.push(Routes.notifications),
          ),
          _SidebarIconAction(
            icon: themeIcon,
            tooltip: l10n.desktopSidebarThemeToggle,
            onPress: () =>
                ref.read(themeControllerProvider.notifier).setMode(nextMode),
          ),
          _SidebarIconAction(
            icon: FLucideIcons.settings,
            tooltip: l10n.desktopSidebarSettings,
            onPress: () => context.push(Routes.settings),
          ),
          _SidebarIconAction(
            icon: FLucideIcons.circleHelp,
            tooltip: l10n.desktopSidebarHelp,
            onPress: () => context.push(Routes.assistant),
          ),
          _CollapseToggleButton(collapsed: collapsed),
        ],
      ],
    );
  }
}

/// Collapse/expand toggle button at the bottom of the sidebar footer.
class _CollapseToggleButton extends ConsumerWidget {
  const _CollapseToggleButton({required this.collapsed});

  final bool collapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = context.theme;
    final tooltip = collapsed
        ? l10n.desktopSidebarExpand
        : l10n.desktopSidebarCollapse;

    void toggle() {
      ref.read(sidebarPreferenceProvider.notifier).toggle();
    }

    if (collapsed) {
      return _SidebarIconAction(
        icon: FLucideIcons.panelLeftOpen,
        tooltip: tooltip,
        onPress: toggle,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: Spacing.level1),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FTooltip(
          tipBuilder: (context, controller) => Text(tooltip),
          child: FButton.icon(
            onPress: toggle,
            variant: FButtonVariant.ghost,
            child: Icon(
              FLucideIcons.panelLeftClose,
              size: 18,
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon-only sidebar action used in collapsed (rail) mode.
class _SidebarIconAction extends StatelessWidget {
  const _SidebarIconAction({
    required this.icon,
    required this.tooltip,
    required this.onPress,
    this.showBadge = false,
    this.badgeColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPress;
  final bool showBadge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return FTooltip(
      tipBuilder: (context, controller) => Text(tooltip),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          FSidebarItem(icon: Icon(icon), selected: false, onPress: onPress),
          if (showBadge && badgeColor != null)
            Positioned(
              right: Spacing.level3 + 2,
              top: Spacing.level2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.square(dimension: Spacing.level2),
              ),
            ),
        ],
      ),
    );
  }
}
