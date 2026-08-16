# 工程与后端平台 功能盘点与审计

> 范围：`Lucent/src/admin/`、`Lucent/src/mail/`、`Lucent/src/modules/files/`、`Lucent/src/llm-runtime/`、`Lucent/src/common/queue/`、`Lucent/src/common/metrics/`、`Lucent/src/modules/product-events/`、`Lucent/src/modules/testing-support/`、`Lucent/deploy/`；参考 `Lucent/plans/`（2026-08-14-saas-modules-and-node-monorepo、2026-07-24-worker-separation-and-cron-repeatable、2026-08-02-rnacos-runtime-config-tuning）、`Luminous/plans/`（2026-08-14-flutter-3.47-upgrade-plan、2026-08-14-product-surface-route）、`Lucent/docs/00-current/TODO.md`、`Lucent/docs/01-reference/architecture.md`。客户端证据取自 `Luminous/lib/core/analytics/` 与 record 特性上传链路。
>
> 评估基准：`Luminous/docs/01-product/Product_Vision.md` —— 手机端是当前首发与验证表面，最小伙伴闭环由低负担输入、个人上下文、Today、纵向洞察、上下文 AI 与反馈学习共同组成；桌面/Web 方向待研究。平台/工程能力按"它对 C 端真实用户的支撑作用"与"投入是否与单产品 0.1.0 前阶段匹配"两条线审判。

## 逐功能分析

### F-1 BullMQ 队列底座（`src/common/queue/`）

- 现状：`BullmqQueueFactory` 统一创建 Queue+Worker 对、统一错误处理、30s 轮询队列深度上报 Prometheus、SIGTERM 优雅停机；`BaseAsyncQueueService` 为 6 条异步业务队列提供 enqueue/poll/cache 生命周期。共 9 条队列（邮件、餐食分析、数据导出、药品识别、今日分析、建议解释、建议文案、报告总结、就诊 PDF）。
- 实际作用：Today 建议卡、餐食识别、就诊 PDF 全部是 LLM/PDF 慢任务——没有异步队列，这些核心产物会直接把 HTTP 请求挂死。这是核心产品链路的承重墙。
- 实现真实性：真实现。`queue.factory.ts:82-158`；Redis 未配置时返回双 null 让调用方同步执行（`queue.factory.ts:88-93`），Redis 断连时 enqueue 失败回退同步处理（`mail-queue.service.ts:39-57`）——降级路径是明示的、有日志的，不是伪装成"已排队"。
- 结论：保留。
- 改造方案：无（保留项）。小问题：`architecture.md:393` 仍写 "7 + 1 mail" 队列与 concurrency=1 的旧表，与实际 9 条不一致，文档需同步。
- 优先级：P0

### F-2 Cron Repeatable Jobs（`src/common/queue/cron-jobs.service.ts`）

- 现状：`upsertJobScheduler` 注册三类调度：用药提醒派发（每分钟）、建议生命周期刷新（每 5 分钟）、数据保留清理（每日）；调度规则存 Redis，重启不丢。
- 实际作用：提醒派发是用药安全闭环的"主动"半边——到点未确认时催用户核对，这是产品主张第三条（"在合适时间主动提醒"）的执行器。数据保留清理承载 90 天事件删除等隐私承诺。
- 实现真实性：真实现。`cron-jobs.service.ts:53-80`；Redis 缺失时显式记日志禁用（`cron-jobs.service.ts:54-57`）。高频提醒独占队列防止慢任务阻塞低频任务，设计克制。
- 结论：保留。
- 改造方案：无。
- 优先级：P0

### F-3 LLM Runtime（`src/llm-runtime/`）

