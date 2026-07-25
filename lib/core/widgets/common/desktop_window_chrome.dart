import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';

/// Desktop window title bar with drag area and window control buttons.
///
/// Rendered at the top of the app on Windows/Linux. Provides a full-width
/// [DragToMoveArea] for window dragging and min/max/close buttons at the
/// right edge of the window — not constrained to the sidebar width.
///
/// On macOS, the system renders traffic-light buttons automatically;
/// this widget is not used there.
class DesktopWindowChrome extends StatefulWidget {
  const DesktopWindowChrome({super.key});

  /// Height of the title bar in logical pixels.
  static const double height = 32;

  @override
  State<DesktopWindowChrome> createState() => _DesktopWindowChromeState();
}

class _DesktopWindowChromeState extends State<DesktopWindowChrome>
    with WindowListener {
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
    final maximized = await windowManager.isMaximized();
    if (mounted && maximized != _isMaximized) {
      setState(() => _isMaximized = maximized);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = context.theme;

    return Container(
      height: DesktopWindowChrome.height,
      color: theme.colors.background,
      child: Row(
        children: [
          const Expanded(child: DragToMoveArea(child: SizedBox.expand())),
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
        ],
      ),
    );
  }
}

/// Window control buttons (min/max/close) for Windows/Linux.
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
            iconSize: IconSizeTokens.level2,
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
    this.iconSize = IconSizeTokens.level2,
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
