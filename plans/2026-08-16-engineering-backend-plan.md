# 工程与后端平台改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。

> 来源: `Luminous/research/02-功能盘点/engineering-工程与后端平台.md`(已审阅;内容以逐功能分析为准改写——该文档无速览表、无结尾汇总,逐功能分析即全部权威内容)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 10 位(最后执行,因它是其余计划的工程底座,本身几乎无改造)。

## 一、目标与范围

本计划覆盖后端平台与工程基础设施域:`Lucent/src/admin/`、`src/mail/`、`src/modules/files/`、`src/llm-runtime/`、`src/common/queue/`、`src/common/metrics/`、`src/modules/product-events/`、`src/modules/testing-support/`、`Lucent/deploy/`,以及客户端埋点 `Luminous/lib/core/analytics/` 与四份计划态投入(Worker 分离、rnacos 热配置、SaaS 模块、Node monorepo 合并)、Flutter 3.47 升级、桌面 SaaS 路线。

评估基准:`Luminous/docs/01-product/Product_Vision.md`——手机端是当前首发与验证表面;平台/工程能力按"对 C 端真实用户的支撑作用"与"投入是否与单产品 0.1.0 前阶段匹配"两条线审判。

核心结论:已实现的工程底座(F-1~F-7、F-10)全部为真实现、保留不动,本计划几乎不产生代码改造;所有计划态投入(F-11~F-14)统一判定为「阶段错配、暂缓启用」,本计划的主要产出是**写清各自的启用触发条件**;F-15 走保守跟进;F-16 保留方向、暂缓执行。

## 二、保留不动(清单)

以下全部为真实现,零改造,只列清单:

- **F-1 BullMQ 队列底座**(`Lucent/src/common/queue/`):12 条 Queue 实例（6 条继承 `BaseAsyncQueueService`、4 条业务直建、2 条调度队列）统一创建/降级/停机，是所有慢任务功能的公共承重墙。唯一待办:`architecture.md` 文档漂移修正，见改造项 P2-F。
- **F-2 Cron Repeatable Jobs**(`src/common/queue/cron-jobs.service.ts`):用药提醒派发(每分钟)、建议生命周期刷新(每 5 分钟)、数据保留清理(每日),调度存 Redis 重启不丢。
- **F-3 LLM Runtime**(`src/llm-runtime/`):按角色创建 LangChain 模型实例,`requireChatModel()` 对未配置角色抛 503 而非伪装可用。
- **F-4 邮件服务**(`src/mail/`):nodemailer SMTP + BullMQ 队列 + 失败同步兜底,服务邮箱验证码链路;模板仅验证码一类,够用,不提前建模板体系。
- **F-5 文件上传**(`src/modules/files/`):`POST /user/files/upload` 签发 COS 预签名 PUT URL,客户端直传;被餐食识别与记录附件两条客户端链路真实消费。
- **F-6 可观测性栈**(`src/common/metrics/` + `deploy/`):MetricsService 与 /metrics 端点不动;Grafana 看板与 Alertmanager 规则在 0.1.0 前按「最低可跑」维护,OTel 保持 `OTEL_ENABLED` 默认关闭——这是持续维护原则,非改造项。
- **F-7 产品事件埋点**(`src/modules/product-events/` + `Luminous/lib/core/analytics/`):客户端在真实成功边界打点、失败落 pending-sync 重放、clientEventId 幂等;隐私设计(枚举-only、无自由文本、90 天删除)保持现状。
- **F-10 testing-support**(`src/modules/testing-support/`):全栈 E2E 夹具基础设施,环境门 + 密钥门双重隔离干净;唯一待办是删一句陈旧注释,见改造项 P2-F。

## 三、改造项(按优先级分组)

### P0

无。P0 功能(F-1、F-2、F-3)全部为真实现保留,零改造。

### P1

**P1-A F-16 桌面 SaaS 差异化路线——工程侧触发条件登记（0.1.0 后）**

- 现状:手机端继续承担当前首发；ADR-0012 已接受，0.1.0 后采用 Next.js + Tauri 同步交付独立桌面 MVP。Flutter Desktop 与 PC Flutter Web 停止产品扩展。
- 方向决策与产品侧内容:统一引用 [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md)，本文不展开。
- 本文档只登记**工程侧触发条件**(满足前不动工):
  1. 0.1.0 移动端验证完成；
  2. 认证、离线、隐私、同步、分发约束完成验证；
  3. 在已接受的 Next.js + Tauri 路线上启动独立桌面 MVP。
