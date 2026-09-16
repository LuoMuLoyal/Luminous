---
status: active
owner: frontend
updated: 2026-09-15
---

# 2026-09-08 ~ 09-14 审查报告修复计划

来源：`plans/Luminous-review-09-{08..14}.md` 七份每日审查（本计划落地后源文件删除）。
本计划**逐条对照 2026-09-15 工作树（HEAD=98e62f4a）核实过**，剔除了已修复项、误报与过时项，
行号均为核实当日实际行号，执行时以符号定位为准。

核实方法：5 路并行子代理逐条判定（CONFIRMED / PARTIAL / ALREADY-FIXED / FALSE-POSITIVE / STALE）+ 主线程复核关键项；
本计划成文后又按"问题类别"对全库做了一轮同型补扫（结果见 §5，其中 §5-6 是扫描命中但经核实不改的记录）。
各日判定统计：09-08：2 ALREADY-FIXED（死代码三件套见 251036b5、avatarController）、1 已决策（pre-push）、1 FALSE-POSITIVE（S-4）；
09-09：2 STALE、3 项为流程约定（并入 §5）；09-10：1 PARTIAL、4 CONFIRMED；
09-11：13 CONFIRMED、3 PARTIAL、2 ALREADY-FIXED、1 STALE；09-12：12 CONFIRMED、4 PARTIAL、1 ALREADY-FIXED、1 FALSE-POSITIVE；
09-13：12 CONFIRMED、4 PARTIAL、1 ALREADY-FIXED、1 FALSE-POSITIVE；09-14：8 CONFIRMED、4 PARTIAL、1 ALREADY-FIXED。

## 0. 误报与已修复项（不立项，执行时勿顺手"补修"）

以下条目经核实**无需动作**，列出以避免返工：

- 09-08 C-1/C-2（`account_settings*.dart` 三件套死代码）：已在 09-12 账号重构中整体删除（8aba4b8b 等），`git ls-files` 无残留。
- 09-08 C-3（pre-push 摘除 `flutter test`）：`7ab36dd9`（09-08 当天）有意轻量化且迁移日志已登记；CI `luminous-ci.yml:65` 跑全量 `flutter test --coverage`。**现状即决策，不回滚**；若要调整属独立议题，不进本计划。
- 09-08 W-7（测试断言 l10n key 与页面不一致）：实为**双份 key 并存**（`authAccountManageCustomerService` 与 `authAccountManageSupportCustomerService` 同文案，auth_zh.arb:227-235，generated 本地化两套都有，测试当前全绿）。处置归并到 §4-9（l10n 键去重）。
- 09-09 #1/#4（AuthPageHeader 类级重复、AuthScaffold 雏形）：壳层已于 8aba4b8b 整体删除（含 docs/TODO.md S-7 条目），议题终结。
- 09-12 W-7（ProfilePage.avatarController 死代码）：09-13 重写已删（e9afdeac），现为 `avatarDraft`/`avatarRemoved` useState。
- 09-12 S-6（_variantKey 缺注释）：引入实现时注释已自带（page_state.dart:171-175）。
- 09-13 S-1/S-6（OAuthButtonRow 五页重复 wiring）：**误报**。git -S 全历史显示该组件只进过 login.dart（a7ab09cb 起），register/forgot_password/change_email/account_manage 四页从未有过 OAuth wiring；S-6 并入 docs/TODO.md 已登记的微博全链路移除项，不单独立项。
- 09-13 S-7（account_manage_helpers 死代码）：无 emergencyContact 残留，4 个 helper 均有活跃调用点。
- 09-13 S-14（notification 空态绕路）：`ResponsiveContentFrame.expand: true` 正是为此提供的 sanctioned 解法，现状干净。
- 09-14 S-2（showTextEditSheet label 约束）：调用点注释已存在（profile.dart:134），剩余"加 lint"成本大于收益，不做。
- 09-14 "重复造轮子"节核心建议（给 ResponsiveContentFrame 加 padding 参数）：**报告前提错误**——padding 参数 2026-07-04（67efe044）已存在，且语义是水平 padding，与 auth 页的 vertical Padding 正交。处置见 §4-11。
- 09-12 S-4（tab_branch_container late 初始化器）：行为无风险（初始化器首次访问必在 initState 后）；报告建议的"构造函数赋值"不可行。不改。
- 09-10 #4（authGuarded 签名护栏 lint/grep 矩阵）：`unawaited_futures`/`discarded_futures` 已是 error 级基线 0 违规，主漏网路径已被挡住；按"加规则要慎重"约定不做新 lint。仅保留 doc 说明（§4-6）。
- 09-09 #3/#5（旧日志回填输出痕迹、lucent_dashboard 行号索引）：append-only 日志不回填；grep 注释文字即可定位、行号引用易漂移。两者均"今后执行口径"（§5），不动旧文件。
- 09-08 S-4（oauth_wechat web fallback 漏设 errorMessage）：**误报**——入口 L35-40 已 `errorMessage: null`，带错路径 L48-50/L57-59 立即 return Failed，catch 必然覆盖。
- 报告通用勘误：07-13/09-08 报告引用的 `lib/core/feedback/app_toast.dart` / `AppToast` 类名**不存在**，仓库实际是 `lib/core/feedback/toast.dart` 的 `Toast.show`（本计划所有 toast 项按真实 API 写）。

