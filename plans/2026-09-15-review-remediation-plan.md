---
status: active
owner: frontend
updated: 2026-09-15
---

# 2026-09-08 ~ 09-14 审查报告修复计划

来源：`plans/Luminous-review-09-{08..14}.md` 七份每日审查（本计划落地后源文件删除）。
本计划**逐条对照 2026-09-15 工作树（HEAD=98e62f4a）核实过**，剔除了已修复项、误报与过时项，
行号均为核实当日实际行号，执行时以符号定位为准。

核实方法：5 路并行子代理逐条判定（CONFIRMED / PARTIAL / ALREADY-FIXED / FALSE-POSITIVE / STALE）+ 主线程复核关键项。
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

### 1-1. 测试 fixture 清理已下线的 `bloodType` / `emergencyContact`【09-14 C1】P0·M

契约已删（d660cc4b），wire DTO `disallowUnrecognizedKeys: false` 静默忽略多余键，测试虽绿但 fixture 已与真实响应脱节。8 个文件：

1. JSON fixture 删 `'bloodType'` / `'emergencyContact'` 键，补 `activityLevel: null` / `dietaryPreferences: null`（驱动新字段解码路径）：
   - `test/settings/data/datasources/profile_remote_test.dart:71,76`
   - `test/health_context/remote_data_source_test.dart:454,459`
   - `test/health_context/lucent_repository_test.dart:208`（JSON 字符串内同步处理）
   - `test/review/clinic_summary_provider_test.dart:140`（`'bloodType': 'A'` 直接删）
2. `missingCoreProfileFields: ['bloodType']` → `['activityLevel']`（3 处）：
   - `test/mine/data/repositories/lucent_test.dart:18`
   - `test/mine/page_test.dart:1215`
   - `test/record/page_test.dart:2686`
   - ⚠️ 前置：与 Lucent `user-health-context` 模块确认后端实际会返回的缺口字段名（该列表值由后端决定；activityLevel 可空性与新契约一致才可作占位）。
3. `test/mine/edit_pages_test.dart:54` 恒真断言 `expect(payload.containsKey('bloodType'), isFalse)` 直接删除（legacy 编辑页已无该字段，断言无覆盖价值）。

验证：4 个涉及目录 `flutter test` 绿。

## 2. P1 — 真 bug 与行为缺口

### 2-1. `_hasStoredSession` 静默吞错补日志【09-10 #1 critical / 09-11 S-1】P1·S

`lib/core/providers/auth_guarded.dart:94-96`：`catch (_)` 连编程错误一并吞成"无会话"。保留保守回退语义（doc comment 的意图是对的，测试依赖"平台通道不可用→无会话"），只补可观测性：

```dart
} catch (e, st) {
  appTalker.warning('authGuarded: readRefreshToken failed; treating as no stored session', e, st);
  return false;
}
```

`appTalker` 走 `core/logger` 既有 provider；不改返回语义。

### 2-2. `_submit` 失败仍 toast「已保存」（假成功）【09-13 S-12】P1·S

实锤链路：`health_edit_forms.dart:25-45` 的 `HealthProfileFormNotifier.save` 失败时吞异常写入 `state.errorMessage` 后正常返回 void；`profile.dart:268-278` `_submit` 无条件调 `onChanged()` → 固定 toast `mineEditSavedToast`。断网时用户看到「已保存」。

修复：`save` 改返回 `Future<bool>`（成功 true / catch false，errorMessage 照旧写入 state）；`_submit` 仅成功时 `onChanged()`，失败 `Toast.show(l10n.mineEditSaveFailed)`（新 ARB 键走 `lib/l10n/src/` 分片）。同文件 `Allergy/Condition/CurrentMedicine` 三个 Notifier 同款改法一并做（profile 页之外 mine 编辑页消费 `saved`/`errorMessage` 的地方核对一遍，`profile_edit.dart` 有 listener 弹 toast 逻辑不受影响）。

### 2-3. `onLinkWechat` 空 TODO 死分支【09-08 C-1 余留 / 09-12 W-4 / 09-13 C-1+W-4，三连报】P1·S

`account_manage_sections.dart:213-215` 空 `async {}` + `:239 showWechatLink: false`；`LinkedIdentitiesSection`（account_identity.dart:115）把 `onLinkWechat` 设为 required，强迫两个调用方都传——security_center.dart:113-115 传真实现，账号管理传空函数，两条链路已漂移。

修复：`onLinkWechat` 改可空，`showWechatLink: true && onLinkWechat != null` 才渲染绑定按钮；账号管理侧删掉空函数调用（不再传）。**不**在空 callback 里补 toast——微信入口因企业资质整体隐藏是有意决策（docs/TODO.md 2026-09-06 段），死代码路径应编译期消灭而不是给不可达路径加提示。

