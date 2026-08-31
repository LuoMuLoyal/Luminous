---
status: active
owner: frontend
updated: 2026-08-31
---

# Glossary

工程与运行时术语单一来源。产品领域语言见 [`../product/Product_Vision.md`](../product/Product_Vision.md)。

- **Lucent** — 活跃 NestJS 后端，Luminous 的 API 提供方。
- **Luminous** — 活跃 Flutter 客户端。
- **Luminous-website** — Nuxt 竞赛/产品展示站点，不做签入式产品壳。
- **Forui** — Flutter UI 库，项目当前根主题来源。参见 [[Forui_Reference]]。
- **Riverpod** — Flutter 状态管理方案。参见 [[architecture]]。
- **GoRouter** — Flutter 路由方案，使用 `StatefulShellRoute`。参见 [[architecture]]。
- **OpenAPI Client** — 从 Lucent `openapi.json` 生成的 Dart 客户端。参见 [[OpenApi_Client]]。
- **ADR** — Architecture Decision Record，见 [[reference/adr/README]]。
- **P0–P3 优先级体系** — 跨项目产品优先级框架，定义于 [[Product_Brainstorm_2026-07-07]]（已归档）。P0 为发布前必做项，P1 为首发版本内，P2 为 1.1.0 候选，P3 为 1.2.0+ 候选。
- **Clinic Summary** — 当前后端对就诊摘要的实现名，含 Redis 24h 分享链接与 PDF；产品名称和边界见 [`../product/Product_Vision.md`](../product/Product_Vision.md)。
- **SemanticColor** — 二维语义颜色枚举（6 色 × 10 tone），数据/领域层使用，widget 处解析。
- **Spacing** — 项目间距 token，语义别名 `xs`/`sm`/`md`/`lg`/`xl`/`xl2`… 为主命名（`level1`–`level12` 为向后兼容别名）。
- **DurationTokens** — 动画时长 token，路由过渡 + widget 动画。
- **Breakpoints** — 响应式布局断点。
- **ResponsiveSizing** — 响应式尺寸 helper（卡宽 / sidebar 宽 / grid 列数）。
- **LayoutScale** / **LayoutScaleResolver** — 响应式布局刻度值对象 + 解析器。
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
