---
status: active
owner: frontend
updated: 2026-11-16
---

# 可编排导航外壳：留在 go_router，tab chrome 数据化

Created: 2026-11-12（2026-11-16 重写：原方案主张全仓迁移到 `auto_route`，
经核对 go_router 源码与实测迁移面后推翻，改为在 `go_router` 上做数据驱动）

> **落点**：组件化计划 `2026-10-28-composable-tabs.md` 的 A6（底部 tab 可按用户意见
> 改名 / 换图标 / 换序 / 隐藏）。
>
> **前置判定（2026-11-16 修订）**：原方案称「`StatefulShellRoute` 要求 branches
> 编译期固定，无法满足 tab 集合与顺序是数据」，据此主张全仓迁移 `auto_route`。
> **该前提不成立**：`branches` 是普通 `final List`，运行期构造完全可行；真正受限的
> 只是「router 建好后不能改 branches」。而 Material 底栏上限 5 个、本仓恰好 5 个
> tab，所以「运行期增删 tab」这条路本来就不通往任何产品形态。**顺序、名称、图标、
> 显隐全部可以在 go_router 上做**，代价是一层 index 映射。

## 0. 范围与不变量

- 范围：`lib/features/shell/` + `PrefKeys` + 相关测试与 integration helpers
- **不动 `lib/app/router.dart`**：5 条 `StatefulShellBranch` 原样保留
- 唯一不可协商的外部事实（平台约束，非本计划选择）：
  1. Material `NavigationBar` 可见项上限 5
  2. 可见项下限 3（少于 3 底栏失去意义）
  3. 首页 tab 不可隐藏（它是冷启动落点）

## 1. 关键事实（2026-11-16 核对）

| 项 | 结论 | 依据 |
| --- | --- | --- |
| `branches` 能否运行期构造 | **能**。`required this.branches`，唯一断言是 `branches.isNotEmpty` | `go_router-17.3.0/lib/src/route.dart:896,905,1001` |
| 能否建好后再改 branches | 不能。`currentIndex` 是 `final`，由 branch 的 `navigatorKey` 反查；`goBranch(int index)` 按 index 寻址 | 同上 `:1242,1276` |
| 重建 GoRouter 的代价 | 丢 `GlobalKey<StatefulNavigationShellState>`、各 branch 的 `navigatorKey` 与分支导航栈 | 同上 |
| 迁移面实测 | `lib/` 85 个文件 import `go_router`，`test/` 41 个；`GoRouterState` 15 文件 58 处；`@TypedGoRoute` 13 文件 39 处 | 本仓 grep |
| `auto_route` 的增量能力 | 只有「routes 列表每帧可换」（`AutoTabsRouter(routes:)`）+ 现成的 `transitionBuilder` | `auto_route 11.2.0` |

**结论**：为这点增量能力付 126 个文件的改写 + 守卫/转场/深链重写不划算，尤其在测试
基线本就不干净的前提上（组件化计划 §3 记录了 8 条失败）。

## 2. 目标形态：三分模型

与组件化计划的 registry / catalog / layout 同构：

```text
身份        TabDefinition     注册表里的 tab：tabId + 路由路径 + branchIndex（编译期常量）
              ↓
配置        NavConfig         用户态文档：每 tab 的组内序 / 名称 / 图标 / 可见
              ↓
渲染        ShellPage         按 resolved 顺序渲染；底栏第 i 格 → goBranch(branchIndex)
```

**核心**：branch 结构（`BranchIndex`）是编译期常量，用户配置只改变**渲染顺序**。
底栏的 index 始终是「可见列表里的位置」，经 `ResolvedTab.branchIndex` 翻译回
go_router 的分支。顺序是数据显示层的事，不是路由结构的事。

### 2.1 目录结构（已落地）

```text
lib/features/shell/
  domain/
    entities/
      nav_config.dart        TabId / TabPlacement / NavConfig（纯值 + JSON 编解码）
      tab_definition.dart    TabDefinition（身份 + path + branchIndex）
    services/
      nav_rules.dart         纯规则：名称清洗、编辑校验、配置补全、可见过滤
    repositories/
      nav_config.dart        NavConfigRepository 接口
  data/
    repositories/
      cached_nav_config.dart KV 实现 + navConfigRepositoryProvider
  presentation/
    tab.dart                 shellTabRegistry / ShellTabStyle / ResolvedTab / resolveTabs
    providers/
      nav_config.dart        navConfigProvider / resolvedNavProvider / visibleNavProvider
      data_access.dart       presentation → data 的唯一接缝
    page.dart                底栏（读 resolved 列表）
    sidebar/desktop.dart     桌面侧栏（同一条 resolved 列表）
```

### 2.2 配置模型

