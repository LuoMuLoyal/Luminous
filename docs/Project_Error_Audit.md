# Lumos Project Error Audit

Last updated: 2026-06-04

本文件汇总从项目开始到当前阶段已经暴露过的错误、踩坑和反复修正点，供之后做计划、代码审查、回归测试和交接时核查。

## Scope

- 覆盖范围：`Lucent` 后端、`Luminous` Flutter 前端、两者之间的 API/OpenAPI/文档边界。
- 证据来源：`Lucent/CHANGELOG.md`、`Luminous/docs/MigrationLog.md`、`Luminous/docs/MigrationLog_Archive_PreReset.md`、`Luminous/docs/RestartPlan.md`、superpowers 计划文档、`AGENTS.md`、近期 git 提交摘要。
- 不承诺覆盖没有提交、没有文档、只存在聊天记录或本地未保存状态里的问题。
- 后续发现新错误时，追加到对应分类；不要重写历史条目。

## How To Use This File

每次开始较大任务前，先做两步：

1. 找任务涉及的区域：Backend / Frontend / Contract / Infra / Docs。
2. 对照下面的 "Review Checklist" 和对应错误条目检查测试、文档、生成物、边界条件是否已经覆盖。

每次修复一个复发问题时，追加一条：

```text
ID:
Area:
What went wrong:
Evidence:
Current status:
Future audit:
```

## Review Checklist

- API 行为变更后，同步 `Lucent/docs/public/api-contract.md`、`Lucent/docs/openapi.json`、`Luminous/docs/OpenApi_Client.md`。
- OpenAPI 客户端只用 `dart run tool/regenerate_lucent_openapi.dart` 再生。
- Flutter domain / presentation 不直接依赖 generated `lucent_openapi` 写 DTO。
- nullable PATCH 写入必须覆盖 omitted / explicit null / concrete value 三种状态。
- 后端 upsert 必须覆盖 create 分支和 update 分支。
- 用户私有数据端点必须覆盖 auth required 和 user isolation。
- signed-out 前端路径不得反复打受保护 API；要显示稳定未登录状态或跳 `/login`。
- 写操作成功后必须 invalidate 所有受影响的 Riverpod provider。
- Flutter 页面不要在已经 scrollable 的 shell 中再嵌套无界 `ListView`。
- 新可见文案走 ARB + `flutter gen-l10n`。
- mock / static / unsupported 功能必须明确标注边界，不要展示成真实能力。
- 提交前运行最小相关验证；发布/大范围变更前运行全量验证。

## Recurring Patterns

### RISK-001: Contract Drift

API 文档、OpenAPI、后端实现、Flutter 调用曾多次不一致。典型后果是前端 DTO 字段过期、错误码不一致、请求 body 仍按旧协议发送。

未来核查：

```bash
cd Lucent
pnpm export:openapi
cd ../Luminous
dart run tool/regenerate_lucent_openapi.dart
flutter analyze
```

### RISK-002: Generated Client Toolchain Drift

OpenAPI generator 会重写 Dart generated package 的 SDK / dependency constraints，并且当前工具链存在 nullable map entry 生成问题。

未来核查：

```bash
cd Luminous
dart run tool/regenerate_lucent_openapi.dart
flutter analyze
flutter test
```

不要手动跑临时 `npx openapi-generator-cli generate` 作为常规流程。

### RISK-003: Partial Update Semantics

PATCH 写入里，"字段没传"、"字段传 null 清空"、"字段传具体值更新" 语义不同。后端和前端都出过遗漏。

未来核查：

- 后端 service/unit/e2e 测 omitted/null/value。
- 前端 payload helper/widget/repository 测 explicit null 是否真正发出去。
- 不要让 generated DTO 的 `includeIfNull: false` 吞掉清空字段。

### RISK-004: Mock Presented As Real

Record / Medicine / Today / More 多次经历 mock 到真实数据的迁移。风险是 UI 视觉上很完整，但行为仍是 toast/mock/static。

未来核查：

- `docs/UI_Implementation_Plan.md` 必须区分 real / mock / unsupported。
- UI 文案不要暗示未实现的提醒、扫码、OCR、AI 医疗建议已经可用。
- widget tests 覆盖 signed-out、loading、error、empty、populated。

## Backend Error Register

### ERR-BE-001: NestJS 11 CacheModule Redis 配置误用旧 `store`

Area: backend / infra

What went wrong: CacheModule 仍按旧接口配置 `store`，在 NestJS 11 下可能看似启用 Redis，实际退回或表现接近内存缓存。

Evidence: `Lucent/CHANGELOG.md` 2026-05-31 "Cache Manager Redis Wiring + Agent Doc Cleanup"；`Lucent/AGENTS.md` Known Gotchas。

Current status: 已改为 `stores`，Redis store 通过 Keyv adapter 接入。

Future audit:

```bash
cd Lucent
pnpm exec jest --runInBand src/config/cache.config.spec.ts
```

### ERR-BE-002: medicines cache invalidation 没按 Keyv/Redis 实际 key 结构扫描

Area: backend / cache / medicine import

What went wrong: 导入后缓存清理可能报告 `invalidated: 0`，旧 medicine search/detail 缓存仍保留。

