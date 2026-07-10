# Luminous Runtime Snapshot

## 技术栈

- Flutter + Riverpod + GoRouter + `hooks_riverpod` + `flutter_hooks`。
- 编译期环境变量入口统一为 `lib/core/config/env_keys.dart` +
  `lib/core/config/env_reader.dart`。
- 默认通过 `--dart-define-from-file=.env` 注入运行时与 full-stack E2E 所需键；
  Android 模拟器专用地址使用 `E2E_LUCENT_BASE_URL`，避免和 app 本地调试的
  `LUCENT_BASE_URL=http://127.0.0.1:3000` 冲突。
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
- 语义颜色枚举 `SemanticColor` 位于 `lib/core/design/semantic_color.dart`。
- 二维 token 系统：`SemanticColor`（6 个语义色）× `SemanticColorPalette`（5 个预计算 tone：solid/foreground/muted/subtle/border）。
- `SemanticColors` 通过 `FColors.extensions` 注入 Forui 主题，暗色模式 alpha 自动补偿。
- 数据/领域层使用 `SemanticColor`；widget 通过 `palette(context)` 或便捷方法 `solid/muted/subtle/border(context)` 解析。

## Token 现状

所有 token 位于 `lib/core/design/`，通过 barrel `design.dart` 统一导出。

- `Spacing` — `level1..level12` 数字刻度（4 / 6 / 10 / 14 / 20 / 28 / 36 / 44 / 56 / 72 / 96 / 128）。
- `RadiusTokens` — `level0..level9` + `levelFull`，映射 Forui `FBorderRadius` 九级 + pill。
- `TypographyToken` — `level1..level10` 枚举，映射 Forui `FTypeface` 十级。
- `DurationTokens` — 路由过渡 + widget 动画时长常量。
- `Breakpoints` — `mobile` / `tablet` / `desktop` / `wide` / `assistantContent`。
- `ResponsiveSizing` — 卡宽 / sidebar 宽 / grid 列数 / 可缩放尺寸 helper。
- `LayoutScale` + `LayoutScaleResolver` — 响应式布局刻度（page padding / section gap / card padding / max content width）+ 对话框固定宽度。
- 旧的 `App*` 前缀类型名已全部移除。

## 页面脚手架

- `PageScaffoldShell` 已删除。
- 子页直接组合 `FScaffold` + `FHeader` + `ResponsiveContentFrame`。
- Drawer / FAB 场景在本地处理。

## Android

- app module 跟随 Flutter 托管默认 `minSdk`。
- 不再仅在 Gradle 中固定 Android 12+。
- Android 12 splash 行为由现有 `values-v31/` 资源分管。

## 生成客户端

- 包位置：`generated/lucent_api`。

## 认证与会话

- 认证/会话状态分为：恢复中、确认已登出、已登录。
- 网络层拦截器链：`AuthInterceptor`（token 注入 + 401 刷新） → `RetryInterceptor`（5xx/超时重试） → `ErrorInterceptor`（错误映射）。
- `LucentDioClient` 仅负责 Dio 实例配置 + interceptor 注册，不包含业务逻辑。
- `lucentClientProvider`（keepAlive）是全部 feature 代码的统一 API 访问入口；旧 `lucent*ApiProvider` 已标记 `@Deprecated`。
- `LucentSseClient` 支持 `reconnect` 参数自动重连。

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
