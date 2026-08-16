# 功能审计：个人中心（mine）/ 设置（settings）/ 认证（auth）/ 法律页面（legal）/ 支持（support）

> 审计日期：2026-08-15
> 审计范围：Luminous（Flutter 客户端）+ Lucent（NestJS 后端）本组模块专属功能点
> 判定基准：Product_Vision（长期健康伙伴、手机端是当前首发与验证表面，桌面/Web 待研究）；计划视为已执行（法律页面按已上线评估）；健康平台同步开关已由 `platform-通知与横切能力.md` 审计，此处只引用不重复
> 真伪口径：真实现（端到端生效）/ 部分实现（有真实链路但存在缺口）/ 假实现（只有本地开关/占位，无执行器）/ 死代码（无任何消费方）

---

## 一、功能点总览表

| # | 功能点 | 一句话作用 | 真伪判定 | 结论 | 优先级 |
|---|--------|-----------|---------|------|--------|
| 1 | 邮箱+密码登录 | 走后端 `POST /auth/login`，argon2 校验，返回 access/refresh token | 真实现 | 保留 | - |
| 2 | 验证码登录 | 走后端验证码场景 `login`，Redis 限流 + 冷却 | 真实现 | 保留 | - |
| 3 | 注册（邮箱+密码+验证码） | 后端 `POST /auth/register` + 条款勾选强校验 | 真实现 | 保留 | - |
| 4 | 忘记密码 / 重置密码 | 后端 `forgot-password` / `reset-password`，邮件验证码 | 真实现 | 保留 | - |
| 5 | 邮箱验证 | 后端 `verify-email`，账号页状态徽章联动 | 真实现 | 保留 | - |
| 6 | 验证码邮件投递 | nodemailer SMTP 队列（driver=log 时可降级） | 真实现 | 保留 | - |
| 7 | 微信登录（移动 SDK / 桌面 / Web 回退） | fluwx 授权 + 后端 wechat-mobile/web callback；三路径降级 | 真实现 | 保留 | - |
| 8 | QQ / 微博 / Google OAuth | 后端 authorize URL + callback 全链路 | 真实现（投入价值存疑） | 收敛或下线 | P2 |
| 9 | Apple 登录 | `sign_in_with_apple` + 后端 apple callback | 真实现 | 保留 | - |
| 10 | 登出 | 后端注销 refreshToken + 本地强制清 token | 真实现 | 保留 | - |
| 11 | 会话管理（列出/撤销会话） | 后端 `GET/DELETE /auth/sessions`，**无客户端 UI** | 真实现（后端孤悬） | 补 UI 或下线 | P2 |
| 12 | 修改邮箱 / 修改密码 / 解绑三方身份 | 后端强校验 + 审计日志 | 部分实现（**PIN 启用时客户端 403**） | 改造 | P1 |
| 13 | 注销账号 | 密码或邮箱验证码确认 → 软删 → 30 天后级联硬删 | 真实现 | 保留 | - |
| 14 | 安全 PIN 码 | argon2 哈希 + 短期 elevation token + 后端守卫敏感接口 | 真实现 | 保留 | - |
| 15 | 通知权限申请 / 系统设置跳转 | 系统权限三态管理 | 真实现 | 保留 | - |
| 16 | 用药提醒开关 + 提前提醒 + 免打扰 + 声音/振动 | 本地通知调度执行器（`medicineReminderNotificationSync`）真实消费 | 真实现 | 保留 | - |
| 17 | 健康提醒开关（healthAlerts） | 仅 SharedPreferences 持久化 | 假实现 | 改造（细化 R1–R4 规则，建议升级通知） | P1 |
| 18 | 每周摘要开关（weeklySummary） | 仅 SharedPreferences 持久化 | 假实现 | 改造（改为"每周纵向洞察通知"） | P1 |
| 19 | 饮水提醒开关（waterReminders） | 仅 SharedPreferences 持久化 | 假实现 | 改造（纳入 R3，建议升级通知） | P1 |
| 20 | 睡眠提醒开关 + 时段 | 仅 SharedPreferences 持久化 | 假实现 | 暂缓（先不管：保留设置，不排期） | P1 |
| 21 | 报告分享（数据共享同意） | 后端 user-settings + assistant 读取真实执行 | 真实现 | 保留 | - |
| 22 | AI 设置（摘要/助手/记忆/上下文） | 后端 user-settings 持久化 + 防连点写入 | 真实现 | 保留 | - |
| 23 | 数据导出（就诊报告 PDF） | 后端队列生成 PDF + elevation 门禁 + 下载链接 | 真实现 | 保留（次级出口） | - |
| 24 | 数据保留期（30/90 天/永久） | `cacheCleanup` 启动清理本地 Drift 缓存 | 真实现 | 保留 | - |
| 25 | 图片质量（标准/省流） | 仅 SharedPreferences 持久化 | 假实现 | 改造（接入图片压缩链路） | P1 |
| 26 | 同步网络偏好（仅 Wi-Fi） | 仅 SharedPreferences 持久化，SyncWorker 不消费 | 假实现 | 改造（SyncWorker 加"仅 Wi-Fi"判断） | P1 |
| 27 | 主题（模式/色系/高对比度） | 本地偏好 + Forui 主题真实应用 | 真实现 | 保留 | - |
| 28 | 语言设置 | 本地偏好 + locale 全局生效 | 真实现 | 保留 | - |
| 29 | 无障碍字号 | 本地偏好 + 字号缩放真实应用 | 真实现 | 保留 | - |
| 30 | 高级设置 / 功能开关 / 恢复默认 | 本地偏好真实读写 | 真实现 | 保留 | - |
| 31 | 关于页（版本/tagline/开源许可） | `package_info_plus` 本地元数据 | 真实现 | 保留 | - |
| 32 | 检查更新 | 后端 app-info + semver 比较 + 跳转下载页 | 真实现 | 保留 | - |
| 33 | Mine 个人资料主卡 / 完整度 / 缺口 | 聚合后端 account + health-context 计算 | 真实现 | 保留 | - |
| 34 | 昵称 / 头像编辑 | 后端 `PATCH /account` | 真实现 | 保留 | - |
| 35 | 健康档案（身高/体重/出生日期/性别/血型/紧急联系人） | 后端 `PATCH /health-context/profile` | 真实现 | 保留 | - |
| 36 | 过敏史 / 疾病史 / 当前用药 CRUD | 后端 health-context 全 CRUD + 二次确认 | 真实现 | 保留 | - |
| 37 | 同步失败横幅 + 全部重试 + 诊断面板 | 本地 pending-sync 永久失败计数 + 用户面/诊断面分离 | 真实现 | 保留 | - |
| 38 | 通知收件箱入口 / 未读红点 | 真实后端未读数（notification 模块，非本组重复审计） | 真实现 | 保留 | - |
| 39 | 法律文档（7 类，remote-first + assets 回退） | 后端 Prisma 文档 + 本地 Markdown 兜底，内容真实可读 | 真实现 | 保留 | - |
| 40 | 登录/注册页条款与隐私入口 | 跳转 `/legal/terms`、`/legal/privacy` | 真实现 | 保留 | - |
| 41 | ICP 备案 + About 公司信息（计划 P2-1） | 计划明确标注"待实施"，非承诺功能 | 未实施（计划遗留） | 待备案后实施 | P2 |
| 42 | 帮助中心 FAQ | 本地 Markdown 双语文档渲染 + 骨架屏/重试 | 真实现 | 保留 | - |
| 43 | 意见反馈（mailto + TraceID） | 唤起邮件客户端，附最近请求 TraceID | 真实现（非后端工单） | 保留 | - |
| 44 | 客户端 support 数据层（resources provider/repository） | 帮助页已自包含化，**零消费方** | 死代码 | 改造（FAQ 上收为可运营内容源） | P2 |
| 45 | 后端 support-resources 资源列表接口 | 静态列表，客户端已不使用（app-info 仍在用） | 真实现（客户端弃用） | 改造（保留为未来运营入口） | P2 |

