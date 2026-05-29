part of '../main_shell.dart';

class _MainNavigationRail extends StatefulWidget {
  const _MainNavigationRail({
    required this.items,
    required this.itemColors,
    required this.currentIndex,
    required this.backgroundColor,
    required this.inactiveColor,
    required this.extended,
    required this.onTap,
  });

  final List<_MainTabItem> items;
  final List<Color> itemColors;
  final int currentIndex;
  final Color backgroundColor;
  final Color inactiveColor;
  final bool extended;
  final ValueChanged<int> onTap;

  @override
  State<_MainNavigationRail> createState() => _MainNavigationRailState();
}

class _MainNavigationRailState extends State<_MainNavigationRail> {
  static const double _minWidth = 80;
  static const double _maxWidth = 360;
  static const double _defaultCollapsed = 136;
  static const double _defaultExpanded = 228;

  late double _width;

  @override
  void initState() {
    super.initState();
    _width = widget.extended ? _defaultExpanded : _defaultCollapsed;
  }

  @override
  void didUpdateWidget(_MainNavigationRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.extended != widget.extended) {
      _width = widget.extended ? _defaultExpanded : _defaultCollapsed;
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _width = (_width + details.delta.dx).clamp(_minWidth, _maxWidth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentColor = widget.itemColors[widget.currentIndex];
    final railBackground = Color.alphaBlend(
      currentColor.withValues(alpha: isDark ? 0.10 : 0.055),
      widget.backgroundColor,
    );

    return SizedBox(
      width: _width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: railBackground,
          border: Border(
            right: BorderSide(
              color: Color.alphaBlend(
                currentColor.withValues(alpha: isDark ? 0.18 : 0.10),
                theme.colorScheme.outline,
              ),
            ),
          ),
        ),
        child: SafeArea(
          right: false,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(widget.items.length, (i) {
                    final selected = i == widget.currentIndex;
                    final item = widget.items[i];
                    final itemColor = widget.itemColors[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onTap(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: _width >= 160 ? 12 : 0,
                          ),
                          alignment: _width >= 160
                              ? Alignment.centerLeft
                              : Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? itemColor.withValues(
                                    alpha: isDark ? 0.22 : 0.14,
                                  )
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: _width >= 160
                              ? Row(
                                  children: [
                                    Icon(
                                      selected ? item.activeIcon : item.icon,
                                      size: 24,
                                      color: selected
                                          ? itemColor
                                          : widget.inactiveColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item.text,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: selected
                                              ? itemColor
                                              : widget.inactiveColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      selected ? item.activeIcon : item.icon,
                                      size: 24,
                                      color: selected
                                          ? itemColor
                                          : widget.inactiveColor,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.text,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selected
                                            ? itemColor
                                            : widget.inactiveColor,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // 右侧拖拽手柄
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onHorizontalDragUpdate: _onDragUpdate,
                  behavior: HitTestBehavior.translucent,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeColumn,
                    child: SizedBox(
                      width: 8,
                      child: Center(
                        child: Container(
                          width: 3,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
