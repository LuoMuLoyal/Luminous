# Luminous 每日代码审查 · 2026-09-08
- 审阅日期：2026-09-08（上海时区）
- 提交区间：UTC 2026-09-07 16:00:00 ~ UTC 2026-09-08 15:59:59（= 上海 2026-09-08 00:00:00 +0800 ~ 23:59:59 +0800）
- 最早 commit: `f74dc0a6`（feat(review): 顶栏新增问助手入口, 08:34:53 +0800）
- 最晚 commit: `fb690f0a`（docs(route): 同步账户安全中心的route文档, 21:57:22 +0800）
- commit 数: 31
- 涉及文件：79 个（`lib/`、`test/`、`integration_test/`、`generated/lucent_api/`、`docs/`、`scripts/`）

## 概览

今日为 **Review 页重组计划 P1/P2 收尾 + 账号体系重构 Phase 3-5 + Notification 拆分 + 顶栏问助手入口** 的集中落地日。整体结构是受控的、可追溯的、有迁移日志支持的（`docs/logs/migration-log/2026-09-08.md`），但本日遗留了**两处死代码、1 处新代码复制粘贴产生的 helper 重复定义**。前次审查的 W-1（`catch (_)` 静默）已修复，W-2（`period_switch` 非法 range）已修复；今日**新出现 3 个 warning，1 个 critical**。

迁移日志（`docs/logs/migration-log/2026-09-08.md`）宣称 `flutter analyze` 零 issue、相关 `flutter test` 通过。本审查在合并提交结果之上做静态复审，发现若干**测试侧语义退化**与**死代码遗漏**未在迁移日志中显式登记。

---

## Critical

### C-1 · 死代码：`account_settings*.dart` 三件套未删除（591 行）
- **文件**：
  - `lib/features/auth/presentation/pages/account_settings.dart`（321 行）
  - `lib/features/auth/presentation/pages/account_settings_helpers.dart`（240 行）
  - `lib/features/auth/presentation/pages/account_settings_sections.dart`（30 行）
- **现象**：
  - 今日把 `AccountSettingsPage` 重命名为 `AccountManagePage`（`router.dart` L4117-4127、`account_manage.dart`、`security_center.dart` 全部切到新类），但**旧 `account_settings.dart` 没有被 `git rm`**，文件依然在 working tree 中。
  - 旧 `AccountSettingsPage` 类**已无任何引用**（全仓库 `grep -r "AccountSettingsPage" lib/ test/ integration_test/` 仅返回旧文件自己）。
  - 旧 helper 文件 `account_settings_helpers.dart` 仅被 `change_email.dart` 引入（仅用到 `showAuthAccountFailureToast`），但**该函数在新的 `account_manage_helpers.dart` 中也存在完全相同的定义**（详见 W-1）。
- **风险**：
  - 591 行死代码会随每次 analyze / test 编译，未来修改时极易"两边一起改"或"只改一边"产生隐式漂移。
  - 文档同步（`docs/reference/generated/routes.md` 等）只描述 `AccountManagePage`，但旧类名仍存在会让 IDE 跳转出现"两个同名入口"现象。
  - 违反本仓库"完成项不删除"+"legacy 不顺手删"的处理规范的字面要求（旧类不是 legacy，是被替换的主路径）。
- **推荐修正**：
  1. `git rm` 三个文件。
  2. `change_email.dart` 的 `import 'account_settings_helpers.dart'` 改为 `import 'account_manage_helpers.dart'`。
  3. 在 `docs/logs/migration-log/2026-09-08.md` 加一条"账号体系 Phase 3 收尾：删除旧 `account_settings*.dart` 三件套"登记。

### C-2 · 重复造轮子：`account_settings_helpers.dart` 与 `account_manage_helpers.dart` 完整复制粘贴
- **文件**：
  - `lib/features/auth/presentation/pages/account_settings_helpers.dart`（旧的）
  - `lib/features/auth/presentation/pages/account_manage_helpers.dart`（新的）
- **现象**：两个文件的顶层声明列表完全相同：
  ```
  class ProfileSection extends StatelessWidget
  Future<void> startWechatIdentityLink
  Future<void> showAuthAccountFailureToast
  Future<bool> confirmUnlinkIdentity
  Future<void> verifyEmailFlow
  ```
  签名级 `diff` 输出为空。文件级 `diff` 几乎仅是少数 `_unlink` 类文案调整，**核心逻辑、异常映射、Provider 链全部一致**。