- 现状：按角色（analysis/vision/language/chat/chatCompression/embedding）创建 LangChain 模型实例，含 DeepSeek/阿里 qwen3 的 provider quirks。
- 实际作用：全部 AI 产物（建议卡解释、餐食识别、药品识别、报告总结、Assistant 对话）的模型入口。角色分离让不同任务可用不同价位/能力的模型——直接关系到单用户 LLM 成本。
- 实现真实性：真实现，且有一个值得称道的反假实现细节：`requireChatModel()` 对未配置角色直接抛 503（`llm-runtime.service.ts:114-132`），而不是拿空凭据创建一个必败的模型伪装可用——与"证据不足明确弃权"的产品语义一致。
- 结论：保留。
- 改造方案：无。提示词/温度等调参通道见 F-12 的评审结论。
- 优先级：P0

### F-4 邮件服务（`src/mail/`）

- 现状：nodemailer SMTP 传输 + BullMQ 队列 + 队列失败时同步发送兜底；`log` driver 仅开发态打印。主要消费者是 auth 的邮箱验证码链路（注册/改邮箱）。
- 实际作用：账号体系的邮箱验证依赖它。真实但窄：C 端以微信登录为主路径时，邮件只服务邮箱账号这一支。
- 实现真实性：真实现。`mail-transport.service.ts:29-48` 的 log driver 是明示开发降级，不是生产伪装。
- 结论：保留。
- 改造方案：无。模板目前只有验证码一类（`templates.ts`），够用，不需要提前建模板体系。
- 优先级：P1

### F-5 文件上传（`src/modules/files/`）

- 现状：单端点 `POST /user/files/upload`，校验 content-type 白名单与大小上限后签发 COS 预签名 PUT URL，客户端直传。
- 实际作用：餐食拍照识别与记录附件图片的入口——餐食识别是稀疏记录语义下"低负担记录"的重要输入方式。
- 实现真实性：真实现。`files.service.ts:21-57`；客户端 record 特性（`quick_entry_meal.dart`、`pending_image.dart` 等）真实消费 `api_paths.dart:31` 的该端点。
- 结论：保留。
- 改造方案：无。
- 优先级：P1

### F-6 可观测性栈（`src/common/metrics/` + `deploy/prometheus|grafana|alertmanager`）

- 现状：`MetricsService` 集中注册 HTTP 延迟、BullMQ 深度与成败、LLM 耗时与 token、建议重算/物化、埋点发射失败等指标；`setup-app.ts:158` 的中间件记录请求指标；deploy 一套 compose 起 prometheus/grafana/alertmanager/三个 exporter；另有 OTel 分布式追踪（`src/tracing.ts`）。
- 实际作用：LLM 成本与队列积压是这款产品最真实的两类运营风险（token 费用、建议卡生成失败），这两类指标直接对着它们——这部分价值真实。Grafana 看板/Alertmanager/OTel 则主要服务运维者自身。
- 实现真实性：真实现。`metrics.service.ts:63-345`。两处文档漂移：`architecture.md:370-373` 说存在 `metrics.middleware.ts` 文件，实际中间件内联在 `setup-app.ts`。
- 结论：保留（精简）。
- 改造方案：保留 MetricsService 与 /metrics 端点不动；Grafana 看板与 Alertmanager 规则在 0.1.0 前按"最低可跑"维护,OTel 保持 `OTEL_ENABLED` 默认关闭。原则：先有的栈继续跑
- 优先级：P1

### F-7 产品事件埋点（`src/modules/product-events/` + `Luminous/lib/core/analytics/`）

- 现状：客户端 `ProductEventService` 在真实成功边界打点（建议卡曝光按会话+规则码去重、回顾打开按会话去重），失败落本地 pending-sync 队列稍后重放，同一 clientEventId 幂等；服务端另有权威事件发射器（健康事件开始/结束、建议动作、分享打开），fire-and-forget 且失败只记脱敏日志。
- 实际作用：这批数据能回答事件领域的“开始→建议→结束→回顾”路径是否发生，但不能验证长期健康伙伴的核心假设。现有事件埋点可保留；后续还需以同样克制的方式测量非生病周价值、上下文回答、建议反馈和授权变化。隐私设计（枚举-only、无自由文本、90 天删除）与健康数据产品的合规姿态一致。
- 实现真实性：真实现。客户端 `product_event_service.dart:135-182`，服务端 `events.service.ts:84-176`；服务端发射器被 health-events、reports/clinic-summary、today-suggestion 五个真实业务点调用。补记是完整链路（离线→重放→幂等去重），不是"点击即成功"的假象。
- 结论：保留。
- 改造方案：无。注意它的价值兑现依赖 F-8 有人看。
- 优先级：P1