---

## 二、逐功能分析

### A. 认证模块（auth）

#### A1. 邮箱+密码登录 / 验证码登录 / 注册 / 忘记密码（#1–#6）——真实现，保留

- 现状：客户端 `LucentAuthRepository`（`lib/features/auth/data/datasources/auth.dart`，526 行）逐一映射后端 controller；登录页双 Tab（密码/验证码），注册页含条款勾选（`acceptedTerms` 未勾选不可提交）、验证码冷却倒计时（`CooldownTimerMixin`）。
- 实际作用：token 落 `flutter_secure_storage`；后端验证码服务带 TTL/冷却/Redis 限流（`verification-code.service.ts`），邮件经 nodemailer 队列投递（`mail-transport.service.ts`，driver 可配 smtp/log）。登录页有 returnTo 回跳、OAuth 深链回跳等完整链路。
- 真伪判定：真实现。抽样确认：`POST /auth/login`、`POST /auth/register`、`POST /auth/send-verification-code`、`POST /auth/forgot-password`、`POST /auth/reset-password` 均在后端 `local.controller.ts` 真实存在并有单测。
- 结论：保留。注册即登录、条款入口齐全，无需改动。

#### A2. 微信登录三路径（#7）——真实现，保留

- 现状：`OAuthLoginController.startWechatLogin` 依次尝试移动 SDK（fluwx，`mobile_auth_client_fluwx.dart`，按 AppId 环境变量门控）→ 桌面 loopback（`desktop_oauth_callback_server.dart`）→ Web authorize URL 回退；后端 `oauth.controller.ts` 提供 wechat-web/wechat-mobile 两条 callback。
- 实际作用：移动端走真实微信授权码换取会话；未配置或未安装微信时自动降级到浏览器授权页 + 手动粘贴 callback 的兜底输入框。
- 真伪判定：真实现。
- 结论：保留。注意桌面路径服务于已冻结的桌面端，属"保留代码"范畴，不影响移动端主路径。

