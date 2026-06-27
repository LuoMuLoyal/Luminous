# Luminous 逐个 Tab 精修实施计划

> 对应背景：桌面 Shell SaaS 骨架改造已完成（`plans/desktop-shell-saas-layout-plan.md` Phase 1–5 + 折叠动画优化），下一步把 5 个可见 Tab 的体验从“能跑”打磨到“产品级”。
> 创建时间：2026-06-27
> 范围：Luminous 前端（`lib/features/*`）

---

## 1. 目标与原则

### 1.1 目标
- 让每个可见 Tab（Today / Record / Medicine / Report / Mine）的移动端主界面达到 north-star 概念图（`docs/assets/product-north-star-tabs-long-v2/`）的 80% 质感。
- 补齐缺失的桌面端布局：Medicine / Report / Mine 目前仍是移动单列直接放大，需要在 Shell 内容区内提供合理的桌面布局。
- 统一使用现有设计 Token，删除硬编码数值与重复样式。
- 每个 Tab 改动配套 widget/unit 测试，保证 `flutter test` 不回归。

### 1.2 原则
- **移动端优先**：north-star 资产以移动端为主，桌面端只做“不溢出、信息密度合理”的适配，不追求全新桌面范式。
- **冻结底部导航**：5 个可见 Tab 不变，不复活通用 More tab。
- **不动 auth/account 全屏**：`/login`、`/register`、`/forgot-password`、`/account*` 仍走顶层 `GoRoute`。
- **不动路由结构**：继续使用 `StatefulShellRoute.indexedStack`，只改每个 Branch 根页面/二级页的内部 UI。
- **ARB-only 文案**：新增/修改文案必须进 `lib/l10n/app_zh.arb` / `app_en.arb`。
- **测试先行**：先补测试覆盖当前行为，再改 UI，避免改完后不知道 regress 了什么。

---

## 2. 当前状态速览

| Tab | 移动端布局 | 桌面端布局 | 测试覆盖 | 主要缺口 |
|---|---|---|---|---|
| Today | ✅ 已卡片化，接近 north-star | ✅ 已有 `_DesktopTodayDashboard` 两栏 | 6 个测试 | 空态 `onAction` 未接；AI summary disabled 状态提示弱 |
| Record | ✅ 已响应式，较完整 | ✅ 已有 `_DesktopRecordDashboard` 三栏 | 9 个测试 | 趋势面板 `onEdit` 未接；部分记录类型无快捷入口 |
| Medicine | ⚠️ 移动单列，信息堆叠 | ❌ 无桌面布局（只有 `_MedicineMobileShell`） | 12 个测试 | 通知铃铛红点未读未联动；存在未使用的 desktop 半成品文件 |
| Report | ⚠️ 移动单列，`_ReportMobileShell` | ❌ 无桌面布局 | 6 个测试 | sync 动作是 stub；始终用 mobile typography |
| Mine | ⚠️ 移动单列 `ListView` | ❌ 无桌面布局 | 3 个测试 | 校园服务命名可能过时；隐私/设置入口单一 |
| Settings | ⚠️ 单列，可用 | ⚠️ `PageScaffoldShell` 仅做最大宽度限制 | 5 个测试 | Help dialog 桌面偏拥挤 |
| Assistant | ⚠️ 聊天面 | ⚠️ 高度固定，大屏浪费 | 2 个测试 | 无桌面双栏；错误状态堆叠 |
| Notifications | ⚠️ 列表+详情 | ⚠️ 单列 | 0 个测试 | 多处文案硬编码中文；未接入未读数 |

---

## 3. 跨-cutting 前置工作（Phase 0）

在所有 Tab 精修前先做三件事，避免每个 Tab 重复发明轮子。

### 3.1 统一空态/错误态组件
- 文件：`lib/core/presentation/widgets/app_state_message_view.dart`（已存在）
- 动作：确认各 Tab 的空态、加载失败、权限不足都使用 `AppStateMessageView` / `AppStateErrorView` / shimmer skeleton，不自行实现。

### 3.2 响应式 typography 检查
- 文件：`lib/core/theme/app_theme_extensions.dart`、`lib/core/design/app_design.dart`
- 动作：梳理是否已有 `AppTypographyTokens.desktop` 的规范使用方式；在需要桌面布局的 Tab 中统一按宽度选择 `mobile` / `desktop` typography，而非硬编码。

### 3.3 未读通知数接入
- 文件：`lib/features/notification/presentation/providers/notification_providers.dart`（需确认/新建）
- 动作：把 Medicine / Mine / Today 顶部的铃铛红点接到 `notificationUnreadCountProvider`；Notifications hidden branch 从 Mine 顶部入口扩展到桌面侧边栏？**待决策**（见第 7 节）。

