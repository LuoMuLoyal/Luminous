import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/design/tokens/lucide_icon_bridge.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/control/settings/label.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/core/widgets/common/dialog/icon_picker_sheet.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/shell/domain/services/nav_rules.dart';
import 'package:luminous/features/shell/presentation/providers/nav_draft.dart';
import 'package:luminous/features/shell/presentation/tab.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 底部导航编排页。
///
/// 编辑的是**用户态配置**：顺序、名称、图标、显隐。注册表（系统有哪些 tab）不在
/// 这里——那是编译期事实。所以本页没有「添加 tab」入口，只有既有 tab 的开关与
/// 重排（见 `nav_config.dart` 里为什么不开放运行期增删）。
///
/// 所有改动都先进草稿（`navDraftProvider`），取消即丢弃；「完成」才写回。
/// 非法编辑被规则拒绝并就地提示，草稿保持原样——不会出现「存了一半」的状态。
class NavCustomizerPage extends ConsumerStatefulWidget {
  const NavCustomizerPage({super.key});

  @override
  ConsumerState<NavCustomizerPage> createState() => _NavCustomizerPageState();
}

class _NavCustomizerPageState extends ConsumerState<NavCustomizerPage> {
  @override
  void initState() {
    super.initState();
    // PostFrame：begin() 会写 provider，不能在 build/initState 期间同步改。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(navDraftProvider.notifier).begin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rows = ref.watch(navDraftRowsProvider);
    final visibleCount = rows.where((row) => row.isVisible).length;

    return PageScaffold(
      title: l10n.shellNavCustomizeTitle,
      child: SingleChildScrollView(
        child: ResponsiveContentFrame(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: _pageVerticalPadding(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.shellNavCustomizeDescription,
                  style: context.theme.typography.body.sm.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: SectionLabel(label: l10n.shellNavSectionTabs),
                    ),
                    Flexible(
                      child: Text(
                        l10n.shellNavTabCountSummary(visibleCount, rows.length),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.theme.typography.body.sm.copyWith(
                          color: SemanticColor.neutral.solid(context),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.titleContentGap),
                FTileGroup(
                  physics: const NeverScrollableScrollPhysics(),
                  divider: FItemDivider.full,
                  children: [
                    for (var index = 0; index < rows.length; index++)
                      _NavTabTile(
                        key: ValueKey<String>(
                          'nav-row-${rows[index].id.value}',
                        ),
                        row: rows[index],
                        isFirst: index == 0,
                        isLast: index == rows.length - 1,
                      ),
                  ],
                ),
                const SizedBox(height: Spacing.xl),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FButton(
                    variant: FButtonVariant.outline,
                    size: FButtonSizeVariant.sm,
                    onPress: () => _confirmRestoreDefaults(context),
                    child: Text(l10n.shellNavRestoreDefaults),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRestoreDefaults(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDangerConfirmationDialog(
      context: context,
      title: l10n.shellNavResetConfirmTitle,
      message: l10n.shellNavResetConfirmMessage,
      confirmLabel: l10n.shellNavResetConfirmAction,
      cancelLabel: l10n.shellNavCancelAction,
    );
    if (!confirmed) return;
    await ref.read(navDraftProvider.notifier).restoreDefaults();
    if (!context.mounted) return;
    // 恢复默认之后草稿已经结束，留在本页会看到一份"新默认"但不是草稿，
    // 再改会基于已提交的默认重新开始——语义上容易误解，直接退出更清楚。
    if (context.canPop()) {
      context.pop();
    }
  }
}

/// 列表里的一行：图标 + 名称 + 上移/下移 + 显隐。
///
/// 用「上移 / 下移」按钮而不是拖拽：只有 5 项、且用户改的是**跨设备长期生效**的
/// 顺序，按钮点击是可预期、可自动化的；拖拽在这个密度下反而是把 4px 的手势误差
/// 变成顺序错误。组件编排页用拖拽是因为那里有几十个组件、顺序是探索性的。
class _NavTabTile extends ConsumerWidget with FTileMixin {
  const _NavTabTile({
    super.key,
    required this.row,
    required this.isFirst,
    required this.isLast,
  });

  final ResolvedTab row;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(navDraftProvider.notifier);

    return FTile(
      title: Text(row.label(l10n)),
      subtitle: Text(row.definition.path),
      prefix: Icon(row.icon(), size: IconSizeTokens.md),
      details: _IconButton(
        tooltip: l10n.shellNavIconFieldLabel,
        icon: SemanticIcons.actionEdit,
        onPress: () => _pickIcon(context, notifier),
      ),
      suffix: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconButton(
            tooltip: l10n.shellNavMoveUp,
            icon: SemanticIcons.actionUp,
            // 首项不能再上移：置灰而不是隐藏，否则行宽随位置跳动。
            onPress: isFirst
                ? null
                : () => _report(context, notifier.move(row.id, -1)),
          ),
          _IconButton(
            tooltip: l10n.shellNavMoveDown,
            icon: SemanticIcons.actionDown,
            onPress: isLast
                ? null
                : () => _report(context, notifier.move(row.id, 1)),
          ),
          const SizedBox(width: Spacing.xs),
          FSwitch(
            value: row.isVisible,
            onChange: (value) =>
                _report(context, notifier.setVisible(row.id, value)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickIcon(
    BuildContext context,
    NavDraftController notifier,
  ) async {
    final picked = await showAppIconPicker(context, currentIcon: row.icon());
    if (picked == null || !context.mounted) return;
    final name = LucideIconBridge.nameOf(picked);
    if (name == null) return;
    _report(context, notifier.setIcon(row.id, name));
  }

  /// 把拒绝原因翻译成提示；接受时静默。
  void _report(BuildContext context, NavResolution resolution) {
    final violation = resolution.rejection;
    if (violation == null) return;
    unawaited(
      Toast.show(
        context,
        _violationMessage(AppLocalizations.of(context)!, violation),
      ),
    );
  }
}

String _violationMessage(AppLocalizations l10n, NavRuleViolation violation) {
  return switch (violation) {
    NavRuleViolation.tooFewVisible => l10n.shellNavErrorTooFewVisible(
      minVisibleTabs,
    ),
    NavRuleViolation.tooManyVisible => l10n.shellNavErrorTooFewVisible(
      maxVisibleTabs,
    ),
    NavRuleViolation.homeTabHidden => l10n.shellNavErrorHomeHidden,
    NavRuleViolation.invalidLabel => l10n.shellNavErrorTooLong(
      maxTabLabelGraphemes,
    ),
    NavRuleViolation.unknownIcon => l10n.shellNavErrorForbiddenCharacters,
    NavRuleViolation.unknownTabId ||
    NavRuleViolation.duplicateTabId => l10n.shellNavErrorForbiddenCharacters,
  };
}

/// 小尺寸图标按钮；`onPress` 为 null 时呈禁用态。
class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.tooltip,
    required this.icon,
    required this.onPress,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    return FTooltip(
      tipBuilder: (context, controller) => Text(tooltip),
      child: FButton.icon(
        variant: FButtonVariant.ghost,
        size: FButtonSizeVariant.xs,
        onPress: onPress,
        semanticsLabel: tooltip,
        child: Icon(
          icon,
          color: onPress == null ? SemanticColor.neutral.solid(context) : null,
        ),
      ),
    );
  }
}

/// 「完成」/「取消」的页面级动作由 `PageScaffold` 的返回箭头 + 自动保存承担，
/// 但编排页需要显式提交，所以这里提供一个可复用的提交入口。
///
/// 放在独立函数而不是 page 方法里：设置页的 tile 也要能直接跳到本页并提交。
Future<void> commitAndLeaveNavCustomizer(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = AppLocalizations.of(context)!;
  final resolution = ref.read(navDraftProvider.notifier).commit();
  final violation = resolution.rejection;
  if (violation != null) {
    unawaited(Toast.show(context, _violationMessage(l10n, violation)));
    return;
  }
  if (!context.mounted) return;
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/');
  }
}

/// 页面上下留白：窄屏收紧一档，宽屏放松。
///
/// 与设置页同一条视觉节奏，但**不跨 feature import**——那是 settings 的
/// `presentation/utils/`，本 feature 不许引用（`cross_feature_import`）。两行
/// 令牌运算就地写，比为了复用去改分层口径划算。
double _pageVerticalPadding(BuildContext context) {
  return MediaQuery.sizeOf(context).width < Breakpoints.mobile
      ? Spacing.xl2
      : Spacing.xl3;
}