- 

#### A4. 登出（#10）——真实现，保留

- 现状：`logout()` 先带 refreshToken 调后端 `POST /auth/logout`，`finally` 中无条件清本地 session（避免 500/超时后 token 残留）。设置页登出接入 `showDangerConfirmationDialog` 二次确认；JPush alias 随认证状态绑定/解绑。
- 真伪判定：真实现。结论：保留。

#### A5. 会话管理 API 无客户端 UI（#11）——真实现但后端孤悬

- 现状：后端 `session.controller.ts` 提供 `GET /auth/sessions`、`DELETE /auth/sessions/:sessionId`，已生成进客户端 `auth_api.dart`，但全客户端无任何 UI/调用方（grep 确认零消费）。
- 实际作用：用户无法查看/撤销登录设备，接口闲置。
- 真伪判定：真实现（后端侧），客户端未接线。
- 结论：改造。P2 优先级：在"账号与安全"页新增会话管理入口（列出活跃会话 + 远程撤销）

#### A6. 修改邮箱 / 修改密码 / 解绑三方（#12）——部分实现，存在 PIN 缺口（P1）

- 现状：客户端三个操作分别调 `POST /account/email`、`POST /account/password`、`DELETE /account/identities/:identityId`；后端在**类级挂 `SecurityElevationGuard`**、在这三个 handler 上标 `@RequireSecurityElevation()`，要求请求头带 `x-security-elevation: Bearer <token>`（PIN 校验成功后签发、15 分钟有效）。
- 实际作用：`showSecurityElevationDialog` 目前只被**数据导出**（`data_export.dart`、`export_actions.dart`）调用；改密码/改邮箱/解绑身份三条路径**从不触发 PIN 对话框**，elevation token holder 为空时请求直接 403（`elevation_token_invalid`），用户只会看到通用失败 toast。
- 真伪判定：部分实现——后端守卫真实生效，但客户端 PIN 门禁缺接线，**启用 PIN 的用户无法改密/改邮箱/解绑身份**。
- 结论：改造（P1）。在 `AuthAccountNotifier.changePassword / changeEmail / unlinkIdentity` 入口统一接入 `showSecurityElevationDialog`（已持有有效 token 时自动跳过），与导出流程复用同一组件；失败 toast 需给出"请验证安全 PIN"的引导文案。

#### A7. 注销账号（#13）——真实现，保留

- 现状：`DeleteAccountSection` 支持密码确认（本地密码用户）与邮箱验证码确认（OAuth-only 用户，场景 `deleteAccount`）；后端校验后 `softDeleteUser`（deletedAt + status=deleted），`DataRetentionService` 每日清理过期会话/已读通知/90 天原始事件，软删账号 30 天后按外键级联硬删；审计日志记 `account.delete`。
- 真伪判定：真实现。结论：保留。
- 注：注销页顶部有政策提示 + 跳转 `/legal/account-cancellation`，与法律模块闭环。

#### A8. 安全 PIN 码（#14）——真实现，保留