Evidence: `Lucent/CHANGELOG.md` 2026-05-31 "Medicines Cache Invalidation + OpenAPI Export Sync"。

Current status: 已按 Keyv namespace 与 raw store 结构扫描并归一化逻辑 key。

Future audit:

```bash
cd Lucent
pnpm exec jest --runInBand src/medicines/cache/medicines-cache-admin.service.spec.ts
node --test scripts/medicine/import-medicine-knowledge.test.js
```

### ERR-BE-003: DrugBank target 导入主键和关系插入不稳定

Area: backend / medicine import

What went wrong: `drugbank_targets` / `drugbank_drug_targets` 批量插入曾因不稳定主键和非事务批次失败。

Evidence: `Lucent/CHANGELOG.md` 2026-05-30 "Medicine Knowledge Foundation"。

Current status: 已显式生成稳定主键，并在 target + relation 批次内使用事务。

Future audit:

- 修改导入脚本时运行 representative fixture。
- 不要把 DrugBank `full database.xml` 转成 xlsx 作为常规导入路径。

### ERR-BE-004: Auth 登录空凭据仍可签 token

Area: backend / auth / security

What went wrong: 登录只传邮箱、不传 `password` 或 `code` 时曾仍会签发 token。

Evidence: `Lucent/CHANGELOG.md` 2026-05-30 "Auth 安全边界 + E2E 基线修复"。

Current status: 已约束登录凭据必须且只能二选一：password 或 code。

Future audit:

```bash
cd Lucent
pnpm test -- auth.service.spec.ts --runInBand
pnpm test:e2e:ci -- auth.e2e-spec.ts
```

### ERR-BE-005: JWT payload `sub` 与 `subject` 重复导致 jsonwebtoken 9 抛错

Area: backend / auth

What went wrong: JWT 签发时 payload 已含 `sub` 又传 `subject`。

Evidence: `Lucent/CHANGELOG.md` 2026-05-30 "Auth 安全边界 + E2E 基线修复"。

Current status: 已修复。

Future audit: Auth token 生成相关变更必须跑 auth service/e2e。

### ERR-BE-006: 软删除用户仍参与默认查询

Area: backend / auth / user lifecycle

What went wrong: `findById` / `findByEmail` 默认没有排除 `deletedAt != null` 用户，可能影响登录、`me`、邮箱占用判断。

Evidence: `Lucent/CHANGELOG.md` 2026-05-30 "Auth 安全边界 + E2E 基线修复"。

Current status: 默认查询已过滤 `deletedAt: null`。

Future audit: 删除、恢复、邮箱占用相关测试必须显式覆盖软删除用户。

### ERR-BE-007: Logout 可越界删除其他用户 refresh session

Area: backend / auth / security

What went wrong: 已认证用户只要拿到别人的 refresh token 明文，就可能删除对方 session。

Evidence: `Lucent/CHANGELOG.md` 2026-06-02 "Auth Logout Boundary + Normalized Change Email Response"。

Current status: logout 删除约束已收紧到当前 JWT 用户。

Future audit: 任何 session/token mutation 都要按 `userId + token/hash` 约束，并加跨账号 e2e。

### ERR-BE-008: Change Email 响应返回 raw dto 而非持久化规范化邮箱

Area: backend / auth / contract

What went wrong: `changeEmail` 返回请求里的 `dto.newEmail`，而不是数据库最终规范化后的邮箱。

Evidence: `Lucent/CHANGELOG.md` 2026-06-02 "Auth Logout Boundary + Normalized Change Email Response"。

Current status: service 返回更新后的 `User`，controller 回显最终邮箱。

Future audit: 所有 mutation 响应应来自持久化结果，而不是直接回显 request DTO。

### ERR-BE-009: Register/changeEmail/refresh 边界与真实安全需求不一致

Area: backend / auth

What went wrong:

- register 早期未要求验证码。
- changeEmail 曾校验旧邮箱或接收 `currentEmail` body，边界不稳定。
- refresh 曾删除同账号其他设备 token。

Evidence: `Lucent/CHANGELOG.md` 2026-05-30 "Auth 注册验证码、邮箱变更与刷新令牌修正"。

Current status: register 校验 `scene=register`；changeEmail 校验新邮箱验证码；refresh 只轮换当前 token。

Future audit: 修改 auth contract 后同时更新 `auth-api-mock.md`、OpenAPI、Flutter DTO 使用。

### ERR-BE-010: ValidationPipe 错误码与合同不一致

Area: backend / API envelope

What went wrong: DTO 校验错误没有稳定映射到合同里的 `400002`。

Evidence: `Lucent/CHANGELOG.md` 2026-06-02 "Auth Validation Code Alignment + UpdateMe Empty-String Clearing"。

Current status: `ValidationPipe` 使用自定义 `exceptionFactory`。

Future audit: 新 DTO 验证失败 e2e 应断言 envelope code。

### ERR-BE-011: `PATCH /auth/me` 空字符串清空行为与文档不一致

Area: backend / auth / contract

What went wrong: `nickname: ''` / `avatar: ''` 行为没有按文档清空为 null。

Evidence: `Lucent/CHANGELOG.md` 2026-06-02 "Auth Validation Code Alignment + UpdateMe Empty-String Clearing"。

