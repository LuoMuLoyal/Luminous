# Luminous

Luminous 正在从移动端智慧用药助手演进为个人健康管理副驾驶（Personal Health Copilot），当前提供药品识别、药品信息查询、提醒与历史回看能力，下一阶段会以 Lucent 后端、服务端药品知识库、Markdown 长文展示和 AI 健康副驾驶能力作为核心方向。

本仓库为 Flutter App。目标后端已通过 `Lucent/` Git submodule 指向 [LuoMuLoyal/Lucent](https://github.com/LuoMuLoyal/Lucent)。旧 Express `backend/` 仅保留为低优先级参考和当前线上 `https://devluo.com` 旧服务的临时联调依据；新的后端能力不要继续写进旧 `backend/`。

## Features

- 药品搜索与药品详情
- 拍照识别与候选回查
- 数据库驱动的药品说明书展示
- Markdown 药品详情与 AI 输出展示（规划中）
- AI 安全辅助、报告解读与健康副驾驶（规划中）
- 今日提醒与本地打卡
- 识别相册与结果沉淀
- 多主题与深浅色模式

## Tech Stack

- App: Flutter (Dart)
- Backend (legacy reference): Node.js + TypeScript + Express
- Backend (target): Lucent, NestJS + PostgreSQL + Prisma + Redis + Passport JWT
- Auth: JWT (Access Token + Refresh Token)
- Data (legacy reference): MongoDB (用户) + MySQL (旧药品库) + Redis（部分缓存/验证码）
- Data (target): PostgreSQL（主存储与药品知识库），Redis（验证码、冷却、短期缓存），Prisma（schema/migration/import）
- Knowledge Data (target external source): `D:\25080\Documents\VSCodeProject\Lumos\DrugDataBase`
- AI: LangChain / OpenAI-compatible gateway

## Repository Structure

```text
Luminous/
  lib/                Flutter 主代码
  test/               Flutter 测试
  Lucent/             目标 NestJS 后端 Git submodule
  backend/            旧 Express 后端，仅低优先级参考
  docs/               架构计划、迁移记录与长文档
  android/ios/...     平台工程
```

迁移期目录约束见 [AGENTS.md](AGENTS.md) 和 [docs/README.md](docs/README.md)。

当前迁移基线与执行记录：

- [docs/RefactorPlan.md](docs/RefactorPlan.md)
- [docs/knowledge-data-platform-plan.md](docs/knowledge-data-platform-plan.md)
- [docs/migration_log.md](docs/migration_log.md)

## Quick Start

### Run Flutter App

首次克隆后先同步后端 submodule：

```bash
git submodule update --init --recursive
```

```bash
flutter pub get
flutter run
```

```bash
flutter analyze
flutter test
```

### Run Legacy Express Backend

```bash
cd backend
npm install
npm run dev
```

Health Check:

- `GET http://127.0.0.1:8787/health`

该服务是旧联调基线，不是新功能的落点。`https://devluo.com` 目前也指向旧 Express 服务，可用于验证现有 Flutter 流程。

### Run Target Lucent Backend

```bash
cd Lucent
pnpm install
pnpm start:dev
```

Lucent 是目标后端项目。新的 API 协议从 `/api/v1` 开始设计，不要求兼容旧 Express 的 `/api/*` 请求体或 `{ code, msg, result }` envelope。协议细节见 [Lucent/docs/api-contract.md](Lucent/docs/api-contract.md)。

### Run With Docker Compose

在项目根目录执行：

```bash
docker compose up -d --build
```

默认会启动以下服务：

- `backend`（旧 Express 服务，8787）
- `mongodb`（当前用户数据，27017）
- `redis`（当前缓存/验证码，6379）
- `mysql`（当前药品库，3306）

当前 compose 仍服务于旧 Express 联调。Lucent/PostgreSQL 的 compose 方案以后端迁移计划为准。

停止服务：

```bash
docker compose down
```

## Configuration

### Flutter Base URL

- File: `lib/constants/constants.dart`（兼容 barrel；新代码优先使用拆分后的 core/shared 常量入口）
- Key: `GlobalConstants.BASE_URL`

当前默认值是 `https://devluo.com`，即已上线的旧 Express 后端。新的 Lucent 联调请通过 `--dart-define=API_BASE_URL=...` 覆盖，不要把新协议绑定到旧默认值。

常见本地开发取值：

- Android 模拟器: `http://10.0.2.2:8787`
- 真机: `http://<LAN-IP>:8787`

### Backend Environment

- Legacy Express files: `backend/.env.development` and `backend/.env.production`
- Legacy loader: `backend/src/config/env.ts`
- Lucent files: follow `Lucent/.env.development` and `Lucent/.env.production` conventions as the target backend grows.

不要提交真实环境文件。旧 Express 配置只用于线上旧服务和临时联调；Lucent 配置以后端迁移计划为准。

## Documentation

- Backend API: [docs/lib-docs/backend-api.md](docs/lib-docs/backend-api.md)
- Target Backend: [Lucent/README.md](Lucent/README.md)
- Lucent API Contract: [Lucent/docs/api-contract.md](Lucent/docs/api-contract.md)
- Lucent Data Sources: [Lucent/docs/data-sources.md](Lucent/docs/data-sources.md)
- Legacy Backend Reference: [backend/README.md](backend/README.md)
- Migration Plan: [docs/RefactorPlan.md](docs/RefactorPlan.md)
- Knowledge Data Platform: [docs/knowledge-data-platform-plan.md](docs/knowledge-data-platform-plan.md)
- Migration Log: [docs/migration_log.md](docs/migration_log.md)

## Troubleshooting

### Backend port 8787 already in use

如果本地执行 `npm run dev` 报 `EADDRINUSE: 8787`，通常是另一个 Node 进程还在运行（常见于此前的 `tsx watch` 终端未关闭）。

PowerShell 排查命令：

```powershell
Get-NetTCPConnection -LocalPort 8787 -State Listen | Select-Object OwningProcess
Get-CimInstance Win32_Process -Filter "ProcessId = <PID>" | Select-Object Name,CommandLine
```

确认后可结束占用进程：

```powershell
Stop-Process -Id <PID> -Force
```

## Contributing

欢迎提交 Issue 与 Pull Request。

建议流程：

1. Fork 并创建功能分支。
2. 提交前执行 `flutter analyze`、`flutter test` 与后端构建检查。
3. 在 PR 中附上修改说明与验证方式。

## License

本项目基于 [Apache License 2.0](LICENSE) 许可开源。详情请参阅源代码中的 `LICENSE` 文件。