---

## 4. 逐个 Tab 精修方案

### 4.1 Today（今日）

#### 当前
- `today_page.dart` + `today_dashboard_view.dart` + 6 个 section part 文件。
- 已有 `_DesktopTodayDashboard` 两栏布局。

#### 目标
- 对齐 `product-north-star-tabs-long-v2/tab-1-today-long.png`：健康状态总览、今日优先事项 2×2 行动卡、为你推荐、今日趋势 mini 图、快捷记录入口。

#### 改动清单
1. `today_overview_section.dart`
   - 把 5 个维度（睡眠/饮水/情绪/用药/经期）改为统一卡片内横向/2×3 网格，使用 `AppResponsiveSizing`。
   - 每个维度带状态 pill（完成/需关注/未记录）。
2. `today_priority_section.dart`
   - 把当前列表改为 2×2 彩色行动卡片，点击直接唤起对应录入（用药提醒 → Medicine，饮水 → Record 水，情绪 → Record 情绪，就医指南 → Assistant）。
3. `today_recommendation_section.dart`
   - 已接入后端推荐，优化卡片排版：图标 + 标题 + 一句摘要 + 操作按钮。
4. `today_todo_section.dart`
   - 空态 `onAction` 接上：空时显示“去记录”按钮，跳转 `/record/create`。
5. `today_ai_summary_section.dart`
   - disabled 状态增加一个 subtle 提示条：“AI 总结已关闭，可在设置开启”，带前往 `/settings` 链接。

#### 桌面端
- 复用 `_DesktopTodayDashboard`：左侧主 feed，右侧 sticky 推荐/趋势/快捷记录面板。
- 微调间距，使两栏在 1200px 以上不拥挤。

#### 测试
- `test/today/today_page_test.dart`：验证 5 个维度展示、优先事项 2×2 卡片、空态按钮跳转。
- `test/today/today_dashboard_desktop_test.dart`（如无则新增）：验证桌面两栏布局存在。

#### 预估
- 1.5–2 天

---

### 4.2 Record（记录）

#### 当前
- `record_page.dart` + `record_dashboard_view.dart` + 大量子部件。
- 桌面端已有 `_DesktopRecordDashboard` 三栏（左侧日历/筛选、中间时间线、右侧趋势/快捷录入）。

#### 目标
- 对齐 north-star v2：日期选择、快速记录 3 列网格、时间线、症状跟踪/情绪趋势。
- 补齐桌面端右侧趋势面板的编辑链路。

#### 改动清单
1. `record_quick_entry_panel.dart`
   - 把快捷操作整理为 3 列网格（症状/用药/情绪/饮食/饮水/经期/睡眠/心情），统一图标 + 颜色。
2. `record_timeline_widget.dart`
   - 时间线空态增加“快速记录一条”入口。
   - 长按/侧滑编辑（移动端已有的话保留）。
3. `record_trends_panel.dart`（桌面右侧）
   - 把 `onEdit: onNewEntry` 改为真正的编辑回调：点击趋势条目打开 `/record/:id/edit`。
4. `record_page.dart`
   - 为尚未映射的 `medication`、`heartRate`、`weight` 类型增加快速入口（或显式说明需从 Medicine/设备同步，避免用户困惑）。

#### 桌面端
- 保持现有三栏，主要修复趋势面板编辑和空态。

#### 测试
- `test/record/record_page_test.dart`：快捷入口网格数量、颜色、跳转。
- `test/record/record_dashboard_desktop_test.dart`：趋势面板点击条目跳转编辑。

#### 预估
- 1.5–2 天

---

### 4.3 Medicine（用药）

#### 当前
- `medicine_page.dart` + `medicine_mobile_dashboard_view.dart` + 多个 section part。
- 无桌面布局，只有 `_MedicineMobileShell`。
- 存在废弃半成品 `medicine_workspace_view.dart` / `medicine_workspace_parts.dart`。

#### 目标
- 对齐 north-star v2：搜索/扫码、我的药盒、下次服药提醒、安全引擎 2×2、快捷操作、用药记录时间线、安全小贴士。
- **新增桌面端布局**，让 Medicine 在 Shell 内容区内两栏展示。

#### 改动清单
1. 废弃文件清理
   - 删除或归档 `medicine_workspace_view.dart` / `medicine_workspace_parts.dart`（如确认无引用）。
2. `medicine_drugbox_section.dart`
   - 药盒卡片优化：药品名称、剂量、下次服药时间、剩余天数。
   - 空态：引导添加药品 / 搜索。