Current status: 已归一化为空值清空。

Future audit: 对所有 partial update 增加 empty string / null / omitted 测试。

### ERR-BE-012: i18n `typesOutputPath` 在 dist/test 运行时访问不存在文件

Area: backend / i18n / runtime

What went wrong: 编译后 `dist` 或 test 环境仍尝试访问源码生成类型路径，导致运行失败。

Evidence: `Lucent/CHANGELOG.md` 2026-06-02 "I18n Dist Runtime Fix + Auth Smoke Validation"；2026-05-30 e2e 修复。

Current status: 只在 development 源码上下文启用类型输出。

Future audit:

```bash
cd Lucent
pnpm build
pnpm export:openapi
```

### ERR-BE-013: AuthController 响应 DTO 循环依赖导致 OpenAPI 不完整

Area: backend / OpenAPI

What went wrong: `AuthController` 通过 `ApiResponse` 引用 `UserFullDto`，触发模块/DTO 循环依赖，`openapi.json` 曾只导出 4 paths / 20 schemas。

Evidence: `Lucent/CHANGELOG.md` 2026-05-29 "OpenAPI 全量导出 + Flutter dio 客户端生成"；`Luminous/docs/MigrationLog_Archive_PreReset.md` Phase 3 Step 1。

Current status: Auth response DTO 已内联/解耦，OpenAPI 覆盖完整 Auth/App 端点。

Future audit: OpenAPI 导出后核对 paths/schemas 数量变化是否符合预期。

### ERR-BE-014: OpenAPI export 直接用 ts-node 时无法解析 Prisma 7 generated `.js` import

Area: backend / OpenAPI / build

What went wrong: `export:openapi` 早期从源码执行，遇到 Prisma 7 generated client import 兼容问题。

Evidence: `Lucent/CHANGELOG.md` 2026-05-30 "Auth 注册验证码、邮箱变更与刷新令牌修正"。

Current status: `export:openapi` 改为先 build 再从 `dist` 导出。

Future audit: 不绕过 `pnpm export:openapi` 脚本。

### ERR-BE-015: Prisma v7 运行时和配置细节多处踩坑

Area: backend / Prisma

What went wrong:

- Prisma v7 不再自动读 `DATABASE_URL`，需要 adapter。
- provider 是 `prisma-client`，不是旧 `prisma-client-js`。
- output path 相对 `schema.prisma` 解析。
- `prisma.config.ts` 在 strict TS 下需要处理 undefined。

Evidence: `Lucent/CHANGELOG.md` 2026-05-28 "OpenAPI + 运行时修复 + 日志滚动"；`Lucent/AGENTS.md` Known Gotchas。

Current status: 已使用 `@prisma/adapter-pg` 和项目约定配置。

Future audit:

```bash
cd Lucent
pnpm exec prisma validate
pnpm build
```

### ERR-BE-016: Joi v18 `.uri({ scheme: regex })` 不兼容

Area: backend / config

What went wrong: Joi v18 不支持 regex scheme 形式，环境校验失败。

Evidence: `Lucent/CHANGELOG.md` 2026-05-28 "OpenAPI + 运行时修复 + 日志滚动"。

Current status: 改为数组 scheme；可选字段允许空字符串。

Future audit: 修改 env schema 后用 development/test 启动或 build 验证。

### ERR-BE-017: Docker build 被 TS strict / runtime dependency 卡住

Area: backend / Docker / CI

What went wrong:

- 未使用 constructor private 参数触发 TS6138。
- `noUncheckedIndexedAccess` 下未处理 `match[2]`。
- production stage 缺少 `prisma` CLI，但 entrypoint 要执行 migration。
- `npx` 与 pnpm 项目工具链不一致。

Evidence: `Lucent/CHANGELOG.md` 2026-05-28 "Docker Build Fix"。

Current status: 已修复 strict TS 与 Docker stage。

Future audit:

```bash
cd Lucent
pnpm build
```

### ERR-BE-018: E2E 环境与本地数据库/Prisma 运行条件不匹配

Area: backend / tests / local env

What went wrong:

- e2e 需要 `NODE_OPTIONS=--experimental-vm-modules`。
- test DB 与 dev DB 端口/账号混淆。
- i18n generated types 在 test/dist 下路径不对。

Evidence: `Lucent/CHANGELOG.md` 2026-05-30 "Auth 安全边界 + E2E 基线修复"；2026-05-30 "Dual Local PostgreSQL + Local Stack Scripts"。

Current status: dev/test PostgreSQL 已拆分，脚本和环境文档已更新。

Future audit:

```bash
cd Lucent
pnpm dev:stack:up
pnpm db:migrate:all
pnpm test:e2e:ci
```

### ERR-BE-019: Health-context profile upsert create 分支漏写 onboarding 完成时间

Area: backend / health context

What went wrong: 用户没有 profile row 时，首次 `onboardingCompleted: true` 只写 update 分支，create 分支没有 `onboardingCompletedAt`。

Evidence: `Lucent/CHANGELOG.md` 2026-06-03 "Health Context Profile Upsert Completion Fix"；commit `8f5bd91`。

Current status: 已修复并新增 unit/e2e。

Future audit: 任何 upsert 都必须测 create/update 两支。

