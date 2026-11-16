/// 底部导航的用户配置模型。
///
/// 三分模型里的**配置**层：注册表（`TabRegistry`）决定系统里有哪些 tab，
/// 本文档决定用户挂了哪些、什么顺序、叫什么名字、用什么图标、是否可见，
/// 渲染层（`ShellPage`）只消费解析后的结果。
///
/// 全部是纯值类型，无框架依赖、无 I/O（`domain_purity`）。
library;

/// 导航配置的当前 schema 版本。
///
/// 每次破坏性改字段就 +1，并在 `nav_rules.dart` 的迁移链里补一段。
/// 读到**未知版本**时整体回退默认，不猜、不部分修复——半修好的导航比默认导航
/// 更难解释，而且用户看不出哪里坏了。
const int currentNavSchemaVersion = 1;

/// tab 的稳定身份。
///
/// 用字符串而不是 `enum`：身份会被持久化，也允许以后出现「由后端下发的 tab」，
/// 那时 `enum` 就得先扩一个 `unknown` 分支。字符串 id 一经发布永不改名。
extension type const TabId(String value) {
  static const today = TabId('today');
  static const record = TabId('record');
  static const medicine = TabId('medicine');
  static const review = TabId('review');
  static const mine = TabId('mine');
}

/// 单个 tab 的用户配置。
///
/// 所有字段都可缺省：缺省表示「跟随注册表默认」，不是「空」。
/// 这样注册表里改默认图标/默认文案能直接传导给没自定义过的用户，
/// 而不需要写一次迁移把所有配置刷一遍。
class TabPlacement {
  const TabPlacement({
    required this.tabId,
    required this.order,
    this.customLabel,
    this.iconName,
    this.isVisible = true,
  });

  /// 指向 `TabRegistry` 的 key。
  final TabId tabId;

  /// 在所属分组内的排序位。渲染前由 `nav_rules` 归一成连续整数。
  final int order;

  /// 用户自定义名称；null 表示用 ARB 文案。
  ///
  /// 这是 l10n 的**显式例外**：用户输入的字符串属于数据，与 `nickname` 同性质，
  /// 不进 ARB。见 `docs/reference/localization.md`。
  final String? customLabel;

  /// Lucide kebab 名（如 `heart-pulse`）；null 表示用注册表默认图标。
  ///
  /// 存名字而不是 `IconData`：`IconData.codePoint` 在 icon tree-shaking 下
  /// 不可信赖，落盘再读回来会变成豆腐块。解析走 `LucideIconBridge`，
  /// 查不到就回退注册表默认图标。
  final String? iconName;

  /// 是否显示在底栏 / 侧栏。隐藏不等于移除，配置仍然保留。
  final bool isVisible;

  TabPlacement copyWith({
    int? order,
    String? customLabel,
    bool clearCustomLabel = false,
    String? iconName,
    bool clearIconName = false,
    bool? isVisible,
  }) {
    return TabPlacement(
      tabId: tabId,
      order: order ?? this.order,
      customLabel: clearCustomLabel ? null : (customLabel ?? this.customLabel),
      iconName: clearIconName ? null : (iconName ?? this.iconName),
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabPlacement &&
          tabId == other.tabId &&
          order == other.order &&
          customLabel == other.customLabel &&
          iconName == other.iconName &&
          isVisible == other.isVisible;

  @override
  int get hashCode =>
      Object.hash(tabId, order, customLabel, iconName, isVisible);

  /// 序列化。**只**在持久化边界使用；进渲染前必须还原成强类型。
  Map<String, Object?> toJson() => <String, Object?>{
    'tabId': tabId.value,
    'order': order,
    if (customLabel != null) 'customLabel': customLabel,
    if (iconName != null) 'iconName': iconName,
    'isVisible': isVisible,
  };

  /// 反序列化；结构不合法时返回 null，由调用方整体回退默认。
  static TabPlacement? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final tabId = raw['tabId'];
    final order = raw['order'];
    if (tabId is! String || tabId.isEmpty) return null;
    if (order is! int) return null;

    final customLabel = raw['customLabel'];
    if (customLabel != null && customLabel is! String) return null;

    final iconName = raw['iconName'];
    if (iconName != null && iconName is! String) return null;

    final isVisible = raw['isVisible'];
    if (isVisible != null && isVisible is! bool) return null;

    return TabPlacement(
      tabId: TabId(tabId),
      order: order,
      customLabel: customLabel as String?,
      iconName: iconName as String?,
      isVisible: isVisible as bool? ?? true,
    );
  }
}

/// 一份完整的导航配置。
///
/// **没有分组**：桌面侧栏的分组目前由注册表的默认分组决定，不开放给用户编排。
/// 这一点是刻意的——分组可配需要跨组拖拽编辑器（`drag_and_drop_lists`），
/// 是 4–6 天的纯 UI 成本，而它解决的诉求（「把用药挪到第三位」）用顺序就能满足。
/// 等真有人抱怨分组，再连同编辑器一起加，不在数据模型里预留半成品字段。
class NavConfig {
  const NavConfig({this.schemaVersion = currentNavSchemaVersion, this.tabs});

  final int schemaVersion;

  /// 用户的 tab 配置；null 表示「完全用注册表默认」。
  ///
  /// 一旦用户动过任何一项，这里就是整份配置（不是补丁）——补丁式合并会让
  /// 「恢复默认」变成两套语义，不值得。
  final List<TabPlacement>? tabs;

  bool get isDefault => tabs == null;

  NavConfig copyWith({List<TabPlacement>? tabs}) {
    return NavConfig(schemaVersion: currentNavSchemaVersion, tabs: tabs);
  }

  /// 恢复默认配置。
  NavConfig resetToDefault() =>
      const NavConfig(schemaVersion: currentNavSchemaVersion);

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    if (tabs != null) 'tabs': [for (final tab in tabs!) tab.toJson()],
  };

  /// 反序列化；**任何**结构问题都返回 null，由调用方整体回退默认。
  ///
  /// 未知 `schemaVersion` 同样返回 null：不猜、不部分修复。
  static NavConfig? fromJson(Object? raw) {
    if (raw is! Map) return null;

    final schemaVersion = raw['schemaVersion'];
    if (schemaVersion != currentNavSchemaVersion) return null;

    final tabs = raw['tabs'];
    if (tabs == null) return const NavConfig();

    if (tabs is! List) return null;

    final parsed = <TabPlacement>[];
    final seen = <TabId>{};
    for (final entry in tabs) {
      final placement = TabPlacement.fromJson(entry);
      if (placement == null) return null;
      // 重复 tabId 是坏数据：两份配置指向同一个 tab，渲染顺序无法定义。
      if (!seen.add(placement.tabId)) return null;
      parsed.add(placement);
    }

    return NavConfig(schemaVersion: currentNavSchemaVersion, tabs: parsed);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NavConfig) return false;
    if (schemaVersion != other.schemaVersion) return false;
    final a = tabs;
    final b = other.tabs;
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(schemaVersion, tabs);
}
