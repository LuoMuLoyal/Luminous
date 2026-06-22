# Luminous TODO

Last updated: 2026-06-22

This file records work that is still missing or intentionally gated. Current facts belong in `Current_State.md`; implementation order belongs in `Next_Plan.md`.

## Widget 测试补充

- [x] **ReportPage**: 生成按钮点击→fetch 计数验证、错误态+retry、空数据态渲染、Sync 按钮刷新（+4 测试）
- [x] **TodayPage**: 登出态渲染、错误态+retry、RefreshIndicator 存在、饮水卡片渲染、药物卡片渲染（+5 测试）
- [ ] **ShellPage**: 5 标签逐一切换验证、Mine 标签 badge 计数

## Golden 测试第二批

- [ ] **Register page golden**: 需完整 auth provider 链路 + `AuthShell(enableFormAnimation: false)`
- [ ] **Report sections golden**: 需独立提取 `ReportScoreHero` / `ReportMetricsGrid` section widget
- [ ] **生成基线**: `flutter test --update-goldens test/golden/`（第一批 3 文件 ~13 个 golden 已编写，待生成镜像）

## freezed 领域实体分批迁移

当前进度：8/60 完成。按功能模块分批：

- [ ] **today_dashboard.dart**（10 实体：TodayDashboard, TodayUserSnapshot, TodayWaterSummary, TodayMedicationSummary, TodayVitalSummary, TodayMealSuggestion, TodayEnvironmentSummary, TodayEnvironmentSignal, TodayLumiSuggestion, TodayPriorityItem）
- [ ] **record_dashboard.dart**（9 实体：RecordDashboard, RecordWeekDay, RecordCalendarDay, RecordQuickAction, RecordDaySummary, RecordSummaryItem, RecordFilter, RecordTimelineEntry, RecordTrend）
- [ ] **report_dashboard.dart**（7 实体：ReportDashboard, ReportHealthScore, ReportMetric, ReportTrendSeries, ReportFinding, ReportExportAction, ReportPatternCard）
- [ ] **mine_dashboard.dart**（8 实体）
- [ ] **medicine_workspace.dart + medicine_risk_check.dart**（12 实体）
- [ ] **daily_record.dart + daily_record_inputs.dart**（9 实体）
- [ ] **search_entities.dart**（5 实体）

每批流程：`dart run build_runner build` → `flutter analyze` → `flutter test`

## 架构改进（需单独规划）

- [ ] `lucent_envelope.dart` 内联 Map 强制转换 → 使用 `coerceToStringMap`
- [ ] `login_page.dart` `AnimatedSwitcher` → 统一用 `flutter_animate`
- [ ] 路由过渡动画参数差异化（auth 慢、CRUD 快）

## 延后（有明确原因）

- `ReportPanel` / `MedicinePanel` 默认 padding (md→lg) — 布局溢出，当前默认与 `AppLayoutTokens.cardPadding` 一致
- `formz` 表单校验 — 新增依赖，当前 AppToast 校验模式工作正常
- `intl.DateFormat` 替代 ISO 字符串 — padLeft 是线协议格式，DateFormat 不适用
- `TodayPalette` / `ReportPalette` 移除 — 使用量小，参照 MedicinePalette 模式逐模块消除

## MVP Gaps To Close

- No blocker is currently left on the frozen mobile MVP promise.
  Current state: The mobile MVP path is now defined as `record -> summarize -> bounded medicine safety check -> export`, with explicit uncertainty for unchecked medicines and no claim of broad cross-source normalization or unreviewed interaction expansion.
  Remaining work below belongs to post-MVP productization or hardening, not to MVP completion.

## MVP Gated But Not Blocking Right Now

- Lightweight assistant with user-controlled context permissions, bounded tool use, and streaming markdown output.
- Additional reviewed medicine rule expansion beyond the frozen current boundary.
- Cross-source medicine normalization and unreviewed interaction expansion.
- Fixed red-flag rules, audited offline-care escalation copy, and campus/help resource completeness.
- Agent-assisted support discovery or map-backed nearby-care lookup.
- Deeper medicine safety rule coverage and clearer unsupported / low-confidence wording beyond the frozen current boundary.
- Report/export finish-pass cleanup in the client only: final status wording consistency, expired-link handling, and one real-environment acceptance run. Do not reopen backend/export scope unless a real bug is found.
- Worker-written reminder delivery history for local/push/SMS channels.
- Environment-driven Today or Mine suggestions.
- Real barcode / OCR / photo / prescription recognition flow.
- Voice or screenshot-based natural-language record intake.
- Privacy-preserving clinic summary / doctor-facing summary generation and preview flow.
- Real authenticated Web report preview beyond the competition/marketing homepage.

## Not MVP

- Women-health / period management.
- Sports recovery.
- Specialist health packs.
- Smart devices.
- Family profiles.
- Skin recognition.
- Desktop-first workflows.