### ERR-BE-020: OpenAPI 文档曾落后于控制器声明

Area: backend / OpenAPI / docs

What went wrong: medicines endpoints 的 `x-bypass-cache` header 已在控制器存在，但 `docs/openapi.json` 没同步。

Evidence: `Lucent/CHANGELOG.md` 2026-05-31 "Medicines Cache Invalidation + OpenAPI Export Sync"。

Current status: 已重新导出 OpenAPI。

Future audit: API decorator 变化后必须 `pnpm export:openapi`。

### ERR-BE-021: CI/CD 和远程部署假设过强

Area: infra / deployment

What went wrong: 部署曾依赖服务器访问 GitHub、镜像推送方式、e2e 命令传参等外部条件，导致 pipeline/部署不稳定。

Evidence: git commits `a418991 fix(ci): 修复ci阶段e2e命令传参问题`、`053029c fix(cicd): 改用普通docker推送业务镜像`；`Lucent/CHANGELOG.md` 2026-06-01 CI/CD pipeline。

Current status: CI/CD 改为构建镜像、同步部署文件、服务器拉取固定镜像、健康检查失败回滚。

Future audit: 修改部署脚本后检查 `Lucent/docs/tencent-cloud-cicd.md`。

### ERR-BE-022: Dose-log contract bundle 没有一次性验全

Area: backend / medicine / OpenAPI / migrations

What went wrong: DeepSeek 的 follow-up 任务报告 dose-log 已完成，但 Codex 复审发现 active `Lucent/dev` 上仍需要恢复/补齐完整 bundle：Prisma migration、service/controller response DTO、OpenAPI schemas、unit/e2e，以及 Luminous regenerated client 对应模型。单看一个接口或一个测试会漏掉这种跨文件不完整。

Evidence: 2026-06-04 Codex fix commit `038f225 fix(health-context): 恢复写接口并补齐用药打卡验证`。

Current status: 已补 `UserMedicineDoseLog` migration、typed dose-log response DTO、OpenAPI 27 paths / 76 schemas、120 unit + 71 e2e 验证。

Future audit:

```bash
cd Lucent
pnpm dev:stack:up
pnpm db:migrate:all
pnpm exec prisma validate
pnpm export:openapi
pnpm test -- medicine-dose-logs.service.spec.ts --runInBand
pnpm test:e2e:ci -- medicine-dose-logs.e2e-spec.ts
```

同时核对 `prisma/schema.prisma`、`prisma/migrations/**`、`src/medicine-dose-logs/**`、`docs/public/api-contract.md`、`docs/openapi.json`、`CHANGELOG.md` 是否同一轮更新。

## Frontend Error Register

### ERR-FE-001: 重置前代码和当前产品边界不匹配

Area: frontend / architecture

What went wrong: 旧 `home/drug/scan/settings/utils/shared widgets` 等实现不能直接代表当前五栏产品边界。

Evidence: `Luminous/docs/RestartPlan.md` 二次开工原则。

Current status: 已重置为五栏骨架，并规定旧提交只能按思路/组件参考。

Future audit: 新代码不得回流到 legacy `lib/pages/`、`lib/stores/`、`lib/viewmodels/`、`lib/components/`。

### ERR-FE-002: Reset 后最小 widget test 缺少 ProviderScope

Area: frontend / tests

What went wrong: 重置版 `test/widget_test.dart` 基线缺少 `ProviderScope`。

Evidence: `Luminous/docs/RestartPlan.md` 第一阶段任务 1。

Current status: 已作为重置基线任务处理。

Future audit: 新 app/root widget 测试必须包 ProviderScope 和必要 overrides。

### ERR-FE-003: Tab 栏在部分设备上越界

Area: frontend / UI layout

What went wrong: 底部 tab 栏没有足够 SafeArea 保护。

Evidence: git commit `4621973 fix(shell): 修复tab栏越界问题`；`Luminous/docs/MigrationLog_Archive_PreReset.md` Step 2。

Current status: 已加 SafeArea。

Future audit: shell/nav 变更后测移动端窄屏与安全区。

### ERR-FE-004: 全局 ProviderContainer 造成隐藏状态和测试污染

Area: frontend / state management

What went wrong: 非 widget 工具类通过全局 `ProviderContainer` 取依赖，增加跨测试污染和隐藏耦合。

Evidence: `Luminous/docs/MigrationLog_Archive_PreReset.md` "全局 ProviderContainer 消除"。

Current status: 已改为 Riverpod Provider 或构造函数注入。

Future audit: 不新增全局可变容器；测试通过参数/overrides 注入依赖。

### ERR-FE-005: `Navigator.push(MaterialPageRoute(...))` 绕过 GoRouter

Area: frontend / routing

What went wrong: 多处业务页面直接使用 Navigator，影响 URL 同步、路由守卫和测试。

Evidence: `Luminous/docs/MigrationLog_Archive_PreReset.md` "导航统一：Navigator.push -> GoRouter"。

Current status: 绝大多数已迁移到 GoRouter；只有明确无法序列化回调的旧场景保留。

Future audit:

```bash
cd Luminous
rg "MaterialPageRoute|Navigator\\.push|Navigator\\.of\\(context\\)\\.push" lib
```

### ERR-FE-006: 未注册路由与死路由常量