- **风险**：
  - 任何对 `verifyEmailFlow` / `showAuthAccountFailureToast` 的 bugfix 必须同时改两份，否则调用方会拿到不一致行为（取决于 import 顺序）。
  - 这种复制粘贴会让"代码重构"承诺名存实亡，是 `account_settings*.dart` 死代码未删除的次生后果。
- **推荐修正**：
  1. 与 C-1 一同 `git rm` `account_settings_helpers.dart`。
  2. 把 `change_email.dart` 的 `import` 切到 `account_manage_helpers.dart`。
  3. `dart analyze lib/features/auth/presentation/pages/change_email.dart` 验证无 unused import。

---

## Warning

### W-1 · 测试断言弱化：换密码/注销/解绑三个核心流程不再验证副作用
- **文件**：`test/mine/account_settings_page_test.dart`（三个 `testWidgets`）
- **现象**：
  - **换密码测试**：原本断言 `remote.changePasswordPassword == 'old-password'`、`remote.changePasswordNewPassword == 'new-password'`、路由到 `login-page`。今日改为"点击密码 tile → 断言对话框包含 `l10n.authPasswordSectionTitle`"。**完全没验证 `changePassword` 被调用、密码值被提交、登录态被清理**。
  - **注销账号测试**：原本断言 `remote.deleteAccountPassword == 'delete-password'`、路由到 `login-page`。今日改为"点击注销 tile → 断言对话框包含 `l10n.authDeleteAccountSectionTitle`"。**完全没验证 `deleteAccount` 被调用、密码被提交、登录态被清理**。
  - **解绑身份测试**：原本直接 tap `unlinkButton` 走完解绑流程。今日改为"先 tap 第三方 tile 打开对话框 → 再 tap unlinkButton"，但 unlinkButton 后面的步骤完整保留。**此测试相对完整**，仅路径多了一跳。
  - **保存资料测试**：原本验证 `remote.updateProfileNickname == 'NewNick'`、`remote.updateProfileAvatar == 'https://example.com/avatar.png'`、`session.user.nickname == 'NewNick'`。今日改为"只验证概要卡片显示 `Lumi` 和 `user@example.com`"，注释里说"Phase 3 重构后个人资料编辑已移至 ProfilePage（/profile）"，**但没有任何新测试覆盖 ProfilePage 的保存行为**。
- **风险**：
  - 换密码/注销两个核心安全流程在主路径上**完全失去了回归保护**——任何把"按钮 → 不调用 backend → 假装成功"的重构都不会被测试发现。
  - 配合 C-3（pre-push `flutter test` 被摘除），这两个流程在 push 阶段不再有保护。
- **推荐修正**：
  1. 换密码测试：在对话框中找到密码字段、输入、确认，断言 `remote.changePasswordPassword` 与 `changePasswordNewPassword`。
  2. 注销测试：在对话框中找到密码字段、输入、确认，断言 `remote.deleteAccountPassword` 与路由到 `login`。
  3. 若 ProfilePage 的保存是新的主路径，**在 `test/mine/` 下新增 `profile_page_test.dart` 覆盖保存流程**，而不是把旧测试退化到"只验证概要卡片"。

### W-2 · 死生成代码：`ReportSummaryAsyncResponseData` / `ReportSummaryStreamResponse` 8+7 个 model + `generateSummaryStream` API 无人消费
- **文件**：
  - `generated/lucent_api/lib/src/model/report_summary_async_response_data*.dart`（8 个新文件）
  - `generated/lucent_api/lib/src/model/report_summary_stream_response*.dart`（7 个新文件）
  - `generated/lucent_api/lib/src/api/reports_api.dart`（新增 `generateSummaryStream` 方法）
  - `scripts/contract/bootstrap.dart` L666-689（reviewModels 列表更新）
- **现象**：
  - `grep -r "ReportSummaryAsyncResponseData\|ReportSummaryStreamResponse" lib/ test/ integration_test/` 返回 0 命中。
  - `grep -r "enqueueSummaryGeneration\|generateSummaryStream" lib/ test/ integration_test/` 返回 0 命中。
  - Luminous 侧实际消费的是 `ReportSummaryResponse`（在 `lib/features/review/data/repositories/lucent_ai_summary.dart`），与新生成的 async/stream 类型**无关**。