```dart
class TabPlacement {
  final TabId tabId;
  final int order;              // 渲染前归一成连续整数
  final String? customLabel;    // null = 用 ARB 默认（l10n 显式例外）
  final String? iconName;       // Lucide kebab 名；null = 用注册表默认
  final bool isVisible;
}

class NavConfig {
  final int schemaVersion;          // 未知版本 → 整体回退默认
  final List<TabPlacement>? tabs;   // null = 完全用注册表默认
}
```

**没有分组字段**：桌面侧栏分组不开放编排（见 §4）。

## 3. 已完成（2026-11-16）

- `TabId` / `TabPlacement` / `NavConfig` + 严格 JSON 编解码：任何结构问题或未知
  `schemaVersion` 都返回 null，上层整体回退默认——不猜、不部分修复
- `nav_rules.dart`：`validateTabLabel`（12 字素上限、零宽与 bidi 字符拒绝）、
  `validateNavConfig`（未知 id / 重复 id / 非法名称 / 非法图标 / 可见数 3..5 /
  首页不可隐藏）、`completeNavConfig`（注册表新增与删除的 tab 自动对齐、order 归一）、
  `visibleTabs`
- `CachedNavConfigRepository` + `PrefKeys.shellNavConfig`；写默认配置等价于删键
  （否则以后改注册表默认值时这批用户卡在旧默认上）
- `ShellPage` 与 `DesktopSidebar` 改为读 `visibleNavProvider`，切换经
  `branchIndex` 翻译；底栏选中态按可见列表位置算
- 删除 `enum ShellTab` / `enum ShellBranch` / `test/shell/branch_test.dart`
- 测试：`nav_config_test`（JSON 与坏数据）、`nav_rules_test`（规则与补全）、
  `cached_nav_config_test`（降级语义）、`nav_render_test`（顺序 / 名称 / 隐藏 /
  坏数据 / 编排往返的端到端行为）
- **N2 编排 UI**：`/customize/nav`（`nav_customizer.dart`），入口
  `mine → settings → 常规 → 底部导航`。每行图标 + 名称 + 路由路径 + 换图标 +
  上移/下移 + 显隐；编辑走 `navDraftProvider` 草稿（取消即丢弃、完成才写回），
  非法编辑逐次拒绝并 toast，恢复默认带二次确认。用按钮而非拖拽——5 项、
  顺序长期生效，按钮更可预期。测试：`nav_draft_test`、`nav_customizer_page_test`
- 跨层：编排页的上下留白就地用 `Spacing` 令牌算，没有复用 settings 的
  `page_padding.dart`（`cross_feature_import` 禁止）

## 4. 明确不做

| 项 | 不做的原因 |
| --- | --- |
| 运行期**新增** tab | Material 底栏上限 5，本仓已占满。多出来的 tab 无处可放，做出来也只是「隐藏一个换一个」 |
| 侧栏**分组**可编排 | 跨组拖拽需要专门编辑器（`drag_and_drop_lists`），是 4–6 天的纯 UI 成本；它解决的诉求（「把用药挪到第三位」）用顺序即可满足。等真有抱怨再加，不在数据模型里预留半成品字段 |
| `auto_route` 迁移 | 见 §1：增量能力不足以抵偿 126 文件改写 |
| 兼容层 | 未发版，旧枚举与旧断言直接删除 |

## 5. 待做

### N3 同步

- Lucent `/layouts/tab_chrome` 契约落地后接 `pending_sync_queue`
  （`entityType: 'nav_config'`）。与组件化计划的 `layout.<surface>` 走同一套同步机制
- 估：1–2 天

## 6. 验收

- `flutter analyze lib test integration_test` 无问题
- `--clean-layers` 零新增违规（已核对：基线 16 条，改动后仍 16 条）
- `test/shell` 全绿；顺序 / 名称 / 隐藏 / 坏数据 / 编排往返各有端到端用例
- 深链不受影响：`/medicine`、`/record/create?kind=water`、通知跳转、OAuth 回调
  在顺序被改过之后仍落点正确（路由表未变，由 `test/app/router_test.dart` 覆盖）
- 冷启动：配置从 KV 同步恢复，首帧不闪烁

## 7. 执行注意

- l10n 铁律：改 `lib/l10n/src/` 片段 → `dart scripts/l10n/arb_tools.dart merge` →
  `flutter gen-l10n`，**不碰 `app_*.arb`**
- tab 名称自由文本是 l10n 的显式例外（用户数据，与 `nickname` 同性质），
  须写进 `docs/reference/localization.md`
- Forui 优先；编排页不引入 Material 组件
- 每阶段追加 `docs/logs/migration-log/YYYY-MM-DD.md`（只追加不覆盖）
- 完成项从本文件**直接删除**，不留 `✅` / `DONE` 标记
