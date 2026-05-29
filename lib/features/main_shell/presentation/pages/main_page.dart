part of '../main_shell.dart';

// 主页面：底部 Tab 容器
//
// 注意：
// - 这里用 IndexedStack 保持每个 Tab 的状态（避免切换时重复 initState）
// - 不要在这里再包 SafeArea（单页自己负责），否则容易出现双重 padding

/// 底部导航栏，选中底衬覆盖图标+文字。
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final List<_MainTabItem> items;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: List.generate(items.length, (i) {
            final selected = i == currentIndex;
            final item = items[i];
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? activeColor.withValues(alpha: isDark ? 0.22 : 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? item.activeIcon : item.icon,
                        size: 24,
                        color: selected ? activeColor : inactiveColor,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected ? activeColor : inactiveColor,
                          height: 1.1,
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
    );
  }
}

/// 主页面底部 Tab 容器。
///
/// 只负责一级页面切换与状态保活，不承担各业务页的数据逻辑。
/// 状态由 [mainShellProvider]（Riverpod）管理，替代旧 GetX `MainController`。
class MainPage extends ConsumerWidget {
  /// 创建主页面 Tab 容器组件。
  const MainPage({super.key});

  /// 与底部 Tab 一一对应的页面实例列表。
  static const List<Widget> _pages = [
    HomePage(),
    RecordPage(),
    DrugPage(),
    MinePage(),
    MorePage(),
  ];

  /// 需要在后台预热的二级页面列表。
  static const List<Widget> _secondaryPages = [
    SearchPage(),
    SafetyAssistPage(),
    SettingsPage(),
    ProfileSettingsPage(),
  ];

  List<_MainTabItem> _tablist(AppLocalizations? l10n) {
    return [
      _MainTabItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        text: l10n?.mainTabToday ?? '今日',
      ),
      _MainTabItem(
        icon: Icons.edit_calendar_outlined,
        activeIcon: Icons.edit_calendar,
        text: l10n?.mainTabRecord ?? '记录',
      ),
      _MainTabItem(
        icon: Icons.medication_outlined,
        activeIcon: Icons.medication,
        text: l10n?.mainTabMedicine ?? '用药',
      ),
      _MainTabItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        text: l10n?.mainTabProfile ?? '我的',
      ),
      _MainTabItem(
        icon: Icons.more_horiz,
        activeIcon: Icons.more_horiz,
        text: l10n?.mainTabMore ?? '更多',
      ),
    ];
  }

  Widget _buildSecondaryPreloadLayer(Set<int> preloadedIndexes) {
    return Offstage(
      offstage: true,
      child: TickerMode(
        enabled: false,
        child: Stack(
          fit: StackFit.expand,
          children: List<Widget>.generate(_secondaryPages.length, (index) {
            if (!preloadedIndexes.contains(index)) {
              return const SizedBox.shrink();
            }
            return KeyedSubtree(
              key: ValueKey<String>('secondary-preload-$index'),
              child: _secondaryPages[index],
            );
          }),
        ),
      ),
    );
  }

  List<Color> _resolvedTabColors(ThemeData theme) {
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final colors = <Color>[
      scheme.primary,
      Color.lerp(scheme.secondary, scheme.primary, 0.34)!,
      Color.lerp(scheme.tertiary, scheme.secondary, 0.26)!,
      Color.lerp(scheme.secondary, scheme.tertiary, 0.58)!,
      Color.lerp(scheme.primary, scheme.tertiary, 0.5)!,
    ];

    return colors
        .map((color) => isDark ? Color.lerp(color, Colors.white, 0.08)! : color)
        .toList();
  }

  Widget _buildPageStack(MainShellState shellState, List<_MainTabItem> tabs) {
    return Stack(
      fit: StackFit.expand,
      children: [
        IndexedStack(
          index: shellState.currentIndex,
          children: List<Widget>.generate(
            tabs.length,
            (index) => shellState.loadedIndexes.contains(index)
                ? _pages[index]
                : const SizedBox.shrink(),
          ),
        ),
        _buildSecondaryPreloadLayer(shellState.preloadedSecondaryIndexes),
      ],
    );
  }

  // ignore: long-method
  Widget _buildWideNavigationPane({
    required AppWindowClass windowClass,
    required List<_MainTabItem> tablist,
    required List<Color> tabColors,
    required Color backgroundColor,
    required int currentIndex,
    required Color inactiveColor,
    required void Function(int) onSelectTab,
  }) {
    return _MainNavigationRail(
      items: tablist,
      itemColors: tabColors,
      currentIndex: currentIndex,
      backgroundColor: backgroundColor,
      inactiveColor: inactiveColor,
      extended: windowClass.usesExtendedNavigation,
      onTap: onSelectTab,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shellState = ref.watch(mainShellProvider);
    final notifier = ref.read(mainShellProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final windowClass = AppWindowClass.fromWidth(constraints.maxWidth);
        final l10n = AppLocalizations.of(context);
        final tablist = _tablist(l10n);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final tabColors = _resolvedTabColors(theme);
        final currentIndex = shellState.currentIndex;
        final currentColor = tabColors[currentIndex];
        final secondaryColor = tabColors[(currentIndex + 1) % tabColors.length];

        final overlayStyle =
            (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
                .copyWith(
                  statusBarColor: Colors.transparent,
                  systemNavigationBarColor: theme.scaffoldBackgroundColor,
                  systemNavigationBarDividerColor: Colors.transparent,
                  statusBarIconBrightness: isDark
                      ? Brightness.light
                      : Brightness.dark,
                  statusBarBrightness: isDark
                      ? Brightness.dark
                      : Brightness.light,
                  systemNavigationBarIconBrightness: isDark
                      ? Brightness.light
                      : Brightness.dark,
                );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: AppAdaptiveScaffold(
            windowClass: windowClass,
            backgroundColor: theme.scaffoldBackgroundColor,
            compactBottomNavigationBar: _BottomNavBar(
              items: tablist,
              currentIndex: currentIndex,
              activeColor: currentColor,
              inactiveColor: isDark
                  ? const Color(0xFF94A3B8)
                  : AppUiConstants.TAB_INACTIVE,
              onTap: notifier.selectTab,
            ),
            wideNavigationPane: _buildWideNavigationPane(
              windowClass: windowClass,
              tablist: tablist,
              tabColors: tabColors,
              backgroundColor: theme.scaffoldBackgroundColor,
              currentIndex: currentIndex,
              inactiveColor: isDark
                  ? const Color(0xFF94A3B8)
                  : AppUiConstants.TAB_INACTIVE,
              onSelectTab: notifier.selectTab,
            ),
            body: AppCanvas(
              accentColor: currentColor,
              secondaryAccentColor: secondaryColor,
              child: _buildPageStack(shellState, tablist),
            ),
          ),
        );
      },
    );
  }
}