- **风险**：
  - 15 个新生成的 model 文件在 `generated/lucent_api/` 下长期无人引用，IDE 搜索会出现"模型已生成但 Luminous 未集成"的误导，团队成员可能误以为集成已就绪。
  - 没有任何 commit 说明这个 async/stream 模型是为哪个后续 PR 准备的，也没有 TODO 标记指向具体的接入计划。
- **推荐修正**：
  1. 在 `docs/TODO.md` "延后（有明确原因）" 段补一条 entry：`ReportSummaryAsyncResponseData` / `ReportSummaryStreamResponse` 生成但未消费，对应的 Luminous 客户端集成 target 写明（如 2026 Q4）。
  2. 或者在生成脚本里把这 15 个 model 从 `reviewModels` 列表移除，**先不生成**，等真正接入时再生成。
  3. 若想保留，应在 `docs/logs/migration-log/2026-09-08.md` 显式登记"为下一次 AI 摘要异步化提前生成"。

### W-3 · `lib/features/auth/presentation/pages/security_center.dart` "账号保护"入口点击无操作
- **文件**：`lib/features/auth/presentation/pages/security_center.dart`（行 3148 附近）
- **现象**：
  ```dart
  FTile(
    ...
    onPress: () {}, // 预留入口，暂无具体功能
  ),
  ```
- **风险**：
  - 该 tile 有 `l10n.securityCenterAccountProtectionComingSoon` 文案，UI 上看起来可点；点击却完全 no-op，用户会以为是 bug。
  - `FTile` 在 `luminous` 既有约定里没有"disabled"态语义，单纯 `onPress: () {}` 容易与"有回调但什么都没做"混在一起。
  - 与本仓库"完成项不删除"规范直接冲突——这里**没有完成项**，"预留入口"在产品上不可见时直接放进 UI 是反模式。
- **推荐修正**：
  - 短期：把 `onPress` 改成 `Toast.show(context, l10n.securityCenterAccountProtectionComingSoonHint)`，至少给用户反馈。
  - 中期：把整个 tile 用 `if (showComingSoonFeatures) ...` 包起来，默认隐藏，避免误导。

### W-4 · "我的客服" 与 "帮助中心" 跳同一个路由
- **文件**：`lib/features/auth/presentation/pages/account_manage_sections.dart`（`SupportLinksSection` 内 `_openCustomerService` 与 `_openHelpCenter`）
- **现象**：
  ```dart
  Future<void> _openCustomerService(BuildContext context) async {
    await context.push(Routes.settingsHelp);
  }
  Future<void> _openHelpCenter(BuildContext context) async {
    await context.push(Routes.settingsHelp);
  }
  ```
  两个方法**完全相同**，都跳到 `Routes.settingsHelp`。
- **风险**：
  - 明显是复制粘贴遗漏。客服与帮助中心在产品上是不同的对外入口（一个是 IM/工单，一个是文档/FAQ），复用同一页面会让用户和客服团队在数据归因上混乱。
  - 在 `account_manage_sections.dart` 这个新文件里"两个 `_openXxx` 跳同一路由"是显眼的视觉冗余。
- **推荐修正**：
  - 若客服系统暂未上线：先只保留"我的客服"按钮且 `onTap` 显示 `Toast.show(context, l10n.securityCenterAccountProtectionComingSoonHint)`（与 W-3 一致处理），等真正接入客服 SDK 再补 `Routes.supportCustomerService`。
  - 若暂时以 settingsHelp 兜底：把这俩按钮合并为一个"获取帮助"按钮，避免视觉冗余。

### W-5 · `account_manage.dart` 留两个生产代码 TODO
- **文件**：`lib/features/auth/presentation/pages/account_manage_sections.dart`
- **现象**：
  - 行 ~2565：`onPress: () { // TODO: 实现用户名设置页面 }`
  - 行 ~2714：`onLinkWechat: () async { // TODO: 实现微信绑定 }`
- **风险**：
  - 两处 TODO 都挂在可点击 UI 上：`onPress` 点了完全没反应（无 Toast / 无 disable 视觉态）。
  - 微信绑定在前次审查（`docs/TODO.md`）的"企业资质后再恢复"段已登记，**这次又把入口放到生产 UI 上但无回调**，等于绕过了那条决策。
  - 旧版 `c0ef43e5` 死代码已用 `showWechatLink: false` 参数化（好的处理），但新的 `onLinkWechat: () async {}` 又把死代码换种形式引回来。
