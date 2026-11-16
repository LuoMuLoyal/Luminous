/// 导航配置的**纯规则**：`NavConfig` + 注册表 → 可渲染列表。
///
/// 这里不碰 Flutter、不碰 Riverpod、不碰存储（`domain_purity`），
/// 所以每条拒绝语义都能用普通单测覆盖，不需要 widget 测试。
library;

import 'package:luminous/features/shell/domain/entities/nav_config.dart';

/// tab 可见数量的下限。
///
/// 少于 3 个时底部导航失去意义（一个或两个目的地用不着 tab 栏），
/// 编辑直接拒绝并返回原配置。
const int minVisibleTabs = 3;

/// tab 可见数量的上限。
///
/// Material `NavigationBar` 的视觉上限是 5 个目的地。这是平台约束，
/// 不是产品选择：第 6 个起会挤到不可读。
const int maxVisibleTabs = 5;

/// 用户自定义名称的长度上限。
///
/// 底栏是 5 等分、单行 label，中文按 8 个字符、拉丁按 12 个字符。
/// 这里只做「总字符数」上限（按字素计数，不是 UTF-16 码元数，
/// 否则 emoji 与组合字符会把预算算少一半）。
const int maxTabLabelGraphemes = 12;

/// 名称里禁止出现的字符：零宽字符与 bidi 控制符。
///
/// 它们在底栏里不可见，但能改变相邻文字的显示方向——用户可以把「用药」
/// 显示成别的样子。这类字符没有任何正当用途，一律拒绝。
///
/// 注意 `\uFEFF` 单独列出：BOM 在 Dart 正则里不属于 `\u200B-\u200F` 区间。
final RegExp _forbiddenLabelChars = RegExp(
  r'[\u200B-\u200F\u202A-\u202E\u2066-\u2069\uFEFF]',
);

/// 名称清洗结果。
class TabLabelValidation {
  const TabLabelValidation._({this.value, this.errorCode});

  /// 清洗后的可保存名称；null 表示"不设置自定义名称（用 ARB 默认）"，
  /// 或表示输入被拒绝——由 [errorCode] 区分。
  final String? value;

  /// 拒绝原因；接受时为 null。
  final TabLabelErrorCode? errorCode;

  bool get isAccepted => errorCode == null;
}

/// 名称被拒绝的原因。文案由 presentation 层经 ARB 翻译——`domain/` 里不出现人类可读文案。
enum TabLabelErrorCode {
  /// 清洗后为空。
  empty,

  /// 超过 [maxTabLabelGraphemes]。
  tooLong,

  /// 含零宽字符或 bidi 控制符。
  forbiddenCharacters,
}

/// 清洗并校验用户输入的 tab 名称。
///
/// `null` 表示「清空自定义名称、回到 ARB 默认」，是合法的接受态
/// （`value == null && isAccepted`）；输入非法时 `isAccepted == false`
/// 并给出 [errorCode]。
TabLabelValidation validateTabLabel(String? raw) {
  if (raw == null) return const TabLabelValidation._();

  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return const TabLabelValidation._(errorCode: TabLabelErrorCode.empty);
  }
  if (_forbiddenLabelChars.hasMatch(trimmed)) {
    return const TabLabelValidation._(
      errorCode: TabLabelErrorCode.forbiddenCharacters,
    );
  }

  if (_graphemeLength(trimmed) > maxTabLabelGraphemes) {
    return const TabLabelValidation._(errorCode: TabLabelErrorCode.tooLong);
  }

  return TabLabelValidation._(value: trimmed);
}

/// 近似 grapheme cluster 计数。
///
/// 不引入 `characters` 包：`domain/` 只允许纯 Dart 依赖，而 `characters`
/// 由 Flutter SDK 转出、不在 domain 的白名单里。这里按「组合记号与变体选择符
/// 不单算 + 区域指示符成对算一个（国旗）+ 肤色修饰符不单算」处理，
/// 覆盖中文、拉丁、常见 emoji 与重音组合；与 `characters` 在正常输入上的
/// 差异只出现在少数冷僻组合上，对「底栏放不放得下」这个判断没有影响。
int _graphemeLength(String input) {
  var count = 0;
  var previousWasRegional = false;
  for (final rune in input.runes) {
    final isCombining =
        (rune >= 0x0300 && rune <= 0x036F) || // combining diacritics
        (rune >= 0xFE00 && rune <= 0xFE0F) || // variation selectors
        rune == 0x200D || // zero-width joiner
        (rune >= 0x1F3FB && rune <= 0x1F3FF); // skin tone modifiers
    if (isCombining) continue;

    final isRegional = rune >= 0x1F1E6 && rune <= 0x1F1FF; // flag pairs
    if (isRegional && previousWasRegional) {
      previousWasRegional = false;
      continue;
    }
    previousWasRegional = isRegional;
    count++;
  }
  return count;
}

/// 规则判定的结果：要么是一份可直接渲染的配置，要么是对原配置的拒绝。
class NavResolution {
  const NavResolution._({required this.config, required this.rejection});

  /// 生效的配置（被拒绝时是**原配置**，不是半成品）。
  final NavConfig config;

  /// 拒绝原因；接受时为 null。
  final NavRuleViolation? rejection;

  bool get isAccepted => rejection == null;

  static NavResolution accept(NavConfig config) =>
      NavResolution._(config: config, rejection: null);

  static NavResolution reject(NavConfig config, NavRuleViolation violation) =>
      NavResolution._(config: config, rejection: violation);
}

/// 一次编辑被拒绝的原因。
enum NavRuleViolation {
  /// 可见 tab 少于 [minVisibleTabs]。
  tooFewVisible,

