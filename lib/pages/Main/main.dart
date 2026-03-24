import 'package:flutter/material.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/pages/Album/album.dart';
import 'package:luminous/pages/Drug/drug.dart';
import 'package:luminous/pages/Home/home.dart';
import 'package:luminous/pages/Mine/mine.dart';

// 主页面：底部 Tab 容器
//
// 注意：
// - 这里用 IndexedStack 保持每个 Tab 的状态（避免切换时重复 initState）
// - 不要在这里再包 SafeArea（单页自己负责），否则容易出现双重 padding
/// 主页面底部 Tab 容器。
///
/// 只负责一级页面切换与状态保活，不承担各业务页的数据逻辑。
class MainPage extends StatefulWidget {
  /// 创建主页面 Tab 容器组件。
  const MainPage({super.key});

  /// 创建底部 Tab 主页面对应的状态对象。
  @override
  State<MainPage> createState() => _MainPageState();
}

/// 底部 Tab 容器状态对象。
///
/// 这里只维护当前选中的 Tab 下标，不承载任何业务数据，业务状态由各子页面自己保存。
class _MainPageState extends State<MainPage> {
  /// 底部导航栏配置列表。
  ///
  /// 每一项包含：
  /// - 默认图标路径；
  /// - 选中图标路径；
  /// - 展示文本。
  final List<_MainTabItem> _tablist = const [
    _MainTabItem(
      icon: 'lib/assets/home.png',
      activeIcon: 'lib/assets/home-full.png',
      text: '主页',
      color: Color(0xFF0EA5E9),
    ),
    _MainTabItem(
      icon: 'lib/assets/drug.png',
      activeIcon: 'lib/assets/drug-full.png',
      text: '药品',
      color: Color(0xFF10B981),
    ),
    _MainTabItem(
      icon: 'lib/assets/picture.png',
      activeIcon: 'lib/assets/picture-full.png',
      text: '相册',
      color: Color(0xFFF59E0B),
    ),
    _MainTabItem(
      icon: 'lib/assets/mine.png',
      activeIcon: 'lib/assets/mine-full.png',
      text: '我的',
      color: Color(0xFFE77AA6),
    ),
  ];

  /// 与底部 Tab 一一对应的页面实例列表。
  ///
  /// 页面本身仍然通过 `IndexedStack` 保活，但改成按需挂载，
  /// 避免应用启动时把所有一级页都一起初始化。
  static const List<Widget> _pages = [
    HomeView(),
    DrugView(),
    AlbumView(),
    MineView(),
  ];

  /// 已经真正挂载过的 Tab 下标。
  final Set<int> _loadedIndexes = <int>{0};

  /// 根据 `_tablist` 构建导航目的地列表。
  List<NavigationDestination> _buildDestinations({
    required Color inactiveColor,
  }) {
    return List.generate(_tablist.length, (index) {
      final item = _tablist[index];
      return NavigationDestination(
        icon: _buildTabIcon(assetPath: item.icon, color: inactiveColor),
        selectedIcon: _buildTabIcon(
          assetPath: item.activeIcon,
          color: item.color,
        ),
        label: item.text,
      );
    });
  }

  Widget _buildTabIcon({required String assetPath, required Color color}) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Image.asset(assetPath, width: 30, height: 30),
    );
  }

  /// 当前选中的底部 Tab 下标。
  int _currentIndex = 0;

  /// 构建主页面 UI。
  ///
  /// 上半部分使用 `IndexedStack` 承载四个一级页面，
  /// 下半部分使用 Material 3 `NavigationBar` 负责切换。
  @override
  Widget build(BuildContext context) {
    final currentColor = _tablist[_currentIndex].color;
    final secondaryColor =
        _tablist[(_currentIndex + 1) % _tablist.length].color;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tabBarBackground = isDark
        ? const Color(0xFF111C2E)
        : AppUiConstants.TAB_BAR_BACKGROUND;
    final tabBarBorder = isDark
        ? const Color(0xFF243246)
        : AppUiConstants.TAB_BAR_BORDER;
    final inactiveColor = isDark
        ? const Color(0xFF94A3B8)
        : AppUiConstants.TAB_INACTIVE;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppCanvas(
        accentColor: currentColor,
        secondaryAccentColor: secondaryColor,
        child: IndexedStack(
          index: _currentIndex,
          children: List<Widget>.generate(
            _tablist.length,
            (index) => _loadedIndexes.contains(index)
                ? _pages[index]
                : const SizedBox.shrink(),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tabBarBackground.withValues(alpha: isDark ? 0.96 : 0.94),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: tabBarBorder),
            boxShadow: isDark
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x140F172A),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: Colors.transparent,
                indicatorColor: currentColor.withValues(
                  alpha: isDark ? 0.22 : 0.14,
                ),
                labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((
                  states,
                ) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                    color: selected ? currentColor : inactiveColor,
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                height: 70,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                animationDuration: const Duration(milliseconds: 280),
                destinations: _buildDestinations(inactiveColor: inactiveColor),
                onDestinationSelected: (index) {
                  setState(() {
                    _loadedIndexes.add(index);
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MainTabItem {
  const _MainTabItem({
    required this.icon,
    required this.activeIcon,
    required this.text,
    required this.color,
  });

  final String icon;
  final String activeIcon;
  final String text;
  final Color color;
}