### 2-4. login/register 条款前缀 l10n hack【09-13 W-1】P1·S

`login.dart:312-316`：`l10n.authLoginTermsAgreement('', '')` + 正则裁尾部「与/and」+ `:336` 再按 `localeName` 硬编码连接词——模板微调即碎。核实中发现**更糟的同款**：`register.dart:355` 用 `authTermsAgreement('','')` 且无任何裁剪，zh 渲染出悬空「与」。

修复：`lib/l10n/src/auth_zh.arb` / `auth_en.arb` 新增 `authLoginTermsPrefix`（"登录即代表同意" / "By signing in, you agree to the"）与 `authRegisterTermsPrefix`，login/register 直连渲染；删 `login.dart:336` 的 localeName 判断与正则。流程：改分片 → `dart scripts/l10n/arb_tools.dart merge` → `flutter gen-l10n` → 同步 `docs/reference/localization.md`。

### 2-5. editAvatar / removeAvatar 失败静默【09-13 W-2】P1·S

`profile.dart:117-128` 上传后仅 `if (ok) {...}`；`:103-107` 移除分支同。`uploadAvatar`/`updateProfile` 返回 bool 却不用。补 else 分支 `Toast.show(context, l10n.profileAvatarUploadFailed)`（新 ARB 键）。09-12 W-2 的服务层错误分类（§3-2）落地后，此 toast 天然承接 business 类失败。

### 2-6. OCR 模型下载失败不清理半截文件【09-12 W-1】P1·S

`ocr_model_manager.dart:192-204`：`_downloader.download` 抛错时无人删 `targetPath`（dio 5.11.1 多数情况自删临时文件，但代码无兜底、无"downloader 抛错"测试）。下载 + `_verifyOrDelete` 包 try/catch：失败 `if (file.existsSync()) await file.delete().catchError(...)` + `appTalker.error` 后 rethrow；`test/scan/ocr_model_manager_test.dart` 补 fake downloader 抛 `DioException` 用例（断言文件不存在）。顺带：`_verifyOrDelete:256` 的 `catchError` 补一行日志。

### 2-7. AvatarUploader 错误分类与防御位置【09-12 W-2 + W-5】P1·S

`avatar_uploader.dart`：三处客户端校验（空文件/类型不支持/超限）走 `_failure` → `LucentFailure.network(unknown)`，Sentry 会把「用户传 HEIC」计为网络故障。修复：

1. `lucent_failure.dart` 加 `business` factory（kind 约定见 `lib/core/errors/README.md`），三处校验改用之；`avatar_uploader_test` 断言 kind。
2. size 预检上提到 `upload()` 内 `presignFileUpload` **之前**（服务层兜底，profile 的 5MB UI 预检保留作 UX）。

### 2-8. 路由守卫 redirect 零覆盖【09-11 S-2】P1·M

`test/app/router_test.dart:103-106` 用 `configuration.routes` 裸重建 GoRouter——**redirect 守卫从未被测试走过**（fallbackHome 漏传 bug 长期漏测的根因）。新增 redirect 组：ProviderContainer override `authSessionProvider` 三态（signed-out / signed-in / isRestoring），读真 `appRouterProvider` 断言：signed-out 访问受保护路由 → /login；signed-in + bare /login + returnTo=null → /；returnTo 保留。全程不用 `configuration.routes` 重建。

### 2-9. 单位换算新函数零测试【09-14 W2】P1·S

`test/health_context/unit_conversion_test.dart` 补 `kgToLb` / `lbToKg` / `cmToFeetInches` / `feetInchesToCm`：`150→(4,11)`、`160→(5,3)`、`182.88→(6,0)`、`59.5` 小数英寸进位、`260→(8,2)` 超界行为固化；`cmToFeetInches(feetInchesToCm(5,7))`、`lbToKg(kgToLb(60))` round-trip（1e-6 容差与既有 group 一致）。

### 2-10. legacy profile_edit 页退役【09-14 S1】P1·M

核实修正：legacy 页**不是**"只剩能打开"——mine tab 有 5 个活入口（lucent.dart:214、archive_handlers.dart:9、account_hero.dart:341/346/351）。两套编辑页并存（`/mine/profile/edit` vs `/profile`）语义重复，新页是规范实现。分两步：

1. 5 个入口改指 `Routes.profile`（账号信息/性别/体重三个 readiness gap 均已有对应 sheet 行）。
2. 跑 `test/mine` 绿后删 `MineProfileEditRoute`（routes.dart:22-30 + routes.g.dart 重生成）+ `profile_edit.dart` + `edit_pages_test.dart` 等孤儿测试。

## 3. P2·A — 正确性收口（低成本，尽快）

