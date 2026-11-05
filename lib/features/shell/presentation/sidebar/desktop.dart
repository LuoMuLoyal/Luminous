import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'package:luminous/app/composition/notification/unread_count.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/providers/session/session_snapshot.dart';
import 'package:luminous/core/theme/preference.dart';
import 'package:luminous/core/widgets/common/avatar/avatar_view.dart';
import 'package:luminous/core/widgets/common/control/brand_icon.dart';
import 'package:luminous/features/auth/domain/entities/session.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:window_manager/window_manager.dart';

/// 桌面端侧边栏。
///
/// 视觉参照 Lumine 工作台：整列一个底色，分组只靠**排版**表达。
///
/// 结构仍由 Forui 的 [FSidebar] / [FSidebarGroup] / [FSidebarItem] 承担，
/// 这里只通过 style 收敛三件事：
///
/// - **分组标题**：小字号、次级色，上方留白远大于下方——标题读作下面那组
///   条目的抬头，而不是上一组的脚注。这是分组唯一的外化信号。
/// - **条目**：默认**没有底色**（未悬停/未选中时与侧边栏同色），行距收紧。
///   条目各自一块底色、或每组套一层分组卡，都会把列表切成一块块格子，
///   同组条目就读不成一组。
/// - **选中**：只给选中项铺一块浅色圆角底并加重文字，其余条目保持安静。
///
/// [FSidebarGroupStyle.childrenPadding] 的默认值把每组末尾都垫 16px，导致组与组
/// 之间的间距全部由它撑开、与标题留白不成比例；这里把底部内边距抹平，分组
/// 节奏改由标题自身的 padding 控制。
abstract final class DesktopSidebarMetrics {
  /// 侧边栏宽度。
  static const double width = 264;

  /// 上一组结束到下一组标题之间的空档。
  static const double groupGap = Spacing.xl3;

  /// 分组标题与它统领的条目之间的距离。
  static const double labelGap = Spacing.xs;
}

/// 桌面侧边栏的视觉常量，供 [FSidebarStyle] 覆写使用。
class DesktopSidebarStyle {
  const DesktopSidebarStyle._();

  /// 生成一个以当前主题为基准、收敛了分组节奏的 [FSidebarStyle]。
  ///
  /// 底色沿用主题里 `scaffoldStyle.sidebarBackgroundColor` 那一档，与内容区
  /// 形成一档色差；不画边框——层次靠色差，不靠描边。
  static FSidebarStyle resolve(BuildContext context) {
    final theme = context.theme;
    final colors = theme.colors;
    final base = theme.sidebarStyle;

    final groupStyle = base.groupStyle.copyWith(
      labelStyle: TextStyleDelta.delta(
        color: colors.mutedForeground,
        fontSize: theme.typography.body.xs.fontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      headerPadding: const EdgeInsetsGeometryDelta.value(
        EdgeInsets.fromLTRB(
          Spacing.md,
          DesktopSidebarMetrics.groupGap,
          Spacing.md,
          DesktopSidebarMetrics.labelGap,
        ),
      ),
      // 每组末尾不再额外垫高：组间节奏由标题的上方留白决定。
      childrenPadding: const EdgeInsetsGeometryDelta.value(EdgeInsets.zero),
      childrenSpacing: 2,
      itemStyle: _itemStyle(theme),
    );

    return base.copyWith(
      // 只用色差，不画描边：侧边栏比内容区深一档就是分隔本身。
      decoration: DecorationDelta.value(
        BoxDecoration(color: theme.scaffoldStyle.sidebarBackgroundColor),
      ),
      constraints: const BoxConstraints.tightFor(
        width: DesktopSidebarMetrics.width,
      ),
      groupStyle: groupStyle,
    );
  }

  /// 条目样式：默认无底色，只有选中/悬停出现浅色圆角底；文字走次级色。
  ///
  /// [FSidebarItemStyle.inherit] 的默认值给每个条目都铺 `colors.background`，
  /// 比侧边栏底色亮一档且**每条都是独立的一块**——一列排下来就是五块
  /// 各自浮起的行，这正是「每个标题都像单独的」的来源。这里把默认底色
  /// 改成透明，仍用 `background` 填充其实只有一处不同：非交互态不再有面。
  static FSidebarItemStyle _itemStyle(FThemeData theme) {
    final colors = theme.colors;
    final inherited = FSidebarItemStyle.inherit(
      colors: colors,
      typography: theme.typography,
      icons: theme.icons,
      style: theme.style,
      // 几何基线始终跟随主题（本项目一律用 compact/desktop 基线，见
      // `appThemeData`），不要读运行平台——触摸基线会把条目撑高。
      touch: false,
    );

    return inherited.copyWith(
      // 非交互态**不画面**：条目与侧边栏同色，同组条目才读成一条列表，
      // 而不是一列各自浮起的按钮。只有选中/悬停才出现一块浅色圆角底。
      backgroundColor: FVariants(
        Colors.transparent,
        variants: {
          [.selected]: colors.card,
          [.hovered, .pressed]: colors.muted,
          //
          [.disabled]: Colors.transparent,
        },
      ),
      // 注意：变体值必须是**完整值**，不能是 delta。Forui 的变体解析器先按
      // 约束取候选、再对候选调用 call(base)，delta 会被作用在候选自身而不是
      // 基值上——结果是没有变体时文字/图标颜色为空，条目直接看不见。
      textStyle: FVariants(
        theme.typography.body.sm.copyWith(
          color: colors.mutedForeground,
          overflow: TextOverflow.ellipsis,
          fontWeight: FontWeight.w500,
          height: 1,
        ),
        variants: {
          [.selected]: theme.typography.body.sm.copyWith(
            color: colors.foreground,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
          [.disabled]: theme.typography.body.sm.copyWith(
            color: colors.mutedForeground,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        },
      ),
      iconStyle: FVariants(
        IconThemeData(color: colors.mutedForeground, size: IconSizeTokens.md),
        variants: {
          [.selected]: IconThemeData(
            color: colors.foreground,
            size: IconSizeTokens.md,
          ),
          [.disabled]: IconThemeData(
            color: colors.mutedForeground,
            size: IconSizeTokens.md,
          ),
        },
      ),
      padding: const EdgeInsetsGeometryDelta.value(
        EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 10),
      ),
    );
  }
}

/// 侧边栏主体：头部品牌区 + 导航分组 + 底部工具区。
class DesktopSidebar extends ConsumerWidget {
  const DesktopSidebar({
    super.key,
    required this.currentIndex,
    required this.onSelectTab,
  });

  final int currentIndex;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    FSidebarItem tabItem(ShellTab tab) {
      final selected = currentIndex == tab.index;
      return FSidebarItem(
        key: tab.testKey(),
        icon: Icon(selected ? tab.activeIcon : tab.icon),
        label: Text(tab.label(l10n)),
        selected: selected,
        onPress: () {
          if (!selected) {
            unawaited(HapticFeedback.selectionClick());
          }
          onSelectTab(tab.index);
        },
      );
    }

    return FSidebar(
      style: DesktopSidebarStyle.resolve(context),
      header: _WindowTitleBar(session: session),
      footer: const _SidebarFooter(),
      children: [
        FSidebarGroup(
          label: Text(l10n.desktopSidebarGroupToday),
          children: [tabItem(ShellTab.today), tabItem(ShellTab.record)],
        ),
        FSidebarGroup(
          label: Text(l10n.desktopSidebarGroupKnowledge),
          children: [tabItem(ShellTab.medicine), tabItem(ShellTab.review)],
        ),
        FSidebarGroup(
          label: Text(l10n.desktopSidebarGroupAccount),
          children: [tabItem(ShellTab.mine)],
        ),
      ],
    );
  }
}

/// Sidebar header with drag-to-move support.
///
/// Wraps the header content with [DragToMoveArea] so the user can drag
/// the sidebar header to move the window. Window control buttons (min/max/close)
/// are rendered separately by [DesktopWindowChrome] at the window's top-right.
///
/// On macOS, the system renders traffic-light buttons automatically;
/// we add left padding so the header content doesn't overlap them.
class _WindowTitleBar extends StatelessWidget {
  const _WindowTitleBar({required this.session});