3. `medicine_safety_engine_section.dart`
   - 改为 2×2 网格（酒精/咖啡因/重复用药/过敏/经期孕哺），每个卡片带 severity 颜色。
   - 点击展开详情或跳转 `/medicine/risk-check`。
4. `medicine_quick_operations_section.dart`
   - 4 个快捷操作统一为圆形图标 + 标签（搜索、扫码、风险检查、新建提醒）。
5. `medicine_records_section.dart`
   - 用药记录时间线，支持“已服用/跳过/待服用”状态。
6. `medicine_page.dart`
   - 顶部通知铃铛红点接入 `notificationUnreadCountProvider`。
   - 构建 `_DesktopMedicineDashboard`：左侧主 feed（药盒 + 安全引擎 + 时间线），右侧 sticky 面板（下次提醒 + 快捷操作 + 小贴士）。

#### 桌面端
- 新建 `medicine_desktop_dashboard_view.dart`（或内嵌 `_DesktopMedicineDashboard`）。
- 断点 ≥ `AppBreakpoints.desktop` 时切换。

#### 测试
- `test/medicine/medicine_page_test.dart`：安全引擎 2×2 网格、药盒空态、快捷操作数量。
- `test/medicine/medicine_desktop_dashboard_test.dart`（新增）：桌面两栏存在，右侧下次提醒/快捷操作可见。

#### 预估
- 3–4 天（含桌面布局）

---

### 4.4 Report（报告）

#### 当前
- `report_page.dart` + `report_dashboard_view.dart` + sections。
- `_ReportMobileShell`，始终 mobile typography，无桌面布局。
- sync 动作是 stub。

#### 目标
- 对齐 north-star v2 / `product-north-star-web-report-v1.png`：健康分数 hero、2×2 指标卡、健康趋势大图、重点发现、导出摘要、隐私设置。
- 新增桌面端布局。

#### 改动清单
1. `report_dashboard_view.dart`
   - 移除 `_ReportMobileShell` 硬编码，改用 `PageScaffoldShell` / `ResponsiveContentFrame`。
   - 根据宽度选择 mobile/desktop typography。
2. `report_score_hero_section.dart`
   - hero 区域：大分数 + 盾牌插图 + 状态 pill + 周期选择器。
   - 桌面端分数与指标卡并排。
3. `report_metrics_grid_section.dart`
   - 改为 2×2 指标卡，每张卡带 sparkline  mini 图和环比箭头。
4. `report_trend_section.dart`
   - 趋势图在桌面端占更大高度，图例可点击隐藏系列。
5. `report_findings_section.dart`
   - 重点发现卡片使用 severity 颜色，支持展开详情。
6. `report_export_section.dart`
   - 导出按钮增加 loading/error 状态，sync stub 接入 `data_export_controller_provider` 的真实刷新。
7. 新增桌面布局
   - 左侧：hero + 趋势图 + 重点发现。
   - 右侧 sticky：指标卡 + 导出摘要 + 隐私入口。

#### 测试
- `test/report/report_page_test.dart`：hero 分数、2×2 指标卡、导出按钮 loading 状态。
- `test/report/report_desktop_dashboard_test.dart`（新增）：桌面双栏布局、右侧面板存在。

#### 预估
- 2.5–3.5 天

---

### 4.5 Mine（我的）

#### 当前
- `mine_page.dart` + `mine_dashboard_view.dart` + sections。
- 纯移动单列 `ListView`，无桌面布局。

#### 目标
- 对齐 north-star v2：头像 + 资料完成度、健康档案入口、隐私控制中心、数据导出、我的目标、校园服务、提醒设置、账户与设置。
- 新增桌面端布局。

#### 改动清单
1. `mine_account_hero_section.dart`
   - 头像、用户名、资料完成度进度条、编辑入口。
   - 桌面端 hero 横向展开，右侧放摘要卡。
2. `mine_status_overview_section.dart`
   - 顶部 3 个摘要卡：记录天数 / 连续天数 / 健康评分（或状态评估）。
3. `mine_health_archive_section.dart`
   - 健康档案入口改为 2×2 网格：基础信息 / 过敏 / 当前用药 / 女性健康 / 紧急联系人。
   - 每项显示完成状态。
4. `mine_privacy_control_section.dart`
   - 隐私开关（数据共享、AI summary）使用主题 accent 色，增加简短说明。
5. `mine_campus_service_section.dart`
   - 评估“校园服务”命名是否过时；如过时改为“健康服务”或“更多服务”。
   - 2×2 服务卡片统一风格。
6. `mine_data_export_section.dart`
   - 数据导出入口增加最近导出时间/状态。
7. 新增桌面布局
   - 左侧：hero + 健康档案 + 隐私控制。
   - 右侧 sticky：状态摘要 + 校园服务 + 数据导出 + 设置入口。

