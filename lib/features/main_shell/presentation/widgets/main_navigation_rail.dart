part of '../main_shell.dart';

class _MainNavigationRail extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentColor = itemColors[currentIndex];
    final width = extended ? 228.0 : 100.0;
    final railBackground = Color.alphaBlend(
      currentColor.withValues(alpha: isDark ? 0.10 : 0.055),
      backgroundColor,
    );

    return SizedBox(
      width: width,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: List.generate(items.length, (i) {
                final selected = i == currentIndex;
                final item = items[i];
                final itemColor = itemColors[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: extended ? 16 : 16,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? itemColor.withValues(alpha: isDark ? 0.22 : 0.14)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: extended
                          ? Row(
                              children: [
                                Icon(
                                  selected ? item.activeIcon : item.icon,
                                  size: 24,
                                  color: selected ? itemColor : inactiveColor,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  item.text,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected ? itemColor : inactiveColor,
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
                                  color: selected ? itemColor : inactiveColor,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.text,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: selected ? itemColor : inactiveColor,
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
        ),
      ),
    );
  }
}
