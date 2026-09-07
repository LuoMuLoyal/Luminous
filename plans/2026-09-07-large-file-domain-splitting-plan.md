---
status: active
owner: frontend
updated: 2026-09-07
---

# Luminous 超大文件按领域拆分计划

> 分析日期：2026-09-07
> 分析对象：`Luminous/lib/` 全量手写 Dart 源码（排除 `*.freezed.dart` / `*.g.dart` / `app_localizations*` / `generated/`）
> 目标：把单文件超过 450 行的超大源码文件按**业务领域/职责边界**拆分为多个小文件，每个新文件职责单一、可独立测试。
> 约束：遵循 `Luminous/AGENTS.md` 的 File Naming Rules（文件名=职责而非位置；目录传达类型时不加后缀；不加目录名前缀；不用纯类型词）；不违反分层架构；不机械按行切片。

---

## 一、全景：超大文件清单

共 **55 个手写文件 ≥ 400 行**，其中 **33 个 ≥ 450 行**（拆分重点）。按 feature 分布：

| Feature | ≥450 行文件数 | 最大文件 | 主要大文件 |
|---------|-------------|---------|-----------|
| **record** | 10 | detail (975) | create (552), sidebar (549), lucent (538), quick_entry_panel (516), quick_entry_sleep (499), edit (488), record_edit_controller (470), quick_entry_settings (458), quick_entry_preferences (424) |
| **auth** | 6 | login (651) | account_settings_sections (609), auth datasources (595), oauth_login (515), shell (462) |
| **medicine** | 5 | detail (531) | page (471), reminder/edit (453), mobile_drugbox (506), mobile_safety (504), risk/overview (497) |
| **today** | 3 | lucent (636) | dashboard_view (612), suggestion_primary_card (518), summary (449), observation (424) |
| **assistant** | 3 | conversation (922) | page_body (636), page (441) |
| **review** | 3 | clinic_summary_preview_dialog (819) | page (545), history (485) |
| **settings** | 3 | notification (630) | advanced (426), notification page (402) |
| **scan** | 2 | barcode_scanner (645) | box_scan (500) |
| **health_data** | 1 | health_record_mapper (488) | — |
| **mine** | 2 | current_medicine_edit (441), archive (430) | — |

> **注**：`lucide_icon_bridge.dart`（2070 行）虽最大但为**生成文件**（`scripts/generate_lucide_bridge.dart` 产出），不在手工拆分范围内。

---

## 二、P0 深度拆分方案（5 个核心大文件，子 agent 逐行分析完成）

### 2.1 `record/presentation/pages/detail.dart` — 975 行 → 12 文件

**现状**：页面骨架 + 状态编排 + 轮询 + 餐食确认 + 复制 + 睡眠详情 + 多个原子组件 + 工具函数，全在一个文件里。

| 新文件（相对 `features/record/`） | 容纳内容 | 预估行数 |
|---|---|---|
| `presentation/pages/detail.dart`（保留） | 路由入口 `RecordDetailPage`，认证守卫 | ~75 |
| `presentation/widgets/detail/body.dart` | `_RecordDetailBody` + State：build 编排、同日期记录、水量聚合 | ~360 |
| `presentation/controllers/meal_analysis_poller.dart` | 分析轮询 Timer / 退避 / 防重入 | ~60 |
| `application/usecases/record_detail_actions.dart`（并入现有） | `_confirmMealAnalysis` + `_copySummary` | +55 |
| `presentation/widgets/detail/info_rows.dart` | `_DetailRows` / `_DetailRow` / `_DetailRowData` | ~70 |
| `presentation/widgets/detail/hero_avatar.dart` | `_KindHeroAvatar` + `_kindIconFallback` | ~45 |
| `presentation/widgets/detail/source_badge.dart` | `_SourceBadge` | ~29 |
| `presentation/widgets/detail/surface.dart` | `_DetailSurface` 卡片容器 | ~15 |
| `presentation/widgets/detail/image.dart` | `_RecordDetailImage` 图片附件 | ~48 |
| `presentation/widgets/detail/water_progress.dart` | 水进度卡片（build 内联段 418–465） | ~55 |
| `presentation/widgets/detail/loading.dart` | `_RecordDetailLoading` 骨架屏 | ~26 |
| `presentation/utils/detail_labels.dart` | `_moodLabel`/`_kindLabel`/`_sourceLabel`/`_valueWithUnit` 等工具函数 | ~74 |