## 1. P0 — 契约一致性（先做）

### 1-1. 测试 fixture 与真实契约的一致性【09-14 C1，已清理后留下的口径】

已下线的字段（`bloodType` / `emergencyContact`）曾在 8 个测试文件里留存：wire DTO
`disallowUnrecognizedKeys: false` 宽松解析不会报错，测试继续绿，但 fixture 已与真实响应脱节——
同类"契约收敛后测试没跟着收敛"的问题读代码发现不了，只能靠对后端契约逐字段核对。

- 已清理 8 处（3 处 `missingCoreProfileFields: ['bloodType']` 改为真实缺口字段、1 处对已退场字段的
  恒真断言、1 处 clinic summary 冗余字段、3 处 JSON fixture 补 `activityLevel`/`dietaryPreferences`）。
- 后续新增/修改 fixture 时：字段名与可空性以 Lucent 的 zod schema / types 为准
  （如 `CORE_PROFILE_FIELDS`、`clinicSummaryProfileSchema`），不要凭 DTO 生成物反推业务取值。

## 2. P1 — 真 bug 与行为缺口

### 2-1. legacy profile_edit 页退役【09-14 S1】P1·M

核实修正：legacy 页**不是**"只剩能打开"——mine tab 有 5 个活入口（lucent.dart:214、archive_handlers.dart:9、account_hero.dart:341/346/351）。两套编辑页并存（`/mine/profile/edit` vs `/profile`）语义重复，新页是规范实现。分两步：

1. 5 个入口改指 `Routes.profile`（账号信息/性别/体重三个 readiness gap 均已有对应 sheet 行）。
2. 跑 `test/mine` 绿后删 `MineProfileEditRoute`（routes.dart:22-30 + routes.g.dart 重生成）+ `profile_edit.dart` + `edit_pages_test.dart` 等孤儿测试。

## 3. P2·A — 正确性收口（低成本，尽快）

### 3-1. `_DietaryPreferencesRow` 引用比较【09-13 S-10】P2·S

`profile.dart:617-623` 改 `const ListEquality().equals(...)`（collection 包已是依赖）；或父层 `useMemoized` 缓存列表引用。取前者，一行。

### 3-2. `_wireValue` List 分支 assert【09-13 S-11】P2·S

`snapshot.dart:255-265` else 分支加 `assert(item is String || item is num || item is bool, ...)`，debug 期暴露未来 List<DateTime>/List<Map> 误用。

### 3-3. avatar 裁剪失败用 SnackBar【09-12 W-6 附带发现】P2·S

`avatar_draft.dart:159-164` `_showCropFailure` 用 ScaffoldMessenger/SnackBar，违反"轻反馈用 AppToast"约定。迁 `Toast.show(l10n.profileAvatarCropFailed)`（新 ARB 键）；`bytes.isEmpty` 分支补 `Toast.show(l10n.profileAvatarEmptyFile)`；取消路径维持静默（主动取消不提示是合理 UX）。