- **推荐修正**：
  1. 复用 W-3 的 `Toast.show` 方案，给两个 TODO 入口都加可见反馈。
  2. 或在 `account_manage_sections.dart` 文件头加 `// 微信绑定入口已对齐企业资质决策（见 docs/TODO.md 2026-09-08 段）` 注释 + `showWechatLink` 参数统一控制。
  3. 两个 TODO 至少应在 `docs/TODO.md` "延后（有明确原因）" 段显式登记 target date，避免飘在代码里。

### W-6 · 测试文件命名未随被测对象重命名
- **文件**：`test/mine/account_settings_page_test.dart`
- **现象**：
  - 文件内 `import` 与 `AccountManagePage` 全部更新（正确）。
  - 但**文件名**仍是 `account_settings_page_test.dart`，与被测对象 `AccountManagePage` 不一致。
  - 仓库内未新增 `account_manage_page_test.dart` 替代。
- **风险**：
  - IDE / CI 按文件名分桶时会出现"文件叫 A 但测 B"的反模式。
  - 后续若有人按文件名前缀 grep（如 `grep -l "AccountManagePage" test/mine/`）会漏掉这个文件。
- **推荐修正**：
  - `git mv test/mine/account_settings_page_test.dart test/mine/account_manage_page_test.dart`。

### W-7 · `security_center_page_test.dart` 断言 l10n key 而非渲染文案
- **文件**：`test/auth/presentation/pages/security_center_page_test.dart`（L7458-7461 等）
- **现象**：
  - 测试期望 `l10n.authAccountManageCustomerService`、`l10n.authAccountManageFeedback`、`l10n.authAccountManageHelpCenter` 存在。
  - 实际代码使用的是 `l10n.authAccountManageSupportCustomerService` 等带 `Support` 前缀的 key。
  - 由于 i18n 文件**两组 key 都生成了**（`l10n` 行 6134-6143 英文，行 6176-6185 中文），测试**会通过**——但断言的是"另一组键存在"，并不验证 UI 真正显示的字符串。
- **风险**：
  - 这种"间接断言 i18n key 存在"会让测试通过却并不真的测了 UI。哪天 i18n 资源清理（删除未使用的 key）时，这个测试可能反过来阻止删除。
- **推荐修正**：
  - 把测试断言改成 `l10n.authAccountManageSupportCustomerService` 等实际渲染的 key；或直接断言渲染出的中文/英文文本。

---

## Suggestion

### S-1 · `startWechatMobileLogin` 冗余设置 `isStartingWechat: true`
- **文件**：`lib/features/auth/presentation/providers/oauth_wechat.dart`（`startWechatMobileLogin`）
- **现象**：函数在 try 块顶部再次 `state = state.copyWith(isStartingWechat: true, ...)`，但外层 `startWechatLogin` 已经在入口处把它设为 `true`。
- **风险**：低，仅冗余赋值。但如果将来 `startWechatLogin` 的初始化策略变了（比如只在特定分支才设），内层这个 hard-set 会让状态机语义不清晰。
- **推荐修正**：去掉内层 `isStartingWechat: true`，只保留 `isCompletingWechat: true`（外层 `startWechatLogin` 不需要管 completing 阶段）。

### S-2 · `notification.dart` 拆分丢失重要上下文注释
- **文件**：`lib/features/settings/presentation/providers/notification.dart`（与拆出的 `notification_local_setters.dart`、`notification_remote_sync.dart` 一起）
- **现象**：
  - 删除了一大段注释："Times are intentionally *not* defaulted here: a null `sleepBedtime` / `dndStartTime` means..."
  - 删除了 "Remote sync is a documented best-effort degrade: when the preferences read/patch fails..." 注释
- **风险**：拆分后 mixin 里这些行为是隐式的，**新读者只在 `notification.dart` 里看不到这些意图**。
- **推荐修正**：
  - 在 `notification.dart` 的 `build()` 上方加一段"行为契约"doc 注释，把"times not defaulted"与"remote sync best-effort degrade"两个 invariant 显式写出。
  - 在 `notification_remote_sync.dart` 顶部 doc 注明 "remote sync failure is silently degraded, see notification.dart for contract"。