- 现状：客户端 `security_pin.dart`（启用二次确认、6 位数字过滤、行内错误、修改/禁用清 elevation）；后端 `pin.service.ts` argon2id 哈希、`securityElevationVersion` 递增使旧 elevation token 立即失效、`verify` 签发 15 分钟 HS512 token；`SecurityElevationInterceptor` 自动注入请求头。
- 实际作用：PIN 替代 2FA，真实保护改密/改邮箱/解绑/导出四类敏感操作。
- 真伪判定：真实现（服务端真实守卫，非本地伪装）。结论：保留，但见 A6 接线缺口。

### B. 设置模块（settings）

#### B1. 通知设置（#15–#20）——混合：4 真 4 假

- 现状：`NotificationSettingsController` 全部持久化到 SharedPreferences；执行器方面：
  - **真（本地调度执行器）**：用药提醒总开关、提前提醒分钟数、免打扰时段、声音、振动——被 `medicineReminderNotificationSync`（bootstrap 常驻 watch）消费，经 `LocalNotificationGateway` 真实重排本地通知（cancel→plan→schedule）。
  - **假（无执行器）**：健康提醒（healthAlerts）、每周摘要（weeklySummary）、饮水提醒（waterReminders）、睡眠提醒（sleepReminderEnabled + 时段）——全客户端 grep 无任何消费者，后端也没有周摘要/健康告警生成逻辑（通知类型表里只有 ai_today_summary 等，无 weekly）。
- 实际作用：四个假开关 UI 上正常可拨动，但拨动后**什么都不发生**（无本地调度、无 JPush 下发、无后端配置），属于典型的"只有本地开关没有执行器"。
- 真伪判定：4 项真实现（medication/sound/vibration/dnd/advance，共 5 个开关），4 项假实现。
- 结论：改造（P1），按产品决策（2026-08-15）统一执行器口径：
  - 健康提醒（healthAlerts）：细化成 4 条具体规则，由 today-suggestion 规则引擎物化后升级通知，每天最多 1 条——R1 睡眠恶化（有记录且连续 3 晚入睡晚于个人基线）、R2 症状加重（事件期内连续 2 次 check-in 为"加重"或新记录症状）、R3 饮水缺口（连续 2 天已记录进水量低于基线 50%）、R4 档案缺口（新增药物进药箱但过敏史未填写）；无记录不触发；反馈复用建议卡"不适用/太频繁/不再提醒"。
  - 每周摘要（weeklySummary）：改造为"每周纵向洞察通知"——后端周洞察生成后经站内信/本地通知推送，开关控制该推送（原"泛化周报"概念退出，开关服务于新的周洞察推送）。
  - 饮水提醒（waterReminders）：纳入 R3（已记录进水量低于基线时触发，每天最多 1 条），执行器为"建议升级通知"。
  - 睡眠提醒（sleepReminderEnabled + 时段）：先不管——保留开关与时段设置，复用 `reminder_notification_coordinator` + `local_notification_gateway` 按设定时段触发。

#### B2. 通知权限卡片（#15）——真实现，保留

- 现状：三态（未授权/已授权/永久拒绝），永久拒绝直接跳系统设置，授权状态参与用药提醒调度判断。
- 真伪判定：真实现。结论：保留。

#### B3. 报告分享（dataSharingConsent，#21）——真实现，保留

- 现状：开关写后端 user-settings（`PATCH /user/settings`），二次确认弹窗；后端 assistant `read.service.ts` 真实读取该值决定上下文可用性。
- 真伪判定：真实现（有后端执行器）。结论：保留。

#### B4. AI 设置（#22）——真实现，保留

- 现状：四个开关 + 四个上下文开关 PATCH 到后端，`_isPatching` 防连点；成功后发 `DataChangeTopic.userSettings` 驱动 Today 页刷新。
- 真伪判定：真实现。结论：保留。

#### B5. 数据导出（#23）——真实现，但有两处体验问题

- 现状：`DataExportPage` 申请 → 后端队列 → PDF 生成（COS 存储）→ 轮询 `GET /data-export-requests/latest` → 下载链接；`POST` 端 `@RequireSecurityElevation()`。
- 实际作用：导出真实生成（就诊报告 PDF：hospital/monthly/print 三形态），报告页导出共用同一链路。
- 真伪判定：真实现。
- 结论：保留，作为次级出口（移入"更多"，用户主动寻找时可达；测量 surface=more）。两处体验改造：
  - **P2**：导出被 PIN 门禁硬性阻塞——未启用 PIN 的用户点击导出只弹"安全 PIN 未启用"toast 后无声失败，应引导去启用 PIN。
  - **P2**：导出内容与 FAQ 文案不符——后端注释明示"不导出原始用户数据"（是报告 PDF），FAQ 却写"导出你的健康数据"，且后端 TODO B4 承认缺数据可移植性导出（GDPR/PIPL）。改文案