### 3-4. OCR `_DigestAccumulator` 简化【09-12 S-3】P2·S

`ocr_model_manager.dart:72-96` 换 `sha256.bind(file.openRead()).first`（crypto 3.x 公开 API），删 accumulator 类。行为等价，verifier fake 不受影响。

### 3-5. unit_conversion 回退路径测试【09-13 S-4】P2·S

回退常数是文档化设计（unit_conversion.dart:13-16），保留；补一个单测断言「包返回 null 时走本地公式」路径，把降级策略钉进测试。

### 3-6. l10n 双份同文案键去重【09-08 W-7 真实内核】P2·S

`authAccountManageCustomerService/Feedback/HelpCenter` 与 `authAccountManageSupport*` 三对同文案键并存（auth_zh.arb:227-235）。页面已全用 `Support*` 前缀（account_manage_sections.dart:362-376）；测试用旧前缀（account_settings_page_test.dart:51-53）。删旧三键（zh+en 分片），测试改用 `Support*` 键，merge + gen-l10n，同步 localization.md。零引用键清理前跑一次 grep 确认。

### 3-7. `weightInLb` 定位澄清【09-13 S-13】P2·S

`weightInLb` 是 archive_sections.dart:70 的现役接口，非"旧别名"。直接让 archive_sections 改用 `kgToLb` 后删掉该函数（消多余间接层）；同步 unit_conversion_test 删对应 group。

### 3-8. auth 页骨架收敛 AuthScrollBody【09-14 "重复造轮子"修正案】P2·S

报告的 padding 参数方案不成立（见 §0）。改为 auth feature 内加 `AuthScrollBody`（~10 行 StatelessWidget 包 `SingleChildScrollView → ResponsiveContentFrame → Padding(vertical: width<mobile?xl2:xl3) → Column`），6 页（login/register/forgot_password/change_email/account_manage/security_center）各减 ~6 行；这是行为组合而非样式 preset，符合 AGENTS.md wrapper 例外。与 §4-7 骨架测试同批做。

### 3-9. 生成模型 `ReportSummaryAsync/Stream*` 清理【09-08 W-2】P2·M（跨仓，合同级）

`bootstrap.dart:666-687` 的 reviewModels 列出的 async 8 + stream 7 个模型在 lib/test/integration_test **零消费**（实际 SSE 走 `ai_summary_remote.dart:49-51` 原始 `LucentSseClient.postJson`，结果只用 `ReportSummaryResponse`）；review 页 AI 摘要主路径已退役（docs/TODO.md「延后」段），legacy 兼容页仅消费 `ReportSummaryResponse`。**不能**直接从 reviewModels 删——`_filteredClients` 要求 models 与 reports_api.dart import 闭包一致并 fail-fast（bootstrap.dart:730-736），Lucent openapi.json 仍暴露 enqueue/stream 两端点。正确路径：Lucent 侧决策删除两端点（或登记延后）→ `pnpm export:openapi` → `dart run scripts/contract/bootstrap.dart` 重跑后模型自然消失。属跨仓合同决策，与 docs/TODO.md 的「Review AI 摘要复核」项合并执行，本计划只登记不实施。

## 4. P2·B — 文档注释与测试补强