Area: frontend / routing

What went wrong: `/profile-settings` 曾定义但未注册 GoRoute，`legalDocuments` route 常量成为死代码。

Evidence: `Luminous/docs/MigrationLog_Archive_PreReset.md` "技术债归档"。

Current status: 已注册相关 GoRoute 并删除死常量。

Future audit: 路由新增时同步测试入口点击和直接 route path。

### ERR-FE-007: 动态列表使用 `ListView(children: [...])`

Area: frontend / performance

What went wrong: 多处动态列表一次性构建全部 children。

Evidence: `Luminous/docs/MigrationLog_Archive_PreReset.md` "ListView 性能优化"。

Current status: 已迁移 3 处动态列表；固定少量子项保留。

Future audit: 动态或不可预知 itemCount 用 `ListView.builder` / sliver builder。

### ERR-FE-008: 静默吞异常

Area: frontend / observability

What went wrong: 5 处 `catch (_) {}` 静默吞错，调试困难。

Evidence: `Luminous/docs/MigrationLog_Archive_PreReset.md` "错误处理加固"。

Current status: 已改为带模块标签的 `debugPrint`。

Future audit:

```bash
cd Luminous
rg "catch \\(_\\) \\{\\}" lib
```

### ERR-FE-009: 硬编码 Toast / 可见文本绕过 l10n

Area: frontend / localization

What went wrong: 有 Toast 文案和 AI 卡片中文文案硬编码。

Evidence: `Luminous/docs/MigrationLog_Archive_PreReset.md` "国际化 + 安全审查"；`Luminous/docs/Localization.md`。

Current status: 部分 Toast 已修；AI 解析逻辑层中文硬编码曾记录为设计级待改。

Future audit: 新可见文本必须写 ARB，运行 `flutter gen-l10n`。

### ERR-FE-010: 若干旧 feature 缺少专属测试

Area: frontend / tests

What went wrong: 重置前 `drug/`、`legal/`、`medicine_picker/` 等缺少专属测试。

Evidence: `Luminous/docs/MigrationLog_Archive_PreReset.md` 审计发现。

Current status: 重置后旧 feature 不再是当前主线；新 feature 已逐步补 widget tests。

Future audit: 新页面/路由/写流程必须带 widget tests。

### ERR-FE-011: OpenAPI generator 重置 generated package constraints

Area: frontend / OpenAPI

What went wrong: 再生 `packages/lucent_openapi` 后，generated `pubspec.yaml` SDK / `json_annotation` constraints 被工具改回不兼容值。

Evidence: `Luminous/docs/MigrationLog.md` "Stable Lucent OpenAPI Regeneration Command"；`Luminous/docs/OpenApi_Client.md`。

Current status: `tool/regenerate_lucent_openapi.dart` 已统一修复 constraints、serializer、nullable map entries。

Future audit: 只用 wrapper。

### ERR-FE-012: Generated write DTO 泄漏到 domain/presentation

Area: frontend / architecture / OpenAPI

What went wrong: health-context 写操作直接把 generated OpenAPI DTO 暴露给 repository interface 和 Mine/Search UI。

Evidence: `Luminous/docs/MigrationLog.md` "Post-Audit Health Context Write Boundary Fix"；commit `a13408d`。

Current status: 已新增本地 domain write inputs/enums。

Future audit:

```bash
cd Luminous
rg "lucent_openapi" lib/features/mine lib/features/health_context/domain lib/features/search/presentation
```

### ERR-FE-013: Generated DTO `includeIfNull: false` 吞掉显式 null 清空

Area: frontend / OpenAPI / data correctness

What went wrong: Flutter 写 health-context 时，使用 generated DTO 会丢掉 explicit `null`，导致用户无法清空 nullable 字段。

Evidence: `Luminous/docs/MigrationLog.md` "Post-Audit Health Context Write Boundary Fix"。

Current status: `HealthContextRemoteDataSource` 写操作改为 raw Dio JSON map，保留 null。

Future audit: 新写 API 增加 payload helper tests，验证 `null` 真正出现在 body。

### ERR-FE-014: Search add-to-current-medicines 缺少 auth 分支和完整 invalidation

Area: frontend / search / health context

What went wrong: Search 添加当前用药早期只关注写入调用，没有完整处理 signed-out 路由和 medicine workspace 刷新。

Evidence: `Luminous/docs/MigrationLog.md` "Post-Audit Health Context Write Boundary Fix"。

Current status: signed-out 跳 `/login`；signed-in 写入后 invalidate health-context 与 medicine workspace。

Future audit: 所有 signed-in 写操作都要测 signed-out branch + affected providers。

### ERR-FE-015: Mine profile cards 停留在 toast，没有路由到真实编辑页

Area: frontend / mine / routing

What went wrong: Mine dashboard profile card 点击早期只是 toast，不能进入已创建的 edit flows。

Evidence: `Luminous/docs/MigrationLog.md` "Post-Audit Health Context Write Boundary Fix"。

Current status: 基础资料、过敏、疾病、当前用药入口已路由到真实 edit flows。

Future audit: UI 上出现可点击入口时，widget test 证明 route 或 action 真实发生。

