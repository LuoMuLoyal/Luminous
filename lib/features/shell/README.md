# lib/features/shell — 五 Tab 应用壳

`StatefulShellRoute` 的 chrome 层:移动端渲染 `FBottomNavigationBar`、桌面端渲染
`FSidebar`,并统一提供桌面 tab 页壳、右侧详情面板、切换不卡帧的懒构建组件与 tab
切换的交叉淡化容器。

**导航是数据**:注册表决定系统里有哪些 tab,用户配置决定挂了哪些、什么顺序、
叫什么、用什么图标。渲染层只消费解析结果。

## 三分模型

```text
注册表  shellTabRegistry          系统有哪些 tab(身份 + 路径 + branchIndex)
   ↓
配置    NavConfig                 用户挂了哪些(顺序 / 名称 / 图标 / 显隐),KV 持久化
   ↓
渲染    ShellPage / DesktopSidebar  底栏 i 格 → goBranch(branchIndex)
```

**关键不变量:branch 结构与用户配置无关。** `lib/app/router.dart` 的
`StatefulShellRoute` 固定 5 条 branches,`TabDefinition.branchIndex` 是编译期常量;
配置只改变**渲染顺序**,经一层 `visibleIndex → branchIndex` 映射翻译回 go_router。
这是"留在 go_router 也能做顺序可配"的根据——顺序是数据显示层的事,不是路由结构的事。

## 职责与边界
- 管:`shellTabRegistry` / `TabDefinition` / `ShellTabStyle`(默认图标与 ARB 文案)、
  `NavConfig` 及其规则与持久化;`ShellPage`(FScaffold 双形态 + ConnectivityBanner +
  桌面窗口拖动标题栏/侧栏 footer);`DesktopTabShell`(玻璃顶栏 + 内容 maxWidth 约束 +
  可选下拉刷新/滚动位置保持);`DesktopDetailPane` 与 `detail_pane_state.dart`(桌面右侧
  详情面板及其开关状态);`ShellDeferredContent`;`ShellTabBranchContainer`(替换默认
  `IndexedStack` 的 branch 容器);`presentation/sidebar/desktop.dart`(桌面侧边栏)。
- 不管:路由表与 branch 声明(在 `lib/app/router.dart`);tab 内容页(各 feature
  presentation);登录鉴权(core/auth + app 层 redirect);面板里渲染的详情内容本身。

## 对外契约
- `domain/entities/nav_config.dart` — `TabId` / `TabPlacement` / `NavConfig`(纯值 + JSON)
- `domain/entities/tab_definition.dart` — `TabDefinition`
- `domain/services/nav_rules.dart` — 纯规则:`validateTabLabel` / `validateNavConfig`
  / `completeNavConfig` / `visibleTabs`,以及 `NavRuleViolation` 拒绝原因
- `domain/repositories/nav_config.dart` — `NavConfigRepository`
- `data/repositories/cached_nav_config.dart` — KV 实现 + `navConfigRepositoryProvider`
- `presentation/tab.dart` — `shellTabRegistry` / `ShellTabStyle` / `ResolvedTab` /
  `resolveTabs` / `shellTabKey`
- `presentation/providers/nav_config.dart` — `navConfigProvider` / `resolvedNavProvider`
  / `visibleNavProvider`
- `presentation/providers/nav_draft.dart` — `navDraftProvider` / `navDraftRowsProvider`
  （编排页草稿）
- `presentation/pages/nav_customizer.dart` — `NavCustomizerPage`（底部导航编排页）
- `presentation/routes.dart` — `/customize/nav`
- `domain/repositories/nav_config_remote.dart` — `NavConfigRemote` / `NavConfigSyncQueue`
  （同步端口；实现在 customizer，由组合根注入）
- `data/sync/nav_config_sync.dart` — `NavConfigSync`（推送 / 拉取 / 离线入队）
- `presentation/providers/data_access.dart` — presentation 访问 data 的唯一接缝
- 其余导出:`ShellPage` / `DesktopTabShell` / `DesktopDetailPane` / `detailPaneProvider` /
  `ShellDeferredContent` / `ShellTabBranchContainer`

## 不变量
- **branch 数量与顺序是编译期的**。`shellTabRegistry` 的 `branchIndex` 必须与
  `router.dart` 里 `StatefulShellRoute` 的 branches 列表下标一致;两者一起改。
- **底栏 index 是"可见列表里的位置",不是 branch 下标**。用户调整顺序后两者会分开,
  切换必须经 `ResolvedTab.branchIndex` 翻译。
- **`ShellTabStyle.review.testKey` 固定为 `shell-tab-report`**(改名兼容)。
- **可见 tab 数 3..5**:少于 3 导航失去意义,多于 5 超出 `NavigationBar` 视觉上限。
- **首页 tab 不可隐藏**:它是冷启动落点。
- **非法编辑回退原配置**,不存半成品;`commit()` 返回 `NavResolution`,调用方读
  `rejection` 出提示即可。