1. **page_state.dart:84-87 Priority 1 注释**【09-10 #2】：函数体不读 `session.isRestoring`，把从句改为行为式表述（"During session restore, providers gated by authGuarded stay loading on a cache miss…"）。P2·S
2. **markdown_style.dart:84**【09-11 W-1】：`level5=20/级` → `xl=20/级`、`level2=6` → `sm=6`。P2·S
3. **AuthShell 残留注释 ×3**【09-14 W1】：account_sessions.dart:44、account_security.dart:295、account_identity.dart:275 改「与认证页标准骨架（PageScaffold）共用同一层背景」。P2·S
4. **profile.dart:546-547 幽灵文件注释**【09-13 W-3】：enum_select_sheet.dart 不存在，改「枚举字段走内嵌 FSelectMenuTile，数值（身高/体重）走 quantity_sheet」。P2·S
5. **state_message.dart `card` 参数 docstring**【09-14 S4 + 09-13 S-2/S-3】：补「`card: false` 时不包裹滚动视口，调用方需自行保证外层可滚动」；card/scrollable 参数拆分不做（唯一调用方 notification/list.dart 行为正确）。P2·S
6. **auth_guarded.dart doc 签名演进说明**【09-10 #4】：Usage 段前加一段「async since 2026-09-10；同步上下文不能 try/catch AuthRequiredException，用 FutureProvider/AsyncNotifier」。P2·S
7. **login_page_test 骨架断言**【09-14 S5】：窄/宽屏断言 Padding vertical == xl2/xl3（配合 §3-9 的 AuthScrollBody 则断言 wrapper）；勿断言已删除的类名。P2·S
8. **box_scan_preview.dart:25 注释**【09-13 S-9】：补「父级 SingleChildScrollView 已带滚动，FTileGroup 须禁用自身滚动避免双滚动」。P2·S
9. **icon_picker_sheet.dart:164-171**【09-13 S-8】：手绘 handle 换 `SheetDragHandle` + 补标题行；不套完整 showAppEditSheet（即点即选无确认语义）。P2·S
10. **security_center.dart:194-211 预留入口**【09-08 W-4 / 09-13 W-6】：`onPress: null` 渲染禁用态并去 `actionNext` 箭头，保留 ComingSoon 文案。P2·S
11. **mine 头像语义标签**【09-12 S-1 残留】：avatar_action_view.dart:46-48 有头像时 label 用 `profileAvatarViewerLabel` 但点击开管理面，换成「管理头像」方向 ARB 键；导航行为不动。P2·S
12. **avatar_viewer.dart 桌面尺寸**【09-13 S-15】：桌面分支 420/280 改随约束计算（`maxHeight*0.8` / `min(280, width*0.5)`）。P2·S
13. **titleContentGap 钉死**【09-11 S-4】：新 widget 测试断言 `context.titleContentGap == 14 == Spacing.lg`（FTheme.scope 内）。P2·S
14. **searchGate addTearDown**【09-10 #5】：medicine_search_notifier_test.dart 加 `addTearDown(() { final g = searchGate; if (g != null && !g.isCompleted) g.complete(); })`，防 expect 失败时吃满 30s 超时。P2·S
15. **测试真实时钟收敛**【09-10 #3】：4 处 50ms 改 `await expectLater(c.read(provider.future), throwsA(isA<AuthRequiredException>()))`（session_gate_test.dart:117、auth_guarded_test.dart:52/128/148/168、risk_check_provider_test.dart:77、risk_check_providers_test.dart:227,250）；450ms debounce 系列（search 测试 14 处）本轮不动（需 lib 注入钩子，收益一般）。P2·M
16. **account_manage.dart:81-100 双路径**【09-12 S-5】：useEffect 依赖改 `[wechatCode, wechatState, session.isLoading]` 后删 build 内兜底注册；现有 OAuth 回调测试验证。P2·S
17. **AvatarView 40px border**【09-12 S-7】：视觉复核后 account_manage_sections.dart:94-99 传 `borderColor: Colors.transparent` 或维持默认；不加 dense 模式。P2·S
18. **analyze_trace 0x0A 快检**【09-12 S-2】：可选，工具脚本不在门禁内；时间富余再做。P2·S
19. **测试文件改名**【09-08 W-6】：`test/mine/account_settings_page_test.dart` 实测的是 `AccountManagePage`，`git mv` 为 `account_manage_page_test.dart`（与 §3-9 同文件，一批做）。P2·S
20. **account_manage 测试补强**【09-08 W-1】P2·M：widget 测试进对话框输密码提交、断言 remote 收到的字段与登录态清理（provider 层副作用已由 test/auth/.../account_provider_test.dart:560-610 覆盖，此处补 UI 链路）。
21. **oauth_wechat.dart:92-96 冗余状态位**【09-08 S-1】：`startWechatMobileLogin` 内层 `isStartingWechat: true` 与外层入口（L35-40）重复，删内层重复设置。P2·S
22. **notification.dart 同步契约注释**【09-08 S-2】：remote_sync mixin doc 补「失败回滚 state 后 rethrow，调用方需 catch」（notification.dart:161-166 现行为）；页面未 catch 属预期（上层兜底），doc 说清即可。P2·S
23. **health_event_section catch helper**【09-08 S-3】：两处手写 `catch (e, st) + talker` 可抽 core 层 helper，可选，现状可读性尚可。P2·S
24. **FakeSupportRepository 去重**【09-08 S-5】：test/mine/account_settings_page_test.dart:437-442 与 test/settings/help_settings_page_test.dart:165 两份重复，抽 `test/helpers/fake_support_repository.dart`。P2·S
25. **showWechatLink 调用点注释**【09-08 S-6】：account_identity.dart:125-127 参数 doc + login.dart:359 已可发现，可选不加。P2·S

