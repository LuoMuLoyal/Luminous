# 个人中心 / 设置 / 认证(mine-settings-auth)改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。

> 来源: `research/02-功能盘点/mine-settings-auth-个人中心与设置.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 9 位。

## 一、目标与范围

范围:认证(auth)、设置(settings)、法律页面(legal)、个人中心(mine)、支持(support)五个模块的存量功能整改。

核心目标:

- 补齐安全 PIN elevation 在敏感账号操作上的客户端接线(A6),消除"启用 PIN 后无法改密/改邮箱/解绑"的 403 死角。
- 消灭设置页 6 个"只有本地开关没有执行器"的假实现:通知类 4 个(healthAlerts/weeklySummary/waterReminders/sleep)与存储类 2 个(图片质量/仅 Wi-Fi),逐个接上真实执行器或明确暂缓。
- 收敛 support 死代码与后端弃用接口(按调研批注口径:删除后端 `support-resources` 接口,前端 FAQ 维持静态 md)。
- 其余约 30 项真实现功能保留不动。

## 二、保留不动(清单)

以下均为审计确认的真实现,本计划不改动:

- 邮箱+密码登录、验证码登录、注册(条款勾选强校验)、忘记/重置密码、邮箱验证(#1–#5)
- 验证码邮件投递(nodemailer SMTP 队列,driver=log 可降级)(#6)
- 微信登录三路径(移动 SDK / 桌面 loopback / Web 回退)(#7;桌面路径属冻结桌面端的保留代码)
- 登出(后端注销 refreshToken + 本地强制清 token)(#10)
- 注销账号(密码/邮箱验证码确认 → 软删 → 30 天级联硬删)(#13)
- 安全 PIN 码本体(argon2id 哈希 + 15 分钟 elevation token + 后端守卫)(#14,接线缺口见 A6)
- 通知权限三态卡片与系统设置跳转(#15)
- 用药提醒开关组(总开关/提前提醒/免打扰/声音/振动,已被 `medicineReminderNotificationSync` 真实消费)(#16)
- 报告分享开关 dataSharingConsent(后端 user-settings + assistant 真实读取)(#21)
- AI 设置四开关 + 四上下文开关(后端持久化 + 防连点)(#22)
- 数据保留期(30/90 天/永久,`cacheCleanup` 启动清理 Drift 缓存)(#24)
- 主题 / 语言 / 无障碍字号 / 高级设置 / 功能开关 / 恢复默认(#27–#30)
- 关于页与检查更新(`GET /public/app-info` + semver 比较)(#31–#32)
- Mine 个人资料主卡 / 完整度 / 缺口检测(#33)
- 昵称 / 头像编辑(`PATCH /account`)(#34)
- 健康档案与健康史 CRUD(health-context 全 CRUD + 二次确认)(#35–#36)
- 同步失败横幅 + 全部重试 + 诊断面板(#37)
- 通知收件箱入口 / 未读红点(#38,notification 模块另行审计)
- 7 类法律文档(remote-first + assets 回退,双语 14 文件)(#39)与登录/注册条款入口(#40)
- 帮助中心 FAQ(本地 Markdown 双语 + 骨架屏/重试)(#42)
- 意见反馈(mailto + TraceID 一键复制,邮件渠道为刻意设计)(#43)

## 三、改造项(按优先级分组)

### P1

#### P1-2 B1:通知设置四个假开关接执行器（0.1.0 前）

- 现状:`NotificationSettingsController` 把 healthAlerts / weeklySummary / waterReminders / sleepReminderEnabled+时段 全部只写 SharedPreferences,全客户端 grep 无消费者,后端也无周摘要/健康告警生成逻辑;开关可拨动但拨动后什么都不发生。
- 改造方案(按 2026-08-15 产品决策的统一口径):
  - **健康提醒(healthAlerts)**:细化为 4 条规则,由 today-suggestion 规则引擎物化后以"建议升级通知"触达,每天最多 1 条——R1 睡眠恶化(有记录且连续 3 晚入睡晚于个人基线)、R2 症状加重(事件期内连续 2 次 check-in 为"加重"或新记录症状)、R3 饮水缺口(连续 2 天已记录进水量低于基线 50%)、R4 档案缺口(新增药物进药箱但过敏史未填写);无记录不触发;反馈复用建议卡"不适用/太频繁/不再提醒"。规则物化与升级通知执行器的实现属于 today 域,见 [`2026-08-16-today-remediation-plan.md`](2026-08-16-today-remediation-plan.md);本计划只负责把 healthAlerts 开关对接到该链路(开关状态作为规则引擎/通知触达的门禁条件)。
  - **每周摘要(weeklySummary)**:改造为"每周纵向洞察通知"开关——后端周洞察生成后经站内信/本地通知推送,本开关控制该推送;原"泛化周报"概念退出。周洞察生成本体归 today/report 域链路,本计划只负责开关语义与门禁接线。
  - **饮水提醒(waterReminders)**:并入 R3(低于基线时触发,每天最多 1 条),执行器同为"建议升级通知",不再做独立的定时饮水提醒调度。
  - **睡眠提醒(sleepReminderEnabled + 时段)**:0.1.0 前接入本地通知执行器，复用 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) F-7 的协调器/网关；每日只在就寝时间触达，起床时间不作闹钟。
- 前后端分工:前端负责开关持久化与门禁接线(SharedPreferences + PrefKeys 现状不变);规则引擎物化、升级通知、周洞察推送由 today/通知横切侧实现。
- 依赖:today-suggestion 规则引擎与建议升级通知执行器(第 4 位计划)。

#### P1-3 B6:数据存储设置两个假开关接执行器（图片质量/仅 Wi-Fi 同步为 0.1.0 后）

- 现状:图片质量(标准/省流)零消费者,无任何图片加载分支读取;同步网络偏好(仅 Wi-Fi)无消费者,`SyncWorker` 只判断"任意网络 != none"即 flush。
- 改造方案:
  - **图片质量**:接入图片压缩链路——`ImageCompressor` 读取该偏好,按"标准/省流"参数执行压缩(前端改动,涉及图片压缩调用点与设置读取)。
  - **同步网络偏好**:`SyncWorker` flush 前增加 connectivity 检查:开启"仅 Wi-Fi"时,非 Wi-Fi 网络下跳过 flush(前端改动,涉及 `SyncWorker` 与 connectivity 判断)。
- 前后端分工:均为纯前端改造,后端不动。
- 依赖:无;与 P1-2 同批执行。

### P2（0.1.0 前）

#### P2-1 A5:会话管理补客户端 UI

- 现状:后端 `session.controller.ts` 提供 `GET /auth/sessions`、`DELETE /auth/sessions/:sessionId`(含单测),已生成进客户端 `auth_api.dart`,但全客户端零 UI/调用方。
- 改造方案(按逐功能分析口径:补 UI):
  - 前端:在"账号与安全"页新增会话管理入口,列表展示活跃会话(设备/时间等后端返回字段),支持远程撤销单条会话;撤销后刷新列表,当前会话撤销等同登出处理。
  - 后端:无需改动。
- 依赖:无。采用补客户端 UI 的路径，不删除会话管理接口。

#### P2-2 B5:数据导出两处体验修复

- 现状:`DataExportPage` 导出链路真实(申请 → 后端队列 → PDF → 轮询 `GET /data-export-requests/latest` → 下载链接),`POST` 端带 `@RequireSecurityElevation()`;导出物是就诊报告 PDF,不是原始数据导出。
- 改造方案(按逐功能分析口径):
  - **PIN 未启用引导**:未启用 PIN 的用户点击导出目前只弹"安全 PIN 未启用"toast 后无声失败;改为弹引导对话框,提供"去启用 PIN"跳转安全 PIN 设置页(前端,涉及 `data_export.dart` / `export_actions.dart` 的失败分支)。
  - **FAQ/导出文案对齐**:FAQ 写"导出你的健康数据"与后端"不导出原始用户数据"不符;改文案,将 FAQ 与导出页描述对齐为"导出就诊报告 PDF"(前端,改 `assets/faq/faq_{zh,en}.md` 与导出页文案)。原始数据可移植性导出移入 0.1.0 后 TODO。
- 前后端分工:均为前端文案/交互改动,后端不动(真导出若立项另议)。
- 依赖:无。

#### P2-3 E3/E4:support 死代码清理 + 删除后端 support-resources 接口

- 现状:`features/support/` 下 `supportResourcesProvider`、`LucentSupportRepository` 的 resources 部分在帮助页自包含化后零消费方(死代码);后端 `SupportResourcesService.getResources()` 返回静态列表,客户端已不调用(`support_resources_api.dart` 无人使用);`appInfoProvider` / `GET /public/app-info` 仍被 about/help/反馈页使用,必须保留。
- 改造方案(以调研文档第 231 行批注为准,**不采用**速览表/逐功能正文中的"FAQ 上收为后端可运营内容源"方案):
  - 后端(Lucent):删除 `support-resources` 资源列表接口(`SupportResourcesService.getResources()` 及对应 controller 路由),保留 `app-info` 端点;删除后运行 `pnpm export:openapi`。
  - 前端(Luminous):删除 `supportResourcesProvider` 与 `LucentSupportRepository` 中的 resources 部分,保留 `appInfoProvider` 及 repository 的 appInfo 部分;重新生成 API 客户端(`dart run scripts/bootstrap_generated_sources.dart`),移除生成的 `support_resources_api.dart` 消费面;FAQ 维持 `assets/faq/faq_{zh,en}.md` 静态 md 自包含渲染,不做上收。
- 前后端分工:后端删接口 + 重导出契约;前端删死代码 + 重生成客户端。
- 依赖:Lucent 契约变更需走 openapi 再生成流程；`supportResourcesProvider` 与 repository 的 resources 部分随接口一并删除。

## 四、跨计划引用与依赖

- **建议升级通知执行器 / today-suggestion 规则引擎**(P1-2 的 R1–R4 与饮水提醒的执行器本体):方案见 [`2026-08-16-today-remediation-plan.md`](2026-08-16-today-remediation-plan.md),本文不重复展开。
- **睡眠提醒复用 `LocalNotificationGateway` / `reminder_notification_coordinator`**:接入本地通知执行器后生效；每日仅在就寝时间触达，起床时间只保留为记录/分析偏好，不作为闹钟。
- **JPush alias 绑定/解绑**(登出 A4 已接入,本计划无新增改动;机制归口):见 [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md)。
- **健康平台自动同步开关**(设置页开关在后端执行器未配置前保持禁用,本组仅引用不改动):见 [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md) 的 health_sync 一节。
- **桌面/Web 形态挂起项**(微信登录桌面路径等保留代码):Flutter Desktop 与 PC Flutter Web 不再扩展；独立 Next.js + Tauri MVP 在 0.1.0 后启动。
- 全局执行顺序上,本计划(第 9 位)依赖第 1 位(通知横切)、第 2 位(medicine)、第 4 位(today)先行落地对应执行器。

## 五、本计划内执行顺序

1. **P1-2 B1 通知假开关改造（0.1.0 前）**——健康提醒/每周摘要/饮水提醒与睡眠提醒均接真实执行器；睡眠仅就寝时间本地通知。
2. **P2-3 E3/E4 support 清理（0.1.0 前）**——涉及 Lucent 契约删除与客户端再生成。
3. **P2-1 A5 会话管理 UI**、**P2-2 B5 导出体验修复（均 0.1.0 前）**——彼此独立，收尾阶段并行。
4. **P1-3 图片质量/仅 Wi-Fi 同步（0.1.0 后）**。

## 六、已决边界与延期项

- Apple 与微信 OAuth 仅隐藏前端入口；不删后端回调、已有身份绑定或数据。QQ、微博、Google 保留；微博/Google 图标问题列入 TODO。
- 睡眠提醒在 0.1.0 前接入本地通知执行器。会话管理补 UI；`support-resources` 后端端点及客户端 resources provider/repository 部分一并删除，保留 `app-info` 与静态 FAQ。
- 数据导出定义为「导出就诊报告 PDF」：设置入口迁至「设置 → 更多 → 导出就诊报告 PDF」，报告页入口保留；PIN 引导、文案与路由重排均在 0.1.0 前。原始数据导出延后至 TODO。
- 图片质量和仅 Wi-Fi 同步为 0.1.0 后；备案、公司信息和站内工单仍按外部条件/后续任务处理。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