- **配置读不出来即回退默认**,但不清除原始值(留给以后能读懂它的版本)。
- **本地 KV 是权威读源**:远端同步是旁路,推送失败入 `ui_layout` 队列重放,
  拉取失败静默保持本地。远端文档解不开时**不覆盖**用户当前能用的配置。
- `componentHost` 式降级:配置里未知 `tabId` 跳过,**其余 tab 照常渲染**。
- 桌面/移动形态仅由 `Breakpoints.desktop` 宽度决定;indexedStack 保证各 branch 导航栈
  独立保活(test/shell/shell_page_test.dart、test/app/router_test.dart)。
- **桌面端是与手机端平等的一等平台**(ADR-0008 2026-11-02 修订):任一改动需同时覆盖
  手机端。
- 详情面板关闭时不占位:内容区宽度与「没有面板」时完全一致。

## 依赖禁区
- 不承载业务数据读写;新数据需求走对应 feature 的 domain/repository。
- 不 import 其他 feature 的 presentation provider;侧栏未读徽标经 notification 的
  data provider,主题/会话经 core 层 provider。
- **不 import 其他 feature 的 `presentation/**`**：编排页的上下留白就地用
  `Spacing` 令牌算（`_pageVerticalPadding`），没有复用 settings 的
  `page_padding.dart`——两行令牌运算不值得为它改分层口径。
- `presentation/` **不许** import `lib/features/shell/data/**`,一律经
  `presentation/providers/data_access.dart`(`--clean-layers` 的 `presentation_layer`
  是 error 级、无白名单)。

## 陷阱与决策
- **编排入口**：`mine → settings → 常规 → 底部导航`（`settings-row-nav`），
  路由 `/customize/nav`。页面改的是**配置**，注册表不在页面上——所以没有
  「添加 tab」入口，只有既有 tab 的重排 / 改名 / 换图标 / 显隐。
- **编辑走草稿**（`navDraftProvider`）：进页面 `begin()` 以补全后的配置为起点，
  改动只进内存，「取消」丢弃。不在改动时立即写 KV——否则两次写之间进程被杀，
  用户回不到原样。
- **非法编辑逐次拒绝**：`move`/`rename`/`setIcon`/`setVisible` 都返回 `NavResolution`，
  被拒绝时草稿不变、`AppToast` 提示。用户拖出第 6 个可见 tab 时立刻知道，
  而不是点完成才发现。
- **用上移/下移按钮而不是拖拽**：只有 5 项，且改的是跨设备长期生效的顺序——
  按钮点击可预期、可自动化。组件编排页（`features/customizer`）用拖拽是因为
  那里有几十个组件、顺序是探索性的。首项的上移与末项的下移**置灰不隐藏**，
  否则行宽随位置跳动；越界移动是无操作，不报错。
- **`ShellTab` 枚举已删除**,由 `TabId` + `shellTabRegistry` 取代。`enum` 把身份、顺序、
  分支索引三合一压在 `index` 上,三者任一变非常量就全塌。测试改用 `shellTabKey(TabId.x)`
  按**身份**查找,不按位置。
- **桌面侧栏分组不开放编排**:分组归属是注册表侧事实,组内顺序来自配置。跨组拖拽需要
  专门的编辑器(`drag_and_drop_lists`),是可独立评估的纯 UI 成本,不在本次范围内。
- **tab 名称自由文本是 l10n 的显式例外**(用户数据,与 `nickname` 同性质),
  见 `docs/reference/localization.md`。零宽字符与 bidi 控制符一律拒绝。
- **图标按名字存**,不存 `IconData`:`codePoint` 在 icon tree-shaking 下不可信赖,
  落盘读回会变豆腐块。解析走 `LucideIconBridge`,查不到回退默认图标。
- **`completeNavConfig` 永远成功**:注册表新增的 tab 自动补进来(插在默认位置附近,
  不是甩到末尾),删掉的自动跳过。所以升级加 tab 后老配置照样渲染。
- tab 切换动画的唯一所有者是 `ShellTabBranchContainer`。tab 根路由必须是
  `NoTransitionPage`:在根路由上加 `CustomTransitionPage` 既不会在切 tab 时播放
  (go_router 复用已恢复 branch 的 Navigator),又读起来像"tab 切换动画",别再加。
- `ShellDeferredContent` 用 post-frame callback 延后一帧再构建,占位色取
  `SemanticColor.neutral.shimmerBase`。
- 桌面侧栏 header 是窗口拖动区(`DragToMoveArea`);窗口控制按钮由
  `DesktopWindowChrome` 另行渲染,不在本目录。
- 桌面侧栏的层次**只用色差**,不画描边/阴影/分组卡片。分组由标题的 `headerPadding`
  表达(上方 `Spacing.xl3`、下方 `Spacing.xs`),`childrenPadding` 归零。