## 5. 同类问题补扫（本计划成文后按问题类别对全库重扫的增量）

方法：把已确认条目抽象成模式，逐类全库 grep + 逐命中读上下文判定。**下表"不改"项同样重要**——
它们是扫描命中但经核实属于合理设计，执行时不要为"一致性"去动。

### 5-1. 假成功同型扫查结论

`settings/profile.dart` 的 `_submit` 是唯一一处真实假成功点（已修）。补扫时曾判定
`mine/presentation/pages/profile_edit.dart:92-93` 只监听 `saved`、缺 `errorMessage` 分支；**开工复核推翻**：
该文件 88-100 行的 `ref.listen` 内 96-99 行**已有** `errorMessage` 变化时的失败 toast，当时误判源于只读了两行。

`health_edit_forms.dart` 四个 Notifier 的 `saved`/`errorMessage` 语义本身是**正确**的（Allergy 65-110、
Condition、CurrentMedicine 均失败置 `errorMessage` 而不置 `saved`，mine 侧三个 edit 页的 listener
也都同时处理两者）。

`medicine/presentation/pages/reminder/detail.dart:361-372` 是**正确范式**（`success` 三元 toast），
后续同类修复可作参照写法。

### 5-2. l10n 同文案双份键远不止 auth 三组：全库 84 组【P2·M】

§3-9 只处理了 auth 的 3 组，实际按「同一 zh 分片内值完全相同（长度 ≥2，剔除 `@` 元数据）」扫描得
**84 组**（assistant 3、auth 14、common 3、medicine 17、mine 6、network 2、notification 2、
record 13、review 15、settings 6、today 3；含三/四份同值的）。**不能一键全删**——需按语义分三类处置：

1. **有意区分（保留）**：编辑态 vs 页面标题（`authChangeEmailFormTitle`/`authEmailChangeAction`）、
   列表 vs 详情（`legalListTitle`/`legalDetailTitle`）、入口 vs 页标题（`assistantEntryTitle`/`assistantPageTitle`
   ——已核实分别被 today/review 顶栏与 assistant 页消费）、
   `medicineQuickSafetyCheckTitle`（medicine 页快捷操作卡，4 处消费）vs `medicineRiskCheckPageTitle`
   （risk_check 页标题，2 处消费）、`scanViewReminderAction`（scan 侧 2 处 + 测试 6 处）vs
   `medicineDetailOpenReminderAction`（medicine_detail_content:115 单点）。
   判定口径：**两个键的消费点分属不同 UI 语境就保留**；写脚本时必须把消费点列出来逐个看，不能只看文案。
2. **纯重复（删一留一）**：`authAccountManageSupport*` vs `authAccountManage*`（§3-9，已核实页面用
   `Support*`、测试用旧键，属真重复）；其余读消费点时若发现"同一 UI 语境两个键"即归此类。
3. **枚举/状态同值（保留）**：`reviewStatusUnknown`/`reviewReviewStatusUnknown`/`reviewReviewOutcomeUnknown`、
   `medicineDoseStatusTaken` 等，不同实体各有语义，删一个会迫使跨实体复用同一键。