  /// 可见 tab 多于 [maxVisibleTabs]。
  tooManyVisible,

  /// 首页 tab 不能隐藏（它同时是冷启动落点）。
  homeTabHidden,

  /// 配置里出现的 tabId 不在注册表中。
  unknownTabId,

  /// 同一 tabId 出现两次。
  duplicateTabId,

  /// tab 名称不可保存（见 [TabLabelErrorCode]）。
  invalidLabel,

  /// tab 图标名无法解析（不在 `LucideIconBridge` 里）。
  unknownIcon,
}

/// 校验一份用户配置是否可保存。
///
/// [knownTabIds] 由注册表提供；
/// [isKnownIcon] 由 presentation 层注入，避免 `domain/` 依赖 `core/design`。
///
/// 被拒绝时返回的仍是 `current`，调用方直接用 `resolution.config` 即可，
/// 不需要自己判断——非法编辑回退原配置是**一条路径**，不是两条。
NavResolution validateNavConfig(
  NavConfig current, {
  required Set<TabId> knownTabIds,
  bool Function(String iconName)? isKnownIcon,
}) {
  final tabs = current.tabs;
  if (tabs == null) return NavResolution.accept(current);

  final seen = <TabId>{};
  for (final tab in tabs) {
    if (!knownTabIds.contains(tab.tabId)) {
      return NavResolution.reject(current, NavRuleViolation.unknownTabId);
    }
    if (!seen.add(tab.tabId)) {
      return NavResolution.reject(current, NavRuleViolation.duplicateTabId);
    }
    final label = tab.customLabel;
    if (label != null && !validateTabLabel(label).isAccepted) {
      return NavResolution.reject(current, NavRuleViolation.invalidLabel);
    }
    final icon = tab.iconName;
    if (icon != null && isKnownIcon != null && !isKnownIcon(icon)) {
      return NavResolution.reject(current, NavRuleViolation.unknownIcon);
    }
  }

  final visibleCount = tabs.where((t) => t.isVisible).length;
  if (visibleCount < minVisibleTabs) {
    return NavResolution.reject(current, NavRuleViolation.tooFewVisible);
  }
  if (visibleCount > maxVisibleTabs) {
    return NavResolution.reject(current, NavRuleViolation.tooManyVisible);
  }

  // 冷启动落点是首页的路径，所以首页不能在配置里被隐藏。
  final home = tabs.where((t) => t.tabId == TabId.today).firstOrNull;
  if (home != null && !home.isVisible) {
    return NavResolution.reject(current, NavRuleViolation.homeTabHidden);
  }

  return NavResolution.accept(current);
}

/// 把一份配置**补全并对齐**到注册表，返回归一后的 tab 列表。
///
/// 与 [validateNavConfig] 的分工：
/// - 校验回答「用户这次编辑能不能存」——拒绝就回退原配置；
/// - 补全回答「存下来的配置怎么渲染」——注册表新增的 tab 自动补进来，
///   注册表删掉的 tab 自动跳过，`order` 归一成连续整数。补全**永远成功**，
///   所以新版本加了 tab、用户的老配置照样能渲染。
///
/// [defaultOrder] 是注册表的默认顺序，用来给补全进来的 tab 定位：
/// 新 tab 插在它默认顺序所指示的位置附近，而不是一律甩到末尾。
List<TabPlacement> completeNavConfig(
  NavConfig config,
  List<TabId> defaultOrder,
) {
  final stored = config.tabs;

  if (stored == null) {
    return [
      for (var i = 0; i < defaultOrder.length; i++)
        TabPlacement(tabId: defaultOrder[i], order: i),
    ];
  }

  final known = defaultOrder.toSet();

  // 去重并按 order 排序。`NavConfig.fromJson` 已经拒绝重复 id，但这里是
  // 纯函数、可能被直接构造调用，不能假设上游校验过——重复项会让渲染出
  // 两个 key 相同的底栏格子（Flutter 直接抛 duplicate key）。
  final seen = <TabId>{};
  final ordered = [
    for (final tab in stored)
      if (known.contains(tab.tabId) && seen.add(tab.tabId)) tab,
  ]..sort((a, b) => a.order.compareTo(b.order));

  // 注册表里有、配置里没有的 tab：按默认顺序插到前一个已存在 tab 之后。
  for (var i = 0; i < defaultOrder.length; i++) {
    final id = defaultOrder[i];
    if (seen.contains(id)) continue;

    var insertAt = 0;
    for (var j = i - 1; j >= 0; j--) {
      final index = ordered.indexWhere((t) => t.tabId == defaultOrder[j]);
      if (index >= 0) {
        insertAt = index + 1;
        break;
      }
    }
    ordered.insert(insertAt, TabPlacement(tabId: id, order: 0));
    seen.add(id);
  }

  // order 归一成 0..n-1，避免用户反复拖拽后 order 值越滚越大。
  return [
    for (var i = 0; i < ordered.length; i++)
      TabPlacement(
        tabId: ordered[i].tabId,
        order: i,
        customLabel: ordered[i].customLabel,
        iconName: ordered[i].iconName,
        isVisible: ordered[i].isVisible,
      ),
  ];
}

/// 只保留可见的 tab。
///
/// 移动端底栏与桌面侧栏都按这个过滤——两端顺序一致是刻意的，
/// 用户在手机上排完再开桌面端不应该看到另一套顺序。
List<TabPlacement> visibleTabs(List<TabPlacement> tabs) => [
  for (final tab in tabs)
    if (tab.isVisible) tab,
];