- 工程纪律:不建 `apps/saas` 空壳,不重写现有 Flutter 桌面。
- 依赖:ADR-0012 决策;F-13(OAuth + dashboard)是其动工后的前置依赖。

### P2

**P2-A F-11 Worker 进程分离——暂缓启用，0.1.0 后触发**

- 现状:计划设计为「同镜像 + `WORKER_MODE` 环境变量拆分 api/worker 进程,worker 带 /healthz+/metrics 探针,compose 独立 worker 容器与资源限额」,但该设计**从未实现**(当前 api/worker 未拆分,无 WORKER_MODE 分支);要解决的问题(队列高峰拖慢 HTTP)在 0.1.0 前单机量级下不存在——队列并发均为 1-3(mail=3,其余 1),event loop 竞争不是已观测痛点。
- 方案:保持默认兼容模式运行,启用前不再投入。启用绑定到可观测触发条件,而非时间表:Grafana 里 `bullmq_waiting_jobs` 持续非零,或 p95 HTTP 延迟与队列高峰相关。
- 前后端分工:纯后端/运维(Lucent deploy),无客户端工作。
- 依赖:F-6 的 Grafana 看板是触发条件的观测载体(F-6 保留不动,已具备)。

**P2-B F-12 rnacos 动态运行时配置——降级为「环境变量 + 重启」，0.1.0 后触发**

- 现状:计划引入配置中心热调餐食识别 temperature/阈值、队列并发、缓存 TTL。要调的非敏感参数总共十几个,环境变量 + 重启的代价只有几十秒;多一个 rnacos 服务的部署、持久化、鉴权、监控成本对单产品单环境阶段是典型投入错配。
- 方案:降级为「环境变量 + 重启」,rnacos 不部署、代码保留。真正该先建的是餐食识别的**离线评测集**(标注图片 + 指标对比脚本)——识别质量的真实瓶颈是固定标注集 + A/B 评测流程,不是改参数要不要重启。
- 启用触发条件:离线评测流程存在,且证明参数需要以天为粒度频繁调整时,再回来启用热配置(该计划第 431 行自我声明「质量提升靠 A/B 而非调参通道」即是论据)。
- 前后端分工:纯后端;离线评测集归属见第四节(扫描/识别域计划)。

**P2-C F-13 SaaS 模块——0.1.0 后启动，动工只做两件**

- 现状:web 微信扫码 OAuth(工作台前置)、`GET /me/dashboard` 聚合 API 是桌面工作台的前置依赖,不直接服务手机端用户。计划里两个「不做」是对的:多租户/角色不做(照护场景由可撤销分享覆盖)、billing 只做契约不接真实支付。
- 方案:维持「0.1.0 不阻塞」排序不变——0.1.0 移动端验证完成前不动工。动工时只做 OAuth + 单页 dashboard 两件,subscription/billing 继续延后。
- 启用触发条件:0.1.0 移动端验证完成,且 F-16 方向决策落地。
- 合规:个保法/数据出境合规评估在 SaaS 上线前启动,不提前花钱。

**P2-D F-14 Node monorepo 合并——0.1.0 后，等 apps/saas 有第一行真实代码**

- 现状:计划以 Lucent 为根收编 website/docs/saas 为 pnpm workspace,追求跨仓原子提交。但原子提交的真实需求(后端合同 + 工作台 + 文档 + 官网一次改完)目前不存在——工作台尚不存在,website/docs 变更频率低,三分仓没有产生过实际协作摩擦的证据。合并收益是结构性的、成本是即时的(迁移、CI 重排、文档门禁兼容、git 历史处理)。
- 方案:暂缓。Phase 0 只做零成本不可逆动作——给 Flutter 桌面/Web 打 freeze tag;其余合并排在「apps/saas 有第一行真实代码」之后,那时原子提交才从理论收益变成日常需求。先合并空壳是把搬家成本花在住户入住前。
- 启用触发条件:`apps/saas` 出现第一行真实代码。
- 依赖:F-16 方向决策、F-13 动工。

**P2-E F-15 Flutter 3.47 升级——不作为 0.1.0 门槛，按上游 3.47.1 可用性触发**

