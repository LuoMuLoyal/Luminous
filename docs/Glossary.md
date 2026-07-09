# Glossary

常用术语单一来源。

- **Lucent** — 活跃 NestJS 后端，Luminous 的 API 提供方。
- **Luminous** — 活跃 Flutter 客户端。
- **Luminous-site** — Nuxt 竞赛/产品展示站点，不做签入式产品壳。
- **Forui** — Flutter UI 库，项目当前根主题来源。参见 [[02-reference/Forui_Reference]]。
- **Riverpod** — Flutter 状态管理方案。参见 [[02-reference/architecture]]。
- **GoRouter** — Flutter 路由方案，使用 `StatefulShellRoute`。参见 [[02-reference/architecture]]。
- **OpenAPI Client** — 从 Lucent `openapi.json` 生成的 Dart 客户端。参见 [[02-reference/OpenApi_Client]]。
- **ADR** — Architecture Decision Record，见 [[02-reference/adr/README]]。
- **MVP** — Minimum Viable Product，当前 1.0 主闭环是 `记录 -> 主动建议卡 -> 用户确认动作 -> 回顾`。`Today`
  是主界面，`Report` 是回顾性视图，不是产品主轴。
- **Proactive Guidance Card（主动建议卡）** — Luminous 1.0 的核心产品对象。每张卡都必须包含
  `证据 -> 建议 -> 动作 -> 边界`，并且只在具备时效性和可干预性时进入 `Today` 首屏。
- **Proposal-Driven Execution（提案式执行）** — Assistant 可以生成可执行提案，但任何写操作都必须由用户显式批准后执行。
- **Observation Item（观察项）** — 证据不足、置信度较低或暂时不值得单独出卡的内容。观察项只能进入摘要或报告，不能进入 `Today`
  的待办或主卡区域。
- **Clinic Summary** — 后端脱敏的医生分享摘要，含 Redis 24h 分享链接与 PDF。
- **Security PIN** — Lucent 6 位应用内安全码，替代旧 TOTP 2FA。
- **AppColors** — 语义颜色枚举，数据/领域层使用，widget 处解析。
- **AppSpacingTokens** — 项目间距 token，`level1`–`level12`。
- **AppRadiusTokens** — 项目圆角 token，`level0`–`level9` 与 `levelFull`。
- **AppTypographyTokens** — 字体层级 token，`level1`–`level10` 映射到 Forui `FTypeface`。
- **NestJS** — Lucent 后端框架。
- **Prisma** — Lucent ORM 与 schema 工具。
- **AI Pipeline** — Lucent 三层 AI 架构：Context / Generation / Policy & Persistence。
- **Meal Analysis** — 餐食图片异步写入时分析管道。
- **Data Export** — 报告/摘要 PDF 导出请求，支持 BullMQ 异步与内联 fallback。
- **AdminJS** — Lucent `/admin` 管理面板，基于 Prisma schema 自动生成资源。
- **BullMQ** — Lucent 任务队列，用于邮件发送、报告导出等异步任务。
- **Talker** — `talker_flutter` 日志基础设施，替代 `debugPrint`，支持运行时级别过滤与 Release 静默。
- **Slot-aware Dose Log** — 用药打卡槽位合同：单条 dose log 携带 `reminderId` + `scheduledTime`，
  幂等 `POST /mark` 按提醒槽位标记，区分同一天内多个提醒。