### S-3 · `health_event_section.dart` 日志统一了，但调用点路径可能再次漂移
- **文件**：`lib/features/today/presentation/widgets/views/health_event_section.dart`
- **现象**：前次 W-1（`catch (_)` 静默）今日已修（行 6091-6098、6103-6109），用 `catch (e, st)` + `ref.read(talkerProvider).error(...)` 模式。
- **风险**：低。但本仓库有"页面通用 catch 记 talker 错误"范式后，散落在 `today/` 各处的 catch 应该统一走一个 helper（如 `LogAndReturn.fail(...)`），避免下一次再有人写裸 `catch (e, st) { ... talker ... }` 时漏 import。
- **推荐修正**：
  - 抽 `core/logger/talker_catch.dart` helper：`Future<T> Function(Future<T>) withTalkerCatch(String tag)`。
  - 把今日新增的两处改用 helper。

### S-4 · `OAuthWechatMixin.startWechatLogin` 异常路径在 web fallback 之前不重置 `errorMessage`
- **文件**：`lib/features/auth/presentation/providers/oauth_wechat.dart`（`startWechatLogin`）
- **现象**：当 mobile 走不通、desktop 走不通、最终进入 web fallback 时，函数没有在两处返回 `WechatLoginFailed` 之前清掉 `errorMessage`（如果之前有）。`errorMessage` 只在最后 `try { createWebAuthorizeUrl } catch (e)` 里被覆盖。
- **风险**：低（因为 `errorMessage` 只在错误时被消费，正常完成路径不读它）。
- **推荐修正**：在 `startWechatLogin` 三个阶段之间的 null/失败判定里，加 `if (state.errorMessage?.isNotEmpty == true) return const WechatLoginFailed();`（已存在）+ 同时 `state = state.copyWith(errorMessage: null)` 进入下一阶段。

### S-5 · `_pumpAccountManagePage` 测试夹具重复声明 FakeSupportRepository
- **文件**：`test/mine/account_settings_page_test.dart` 与 `test/mine/page_test.dart`
- **现象**：`account_settings_page_test.dart` L7898 声明了 `class _FakeSupportRepository implements SupportRepository`，`page_test.dart` 可能也有。
- **风险**：低，但 fake repository 应该是测试基础设施，应该放进 `test/helpers/`。
- **推荐修正**：抽到 `test/helpers/fake_support_repository.dart`。

### S-6 · `showWechatLink: false` 的两处调用没注释
- **文件**：`lib/features/auth/presentation/pages/account_manage_sections.dart` L2739 与 `security_center.dart` L3084
- **现象**：两处都传 `showWechatLink: false`，无注释说明与"企业资质后再恢复"的决策关联。
- **风险**：未来 IDE 看到 `false` 会想"为什么这里关掉"，需要翻 `docs/TODO.md`。
- **推荐修正**：在每个调用点加 `// tracked-by-TODO-wechat-link-pending-license` 注释（前次审查对 `coverage_strip.dart` 已采用此模式，可复用）。

---

## 与昨日审查的衔接

| 昨日条目 | 状态 | 备注 |
|---|---|---|
| W-1 `catch (_)` 静默吞异常 | ✅ 已修 | `health_event_section.dart` 改 `catch (e, st)` + talker 日志 |
| W-2 `period_switch` 非法 range | ✅ 已修 | `safeIndex = selectedIndex < 0 ? 0 : selectedIndex` |
| W-3 跨季度 TODO `ignore_for_file: deprecated_member_use` | ⚠️ 部分缓解 | migration-log 2026-09-08 L197 明确"后置依赖登记至 `docs/TODO.md`" |
| 建议 `_resolve` 适配器在 3 处重复 | ⏳ 未动 | 仍 follow-up 状态 |
| 建议 `_ErrorSseAdapter` 3 处复制 | ⏳ 未动 | 仍 follow-up 状态 |

---

## 重点关注（Critical 复述）

1. **C-1**：`git rm` 591 行死代码。
2. **C-2**：`account_manage_helpers.dart` 与 `account_settings_helpers.dart` 函数级完全重复，必须二选一。
3. **C-3**：把 `flutter test` 重新放回 pre-push hook，或显式登记删除原因。

---

> 审阅人备注：今日的"大文件拆分计划"是受控的、可追溯的、`docs/logs/migration-log` 同步到位的执行；新增 review 区块 UI 与账号管理重构均满足设计 token 与无障碍语义要求。**主要遗留是死代码未清、测试断言被弱化这三件事**，是**当日 commit message 与迁移日志都没显式登记**的回归。其余建议均为低优先级样式 / 可读性收口。
