# 个人中心 / 设置 / 认证(mine-settings-auth)改造计划

Created: 2026-08-16

> 已决事项见 [`2026-08-16-remediation-decision-register.md`](2026-08-16-remediation-decision-register.md)，其优先于本文件旧「不确定点」表述。
> 来源: `research/02-功能盘点/mine-settings-auth-个人中心与设置.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 9 位。

## 一、剩余改造项

### P1-3 B6:数据存储设置两个假开关接执行器（图片质量/仅 Wi-Fi 同步为 0.1.0 后）

- 现状:图片质量(标准/省流)零消费者,无任何图片加载分支读取;同步网络偏好(仅 Wi-Fi)无消费者,`SyncWorker` 只判断"任意网络 != none"即 flush。
- 改造方案:
  - **图片质量**:接入图片压缩链路——`ImageCompressor` 读取该偏好,按"标准/省流"参数执行压缩(前端改动,涉及图片压缩调用点与设置读取)。
  - **同步网络偏好**:`SyncWorker` flush 前增加 connectivity 检查:开启"仅 Wi-Fi"时,非 Wi-Fi 网络下跳过 flush(前端改动,涉及 `SyncWorker` 与 connectivity 判断)。
- 前后端分工:均为纯前端改造,后端不动。
- 依赖:无;与 P1-2 同批执行。

## 二、跨计划引用与依赖

- **建议升级通知执行器 / today-suggestion 规则引擎**(P1-2 的 R1–R4 与饮水提醒的执行器本体):方案见 [`2026-08-16-today-remediation-plan.md`](2026-08-16-today-remediation-plan.md),本文不重复展开。
- **睡眠提醒复用 `LocalNotificationGateway` / `reminder_notification_coordinator`**:已接入独立本地通知协调器；每日仅在就寝时间触达，起床时间只保留为记录/分析偏好，不作为闹钟。
- **JPush alias 绑定/解绑**(登出 A4 已接入,本计划无新增改动;机制归口):见 [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md)。
- **健康平台自动同步开关**(设置页开关在后端执行器未配置前保持禁用,本组仅引用不改动):见 [`2026-08-16-platform-notification-crosscutting-plan.md`](2026-08-16-platform-notification-crosscutting-plan.md) 的 health_sync 一节。
- **桌面/Web 形态挂起项**(微信登录桌面路径等保留代码):Flutter Desktop 与 PC Flutter Web 不再扩展；独立 Next.js + Tauri MVP 在 0.1.0 后启动。
- 全局执行顺序上,本计划(第 9 位)依赖第 1 位(通知横切)、第 2 位(medicine)、第 4 位(today)先行落地对应执行器。

## 三、本计划内执行顺序

1. **P1-3 图片质量/仅 Wi-Fi 同步（0.1.0 后）**。

## 四、已决边界与延期项

- Apple 与微信 OAuth 仅隐藏前端入口；不删后端回调、已有身份绑定或数据。QQ、微博、Google 保留；微博/Google 图标问题列入 TODO。
- 睡眠提醒已在 0.1.0 前接入本地通知执行器；`app-info` 与静态 FAQ 保留。
- 数据导出定义为「导出就诊报告 PDF」：设置入口迁至「设置 → 更多 → 导出就诊报告 PDF」，报告页入口保留；原始数据导出延后至 TODO。
- 图片质量和仅 Wi-Fi 同步为 0.1.0 后；备案、公司信息和站内工单仍按外部条件/后续任务处理。新增医疗判断、外部供应商、用户数据结构或部署成本时，另建任务计划并重新 grill。