执行方式：写一次性脚本列出 62 组 + 各自全部消费点（`lib/` 与 `test/`），人工按上述三类标注后批量处置；
合并 + gen-l10n + `localization.md` 同步。**不要**为省事按键名前缀自动删。

### 5-3. `TODO(...)` 标记未登记 docs/TODO.md【P2·S】

AGENTS.md 的 Deferred marker 约定要求"保留标记 + **同时**有 TODO 条目"。实测 lib/ 有 14 处 TODO，
其中 13 处 `TODO(archive)`（medicine safety_tips/safety_tip/workspace 死代码保留）、
1 处 `TODO(lint-cleanup)`（`lucent_dashboard.dart:3`，已有 `// tracked-by-TODO-...` 跟踪串且在
docs/TODO.md:110-113 有对应条目）、1 处 `TODO(cleanup)`（`database.dart:97` sqlite_master 防御检查）、
1 处账号管理微信（§2-3 已覆盖）。

**缺口**：`TODO(archive)` ×13（分布在 7 个 medicine 文件：safety_tips_remote 1、lucent_workspace 3、
dose_log 1、safety_tip 1、workspace 5、safety_tips 1、safety_tip_style 1）与 `TODO(cleanup)` ×1
在 docs/TODO.md **零命中**。修复：在 docs/TODO.md「延后（有明确原因）」段追加一条
「medicine 历史 dashboard 原型残留与 safety_tips 死代码保留」（说明保留原因 = 兼容历史形状 /
未来随机安全贴士可能复用），并把 `database.dart:97` 的 sqlite_master 防御检查一并登记或直接删除该 TODO
（若检查已无必要）。

### 5-4. 测试真实时钟：§4-15 只覆盖 6 处，实际 16 文件【P2·M】

全库 `Future.delayed` 分布 16 个测试文件。按性质分三类：

- **必须修（与 §4-15 同类：等待一个本可等待的 Future/状态）**：`auth_guarded_test.dart` ×3、
  `risk_check_provider_test.dart`/`risk_check_providers_test.dart`、`session_gate_test.dart` —— 已在 §4-15。
- **可改用 `tester.pump(Duration)`（widget 环境）**：`legal_providers_test.dart` ×2、
  `suggestion_provider_test.dart` ×2、`ai_analysis_provider_test.dart` ×2、`profile_sync_test.dart` ×1、
  `safety_tips_provider_test.dart` ×1、`cached_dose_log_data_source_test.dart` ×6、
  `lucent_repository_test.dart` ×4、`worker_test.dart` ×1、`dao_test.dart` ×1、`sse_test.dart` ×2、
  `message_handler_test.dart` ×2 —— 逐个评估，pure-Dart 测试（非 widget）只能保留真实 delay。
- **有意真时钟（不改）**：`form_mixin_test.dart` ×9（cooldown 是 `Timer.periodic` 1 秒真实节拍，
  测试断言 1050ms 后减 1；lib 侧无注入钩子，改造成本 > 收益）、`medicine_search_notifier_test.dart` ×18
  （450ms debounce，已列入 §6「明确不做」）、`test_helpers.dart` ×2（helper 内部）。

处置：本计划只把第一类做完（§4-15），第二类**逐文件评估后修**（列为 P2·M 单独一批），第三类明确记录不动。

### 5-5. 反序列化硬 cast：§3-2 之外的同类点【P2·S】

- `lib/core/network/client/session_store.dart:307-308`：`decoded['accessToken'] as String?` 在
  `jsonDecode` 已 try/catch + `is! Map` 守卫之后，**但键值是数字/嵌套对象时仍抛**。同 §3-2 加
  `_stringOrNull(Object?)` 容错 helper（返回 null 即视为无 token）。
- `lib/features/record/application/usecases/quick_entry_sleep.dart:191`：`record.payload?[key] as String?`
  在 `DateTime.tryParse` 前硬 cast，payload 类型异常直接抛。改 `payload?[key] is String ? ... : null`。