**命名合规**：`widgets/detail/` 下文件不加 `detail_` 前缀（目录已传达）；`surface.dart`/`image.dart`/`loading.dart` 等为组件名非纯类型词；轮询归位 `controllers/`；动作归位 `application/usecases/`。

---

### 2.2 `assistant/presentation/providers/conversation.dart` — 922 行 → 7 文件（mixin 模式）

**现状**：单一 `AssistantController` 类承载 8 个职责领域。Dart 单类限制下采用 mixin 模式拆分。

| 新文件（相对 `features/assistant/`） | 职责 | 预估行数 |
|---|---|---|
| `presentation/providers/conversation.dart`（保留） | 定义层 + 初始化 + mixin 合并 | ~200 |
| `presentation/providers/conversation_capabilities.dart` | `CapabilitiesLoader` mixin：加载 AI 能力 | ~55 |
| `presentation/providers/conversation_streams.dart` | `ConversationStreams` mixin：会话加载与打开 | ~140 |
| `presentation/providers/conversation_sending.dart` | `MessageSending` mixin：SSE 流式发送 + F-3 断流补偿 | ~140 |
| `presentation/providers/conversation_regenerate.dart` | `MessageRegeneration` mixin：F-5b 重发/重生成 | ~145 |
| `presentation/providers/conversation_management.dart` | `ConversationManagement` mixin：会话 CRUD（清空/重命名/删除） | ~165 |
| `presentation/providers/conversation_proposals.dart` | `ProposalHandling` mixin：F-11 提案确认/拒绝/重新生成 | ~260 |

**风险点**：跨 mixin 的 `_renamingConversationIds` 共享（放主类）；并发守卫 `isSending`/`isLoadingConversation`（放主类 state）。

---

### 2.3 `review/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart` — 819 行 → 5 文件

**现状**：对话框入口 + 主状态类 + 字段选择 + 分享三步骤 + 错误视图 + 枚举映射。

| 新文件（相对 `features/review/`） | 职责 | 预估行数 |
|---|---|---|
| `presentation/widgets/dialogs/clinic_summary_preview_dialog.dart`（保留） | 入口函数 + 主状态类 + 分享步骤枚举 + 业务协调 | ~390 |
| `presentation/widgets/dialogs/clinic_summary_field_selection.dart` | 字段级隐私选择面板 | ~125 |
| `presentation/widgets/dialogs/clinic_summary_share_flow.dart` | 分享三步骤（确认/已创建/已撤销）+ `_NoticeRow` | ~240 |
| `presentation/widgets/dialogs/clinic_summary_error_state.dart` | 加载失败错误视图 | ~40 |
| `presentation/utils/clinic_summary_field_mapping.dart` | preview→share 枚举映射工具函数 | ~35 |

---

### 2.4 `assistant/presentation/widgets/sections/page_body.dart` — 635 行 → 4 文件

**现状**：`AssistantPageBody` 主组件 + 上方状态提示 + 编排器宿主 + 空状态支持组件（含记忆提示 + 免责声明）。

| 新文件（相对 `features/assistant/`） | 职责 | 预估行数 |
|---|---|---|
| `presentation/widgets/sections/page_body.dart`（保留） | `AssistantPageBody` 主编排组件 | ~275 |
| `presentation/widgets/sections/above_composer.dart` | `_AssistantAboveComposer` 加载/错误提示 | ~70 |
| `presentation/widgets/sections/composer_host.dart` | `_AssistantComposerHost` FlowComposer 宿主 | ~85 |
| `presentation/widgets/sections/empty_support.dart` | `_AssistantEmptySupport` + `_AssistantMemoryHintSection` + `_AssistantDisclaimerSection` 空状态组件 | ~195 |

---

### 2.5 `auth/presentation/pages/login.dart` — 651 行 → 5 文件

**现状**：OAuth 五个平台的 start/complete 逻辑 + URI 构建 + 回调 hook + 表单 UI + 链接 + 条款，全在一个 build 方法里。

| 新文件（相对 `features/auth/`） | 职责 | 预估行数 |
|---|---|---|
| `presentation/pages/login.dart`（保留） | 页面骨架 + 表单 UI + 提交 + 链接 + 条款 | ~250 |
| `presentation/pages/oauth_navigation.dart` | `safeReturnTo` + `goAfterLogin` 导航辅助 | ~30 |
| `presentation/pages/oauth_uris.dart` | 四个 Web OAuth 回调 URI 构建函数 | ~55 |
| `presentation/pages/oauth_handlers.dart` | 五个平台的 start*/complete* 登录操作 | ~185 |
| `presentation/pages/oauth_callback_hook.dart` | 深链接 OAuth 回调 useEffect hook | ~65 |

