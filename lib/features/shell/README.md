# lib/features/shell — 五 Tab 应用壳

`StatefulShellRoute.indexedStack` 的 chrome 层:五 tab(today / record / medicine /
review / mine)移动端渲染 `FBottomNavigationBar`、桌面端渲染 `FSidebar`,并统一提供
桌面 tab 页壳与切换不卡帧的懒构建组件。

## 职责与边界
- 管:`ShellTab` / `ShellBranch` 枚举与稳定 test key;`ShellPage`(FScaffold 双形态 +
  ConnectivityBanner + 桌面窗口拖动标题栏/侧栏 footer);`DesktopTabShell`(FHeader +
  内容 maxWidth 约束 + 可选下拉刷新/滚动位置保持);`ShellDeferredContent`。
- 不管:路由表、redirect guard、branch 声明(在 `lib/app/router.dart`);tab 内容页
  (各 feature presentation);登录鉴权(core/auth + app 层 redirect)。

## 对外契约
- 导出:`presentation/tab.dart`(`ShellTab`,review 保留 `shell-tab-report` key)、
  `presentation/branch.dart`(`ShellBranch` / `ShellTabBranchX`)、`presentation/page.dart`
  (`ShellPage`)、`presentation/desktop_tab_shell.dart`(`DesktopTabShell`)、
  `presentation/deferred_content.dart`(`ShellDeferredContent`)。
- 被依赖:`lib/app/router.dart`(挂 `ShellPage`);五个 tab 页均用 `ShellDeferredContent`
  包裹重内容;today / review / mine 等桌面页用 `DesktopTabShell` 提供标题与刷新。

## 不变量
- branch index == tab index,`goBranch` 直接使用枚举 index(test/shell/branch_test.dart)。
- `ShellTab.review.testKey()` 固定为 `shell-tab-report`(改名兼容,test/shell/tab_test.dart)。
- 桌面/移动形态仅由 `Breakpoints.desktop` 宽度决定;indexedStack 保证各 branch 导航栈
  独立保活(test/shell/shell_page_test.dart、test/app/router_test.dart)。

## 依赖禁区
- 不承载业务数据读写;新数据需求走对应 feature 的 domain/repository。
- 不 import 其他 feature 的 presentation provider(仓库跨 feature 规则);侧栏未读徽标
  经 notification 的 data provider,主题/会话经 core 层 provider。

## 陷阱与决策
- review tab 旧名 report:`ShellBranch.report` 枚举名与 test key 均保留旧名,改枚举名
  需同步测试与集成脚本。
- `ShellDeferredContent` 用 post-frame callback 延后一帧再构建,占位色取
  `SemanticColor.neutral.shimmerBase`,避免 tab 切换动画被图表/长列表构建阻塞。
- 桌面侧栏 header 是窗口拖动区(`DragToMoveArea`),macOS 需为系统红绿灯按钮预留左侧
  空间;窗口控制按钮由 `DesktopWindowChrome`
  (core/widgets/common/control/desktop_window_chrome.dart)另行渲染,不在本目录。
