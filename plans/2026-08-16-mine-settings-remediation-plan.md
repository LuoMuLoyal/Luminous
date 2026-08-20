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

#### P1-3 B6:数据存储设置两个假开关接执行器（图片质量/仅 Wi-Fi 同步为 0.1.0 后）

- 现状:图片质量(标准/省流)零消费者,无任何图片加载分支读取;同步网络偏好(仅 Wi-Fi)无消费者,`SyncWorker` 只判断"任意网络 != none"即 flush。
- 改造方案:
  - **图片质量**:接入图片压缩链路——`ImageCompressor` 读取该偏好,按"标准/省流"参数执行压缩(前端改动,涉及图片压缩调用点与设置读取)。
  - **同步网络偏好**:`SyncWorker` flush 前增加 connectivity 检查:开启"仅 Wi-Fi"时,非 Wi-Fi 网络下跳过 flush(前端改动,涉及 `SyncWorker` 与 connectivity 判断)。
- 前后端分工:均为纯前端改造,后端不动。
- 依赖:无;与 P1-2 同批执行。

### P2（0.1.0 前）

## 四、跨计划引用与依赖

- **建议升级通知执行器 / today-suggestion 规则引擎**(P1-2 的 R1–R4 与饮水提醒的执行器本体):方案见 [`2026-08-16-today-remediation-plan.md`](2026-08-16-today-remediation-plan.md),本文不重复展开。
- **睡眠提醒复用 `LocalNotificationGateway` / `reminder_notification_coordinator`**:已接入独立本地通知协调器；每日仅在就寝时间触达，起床时间只保留为记录/分析偏好，不作为闹钟。
- **JPush alias 绑定/解绑**(登出 A4 已接入,本计划无新增改动;机制归口):见 [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md)。
- **健康平台自动同步开关**(设置页开关在后端执行器未配置前保持禁用,本组仅引用不改动):见 [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md) 的 health_sync 一节。
- **桌面/Web 形态挂起项**(微信登录桌面路径等保留代码):Flutter Desktop 与 PC Flutter Web 不再扩展；独立 Next.js + Tauri MVP 在 0.1.0 后启动。
- 全局执行顺序上,本计划(第 9 位)依赖第 1 位(通知横切)、第 2 位(medicine)、第 4 位(today)先行落地对应执行器。

## 五、本计划内执行顺序

1. **P1-3 图片质量/仅 Wi-Fi 同步（0.1.0 后）**。

## 六、已决边界与延期项

- Apple 与微信 OAuth 仅隐藏前端入口；不删后端回调、已有身份绑定或数据。QQ、微博、Google 保留；微博/Google 图标问题列入 TODO。
- 睡眠提醒已在 0.1.0 前接入本地通知执行器；`app-info` 与静态 FAQ 保留。
- 数据导出定义为「导出就诊报告 PDF」：设置入口迁至「设置 → 更多 → 导出就诊报告 PDF」，报告页入口保留；原始数据导出延后至 TODO。
- 图片质量和仅 Wi-Fi 同步为 0.1.0 后；备案、公司信息和站内工单仍按外部条件/后续任务处理。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