#### B6. 数据存储设置（#24–#26）——混合：1 真 2 假

- 现状：
  - 数据保留期：**真**——`cacheCleanup` 在启动时按保留期清理本地 Drift 缓存（daily_records/dose_logs），保留 pending 未同步项。
  - 图片质量（标准/省流）：**假**——零消费者（grep 确认仅设置页与 l10n 引用），无任何图片加载分支读取。
  - 同步网络偏好（仅 Wi-Fi）：**假**——`SyncWorker` 只判断"任意网络 != none"即 flush，不读该偏好；全客户端无消费者。
- 真伪判定：1 真 2 假。
- 结论：改造（P1 与 B1 同批）。图片质量：接入图片压缩链路（`ImageCompressor` 按"标准/省流"参数消费）；同步网络偏好：SyncWorker 增加"仅 Wi-Fi"判断（connectivity 检查）消费该设置。

#### B7. 主题 / 语言 / 无障碍 / 高级设置 / 恢复默认（#27–#30）——真实现，保留

- 现状：`ThemeController`（mode/family/高对比度）、`LocaleController`、无障碍字号缩放均有真实消费方；高级设置（开发者端点选择）与功能开关页为本地偏好；恢复默认一键清空相关 PrefKeys。
- 真伪判定：真实现。结论：保留。

#### B8. 关于页与检查更新（#31–#32）——真实现，保留

- 现状：版本取自 `package_info_plus`；"检查更新"经 `GET /public/app-info` 拿 `latestVersion`/`downloadUrl` 做 semver 比较，发现新版本自动打开下载页；后端字段由环境变量配置；7 个法律入口齐全（见 C 节）。
- 真伪判定：真实现。结论：保留。P2 遗留：ICP 备案 + 公司信息（计划 P2-1 明确待实施，非假实现）。

### C. 法律页面（legal）——视为已上线评估，真实现

#### C1. 7 类法律文档（#39）——真实现，保留

- 现状：`LucentLegalRepository` remote-first（`GET /legal-documents` 列表/详情，Prisma 持久化 + 1 小时缓存），404 时回退 `assets/legal/` 本地 Markdown；双语 14 个文件齐全（privacy/terms/disclaimer/minor-protection/sdk-list/permissions/account-cancellation × zh/en），内容为真实可读正文（如隐私政策含信息收集/使用/存储/权限章节，约 2.2KB），非占位空壳。
- 实际作用：列表页展示 7 类文档（类型图标 + 标题 + 更新时间），详情页 `MarkdownBody` + 可选中文本 + 响应式限宽 + 更新时间展示。
- 真伪判定：真实现。结论：保留。与注销页、登录/注册条款入口闭环。

### D. 个人中心（mine）

#### D1. 个人资料主卡 / 完整度 / 缺口检测（#33）——真实现，保留

- 现状：`LucentMineRepository` 是纯聚合层（无自有数据源），组合 account（auth session）+ `healthContextSnapshotProvider`（后端 health-context）计算 7 项完整度与 6 项缺口；未登录 preview 用 `signedOut()` 静态数据。
- 真伪判定：真实现（数据全部来自后端，非占位）。结论：保留。

#### D2. 昵称 / 头像编辑（#34）——真实现，保留

- 现状：账号页 ProfileSection PATCH `POST /account`（`updateAccountProfile`），成功后 `applyUser` 同步 session。
- 真伪判定：真实现。结论：保留。

#### D3. 健康档案 CRUD（#35–#36）——真实现，保留

- 现状：资料编辑（身高/体重/出生日期/生理性别/血型/紧急联系人）走 `healthProfileFormProvider` → `PATCH /health-context/profile`；过敏/疾病/用药 CRUD 走 health-context 全 CRUD 接口；删除均二次确认；失败有 errorMessage + toast。
- 真伪判定：真实现。结论：保留。

#### D4. 同步失败横幅（#37）——真实现，保留

