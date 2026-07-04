# Luminous Runtime Snapshot

## 技术栈

- Flutter + Riverpod + GoRouter + `hooks_riverpod` + `flutter_hooks`。
- AI 开发增强入口：
  - `.github/copilot-instructions.md`
  - `.cursor/mcp.json`
  - `.vscode/settings.json` 中的 `dart.mcpServer`
  - `lib/core/ai/` 实验 runtime seam

## 主题与设计系统

- `LuminousApp` 使用 Forui 引导的根主题。
- `MaterialApp.router` 从 Forui 派生 light/dark `ThemeData`。
- 整棵树包裹 `FTheme`。
- 运行时 `lib/` 不再保留旧的 `AppThemeSurface` bridge。
- 语义颜色枚举 `AppColors` 位于 `lib/core/design/app_colors.dart`。
- 数据/领域层使用 `AppColors`；widget 通过当前 Forui 主题解析。

## Token 现状

- `AppSpacingTokens` 仅暴露 `level1..level12` 数字刻度。
- `AppRadiusTokens` 仅暴露 `level0..level5` 与 `levelFull`。
- 旧的语义别名已移除，所有调用点已迁移。

## 页面脚手架

- `PageScaffoldShell` 已删除。
- 子页直接组合 `FScaffold` + `FHeader` + `ResponsiveContentFrame`。
- Drawer / FAB 场景在本地处理。

## Android

- app module 跟随 Flutter 托管默认 `minSdk`。
- 不再仅在 Gradle 中固定 Android 12+。
- Android 12 splash 行为由现有 `values-v31/` 资源分管。

## 生成客户端

- 包位置：`packages/lucent_openapi`。

## 认证与会话

- 认证/会话状态分为：恢复中、确认已登出、已登录。

## 测试与验证

- 集成覆盖包含四条真实 Android 模拟器全栈 lane：
  - 登录 smoke
  - Record CRUD lane
  - Record 睡眠结构化录入 lane
  - Today + Report 受保护 dashboard lane（含 Report 同步与真实 AI 流生成）
- 本地验证入口：
  - `tool/check_doc_coverage.dart` — 根据 `docs/doc-map.yaml` 输出文档覆盖 warning（不阻塞）
  - `tool/run_daily_checks.dart` — 仓库安全级检查
  - `tool/run_fullstack_checks.dart` — Android 模拟器 + Lucent test runtime
- `tool/verify_lucent_openapi_sync.dart` — 轻量合同门
  - 默认使用同级 `../Lucent/docs/openapi.json`
  - 支持 `--openapi <path>`
  - 不再要求干净 git 工作树
- GitHub Actions 在构建 APK 前检查生成客户端漂移。

## 测试结构

- 前端测试按 feature 分组在嵌套的 `test/` 与 `integration_test/` 下。
- `integration_test/` 分为离线/mock 流程与 Android 模拟器全栈 lane。
- 全栈移动 E2E 当前为本地/手动；不属于 GitHub Actions 流水线。

## 共享边界

- support-resource 读取放在独立的 `features/support/` 边界，不再嵌套在 `settings` 下。
- app-side AI runtime 边界放在 `lib/core/ai/`，只承载本地实验配置与 provider seam。
- shipping assistant/report AI 仍通过 Lucent 合同与 API 执行。

## 受保护内容

- 受保护 provider 在认证恢复或确认登出时不调用 Lucent。
- 受保护入口点击在当前页弹出登录提示；直接/深链受保护页面保留目标守卫作为 fallback。

## 加载与 Report

- Skeleton loading 按 section 划分：稳定 chrome 和本地/mock/静态 section 立即渲染，后端字段本地 shimmer。
- Report 进入时拉取 Lucent report dashboard。
- 支持 section 级 shimmer、显式登出门槛、三个导出卡片到 Lucent 数据导出请求流。