### F-10 testing-support（`src/modules/testing-support/`）

- 现状：`POST /testing/fullstack-e2e/record-lane/prepare`：造/重置测试用户、清指定日期记录、重置设置、清会话。模块只在 `NODE_ENV === 'test'` 时注册（`app.module.ts:117`），另有共享密钥守卫 + timingSafeEqual（`testing-shared-secret.guard.ts:29-56`）。
- 实际作用：全栈 E2E 的夹具基础设施，直接服务发布门禁。双重隔离（环境门 + 密钥门）做得干净，Swagger 也排除（`@ApiExcludeController`）。
- 实现真实性：真实现。注释里"should always be used alongside JwtAuthGuard"与实际 `@Public()` 用法不符（`testing-support.controller.ts:18-19`），属注释陈旧，不影响安全模型（环境门才是真边界）。
- 结论：保留。
- 改造方案：无（删那句陈旧注释即可）。
- 优先级：P2

### F-11 Worker 进程分离（plans/2026-07-24-worker-separation-and-cron-repeatable.md）

- 现状（按计划评估）：同镜像 + `WORKER_MODE` 环境变量拆分 api/worker 进程，worker 带 /healthz+/metrics 探针，compose 加独立 worker 容器与资源限额。
- 实际作用：防止 CPU 密集的 PDF/LLM 任务拖慢 API 响应。这是真实的工程收益，但它解决的问题（队列高峰拖慢 HTTP）在当前阶段不存在——0.1.0 前单机量级，9 条队列并发均为 1-3，event loop 竞争不是已观测的痛点。
- 实现真实性：真实现（按既定规则评估其能力的真实性：设计本身向后兼容、有优雅停机与回滚路径，无伪装成分）。
- 结论：暂缓启用 = 不排期、代码保留。
- 改造方案：保持默认兼容模式运行；把"何时启用"绑定到一个可观测触发条件（Grafana 里 `bullmq_waiting_jobs` 持续非零或 p95 HTTP 延迟与队列高峰相关），而不是按时间表启用。启用前不必再投入。
- 优先级：P2

### F-12 rnacos 动态运行时配置（plans/2026-08-02-rnacos-runtime-config-tuning.md）

- 现状（按计划评估）：引入配置中心热调餐食识别 temperature/阈值、队列并发、缓存 TTL，Zod 校验 + 原子快照 + 失败保留上一份。
- 实际作用：要调的非敏感参数总共十几个，环境变量 + 重启的代价是几十秒——热更新通道省下的就是这个。计划自己写得克制（不碰密钥、缺字段不解释为 0、明确说"可动态调参≠识别质量提升"），但通道本身对单产品单环境阶段是典型投入错配：多一个 rnacos 服务要部署、持久化、鉴权、监控。餐食识别质量的真实瓶颈是固定标注图片集 + A/B 评测流程，不是改参数要不要重启。
- 实现真实性：真实现（设计文档层面的校验/回滚/脱敏规则均真实可执行）。
- 结论：暂缓 = 不排期、代码保留。
- 改造方案：降级为"环境变量 + 重启"。真正该先建的是餐食识别的离线评测集（标注图片 + 指标对比脚本）；当评测流程存在、且证明参数需要以天为粒度频繁调整时，再回来启用热配置。该计划第 431 行的自我声明（质量提升靠 A/B 而非调参通道）就是暂缓它的最好论据。
- 优先级：P2

### F-13 SaaS 模块（plans/2026-08-14-saas-modules-and-node-monorepo.md 第三节）

