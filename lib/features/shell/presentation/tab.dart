import 'package:flutter/widgets.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/design/tokens/lucide_icon_bridge.dart';
import 'package:luminous/core/router/app_routes.dart';
import 'package:luminous/features/shell/domain/entities/nav_config.dart';
import 'package:luminous/features/shell/domain/entities/tab_definition.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 注册表里五个 tab 的**路由落点**。
///
/// 顺序即 `lib/app/router.dart` 里 `StatefulShellRoute` 的 branch 顺序；
/// `branchIndex` 必须与实际 branches 列表下标一致，改路由表时同步这里。
///
/// 这份表是编译期常量，用户配置改不动它——它回答的是「系统支持哪些 tab」，
/// 不是「用户挂了哪些 tab」。
const List<TabDefinition> shellTabRegistry = <TabDefinition>[
  TabDefinition(id: TabId.today, path: Routes.home, branchIndex: 0),
  TabDefinition(id: TabId.record, path: Routes.record, branchIndex: 1),
  TabDefinition(id: TabId.medicine, path: Routes.medicine, branchIndex: 2),
  TabDefinition(id: TabId.review, path: Routes.review, branchIndex: 3),
  TabDefinition(id: TabId.mine, path: Routes.mine, branchIndex: 4),
];

/// 注册表的默认顺序（`completeNavConfig` 用它给新增 tab 定位）。
final List<TabId> shellTabDefaultOrder = [
  for (final tab in shellTabRegistry) tab.id,
];

Set<TabId> get shellTabIds => {for (final tab in shellTabRegistry) tab.id};

/// 单个 tab 的**默认外观**：默认图标、默认 ARB 文案、稳定 test key。
///
/// 放在 presentation 而不是 domain：`IconData` 与 ARB 都属于 UI 层。
/// 用户没自定义的字段一律回落到这里，所以注册表里改默认图标/文案能直接
/// 传导给所有没自定义过的用户，不需要写迁移刷配置。
class ShellTabStyle {
  const ShellTabStyle({
    required this.icon,
    required this.activeIcon,
    required this.testKey,
    required this.defaultLabel,
  });

  final IconData icon;
  final IconData activeIcon;

  /// 稳定的测试 key。`review` 保留历史 key `shell-tab-report`：
  /// 它从 "report" 改名而来，既有测试与集成脚本仍引用旧 key。
  final String testKey;

  final String Function(AppLocalizations l10n) defaultLabel;

  /// 按 id 查默认外观；未知 id 返回 null（由调用方跳过该 tab）。
  static ShellTabStyle? of(TabId id) => _styles[id];

  static final Map<TabId, ShellTabStyle> _styles = {
    TabId.today: ShellTabStyle(
      icon: SemanticIcons.tabToday,
      activeIcon: SemanticIcons.tabToday,
      testKey: 'shell-tab-today',
      defaultLabel: (l10n) => l10n.tabToday,
    ),
    TabId.record: ShellTabStyle(
      icon: SemanticIcons.tabRecord,
      activeIcon: SemanticIcons.tabRecord,
      testKey: 'shell-tab-record',
      defaultLabel: (l10n) => l10n.tabRecord,
    ),
    TabId.medicine: ShellTabStyle(
      icon: SemanticIcons.tabMedicine,
      activeIcon: SemanticIcons.tabMedicine,
      testKey: 'shell-tab-medicine',
      defaultLabel: (l10n) => l10n.tabMedicine,
    ),
    TabId.review: ShellTabStyle(
      icon: SemanticIcons.tabReview,
      activeIcon: SemanticIcons.tabReview,
      testKey: 'shell-tab-report',
      defaultLabel: (l10n) => l10n.tabReview,
    ),
    TabId.mine: ShellTabStyle(
      icon: SemanticIcons.tabMine,
      activeIcon: SemanticIcons.tabMine,
      testKey: 'shell-tab-mine',
      defaultLabel: (l10n) => l10n.tabMine,
    ),
  };
}

/// 解析完成的 tab：配置 ⊕ 注册表 ⊕ 默认外观，可直接渲染。
///
/// 这是渲染层唯一需要消费的形状。`path` 用来隐藏底栏时判断当前落在哪个 tab，
/// `branchIndex` 交给 `goBranch`，`testKey` 交给测试。
class ResolvedTab {
  const ResolvedTab({
    required this.placement,
    required this.definition,
    required this.style,
  });

  final TabPlacement placement;
  final TabDefinition definition;
  final ShellTabStyle style;

  TabId get id => definition.id;
  String get path => definition.path;
  int get branchIndex => definition.branchIndex;
  bool get isVisible => placement.isVisible;

  /// 用户自定义名称优先；没自定义走 ARB 默认。
  ///
  /// 自由文本是 l10n 的显式例外（与 `nickname` 同性质），见
  /// `docs/reference/localization.md`。
  String label(AppLocalizations l10n) =>
      placement.customLabel ?? style.defaultLabel(l10n);

  /// 解析后的图标：自定义名字能解析就用，否则回落到默认图标。
  ///
  /// 名字存的是 Lucide kebab 名；解析失败**不报错**，静默回退——
  /// 图标是装饰，为它中断渲染不值得。校验入口在 `nav_rules` 的
  /// `unknownIcon`，那里拒绝保存，所以正常情况下这里不会走到回退。
  IconData icon() {
    final name = placement.iconName;
    if (name == null) return style.icon;
    if (!LucideIconBridge.exists(name)) return style.icon;
    return LucideIconBridge.resolve(name, fallback: style.icon);
  }

  IconData activeIcon() {
    final name = placement.iconName;
    if (name == null) return style.activeIcon;
    if (!LucideIconBridge.exists(name)) return style.activeIcon;
    return LucideIconBridge.resolve(name, fallback: style.activeIcon);
  }

  ValueKey<String> testKey() => ValueKey<String>(style.testKey);
}

/// 把补全后的 tab 列表解析成可渲染的 [ResolvedTab] 列表。
///
/// 未知 tabId（不在注册表里）直接跳过——**其余 tab 照常渲染**，
/// 与 `ComponentHost` 跳过未知组件 id 是同一条降级语义。
List<ResolvedTab> resolveTabs(List<TabPlacement> placements) {
  final result = <ResolvedTab>[];
  for (final placement in placements) {
    final definition = _definitionOf(placement.tabId);
    final style = ShellTabStyle.of(placement.tabId);
    if (definition == null || style == null) continue;
    result.add(
      ResolvedTab(placement: placement, definition: definition, style: style),
    );
  }
  return result;
}

TabDefinition? _definitionOf(TabId id) {
  for (final definition in shellTabRegistry) {
    if (definition.id == id) return definition;
  }
  return null;
}

/// 注册表里 tab 的默认外观是否认识这个图标名（供 `nav_rules` 注入）。
bool isKnownTabIcon(String iconName) => LucideIconBridge.exists(iconName);

/// 按身份取稳定的 widget test key。
///
/// 给 e2e / widget 测试用：它们按「哪个 tab」查找，而不是按「排第几格」——
/// 后者会被用户配置带着跑。`find.byKey` 接受 `Key`，这里返回非空 `Key`；
/// 未知 id 回落到一个不可能匹配的 key（测试会直接失败在 `pumpUntilFound`）。
Key shellTabKey(TabId id) {
  final style = ShellTabStyle.of(id);
  return ValueKey<String>(style?.testKey ?? 'shell-tab-unknown-${id.value}');
}