### ERR-FE-016: PageScaffoldShell 缺 Material surface，Mine edit pages 嵌套无界 ListView

Area: frontend / UI layout

What went wrong:

- shell 只用 DecoratedBox，缺 Material surface。
- edit pages 在 `SingleChildScrollView` children 内嵌套 vertical `ListView`，产生 unbounded viewport 风险。

Evidence: `Luminous/docs/MigrationLog.md` "Post-Audit Health Context Write Boundary Fix"。

Current status: shell 改为 Material；edit pages 改为 `Padding + Column`。

Future audit: 页面在 scrollable shell 中不要再放无界 scrollable。

### ERR-FE-017: Mine signed-out 状态反复打 protected health-context API

Area: frontend / auth / mine

What went wrong: signed-out 时 Mine 进入 loading/fetch protected API，而不是稳定未登录视图。

Evidence: `Luminous/docs/MigrationLog.md` 2026-06-01 "Mine - Signed-Out Static View"。

Current status: signed-out 返回本地 static dashboard + login notice。

Future audit: protected repository/provider 先看 auth state。

### ERR-FE-018: Mine settings residue 留在 dashboard 数据里

Area: frontend / mine / settings

What went wrong: Settings 已迁到 standalone `/settings`，Mine data 仍保留旧 settings payload，可能被误渲染。

Evidence: `Luminous/docs/MigrationLog.md` 2026-06-02 "Mine Settings Residue Cleanup"。

Current status: 已清除 leftover mock/Lucent settings arrays。

Future audit: 页面职责迁移后删除旧数据模型字段和 mock 残留。

### ERR-FE-019: Notification settings row tap 与 nested switch 双触发

Area: frontend / settings / UI interaction

What went wrong: 行点击和 Switch 手势嵌套导致一次操作可能触发两次。

Evidence: `Luminous/docs/MigrationLog.md` 2026-06-02 "Settings/API Wiring Cleanup"。

Current status: 已收紧 widget behavior。

Future audit: 可点击行内含 switch/checkbox 时，widget test 覆盖一次点击只切换一次。

### ERR-FE-020: 页面错误视图不统一且 Mine error 不居中

Area: frontend / UI state

What went wrong: 多页面手写 ErrorView，Mine 错误状态不居中。

Evidence: `Luminous/docs/MigrationLog.md` "统一页面错误视图 + 修复居中"。

Current status: 统一用 `AppStateErrorView`。

Future audit: 新页面 error state 不手写；用 `AppStateErrorView`。

### ERR-FE-021: Loading 状态不统一

Area: frontend / UI state

What went wrong: 有页面使用 `CircularProgressIndicator` 或纯色块，体验不一致。

Evidence: `Luminous/docs/MigrationLog.md` "统一页面骨架屏"；`Luminous/AGENTS.md` Guardrails。

Current status: loading states 统一 shimmer skeleton。

Future audit: 新页面 loading 用 `AppStateSkeletonView` 或局部 shimmer skeleton。

### ERR-FE-022: Search 页面早期只是冻结 mock dashboard

Area: frontend / search

What went wrong: Search 输入、source switch、result selection 早期只是静态/mock/toast，未驱动真实 query/source/result state。

Evidence: `Luminous/docs/MigrationLog.md` "Search - Lucent-Backed Medicine Search"。

Current status: 已改为 Lucent-backed search/detail repository + Notifier state。

Future audit: 搜索类页面测试输入、切 source、选择结果、错误/加载。

### ERR-FE-023: Generated OpenAPI `secure` metadata 为空导致 token injection 不可靠

Area: frontend / network / auth

What went wrong: Flutter generated client 的 secure metadata 为空时，token 注入路径不能依赖 generated 标记。

Evidence: `Luminous/docs/MigrationLog.md` "Auth Contract Sync"。

Current status: Lucent token injection 改为使用 stored access token。

Future audit: auth-protected API 调用需要 e2e/widget/repository 测实际 Authorization header 或 mock dio call。

### ERR-FE-024: Frontend ChangeEmailDto 与后端删除 `currentEmail` 后不同步

Area: frontend / auth / OpenAPI

What went wrong: 后端 change-email contract 变更后，Flutter DTO/调用需要移除 `currentEmail`。

Evidence: `Luminous/docs/MigrationLog.md` "Auth Contract Sync"。

Current status: 已再生 client，`ChangeEmailDto` 只发送 `newEmail` 和 `code`。

Future audit: Auth contract 改动后同步 OpenAPI client 和 widget tests。

### ERR-FE-025: App startup 未 restore session，Mine logout 没有真实接线

Area: frontend / auth / app startup

What went wrong: 持久化 session 无法在 app 启动自动恢复；Mine logout 入口早期未调用真实 logout。

Evidence: `Luminous/docs/MigrationLog.md` 2026-06-02 "Auth Startup Restore + Mine Logout Wiring"。

Current status: `LuminousApp` 启动 restore；Mine logout 调用 auth provider 并路由 `/login`。

Future audit: app-level auth changes 需测试 startup restore 和 logout path。

### ERR-FE-026: 过度解释性/营销式页面文案进入普通 app 页面

Area: frontend / UX / localization

What went wrong: Auth/Settings 等普通流程里出现不必要的 narrative、badge、description、hero-style 文案。