#### 测试
- `test/mine/mine_page_test.dart`：资料完成度、健康档案网格数量、隐私开关。
- `test/mine/mine_desktop_dashboard_test.dart`（新增）：桌面双栏布局。

#### 预估
- 2.5–3.5 天

---

## 5. 隐藏 Branch 跟进（低优先级）

### 5.1 Notifications
- **测试**：新建 `test/notification/notification_list_page_test.dart`、detail page test。
- **文案**：把 `今天` / `昨天` / `更早` 和 type-chip 标签改为 ARB 本地化。
- **入口**：桌面侧边栏是否增加 Notifications 图标？建议与产品确认；如增加，需同步更新 `ShellBranch` 可见性逻辑。
- **未读**：铃铛红点接入 `notificationUnreadCountProvider`（已在 Medicine/Mine 改造中覆盖）。
- 预估：1–1.5 天

### 5.2 Assistant
- 保持当前聊天为主，不做大改。
- 仅修复：大屏下对话 surface 高度不再固定为 520，改用 `LayoutBuilder` 占满可用空间。
- 预估：0.5 天

### 5.3 Settings
- 保持单列，只在大屏下增加最大宽度约束（已部分完成）。
- Help dialog 在桌面端改用 `AlertDialog` + 更宽 `contentPadding`，或改为独立页面 `/assistant`。
- 预估：0.5 天

---

## 6. 实施顺序建议

| Phase | 内容 | 预计 |
|---|---|---|
| Phase 0 | 跨-cutting 前置：空态组件确认、响应式 typography、未读数接入 | 1 天 |
| Phase 1 | Today + Record（已有桌面布局，改动小，先打样） | 3–4 天 |
| Phase 2 | Medicine（缺口最大，优先补齐桌面布局） | 3–4 天 |
| Phase 3 | Report + Mine（新增桌面布局 + 视觉升级） | 5–7 天 |
| Phase 4 | 隐藏 Branch 跟进 + 全量回归测试 | 2–3 天 |
| Phase 5 | 文档更新、迁移日志归档、提交 | 0.5–1 天 |
| **合计** | | **14.5–20 天** |

---

## 7. 待决策问题

在动工前请确认以下 3 点，会直接影响排期和文件范围：

1. **Medicine / Report / Mine 的桌面布局是否是本轮必做？**
   - 是 → 按上表 14.5–20 天。
   - 否 → 可先只做移动端精修，桌面端仅保证不溢出；预计 8–11 天。
2. **Notifications 是否要进入桌面侧边栏常驻？**
   - 是 → 需要改 `ShellBranch.isVisible` 逻辑和 `ShellPage` 侧边栏渲染，增加一个图标。
   - 否 → 保持只从 Mine 顶部入口进入。
3. **“校园服务”是否改名？**
   - 如需改名，需同步改文案 key、测试、north-star 描述。

---

## 8. 验收标准（每个 Tab 通用）

- 移动端在 390×844 和 412×915 两种常见尺寸下无溢出、无截断。
- 桌面端在 1440×900 下，内容区在 Shell 内正常展示，无 RenderFlex overflow。
- 新增/修改文案全部来自 ARB，不硬编码。
- `flutter analyze` 无 issue。
- `flutter test` 全量通过，且每个 Tab 至少新增 1 个布局/交互测试。
- 迁移日志 `docs/migration-log/YYYY-MM-DD.md` 同步更新。

---

## 9. 风险与回滚

| 风险 | 影响 | 缓解 |
|---|---|---|
| Medicine 废弃文件清理误删被引用 | build 失败 | 删除前用 `grep` / `flutter analyze` 确认无引用 |
| 桌面布局改坏现有 widget 测试 | 测试失败 | 先补当前行为测试，再改 UI |
| 文案 key 冲突或漏翻译 | l10n 不完整 | 改完跑 `flutter gen-l10n` 并检查 arb 文件 |
| 未读通知数接入影响多个 Tab | 铃铛状态不一致 | 统一到 `notificationUnreadCountProvider`，一处改动 |

---

## 10. 相关文件索引

- 计划：`plans/per-tab-refinement-plan.md`（本文件）
- 桌面 Shell PRD：`plans/desktop-shell-saas-layout-prd.md`
- 桌面 Shell 实施计划：`plans/desktop-shell-saas-layout-plan.md`
- 迁移日志：`docs/migration-log/2026-06-27.md`
- 设计资产：`docs/assets/product-north-star-tabs-long-v2/`
- 路由：`lib/app/router.dart`
- Tab/Branch 定义：`lib/features/shell/presentation/shell_tab.dart`、`lib/features/shell/presentation/shell_branch.dart`