- 现状：`MineSyncFailedBanner` 由 `PendingSyncDao.permanentlyFailedCount()` 驱动；详情对话框展示失败条目（类型/操作/记录 ID/尝试次数/错误），用户面/诊断面分离（友好文案 + 诊断信息折叠 + 一键复制 TraceID）；"全部重试" resetForRetry + `SyncWorker.flush()`。
- 真伪判定：真实现。结论：保留。

#### D5. Mine 页分组入口（#38 及账号与安全/安全 PIN/退出登录入口）——真实现，保留

- 现状：通知与提醒分组（收件箱未读数来自真实后端，notification 模块，不重复审计）、AI 与隐私分组、账号与安全分组、退出登录（未登录不渲染成危险操作）均接入真实路由与状态。
- 真伪判定：真实现。结论：保留。

### E. 支持（support）

#### E1. 帮助中心 FAQ（#42）——真实现，保留

- 现状：帮助页自包含（2026-07-28 重构），FAQ 来自 `assets/faq/faq_{zh,en}.md`（6 组 Q&A），`FCollapsible` 折叠 + `MarkdownBody` 渲染 + 骨架屏/重试。
- 真伪判定：真实现。结论：保留。

#### E2. 意见反馈（#43）——真实现（邮件渠道，非后端工单），保留

- 现状：`_FeedbackSection` 优先取后端 `appInfoProvider.supportEmail`，回退编译期 `SUPPORT_EMAIL` 环境变量，构造 `mailto:` 唤起系统邮件客户端；失败/未配置均有 toast；页面附"最近请求 TraceID"一键复制，便于与后端日志关联。
- 真伪判定：真实现（反馈真实可达，但渠道是邮件客户端而非后端提交——这是刻意的自包含设计，非占位）。
- 结论：保留。若后期需要站内工单，再评估后端提交通道。

#### E3. 客户端 support 数据层（#44）——死代码

- 现状：`features/support/` 下 `supportResourcesProvider`、`LucentSupportRepository` 在帮助页自包含化后**零消费方**；仅同文件的 `appInfoProvider` 仍在被 about/help 页使用。
- 真伪判定：死代码（除 appInfo provider 外）。
- 结论：改造（P2）。本地 FAQ 内容上收到后端 `support-resources` 作为可运营内容源（静态配置 → 可运营），前端帮助页改回消费后端内容；保留 `appInfoProvider` 与 repository 中的 appInfo 部分（仍被 about/help 页使用），resources 部分随上收改造为后端内容消费。

#### E4. 后端 support-resources 资源列表接口（#45）——真实现但客户端已弃用

- 现状：`SupportResourcesService.getResources()` 返回静态列表；客户端已不调用该接口（生成的 `support_resources_api.dart` 无人使用），`app-info` 端点仍被客户端消费。
- 真伪判定：真实现（客户端弃用）。
- 结论：改造（P2）。保留后端 `support-resources` 接口作为未来运营入口：本地 FAQ 内容上收为该接口的可运营内容源（静态配置 → 可运营），前端帮助页改回消费后端内容；或至少保留接口与静态常量不作删除，避免未来站内帮助中心重建成本。

(关于E3和E4的统一回复:目前客户端的FAQ内容仅通过Luminous/assets下的静态md文档分割得到,不由后端提供,仅消费前端自有静态资源,非动态实现.删除该后端接口)

---

## 三、后端投入错配判断

1. **会话管理 API（`GET/DELETE /auth/sessions`）**：后端完整实现（含单测），客户端生成客户端已含方法但无任何 UI 与调用。属"后端先行、C 端未接"的悬空投入。建议：P2 补客户端"登录设备管理"（安全卖点与 PIN 定位一致），或移除接口。
4. **数据导出 ≠ 数据可移植性**：`DataExportService` 注释明示"不导出原始用户数据"，导出物是就诊报告 PDF；后端 TODO（B4）自认缺失"匿名化数据导出 → 数据可移植性 JSON 导出"（GDPR/PIPL）。而客户端 FAQ 宣称"导出你的健康数据"。这是"名义功能与真实能力"的错配：要么落实真正的数据导出（P1，合规刚需），要么改 FAQ 文案（P2 兜底）。
5. **健康平台自动同步**：后端执行器未配置、开关禁用——已在 `platform-通知与横切能力.md` 审计，本组仅引用：设置页自动同步开关在未配置执行器前保持禁用是正确做法，无额外投入错配。

---