Evidence: `Luminous/docs/MigrationLog.md` 2026-06-02 "Auth Page Copy Cleanup"、"Settings Page Cleanup"；`Luminous/AGENTS.md` Guardrails。

Current status: 已收紧普通页面 copy 规则。

Future audit: 普通 app 页面只保留必要标题、标签、值、状态、动作。

### ERR-FE-027: Medicine/Today 静态 mock 容易被误认为真实计划或建议

Area: frontend / product boundary

What went wrong: Medicine 和 Today 视觉完整，但后端只支持一小部分真实数据，容易把 mock/refill/reminder/advice 展示得像真实能力。

Evidence: `Luminous/docs/superpowers/plans/2026-06-03-fifteen-day-lumos-delivery-plan.md` Task 9/10；`Luminous/docs/MigrationLog.md` Today/Meditation real-data notes。

Current status: Medicine/Today 只接入 safe health-context current-medicine subset；unsupported sections 保持 static/mock 边界。

Future audit: 新真实数据接入时更新 UI plan，列出仍 mock 的面板。

### ERR-FE-028: 文档里的文件名/当前状态漂移

Area: docs / frontend

What went wrong: Mine edit flow 文档曾写 `profile_edit_page.dart` 等文件名，而实际文件已是 `profile_edit.dart` 等。

Evidence: 2026-06-03 docs plan commit 前修正。

Current status: `MigrationLog.md` 已对齐实际文件名。

Future audit: 文档中出现具体文件名时，用 `Test-Path` / `rg --files` 验证。

### ERR-FE-029: Medicine skipped dose log 被重新显示为 pending

Area: frontend / medicine / today consistency

What went wrong: Medicine 写入 `skipped` dose log 后，Today 已把 `taken` 和 `skipped` 都算作已处理，但 Medicine workspace 重新读取 dose logs 时只识别 `taken`，导致跳过后又显示成 `pending`。

Evidence: 2026-06-04 post-audit fix during DeepSeek follow-up review.

Current status: Medicine 状态模型已补 `taken / skipped / pending` 三态，Lucent-backed workspace 按当天 dose log 的最新状态映射为对应 label，并新增 skipped regression。

Future audit: 任何跨页共享状态必须统一状态枚举和完成口径；新增 dose-log 状态时同时检查 Medicine、Today、repository tests 和 ARB。

### ERR-FE-030: OpenAPI generator 生成 Markdown 尾随空格

Area: frontend / generated client / docs hygiene

What went wrong: `dart run tool/regenerate_lucent_openapi.dart` 生成的新 DTO Markdown 中保留表格行尾空格和多余 EOF 空行，导致 `git diff --check` 在提交前失败。

Evidence: 2026-06-04 Luminous dose-log client regeneration; affected files included `packages/lucent_openapi/doc/DoseLogItemDto.md`, `DoseLogListDataDto.md`, `DoseLogListResponseDto.md`, and `DoseLogResponseDto.md`.

Current status: 已清理本次生成文档的尾随空格，并在提交前重新运行 `git diff --check`。

Future audit: OpenAPI client 再生后必须运行 `git -C Luminous diff --check`；如果只影响生成 Markdown 空白，可机械清理后再提交，不要跳过检查。

### ERR-FE-031: 写操作漏刷新跨页依赖 provider

Area: frontend / Riverpod / cross-feature state

What went wrong: Record quick-create 保存后只刷新 Record 自己，Today 仍可能显示旧 daily-record summary；Medicine taken/skipped 写入也必须同时刷新 Medicine workspace 和 Today。单页测试容易通过，但跨页状态会陈旧。

Evidence: 2026-06-04 Codex post-audit fix in Luminous commit `f6237a1 fix(medicine): 修复用药打卡与今日状态联动`。

Current status: Record save 已刷新 Record + Today；Medicine taken/skipped 已刷新 Medicine + Today，并补 skipped regression。

Future audit: 每个 signed-in 写操作必须列出 affected providers，并用 widget/repository/provider test 证明至少一个依赖页会刷新。重点搜索：

```bash
cd Luminous
rg "invalidate\(" lib/features
rg "todayDashboardProvider|recordDashboardProvider|medicineWorkspaceProvider" lib test
```

### ERR-FE-032: generated OpenAPI 类型名和本地域名类型冲突

Area: frontend / tests / generated client

What went wrong: 再生 dose-log client 后，测试文件同时看见 generated `DoseLogStatus` 和本地域名状态类型，导致 import ambiguity。生成物扩展越多，类型名和本地 domain 名越容易相撞。

Evidence: 2026-06-04 `test/medicine_workspace_repository_test.dart` 曾因 ambiguous `DoseLogStatus` import 失败；最终通过限制 `lucent_openapi` import 为 `show MedicineDoseLogsApi` 修复。

Current status: 相关测试 import 已收窄，根项目 `flutter analyze` 和 `flutter test` 通过。

Future audit: 测试和 data layer 引入 `lucent_openapi` 时优先用 `show`/prefix；domain/presentation 禁止直接导入 generated DTO。检查：

```bash
cd Luminous
rg "package:lucent_openapi" lib test
rg "lucent_openapi" lib/features/*/domain lib/features/*/presentation
```

## Cross-Repo Contract And Process Errors