- 现状（按计划评估）：web 微信扫码 OAuth（工作台前置）、`GET /me/dashboard` 聚合 API、subscription/billing 延后到商业化、多租户明确不做、admin 复用现有模块。
- 实际作用：OAuth 与 dashboard 是桌面工作台（F-16）的前置依赖，本身不直接服务手机端用户。计划里两个判断是对的：多租户/角色不做（照护场景由可撤销分享覆盖），billing 只做契约不接真实支付。这两个"不做"比"做"更值钱。
- 实现真实性：真实现。
- 结论：暂缓 = 不排期、代码保留。
- 改造方案：维持"0.1.0 不阻塞"的排序不变——0.1.0 移动端验证完成前不动工。动工时只做 OAuth + 单页 dashboard 两件，subscription/billing 继续延后；合规评估（个保法/数据出境）在 SaaS 上线前启动，不提前花钱。
- 优先级：P2

### F-14 Node monorepo 合并（plans/2026-08-14-saas-modules-and-node-monorepo.md 第四节）

- 现状（按计划评估）：Lucent 为根收编 website/docs/saas 为 pnpm workspace，统一工具链与 CI，追求跨仓原子提交。
- 实际作用：原子提交的真实需求来自"后端合同 + 工作台 + 文档 + 官网一次改完"——但工作台尚不存在，website/docs 变更频率低，当前三分仓没有产生过实际协作摩擦的证据。合并的收益是结构性的、成本是即时的（迁移、CI 重排、文档门禁兼容、git 历史处理）。
- 实现真实性：真实现。
- 结论：暂缓 = 不排期、代码保留。
- 改造方案：按 F-16 的 Phase 0 只完成两件不可逆成本为零的事——给 Flutter 桌面/Web 打 freeze tag；其余合并排在"apps/saas 有第一行真实代码"之后，因为那时原子提交才从理论收益变成日常需求。先合并空壳是把搬家成本花在住户入住前。
- 优先级：P2

### F-15 Flutter 3.47 升级（Luminous/plans/2026-08-14-flutter-3.47-upgrade-plan.md）

- 现状（按计划评估）：SDK/AGP 9/Gradle 9/iOS 部署目标跟进，fluwx 6.x 等高风险依赖逐项验证，被上游语义层回归阻塞即等 3.47.1 而非硬闯。
- 实际作用：对 C 端用户无直接可见价值，价值是防升级债累积（SDK 停得越久，微信登录/推送/健康授权这类原生桥接的断裂风险越大）。计划本身的质量高：V/U 标注、回退预案、CI release APK 作 AGP 9 验证门禁，是工程纪律的正面样本。
- 实现真实性：真实现。
- 结论:保留（跟次版本，不抢首发）。
- 改造方案：把"升级策略"固化成惯例——stable 发布后不立即跟，等第一个 patch（本次被 flutter/flutter#191095 阻塞恰好验证了该策略）；暂缓清单（drift/flutter_local_notifications 等 breaking 依赖）维持独立排期，不混入 SDK 升级。
- 优先级：P2

### F-16 桌面 SaaS 差异化路线（待决策提案：ADR-0013；候选执行计划：plans/2026-08-14-product-surface-route.md；依据：docs/01-product/）

- 现状（按计划与最新产品决定评估）：手机端继续承担当前首发；未来 Web 初步考虑 Next.js，桌面初步考虑 Tauri 2 承载同一大屏体验，定位假设是"手机负责低负担记录，电脑负责查看和理解手机端难以看清的纵向信息"。这不是最终技术决策。
- 实际作用：Web 图表/表格生态与 Tauri 2 复用前端代码具有工程吸引力，但目标场景（趋势大屏、就诊资料整理、批量导入）尚无一手用户证据，不能写成已验证需求。它服务第二产品表面，对最小伙伴闭环的首轮验证不是前置条件。
- 实现真实性：真实现。
- 结论：保留方向、暂缓执行。
- 改造方案：保留方向但暂缓执行；不建 apps/saas 空壳，不重写现有 Flutter 桌面。先研究用户是否真的只为大屏纵向阅读打开桌面/Web，再验证认证、离线、隐私、同步和分发约束；Next.js + Tauri 2 只有在产品任务成立后才进入技术选型决策。
- 优先级：P1（方向决策本身），执行 P2