### 3-1. `putPresignedObject` 错误分类【09-11 S-3】P2·M

`object_upload.dart:145-168` 只透传 DioException；集中 mapper（error_mapper.dart:44-58）要求 problem+json，对象存储 403 自有错误体会 `FormatException` → unknown，比报告预估更差。在 `putPresignedObject` 内薄分类：403 → `LucentFailure(business, retryable: true, statusCode: 403)`（可提示"链接已过期请重试"）；其余 badResponse → server、无 response → network；保持 skipAuthRefresh 语义。补 object_upload_test 用例。

### 3-2. 缓存反序列化硬 cast 容错【09-13 S-5】P2·S

`health_context_snapshot_codec.dart:69-70` `?.cast<String>()` 改 `?.map((e) => e?.toString()).whereType<String>().toList()`；`:59` `missingCoreProfileFields` 同改；`:53` `age as int?` 加 `is int` 判断。坏缓存不再炸整份快照。

### 3-3. quantity_sheet clamp 不回写 + late final 隐患【09-13 W-5 + 09-14 S-3 同处】P2·S

`quantity_sheet.dart:31-39 / 109-117`：初值 clamp 到边界后 `slot.value` 保持旧值，脏数据（如 260cm）直接确认会原样回写。`_initialIndexes` 检测 clamp 命中时同步 `widget.slot.value = 边界值`；两处 `late final _indexes` 上补注释「imperial 在 sheet 打开后不可变；如需切换改 didUpdateWidget」。

### 3-4. `_DietaryPreferencesRow` 引用比较【09-13 S-10】P2·S

`profile.dart:617-623` 改 `const ListEquality().equals(...)`（collection 包已是依赖）；或父层 `useMemoized` 缓存列表引用。取前者，一行。

### 3-5. `_wireValue` List 分支 assert【09-13 S-11】P2·S

`snapshot.dart:255-265` else 分支加 `assert(item is String || item is num || item is bool, ...)`，debug 期暴露未来 List<DateTime>/List<Map> 误用。

### 3-6. avatar 裁剪失败用 SnackBar【09-12 W-6 附带发现】P2·S

`avatar_draft.dart:159-164` `_showCropFailure` 用 ScaffoldMessenger/SnackBar，违反"轻反馈用 AppToast"约定。迁 `Toast.show(l10n.profileAvatarCropFailed)`（新 ARB 键）；`bytes.isEmpty` 分支补 `Toast.show(l10n.profileAvatarEmptyFile)`；取消路径维持静默（主动取消不提示是合理 UX）。

### 3-7. OCR `_DigestAccumulator` 简化【09-12 S-3】P2·S

`ocr_model_manager.dart:72-96` 换 `sha256.bind(file.openRead()).first`（crypto 3.x 公开 API），删 accumulator 类。行为等价，verifier fake 不受影响。

### 3-8. unit_conversion 回退路径测试【09-13 S-4】P2·S

回退常数是文档化设计（unit_conversion.dart:13-16），保留；补一个单测断言「包返回 null 时走本地公式」路径，把降级策略钉进测试。

### 3-9. l10n 双份同文案键去重【09-08 W-7 真实内核】P2·S

`authAccountManageCustomerService/Feedback/HelpCenter` 与 `authAccountManageSupport*` 三对同文案键并存（auth_zh.arb:227-235）。页面已全用 `Support*` 前缀（account_manage_sections.dart:362-376）；测试用旧前缀（account_settings_page_test.dart:51-53）。删旧三键（zh+en 分片），测试改用 `Support*` 键，merge + gen-l10n，同步 localization.md。零引用键清理前跑一次 grep 确认。

### 3-10. `weightInLb` 定位澄清【09-13 S-13】P2·S

`weightInLb` 是 archive_sections.dart:70 的现役接口，非"旧别名"。直接让 archive_sections 改用 `kgToLb` 后删掉该函数（消多余间接层）；同步 unit_conversion_test 删对应 group。

### 3-12. 生成模型 `ReportSummaryAsync/Stream*` 清理【09-08 W-2】P2·M（跨仓，合同级）

`bootstrap.dart:666-687` 的 reviewModels 列出的 async 8 + stream 7 个模型在 lib/test/integration_test **零消费**（实际 SSE 走 `ai_summary_remote.dart:49-51` 原始 `LucentSseClient.postJson`，结果只用 `ReportSummaryResponse`）；review 页 AI 摘要主路径已退役（docs/TODO.md「延后」段），legacy 兼容页仅消费 `ReportSummaryResponse`。**不能**直接从 reviewModels 删——`_filteredClients` 要求 models 与 reports_api.dart import 闭包一致并 fail-fast（bootstrap.dart:730-736），Lucent openapi.json 仍暴露 enqueue/stream 两端点。正确路径：Lucent 侧决策删除两端点（或登记延后）→ `pnpm export:openapi` → `dart run scripts/contract/bootstrap.dart` 重跑后模型自然消失。属跨仓合同决策，与 docs/TODO.md 的「Review AI 摘要复核」项合并执行，本计划只登记不实施。