### ERR-XR-001: Lucent/Luminous 当前仓库边界容易混淆

Area: process / repo layout

What went wrong: workspace root 不是 git repo，`Lucent` 和 `Luminous` 是两个独立仓库；历史上还有 `Luminous/backend` legacy。

Evidence: superpowers plans；`Lucent/AGENTS.md`；`Luminous/AGENTS.md`。

Current status: 计划文档已明确 repository layout。

Future audit:

```bash
git -C Lucent status --short
git -C Luminous status --short
```

不要在 `Luminous/backend` 新增功能。

### ERR-XR-002: 文档入口和当前状态文档多次漂移

Area: docs / process

What went wrong: README、MigrationLog、RefactorPlan、ExecutionPlan、RestartPlan、CHANGELOG 等历史文档有过当前/归档边界不清。

Evidence: `Lucent/CHANGELOG.md` 2026-05-30 "文档边界重整"；`Luminous/docs/README.md`。

Current status: 两个仓库都有 docs README 和 reference-only 标记。

Future audit: 行为变更时更新 owner document，不在 README/AGENTS 之间重复大段内容。

### ERR-XR-003: DeepSeek 执行计划需要可审查 evidence bundle

Area: process / multi-agent

What went wrong: 如果执行者只报告 "done"，Codex 难以确认命令、diff、docs、生成物和边界条件是否真实完成。

Evidence: `Luminous/docs/superpowers/plans/2026-06-03-fifteen-day-lumos-delivery-plan.md`；`2026-06-03-fifteen-day-lumos-followup-plan.md`。

Current status: 后续计划要求每个 task 返回固定 evidence bundle。

Future audit: 没有 command results 和 touched files 的任务不接受。

### ERR-XR-004: 当前日期和历史日期容易混用

Area: docs / planning

What went wrong: 计划、日志、审计跨 2026-05-26 到 2026-06-04，历史状态和当前状态容易混淆。

Evidence: 多份 docs/changelog 包含历史条目和 reference-only 提示。

Current status: 新文档应写 `Last updated`，历史条目保留当时语境。

Future audit: 使用绝对日期，不用 "今天/昨天" 写长期文档。

### ERR-XR-005: active branch baseline 没有先验明

Area: process / git / cross-repo review

What went wrong: DeepSeek 的完成摘要以任务状态和 commit 列表为主，但没有先证明当前工作树所在 branch、最新 commit、OpenAPI paths/schemas、数据库 migration 状态都匹配执行结果。结果 Codex 复审时发现 `Lucent/dev` active branch 仍需要恢复 health-context write surface 和 dose-log contract bundle。

Evidence: 2026-06-04 Codex review/fix cycle; Lucent final commit `038f225` and Luminous final commit `f6237a1`。

Current status: 两仓已回到 clean state；Lucent `dev` ahead 7，Luminous `refactor` ahead 10。

Future audit: 任何 DeepSeek 任务开始和结束都必须输出：

```bash
git -C Lucent branch --show-current
git -C Lucent status --short --branch
git -C Lucent log -1 --oneline
git -C Luminous branch --show-current
git -C Luminous status --short --branch
git -C Luminous log -1 --oneline
```

涉及 API 时还要输出 OpenAPI paths/schemas 数量和新增/删除 path 摘要。

## Open Or Watch Items

这些不是都未修复，但属于未来最容易复发的核查点：

- Record 已接入 Lucent daily records 和 quick-create，但 trend panels / richer record types 仍不能说成真实分析能力。
- More 仍主要是 mock-oriented，接真实 API 前要先定义 Lucent schema/contract。
- Today 已接入 health-context current-medicine subset 和 daily-record water/vital summaries；meal/environment/Lumi 等仍不要说成真实建议。
- Medicine 已接入 manual dose-log status；这不是 reminder scheduling，不代表推送通知、日历提醒或自动依从性计划已实现。
- OCR / barcode / push notification / wearable sync 都没有真实后端执行能力。
- 新增跨端数据能力仍必须先做 Lucent schema + API + OpenAPI，再接 Luminous。
- Flutter UI 调整要同时检查 mobile / desktop 文本溢出和滚动布局。

## Standard Verification Bundles

### Backend Full Regression

```bash
cd Lucent
pnpm dev:stack:up
pnpm db:migrate:all
pnpm exec prisma validate
pnpm lint:check
pnpm build
pnpm test:ci
pnpm test:e2e:ci
pnpm export:openapi
```

### Frontend Full Regression

```bash
cd Luminous
flutter analyze
flutter test
```

### Cross-Repo Contract Regression

```bash
cd Lucent
pnpm export:openapi
cd ../Luminous
dart run tool/regenerate_lucent_openapi.dart
flutter analyze
flutter test
```

### Fast Review Commands

```bash
git -C Lucent status --short
git -C Luminous status --short
git -C Lucent diff --check
git -C Luminous diff --check
rg "lucent_openapi" Luminous/lib/features/mine Luminous/lib/features/health_context/domain Luminous/lib/features/search/presentation
rg "MaterialPageRoute|Navigator\\.push|Navigator\\.of\\(context\\)\\.push" Luminous/lib
rg "catch \\(_\\) \\{\\}" Luminous/lib
```