- **不改（自产自销，写入端同为本地 codec，类型受控）**：`daily_record_json_codec.dart`（约 20 处
  `as String?`/`as int?`）、`dose_log_cached.dart:272-281`、`suggestion_json_codec.dart`（已是
  `_asString`/`_safeInt` 容错风格，无需动）、`ai_remote.dart:67-107`（响应来自自家 Lucent，
  problem+json 合同已知；`sourceVersion ?? 0` 是版本比较的显式降级，语义正确）。
- **不改（Stream cast 非数据 cast）**：`sse.dart:133` 的 `byteStream.cast<List<int>>()`。

### 5-6. 静默 catch：10 处 `catch (_)` + 6 处无日志 `catch (e)` 逐个定性 —— **均不改**【记录用】

`catch (_)`：`pending_sync.dart:222`（JSON 解析失败返回 null，注释在方法语义内）、
`dio_client.dart:218`（Sentry 探测，返回 false 即"未启用"，无诊断价值）、
`local_date.dart:26`（快照未就绪取时区，返回 null 触发 fallback）、
`local_date.dart:49`（**已有注释**解释保留后端默认时区）、
health_event 三个 sheet（check_in/end_event/start_event，**均有大段注释**说明"统一投影到 submitError state"）、
`meal_analysis_poller.dart:66`（**已有注释**说明退避策略）、
`suggestion_primary_card.dart:353`（**已有注释**"cast 是防御性的，预期不抛"）。

无日志 `catch (e)`：`health_sync_controller.dart:41/66/84`（错误写入 `state.error`，UI 展示）、
`change_record_date.dart:35`（toast 提示）、`history.dart:148`（写入 `_loadMoreError`，UI 展示）、
`account.dart:126`（`_fail` 内部有 `talker.error`，第 196 行已核实）、
`lucent_daily.dart:190`（rethrow + `_enqueueWriteFailure`）、`lucent_daily.dart:307`（`appTalker.error`）、
`retry_interceptor.dart:81`/`auth_interceptor.dart:179`（`handler.next(e)` 下传，拦截器不该吞也不该噪）。

## 6. 流程约定（写进 AGENTS.md，不涉及代码）

1. **同日收口文件选择**【09-09 #2】：在 Luminous/AGENTS.md Migration-log 节补一句——「收口旧 review 清单时优先新开当日日期的日志文件」。
2. **日志验证段口径**【09-09 #3】：新条目验证段写「执行的命令 + 结论」，不写精确数字（与既有"不写需要持续同步的精确数字"规则对齐）；旧日志不回填。

## 7. 执行顺序与验收

- **Wave 1（P1 主干）**：2-1。每项落地即跑对应目录 `flutter test`。
- **Wave 2（P2·A）**：3-1 → 3-2 → 3-3 → 3-4 → 3-5 → 3-6 → 3-7 → 3-8；3-9（合同级）与 §3-9/§4-19/§4-20 按 09-08 建议合批：同一测试文件（account_settings_page_test 改名 + key 去重 + 断言补强）一批做。
- **Wave 3（P2·B + 同类补扫 + 流程）**：§4 按 1-25 顺手清；§5 同类补扫按 §5-2（84 组 l10n 审计，独立一批，需列消费点脚本）→ §5-3（TODO 登记）→ §5-4（真实时钟第二类逐文件评估）；§5-6 是"逐命中定性后不改"的记录，**不要**为一致性去加日志改代码；最后 §5-5 之外的流程两句进 AGENTS.md。
- **收尾验收**：`flutter analyze` 零 issue；`flutter test` 全量绿；`dart run scripts/docs/verify.dart --warning-only` 无新增告警；l10n 相关改动后 `arb_tools.dart merge` + `flutter gen-l10n` + `docs/reference/localization.md` 同步；本计划全部项实施完毕后按约定整文件删除并在迁移日志登记。
- **明确不做**（除非另行立项）：avatar 真草稿化重构（09-13 W-2 后半）、450ms debounce 注入钩子、cooldown 真时钟测试改造（§5-4 第三类）、card/scrollable 参数拆分、tab_branch_container late 改写、authGuarded 新 lint 规则、pre-push 回滚加 test、reviewModels 手工删模型（走 3-9 合同级路径）、§5-6 的静默 catch 追改。