---

## 三、P1 批量拆分方案（其余 450+ 行文件）

按 feature 分组，按收益/风险排序：

### 3.1 `record` feature（P1 最大 feature，6 个文件待拆）

| 文件 | 行数 | 拆分方向 | 建议新文件 |
|---|---|---|---|
| `pages/create.dart` | 552 | 单一 `RecordCreatePage`，内部 build 方法过长；按记录类型拆分表单段 | 拆出 `create_form_body.dart`（~300）和 `create_type_selector.dart`（~100） |
| `widgets/sections/sidebar.dart` | 549 | 日历面板 `RecordMonthCalendarPanel`（~300）与筛选面板 `RecordFilterPanel`（~150）是两个独立组件 | 拆为 `calendar_panel.dart` + `filter_panel.dart` |
| `data/repositories/lucent.dart` | 538 | 单一 `LucentRecordRepository`，方法按记录 CRUD 分组 | 按方法群拆为 `record_read.dart`（读/列表）+ `record_write.dart`（创建/更新/删除） |
| `widgets/sections/quick_entry_panel.dart` | 516 | 8 个私有组件：面板主体 + header + grid + tile + badge + note 按钮 | 拆出 `quick_record_grid.dart`（~200）+ `quick_record_tile.dart`（~120），面板保留编排 |
| `pages/edit.dart` | 488 | `RecordEditPage` + loading + hint | 与 detail 类似，拆出 `edit_form_body.dart`（~350） |
| `pages/quick_entry_settings.dart` | 458 | 单一 `QuickEntrySettingsPage` | 内部按记录类型拆分设置段到 `quick_entry_type_settings.dart`（~200） |

### 3.2 `medicine` feature（P1，4 个文件待拆）

| 文件 | 行数 | 拆分方向 | 建议新文件 |
|---|---|---|---|
| `pages/detail.dart` | 531 | 9 个私有组件：loading / content / section / header / meta / badge / notice / risk_check_entry | 拆出 `medicine_detail_content.dart`（~300）+ `medicine_detail_section.dart`（~80） |
| `widgets/sections/mobile_drugbox.dart` | 506 | 9 个私有组件（drugbox header/content/reminder/row/empty） | 拆为 `drugbox_header.dart`（~80）+ `drugbox_content.dart`（~250）+ `drugbox_medication_row.dart`（~120） |
| `widgets/sections/mobile_safety.dart` | 504 | 10 个私有组件（safety header/card/summary/metric/alert） | 拆为 `safety_header.dart`（~60）+ `safety_card.dart`（~200）+ `safety_summary.dart`（~150） |
| `widgets/risk/overview_tab_section.dart` | 497 | 9 个组件（score_hero/metric_grid/safe_card/recommendation/empty_state） | 拆为 `risk_score_hero.dart`（~80）+ `risk_metric_grid.dart`（~120）+ `risk_overview_cards.dart`（~200） |

### 3.3 `auth` feature（P1，3 个文件待拆）

| 文件 | 行数 | 拆分方向 | 建议新文件 |
|---|---|---|---|
| `pages/account_settings_sections.dart` | 609 | 12 个独立 section 组件（account_status / email / linked_identities / session / password / delete / danger_zone） | 拆为每 section 一个文件，最大的 `password_section.dart`（~120）+ `delete_account_section.dart`（~100）；其余合并为 2–3 个文件 |
| `data/datasources/auth.dart` | 595 | 单一 `LucentAuthRepository`，方法按认证类型分组 | 拆为 `auth_email.dart`（邮箱/密码登录）+ `auth_oauth.dart`（OAuth 流程）+ `auth_account.dart`（账号管理） |
| `widgets/shared/shell.dart` | 462 | 6 个组件：DesktopShell / BrandPanel / MobileShell / AuthPageHeader / AuthFormPanel | 拆为 `desktop_auth_shell.dart`（~200）+ `mobile_auth_shell.dart`（~150） |

### 3.4 `today` feature（P1，2 个文件待拆）

| 文件 | 行数 | 拆分方向 | 建议新文件 |
|---|---|---|---|
| `data/repositories/lucent.dart` | 636 | 单一 `LucentTodayRepository`，方法按今日聚合 / vital 读数 / 观测指标分组 | 拆为 `today_dashboard.dart`（~350）+ `today_vitals.dart`（~200） |
| `presentation/widgets/views/dashboard_view.dart` | 612 | 8 个组件：MobileDashboard / DesktopDashboard / HealthEventSection / HealthEventCard / HealthEventActionRow / ActiveHealthEventContent | 拆为 `mobile_dashboard.dart`（~250）+ `desktop_dashboard.dart`（~150）+ `health_event_section.dart`（~150） |