- 现状:SDK/AGP 9/Gradle 9/iOS 部署目标跟进,fluwx 6.x 等高风险依赖逐项验证,当前被上游语义层回归(flutter/flutter#191095)阻塞。
- 方案:执行细节见 [`2026-08-14-flutter-3.47-upgrade-plan.md`](2026-08-14-flutter-3.47-upgrade-plan.md)(含 V/U 标注、回退预案、CI release APK 作 AGP 9 验证门禁),本文不重复展开。本文档只固化策略惯例:stable 发布后不立即跟,**等第一个 patch**(本次等 3.47.1,被 flutter/flutter#191095 阻塞恰好验证了该策略);暂缓清单(drift/flutter_local_notifications 等 breaking 依赖)维持独立排期,不混入 SDK 升级。
- 触发条件:Flutter 3.47.1 发布。

**P2-F 文档与注释漂移修正(architecture.md 两处 + F-10 陈旧注释，0.1.0 前)**

- 现状:三处已定位的漂移——`Lucent/docs/01-reference/architecture.md:393` 队列口径过时(仍写「7 + 1 mail」,实际 12 条);`architecture.md:370-373` 说存在 `metrics.middleware.ts` 文件,实际该文件已删、中间件内联在 `setup-app.ts:121-165`(`recordHttpRequest` 在 `setup-app.ts:158`);`Lucent/src/modules/testing-support/guards/testing-shared-secret.guard.ts:19-20` 注释「should always be used alongside JwtAuthGuard」与实际 `@Public()` 用法不符(controller 本身无此注释)。
- 方案:修正 architecture.md 为 12 条 Queue 实例（6 条 `BaseAsyncQueueService`、4 条业务直建、2 条调度队列）及真实 concurrency；改写中间件描述指向 `setup-app.ts:158` 内联实现；删除 testing-support guard 陈旧注释。
- 进展:三处修正均未执行(0.1.0 前唯一可立即落地项)。
- 前后端分工:纯 Lucent 侧文档/注释改动。
- 依赖:无,可随时执行,是本计划中唯一可立即落地的改造项。

## 四、跨计划引用与依赖

本计划是其余 9 份计划的**工程底座**,底座能力本身保留不动,不在本计划展开:

- **队列与 LLM 底座被全域共用**:F-1 的 12 条队列(6 条 `BaseAsyncQueueService`、4 条业务直建、2 条调度)承载 Today 建议卡、餐食识别、药品识别、报告总结、就诊 PDF、数据导出、邮件;F-3 LLM Runtime 是所有 AI 产物的统一模型入口。medicine、scan-search、today、assistant、record、health-event、report 各计划中涉及的慢任务/AI 产物均运行在此底座上,各计划无需也不应改造底座本身。
- **离线评测集归属**:P2-B 提到餐食识别离线评测集是 scan-search/识别域的建设内容,本计划只登记它是 F-12 热配置的启用前置,不重复展开建设方案。
- **桌面/Web 形态**:ADR-0012 已接受；独立 Next.js + Tauri MVP 在 0.1.0 后启动，本计划只登记工程侧触发条件(P1-A)。
- **Flutter 3.47 升级**:执行方案全文引用 [`2026-08-14-flutter-3.47-upgrade-plan.md`](2026-08-14-flutter-3.47-upgrade-plan.md),本计划只固化「跟次版本等 patch」的策略惯例(P2-E)。
- **被引用的 Lucent 侧计划**(评估对象,不在本仓):`Lucent/plans/2026-07-24-worker-separation-and-cron-repeatable.md`、`2026-08-02-rnacos-runtime-config-tuning.md`、`2026-08-14-saas-modules-and-node-monorepo.md`——均维持暂缓,触发条件见本文 P2-A/B/C/D。
- **隐私横切约束**:90 天事件删除由 F-2 每日数据保留清理执行、F-7 枚举-only 埋点遵守,均为保留项,其他计划涉及埋点/事件时不得破坏该约束。

## 五、本计划内执行顺序

1. **P2-F 文档与注释漂移修正（0.1.0 前）**——唯一可立即落地项，不阻塞任何事。
2. **P2-A/B/C/D（0.1.0 后）**——按触发条件恢复，不提前投入。
3. **P2-E** 在 Flutter 3.47.1 可用后跟进，不作为 0.1.0 门槛。
4. **P1-A F-16（0.1.0 后）**——按已接受 ADR-0012 启动独立 Next.js + Tauri MVP。

## 六、已决边界与延期项

- 队列权威口径为 12 条 Queue 实例：6 条继承 `BaseAsyncQueueService`、4 条业务直建、2 条调度队列；仅修正文档/注释，不做队列重构。
- Worker 分离、rnacos、SaaS 与 Node monorepo 均为 0.1.0 后、由既有触发条件控制的事项；Flutter 3.47 仅在上游 3.47.1 可用后跟进，不作为发布门槛。
- 漏斗消费面为 0.1.0 后 TODO，仅做受保护周报或简表，不建设实时 Admin Dashboard。独立桌面 MVP 采用 Next.js + Tauri 同步交付；桌面高级能力仍冻结。
- 新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