  final AuthSessionState session;

  @override
  Widget build(BuildContext context) {
    final headerContent = _SidebarHeaderContent(session: session);

    // On macOS, the traffic lights are at the top-left and overlap the
    // sidebar. Add left padding so the header content is not hidden.
    final macPadding = !kIsWeb && Platform.isMacOS
        ? const EdgeInsets.only(left: 70)
        : EdgeInsets.zero;

    return DragToMoveArea(
      child: Padding(padding: macPadding, child: headerContent),
    );
  }
}

/// The sidebar header content (logo or user info).
class _SidebarHeaderContent extends StatelessWidget {
  const _SidebarHeaderContent({required this.session});

  final AuthSessionState session;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context)!;

    // User info row if authenticated, otherwise logo + app title.
    if (session.isAuthenticated && session.user is AuthUser) {
      final user = session.user as AuthUser;
      final displayName = user.nickname ?? user.email ?? '';
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: GestureDetector(
          onTap: () => context.push(Routes.mine),
          child: Row(
            children: [
              AvatarView(
                avatarUrl: user.avatar,
                size: IconSizeTokens.xl2,
                iconSize: IconSizeTokens.sm,
                semanticLabel: l10n.profileAvatarLabel,
                borderWidth: 0,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.foreground,
                    fontWeight: FontWeight.w700,
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
          const BrandIcon(size: IconSizeTokens.lg),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              l10n.appTitle,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sidebar footer with settings, help, theme toggle, and notifications.
class _SidebarFooter extends ConsumerWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
      AppThemeModePreference.system => SemanticIcons.actionExternalLink,
      AppThemeModePreference.light => SemanticIcons.actionThemeLight,
      AppThemeModePreference.dark => SemanticIcons.actionThemeDark,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FTooltip(
          tipBuilder: (context, controller) =>
              Text(l10n.desktopSidebarNotifications),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              FSidebarItem(
                icon: const Icon(SemanticIcons.notificationBell),
                label: Text(l10n.desktopSidebarNotifications),
                onPress: () => context.push(Routes.notifications),
              ),
              if (hasUnread)
                Positioned(
                  right: Spacing.lg,
                  top: Spacing.md,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: SemanticColor.destructive.solid(context),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox.square(dimension: Spacing.sm),
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
          icon: const Icon(SemanticIcons.actionSettings),
          label: Text(l10n.desktopSidebarSettings),
          onPress: () => context.push(Routes.settings),
        ),
        FSidebarItem(
          icon: const Icon(SemanticIcons.actionHelp),
          label: Text(l10n.desktopSidebarHelp),
          onPress: () => context.push(Routes.assistant),
        ),
      ],
    );
  }
}