### 3.5 `settings` feature（P1，1 个文件待拆）

| 文件 | 行数 | 拆分方向 | 建议新文件 |
|---|---|---|---|
| `providers/notification.dart` | 630 | `NotificationSettingsController` + `_ScopedPreferences` + 状态定义 + 工具函数 | 拆为 `notification_state.dart`（~80）+ `notification_controller.dart`（~400）+ `notification_preferences.dart`（~100） |

### 3.6 `scan` feature（P1，2 个文件待拆）

| 文件 | 行数 | 拆分方向 | 建议新文件 |
|---|---|---|---|
| `pages/barcode_scanner.dart` | 687 | 实际 687 行：页面壳/权限/生命周期（~340）+ 扫码检测编排（~60）+ 结果弹层（~318）+ 扫描框角标绘制（~60） | 拆为 `widgets/scan_result_sheet.dart`（~185）+ `widgets/scan_candidate_sheet.dart`（~85）+ `widgets/scan_corner_painter.dart`（~60）；页面瘦身至 ~400 |
| `pages/box_scan.dart` | 500 | 药盒扫描，含 `_MethodTile` + 多种扫描入口 | 拆为 `box_scan_view.dart`（~350）+ `scan_method_tile.dart`（~80） |

> **子 agent 已完成的 barcode_scanner 详细分析**（行范围 A–I）：`A+B+C+F+G` 页面壳与相机 UI ≈ 339 行，`C` 扫码搜索编排 ≈ 59 行，`D+E+H` 结果弹层 ≈ 318 行，`I` 角标绘制 ≈ 62 行。私有类 `_ScanResultSheet`/`_ScanCornerPainter` 公开化后分别入 `scan_result_sheet.dart` / `scan_corner_painter.dart`；`_showCandidatePicker` 内容抽为 `scan_candidate_sheet.dart`，`showFSheet` 装配留页面。测试 `test/scan/barcode_scanner_page_test.dart` 测页面本身，无需改。

### 3.7 `health_data` feature（P2，1 个文件待拆）

| 文件 | 行数 | 拆分方向 | 建议新文件 |
|---|---|---|---|
| `data/mappers/health_record_mapper.dart` | 488 | 单一 `HealthRecordMapper` + `_BloodPressureDataPoint` + `_SleepAggregator` | 拆为 `blood_pressure_mapper.dart`（~120）+ `sleep_aggregator.dart`（~100）+ `health_record_mapper.dart`（~250） |

### 3.8 `mine` feature（P2，2 个文件待拆）

| 文件 | 行数 | 拆分方向 | 建议新文件 |
|---|---|---|---|
| `pages/current_medicine_edit.dart` | 441 | 单一页面，内部表单段按字段分组 | 拆出 `current_medicine_form.dart`（~300） |
| `widgets/sections/archive.dart` | 430 | 归档列表组件 | 拆出 `archive_list.dart`（~250）+ `archive_item.dart`（~100） |

---

## 四、跨 feature 共享组件上提 `core/`

多个大文件中存在重复的共享组件，优先上提 `core/` 而非 feature 间互引：

| 组件 | 当前位置 | 出现次数 | 建议目标 |
|---|---|---|---|
| `copy.dart`（文本复制辅助） | `medicine/widgets/shared/copy.dart` | medicine + review | `core/widgets/common/copy.dart` |
| `components.dart`（通用 section 组件） | `review/widgets/shared/components.dart` | review | 保持 review，若多处引用再提 |
| 日期格式化工具 | `record/presentation/utils/date_time_formatters.dart` | record | 保持 record，若跨 feature 再提 |
| 表单加载/错误骨架屏 | 各 feature 自行实现 | 5+ feature | `core/widgets/common/state_views.dart` 已有，统一使用 |

---

## 五、执行批次

> 每批收尾门禁：`flutter analyze` / `flutter test` / `dart run scripts/docs/verify.dart --warning-only`；产生 l10n 变化走 ARB 分片合并 + `flutter gen-l10n`。每批完成项从本计划**删除**（AGENTS 规则），并追加迁移日志 `Luminous/docs/logs/migration-log/YYYY-MM-DD.md`。

### 批次 0：基线
- [ ] `dart run scripts/workflows/daily.dart` 确认当前绿；`git -C Luminous status` 干净，记录起跑 commit。

