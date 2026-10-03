---
status: active
owner: frontend
updated: 2026-10-03
---

# AI Development Workflow

本文只覆盖 AI 开发专属机制：MCP 配置、`lib/core/ai/` 实验 seam、feature flag、CI 环境变量。agent 行为与仓库通用守则以 `AGENTS.md` 为唯一规则源。

## Integration Boundary

- AI 辅助开发依赖仓库内提交的指令与 MCP 配置（`.cursor/mcp.json`、`.github/copilot-instructions.md`），不依赖私有 IDE 状态。
- 线上 AI 功能走 Lucent 后端 API；本地 app-side AI 运行时是 `lib/core/ai/` 下的非发布实验 seam。

## MCP Usage

- 首选入口是仓库内提交的 `.cursor/mcp.json`，它把客户端指向使用本工作区 Flutter 工具链的 Dart/Flutter MCP server。
- 客户端无法直接消费 `.cursor/mcp.json` 时，在该客户端中镜像相同的 command/args，不要另造配置。

## App-Side AI Runtime Boundary

`lib/core/ai/` 只承载本地运行时关注点：

- experiment flags
- provider wiring
- runtime capability descriptors
- future vendor adapters

以下内容不属于 `lib/core/ai/`，保持既有 feature 边界：

- Lucent API DTO mapping
- assistant conversation UI state
- report AI summary transport

`runtime_config.dart` / `runtime_providers.dart` 文件头保留标记
`// Experimental dev seam — not part of the shipping assistant path.`；保持实验 seam、默认关闭的语义。未来任何 model SDK 或 Firebase 绑定先落到该 seam，再考虑接入产品流程。

## Experimental Runtime Flags

seam 由编译期 dart-define 门控，默认关闭：

```bash
flutter run \
  --dart-define=LUMINOUS_EXPERIMENTAL_AI_RUNTIME=true \
  --dart-define=LUMINOUS_AI_RUNTIME_PROVIDER=ai_toolkit
```

GenUI 探索（可选，不是当前产品壳的依赖）：

```bash
flutter run \
  --dart-define=LUMINOUS_EXPERIMENTAL_AI_RUNTIME=true \
  --dart-define=LUMINOUS_AI_RUNTIME_PROVIDER=gen_ui \
  --dart-define=LUMINOUS_ENABLE_GEN_UI=true
```

`LUMINOUS_AI_RUNTIME_PROVIDER` 接受 `none` / `ai_toolkit` / `gen_ui` / `custom`，无法识别的值按 `none` 处理。

## CI/CD Environment Variables

配置位置：Repository Settings → Secrets and variables → Actions。工作流拆分与触发见
[workflows README](../../.github/workflows/README.md)。`ci.yml` 只做校验，不注入任何
运行期变量；下表由发布工作流消费。

| Variable | Source | 消费方 | Description |
|----------|--------|--------|-------------|
| `LUCENT_BASE_URL` | GitHub Secrets | `deploy-android` / `deploy-ios` / `deploy-web` | Backend API base URL。三个发布工作流都要求非空，缺失直接失败 |
| `SENTRY_DSN` | GitHub Secrets | 同上 | Sentry DSN（可选：未设置则禁用 Sentry） |
| `SUPPORT_EMAIL` | GitHub Variables | 同上 | 帮助页反馈邮箱，默认 `support@luminous.app`（后端 `AppInfo.supportEmail` 优先） |
| `JPUSH_APP_KEY` | GitHub Secrets | `deploy-android` / `deploy-ios` | JPush AppKey；Android 侧同时作为 Gradle 环境变量填 manifest，缺失则推送静默禁用 |
| `WECHAT_MOBILE_APP_ID` | GitHub Secrets | `deploy-android` / `deploy-ios` | 微信开放平台 AppId；iOS 侧同时写入 `ios/Flutter/Wechat.xcconfig` 供 `CFBundleURLSchemes` 展开 |
| `WECHAT_IOS_UNIVERSAL_LINK` | GitHub Variables | `deploy-ios` | 微信 Universal Link；仍需在 Apple 账号侧配置 Associated Domains 才可用 |
| `LUMINOUS_EXPERIMENTAL_AI_RUNTIME` | GitHub Variables | `deploy-web` | Enable experimental AI runtime（默认 `false`） |
| `LUMINOUS_AI_RUNTIME_PROVIDER` | GitHub Variables | `deploy-web` | AI runtime provider（工作流回退值 `openai`，运行时按 `none` 处理） |
| `LUMINOUS_ENABLE_GEN_UI` | GitHub Variables | `deploy-web` | Enable GenUI features（默认 `false`） |

`deploy-web.yml` 另外在构建前校验：`SENTRY_DSN` 若已设置，必须符合
`https://<key>@<host>/<project>` 格式，否则构建失败。最后三个 `LUMINOUS_*` 是 Web
实验运行时开关，只由 Web 发布注入；移动端发布保持产品默认（关闭）。

## Verification Expectations

改动 AI workflow 文档或 `lib/core/ai/` 时:

- `flutter test test/core/ai`
- `flutter analyze`
- 改动 token / 路由 / feature 目录结构后运行 `dart run scripts/docs/generate.dart` 再生成清单(见 AGENTS.md Commands;`--check` 已接入 scripts/workflows/daily.dart 与 CI)
- 追加 `docs/logs/migration-log/YYYY-MM-DD.md` 条目