### 3-11. auth 页骨架收敛 AuthScrollBody【09-14 "重复造轮子"修正案】P2·S

报告的 padding 参数方案不成立（见 §0）。改为 auth feature 内加 `AuthScrollBody`（~10 行 StatelessWidget 包 `SingleChildScrollView → ResponsiveContentFrame → Padding(vertical: width<mobile?xl2:xl3) → Column`），6 页（login/register/forgot_password/change_email/account_manage/security_center）各减 ~6 行；这是行为组合而非样式 preset，符合 AGENTS.md wrapper 例外。与 §4-7 骨架测试同批做。

## 4. P2·B — 文档注释与测试补强

1. **page_state.dart:84-87 Priority 1 注释**【09-10 #2】：函数体不读 `session.isRestoring`，把从句改为行为式表述（"During session restore, providers gated by authGuarded stay loading on a cache miss…"）。P2·S
2. **markdown_style.dart:84**【09-11 W-1】：`level5=20/级` → `xl=20/级`、`level2=6` → `sm=6`。P2·S
3. **AuthShell 残留注释 ×3**【09-14 W1】：account_sessions.dart:44、account_security.dart:295、account_identity.dart:275 改「与认证页标准骨架（PageScaffold）共用同一层背景」。P2·S
4. **profile.dart:546-547 幽灵文件注释**【09-13 W-3】：enum_select_sheet.dart 不存在，改「枚举字段走内嵌 FSelectMenuTile，数值（身高/体重）走 quantity_sheet」。P2·S
5. **state_message.dart `card` 参数 docstring**【09-14 S4 + 09-13 S-2/S-3】：补「`card: false` 时不包裹滚动视口，调用方需自行保证外层可滚动」；card/scrollable 参数拆分不做（唯一调用方 notification/list.dart 行为正确）。P2·S
6. **auth_guarded.dart doc 签名演进说明**【09-10 #4】：Usage 段前加一段「async since 2026-09-10；同步上下文不能 try/catch AuthRequiredException，用 FutureProvider/AsyncNotifier」。P2·S
7. **login_page_test 骨架断言**【09-14 S5】：窄/宽屏断言 Padding vertical == xl2/xl3（配合 §3-11 的 AuthScrollBody 则断言 wrapper）；勿断言已删除的类名。P2·S
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

## 5. 流程约定（写进 AGENTS.md，不涉及代码）

1. **同日收口文件选择**【09-09 #2】：在 Luminous/AGENTS.md Migration-log 节补一句——「收口旧 review 清单时优先新开当日日期的日志文件」。
2. **日志验证段口径**【09-09 #3】：新条目验证段写「执行的命令 + 结论」，不写精确数字（与既有"不写需要持续同步的精确数字"规则对齐）；旧日志不回填。

## 6. 执行顺序与验收

- **Wave 1（P0+P1 主干）**：1-1 → 2-2（假成功）→ 2-3 → 2-4 → 2-5 → 2-1 → 2-6 → 2-7 → 2-9 → 2-8 → 2-10。每项落地即跑对应目录 `flutter test`；1-1 的 `missingCoreProfileFields` 值需先与 Lucent 侧确认。
- **Wave 2（P2·A）**：3-1 → 3-2 → 3-4 → 3-5 → 3-3 → 3-6 → 3-7 → 3-8 → 3-9 → 3-10 → 3-11；3-12（合同级）与 §3-9/§4-19/§4-20 按 09-08 建议合批：同一测试文件（account_settings_page_test 改名 + key 去重 + 断言补强）一批做。
- **Wave 3（P2·B + 流程）**：§4 按 1-25 顺手清（可与 Wave 2 并行），§5 两句进 AGENTS.md。
- **收尾验收**：`flutter analyze` 零 issue；`flutter test` 全量绿；`dart run scripts/docs/verify.dart --warning-only` 无新增告警；l10n 相关改动后 `arb_tools.dart merge` + `flutter gen-l10n` + `docs/reference/localization.md` 同步；本计划全部项实施完毕后按约定整文件删除并在迁移日志登记。
- **明确不做**（除非另行立项）：avatar 真草稿化重构（09-13 W-2 后半）、450ms debounce 注入钩子、card/scrollable 参数拆分、tab_branch_container late 改写、authGuarded 新 lint 规则、pre-push 回滚加 test、reviewModels 手工删模型（走 3-12 合同级路径）。