### 批次 1：P0 最高收益文件（子 agent 已完成分析，可直接执行）
- [ ] **detail.dart** 拆分（record，975 → 12 文件，核心验证文件）✅
- [ ] **conversation.dart** 拆分（assistant，922 → 7 文件，mixin 模式验证）✅
- [ ] **clinic_summary_preview_dialog.dart** 拆分（review，819 → 5 文件）✅
- [ ] **page_body.dart** 拆分（assistant，635 → 4 文件）✅
- [ ] **login.dart** 拆分（auth，651 → 5 文件）✅

### 批次 2：P1 record feature 批量
- [x] `create.dart` / `sidebar.dart` / `lucent.dart`（record data）拆分 ✅
- [ ] `quick_entry_panel.dart` / `edit.dart` / `quick_entry_settings.dart` 拆分

### 批次 3：P1 medicine + auth feature 批量
- [x] `medicine/detail.dart` + `mobile_drugbox.dart` + `mobile_safety.dart` + `risk/overview_tab_section.dart` ✅
- [x] `auth/account_settings_sections.dart` + `shell.dart` ✅
- [ ] `auth/datasources/auth.dart`（拆分为 auth_email/auth_oauth/auth_account）

### 批次 4：P1 today + settings + scan 批量
- [x] `today/lucent.dart` + `dashboard_view.dart` ✅
- [x] `settings/notification.dart` ✅
- [x] `scan/barcode_scanner.dart` + `box_scan.dart` ✅

### 批次 5：P2 收口
- [x] `health_data/health_record_mapper.dart` 拆分 ✅
- [x] `mine/current_medicine_edit.dart` + `archive.dart` 拆分 ✅
- [ ] 跨 feature 共享组件上提 `core/`
- [ ] 更新受影响 feature `README.md` / `docs/doc-map.yaml`；迁移日志补齐；完成项删除

---

## 六、拆分后判定标准

1. **每个手写源文件 ≤ 350 行**（少数逻辑高度内聚的 controller 可豁免至 ≤ 450）。
2. **每个文件只描述一个业务领域/职责**，文件名即职责词。
3. **跨 feature 依赖全部落在 domain/application/公共 provider 接缝**，`layered_import` 门禁零违规。
4. **目录文件数 ≤ 10**（生成文件除外），超标需记录迁移日志豁免或子目录划分。
5. **行为不变**：所有既有单测/widget 测试/E2E 在拆分后全绿；golden 不漂移。

---

## 七、风险与缓解

| 风险 | 缓解 |
|---|---|
| 私有类跨文件需转公开 | 统一重命名，不保留 `_` 前缀；类名不变，仅可见性调整 |
| mixin 模式（conversation.dart）跨 mixin 字段共享 | 共享状态字段放主类，mixin 通过 getter 访问 |
| 导入路径变更导致 IDE 重构遗漏 | 每批拆分后跑 `flutter analyze` 确保零编译错误 |
| 目录文件数超限 | 拆分后立即检查，必要时建子目录（如 `widgets/detail/`） |
| 测试文件引用私有类 | 私有类转公开后测试自动适配；若有直接引用内部实现的测试，同步更新 |

---

## 八、与既有计划的关系

本计划与以下既有计划**互补不冲突**：
- `2026-09-05-luminous-feature-splitting-plan.md`（workspace 根）：聚焦 **feature 级拆分**（4 个大 feature → 10 个小 feature）；本计划聚焦**文件级拆分**（单文件内部按领域拆分）。feature 级拆分可与本计划并行执行，但建议先完成本计划的文件级拆分，再做 feature 级搬迁。
- `2026-08-22-medium-to-large-migration-inventory.md` Task 7：已有"按 seam 拆分超大页面"条目，本计划是其完整展开与补充。
- 2026-08-16 十份功能盘点改造计划：聚焦产品功能债务，本计划聚焦代码组织债务，不重叠。

---

## 附录：方法说明

- **行数统计**：PowerShell `Get-Content | Measure-Object -Line` 对 `Luminous/lib` 全量 `.dart`；"手写行数"剔除 `*.freezed.dart`、`*.g.dart`、`app_localizations*`、`lucide_icon_bridge.dart`（生成文件）。
- **拆分分析**：对 P0 的 5 个核心大文件使用子 agent 逐行通读分析；其余文件通过方法签名提取 + 结构推断。
- **命名对齐**：`Luminous/AGENTS.md` File Naming Rules（文件名=职责、目录传达类型不加后缀、不加目录名前缀、不用纯类型词、目录 ≤10 文件）。
