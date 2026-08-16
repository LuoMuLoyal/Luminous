---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-16
---

# Active UI — Medicine

Last updated: 2026-08-16 (含本地回执的提醒投递历史)

## 页面结构

根页首页按 Medicine 职责收敛为四块：

1. 当前用药盒
2. 今日服用计划
3. 用药安全摘要
4. 用药操作

未登录时保留 preview workspace + 顶部轻量登录提示，不再误入"添加你的第一个药品"空药盒 CTA。

## 今日服用计划

- slot-aware 打卡链路："已服用 / 跳过"调用 Lucent `POST /user/medicine-dose-logs/mark`。
- Record 页快速用药入口复用同一 dose log 链路：当前药箱决定可记录药品，今日提醒计划决定附近 pending slot 默认选择，成功后发射 `DataChangeTopic.doseLogs` 让 Medicine 主页刷新。
- 快速用药撤销使用 dose log 真实回滚：无旧 log 时删除刚创建的 dose log；已有 log 时恢复旧 status。
- 主页打卡成功 Toast 带「撤销」action，反向 `mark(status: planned)` 幂等恢复原状态。
- 同一种药存在多个 reminder slot 时，每次只确认当前 pending 槽位，不再按药品整天聚合覆盖。
- Hero 的"今日剂次 / 依从率 / 下一剂"按 slot 统计：依从率分母 = 已到期槽位（taken / skipped / overdue 三类）、分子 = taken（skipped 计入分母不计分子）、未到期槽位不计入分母、无到期槽位显示 `--`；下一剂 = 下一**未到期** pending 槽位；`metricDosesToday` 为 F-17 标注死字段，继续填“今日计划槽位总数”。
- Lucent 的稀疏服药合同已保持 reminder slot 独立：`planned` 消费为“待确认”，`skipped` 与“超时未确认”不混成漏服；无 reminder 的临时记录不进入依从率分母。Flutter observed metric 字段待后续合同同步阶段接入（P2 后端仍待做）；前端 P1 已在 mapper 层按到期三态口径对齐。
- 状态 badge 直接控制前景/浅底/边框，不再用 `FBadge.raw` 包装。
- 时间 pill 文本显式使用深色前景。
- 依从率 detail 使用专用 l10n 键（`medicineAdherenceDetail`），不再误用"待服用"。
- `_DrugBoxReminderStrip` 只做信息摘要（下次用药时间 + 依从率），不放 Taken/Skipped 按钮。操作按钮仅在每个 `_TodayPlanRow` 行内，避免同一药品出现两组操作按钮。
- 今日计划默认显示前 4 项，超过时底部显示"查看全部（共 N 项）"可展开/收起。

## 当前用药盒

- `_DrugBoxHeader` 展示药品总数 + 管理按钮，不再在 `_DrugBoxContent` 左侧重复显示大字号计数摘要。
- 药品列表默认显示前 3 种，超过时底部显示"+N 种"可点击跳转药品管理页。

## 通知铃铛

- `_MedicineNotificationButton` 为 `ConsumerWidget`，watch `notificationUnreadCountProvider` 条件渲染红点。
- 铃铛点击路由为 `/notifications`（通知列表页）。

## 用药安全摘要

- 风险检查逻辑已从客户端迁移到后端 API（`GET/POST /api/v1/medicines/risk-check`），前端只消费 API 返回的 `MedicineRiskCheckRecords`。
- 安全卡片（`mobile_safety.dart`）使用单一 `FTappable` → `DecoratedBox` 容器，不再嵌套 `FCard`。所有硬编码中文（"可能已过期"、"上次检查: HH:mm"、"高"/"中"）已迁入 l10n 键。
- 显示最后检查时间：`medicineRiskCheckLastUpdated` l10n 键（正常）/ `medicineRiskCheckStale`（stale=true）。
- 三个指标横向排列（用药数 / 发现数 / 覆盖缺口），竖线分隔，语义着色。
- 紧凑型 `_AlertChip` 替代原来的 `FAvatar` alert 行，最多显示 2 条 + "+N"。severity 标签使用 `medicineRiskCheckSeverityHigh` / `Medium` l10n 键。
- 空状态为盾牌图标 + "暂无风险数据" 文案，整体可点击跳转。
- 红旗组件（`risk_red_flag.dart`）重构为 `RiskRedFlagItem` + `RiskRedFlagSection`，移除 Container 嵌套，改为左侧 4px destructive 色条 + `DecoratedBox(destructive.subtle)` 单容器。
- 红旗升级使用显式线下就医操作文案：`severeAllergy` → 立即拨打急救电话；`informationGap` → 尽快线下核实。
- 告警芯片由 `medicineAlertsFromRiskCheck` 从 `riskCheckRecords` 派生（bestRecord 为 null 时不伪造告警）；`workspace.alerts` / `promisePoints` / `metricDosesToday` 为标注 TODO 的历史占位字段，safety tips 链路为标注 TODO 的死代码，`DoseLogStatus.missed` 为标注不接入主路径的历史兼容值。

## 风险检查边界

- 风险检查由后端 `MedicineRiskCheckService` 执行，支持 static（规则引擎）和 llm（LLM 结构化输出）两种检查类型。
- 后端 `MedicineRiskCheckListener` 监听健康上下文/提醒变更事件，自动标记 stale 并 debounce 5 秒触发静态检查。
- 前端通过 `LucentClient.medicines.medicinesControllerGetRiskCheckV1()` 获取记录，通过 `medicinesControllerRunRiskCheckV1()` 触发检查。
- 前端 `MedicineRiskCheckMapper` 将生成 DTO 映射到 domain entity。
- `MedicineRiskCheckResult` 包含 `overallRiskLevel`（safe/caution/risk/danger）、`overallRiskScore`（0-100）、`findings`、`coverageIssues`、`redFlags`、`overallRecommendation`（LLM only）。
- `MedicineRiskFinding` 新增 `recommendation` 字段（LLM only）和 `longTermUse` / `schedulingConflict` 类型。`copy.dart` 中 `longTermUse` 和 `schedulingConflict` 的 title/body 映射已从 fallback 改为专用 l10n 键。
- `MedicineRiskCheckMapper` 对 unknown finding 类型返回 null 并过滤该条（不再误标 specialGroup）。
- 风险检查页面（`risk_check.dart`）重构为 `FTabs(expands: true)` 双 tab 布局："系统检查" tab 展示静态检查记录，"AI 分析" tab 展示 LLM 检查记录。每个 tab 内 `CheckTabContent` 组件渲染：风险评分英雄区（`RiskScoreRing` CustomPaint 环形进度条 + 等级标签 + 描述文案）、红旗区、指标网格、发现列表（折叠/展开）、覆盖缺口列表、安全状态卡片。LLM tab 额外处理空状态 CTA、过期横幅、总体建议卡片和不可用状态。
- 组件类名统一重命名：`MedicineRiskFindingTile` → `RiskFindingItem`（移除 FCard，改为左侧色条布局，显示 LLM recommendation）；`MedicineRiskCoverageIssueTile` → `RiskCoverageItem`；`MedicineRiskMetricChip` → `RiskMetricCell`（移除 FCard，改为 Expanded + 右边框网格单元格）；`MedicineRiskRedFlagBanner` → `RiskRedFlagItem` / `RiskRedFlagSection`。
- `copy.dart` 新增辅助函数：`medicineRiskLevelLabel`、`medicineRiskLevelColor`、`medicineRiskLevelDescription`、`medicineRiskCheckFormatTime`。
- 新增 27 个 l10n 键（zh + en）：风险检查 tab 标签、风险评分标题/等级/描述、建议/总体建议、最后更新/过期/过期横幅、运行检查/运行 AI 分析、LLM 空状态/不可用、从未检查、长期用药风险标题/描述、用药计划冲突标题/描述。

## 药品搜索与扫描

- 搜索结果的新增前保存风险预检查。
- 来源审核安全预览。
- 过敏安全检查。
- 药品拍照识别（药盒 AI 识别）和条码扫描已在移动端暴露。
- 处方导入/OCR 处方识别仍延后（底层枚举保留但仅 Toast 提示）。
- 扫码页全部硬编码中文已迁入 l10n 键。
- `MedicineMatchType.name` 英文枚举直出改为 `_matchTypeLabel` + l10n 映射。
- 扫码结果对话框和处理遮罩统一使用 `showAppDialog(barrierDismissible: false)` 调用，不再直接使用底层 `showFDialog`；`MedicineRecognizeDialog` 移除 `FDialog` 包装层和 `animation` 参数，由 `DialogShell` 统一管理对话框框架。
- OCR 入口 ABI 预检（2026-07-30）：用户选择 OCR 方式后、打开相机前调用 `PaddleOcrEngine.ensureInitialized()` 预检 native 库可用性。init 失败（非 arm64 设备、模型损坏等）时显示 `_showOcrUnavailableDialog`，提供关闭和"使用 AI 识别"两个操作，避免用户拍照后才发现 OCR 不可用。

## 药品详情页

- 路由 `/medicine/detail/:source/:id`（typed `MedicineDetailRoute`，全屏 `slidePage`；桌面复用同一页面布局，不新增桌面专属 UI，也不启用窄侧栏 sidePanel）。
- 数据来源：`GET /api/v1/medicines/{id}?source=`（`@Public`，后端 30min 缓存；客户端不缓存）。生成客户端 `medicinesControllerGetDetailV1` 返回 `MedicineDetailResponseDto`，`MedicineDetailMapper` 映射为 `MedicineDetail`（空串 trim 转 null）。
- 分区渲染用 `FAccordion` + `FAccordionItem`，首分区（CN 适应症 / DrugBank 描述）`initiallyExpanded: true`；空/null 字段分区整体不渲染；整页无可展示分区显示「暂无说明书内容」空态。
- 加入药箱：`CurrentMedicineWriteInput` + `createCurrentMedicine` + `DataChangeTopic.currentMedicines`，与 search 页一致但**不做风险预检**（预检归 scan-search 计划）；已添加态显示禁用 outline「已添加」。
- Reminder 详情药品卡：`sourceRefId` 非空且 `source ∈ {cn, drugbank}` 时包 `FTappable` 跳详情页，否则保持原样。

## 提醒

- Lucent schedule-only 提醒详情/创建/编辑/删除 UI。
- 可选起止日期窗口使用 Forui `FCalendar.grid`。
- 本地声音偏好。
- 按提醒计划同步的本地通知调度。
- SMS 不可用状态。
- 含本地回执的投递历史展示：本地通知展示后客户端幂等回写 `local/delivered` 行，本地不可达时后端按 JPush 结果写 `push` 行，UI 同时展示 `in_app`/`local`/`push` 通道标签（`deliveryChannelLabel`）。
- 桌面端提醒 new/detail/edit 路由使用 `sidePanelPage`（右侧滑入面板），移动端使用 `slidePage`（全屏）。
- 通知权限 `permanentlyDenied` 状态时自动调用 `openAppSettings()` 跳转系统设置。
- 提醒详情页中间信息列表使用 `FTileGroup` 分组（`FItemDivider.full`），消除独立 `FTile` 造成的行间距；顶部药品图标衬底改为圆角矩形（`RadiusTokens.level2`）。

## 数据层

- `DoseLogRemoteDataSource`/`ReminderRemoteDataSource` 通过 `generated/lucent_api` Retrofit 客户端访问。
- `MarkDoseLogDto` 直接作为 `@Body()` 参数传递。
- **ADR-0009 cache-first**: `CachedDoseLogDataSource` 包装 `DoseLogRemoteDataSource`：
  - `fetchForDate`: 先读缓存（节流 60s）→ 缓存空则走网络 + 写缓存。
  - `create`/`update`/`mark`/`delete`: 远程成功后刷新缓存（`delete` 需要调用方传入日期）；`DioException` 时入队 `pending_sync_queue`（entityType=`dose_log`），注册 SyncWorker handler 重放后按 `scheduledFor` 或调用方提供的日期刷新缓存。
- 消费方已全部迁移。

## 2026-07-19 补充

### 用药主页

- 药箱计数统一使用过滤后的 `items.length`，消除"共 N 种"与实际行数不一致。
- 窄屏"安全守护" pill 隐藏文字仅显示图标。
- 骨架屏按真实 section 顺序重排，统一使用 `AppSkeletonShimmer`。

### 提醒详情

- 详情页新增启停 switch 卡片，直接切换 `isActive`。
- 时间列表 `ReminderInfoRow` 新增 `maxLines: 2`，多时间拼接不再溢出。
- 提醒方式行拆为独立行（通知/短信/提示音），不再拼接为单行。

### 提醒编辑

- 无 medicineId 时自动从药箱列表选第一种药并渲染表单+FSelect。
- 添加时间前去重检查，重复时 toast 提示。
- 移除顶栏保存按钮，仅保留底部主按钮 + `FCircularProgress` 进度。

### 风险检查

- findings/coverageIssues 超过 5 条时折叠，附"展开全部（共 N 条）"按钮。

### 药品搜索

- 移动端结果卡仅在提供 `onTap` 时才包 `FTappable`（桌面预览），移动端不包裹避免无效点击。
- `updateQuery` 新增 300ms 防抖，取消前一次未完成搜索。
- "加入药箱"成功后显示带"去设提醒"action 的 toast（`AppToast.showWithAction`）。
- 桌面端 `DesktopTabs` 删除两个 `onPress: () {}` 空回调假 tab 按钮，只保留标题和用户头像装饰。

### 扫码

- 扫码页重写为四角括号扫描框+暗化遮罩+底部提示文案。
- 权限被拒时显示引导页（"去系统设置开启"按钮）。
- 识别中 loading 遮罩；手电按钮状态实时刷新。
- 识别失败/未找到时底部常驻"手动搜索"入口。
- 多结果候选 sheet 规范化为带标题、分隔线、取消按钮的 bottom sheet。

## 2026-07-19 P2 低级一致性打磨

- `risk_finding_tile.dart` 移除恒 false 的 `0.08 > 0.5` 死代码，图标色改用 `resolvedColor` 而非 `foreground`。
- 提醒失败 toast 专用化：`reminder_detail.dart` 删除失败用 `medicineReminderDeleteFailedToast`；`reminder_edit.dart` 保存失败用 `medicineReminderSaveFailedToast`，错误描述用 `medicineReminderNotFoundDescription`（不再空串）。
- `log_panels.dart` 日志条目超过可见上限时显示 `medicineReminderLogCountTotal`（ICU plural "共 N 条记录"）。
- `result_widgets.dart` 搜索结果匹配方式从硬编码全角冒号改为 `medicineSearchMatchedByType` l10n 键（"匹配方式：{type}"）。

## 2026-07-20 P0 修复

- 移除死路由常量 `AppRoutes.medicineReminders`（该路径无对应页面）。
- 通知铃铛按钮跳转改为 `/notifications`（通知列表页）。
- `_MedicineSafeGuardPill` 窄屏下使用 `FButton.icon`（仅图标），宽屏使用 `FButton`（图标+文字），消除 `child: null` 断言。
- 提醒启停切换失败 Toast 从 `settingsSyncFailed` 改为专用 `medicineReminderToggleFailedToast`。
- 扫码识别中文案从 `scanRecognitionFailedToast` 改为 `scanRecognizingHint`（"识别中…"）。

## 2026-07-20 P1 用药/搜索/扫码

- **桌面搜索栏全状态可见**：loading/error/empty 三个桌面分支均渲染 `_MedicineMobileSearchBar()`，与 ready 态一致。
- **搜索结果"已添加"态**：`SearchPage` 通过 `healthContextSnapshotProvider` 获取当前药品集合，构建 `source:sourceRefId` 键集合传入搜索视图。已添加的结果卡显示禁用 outline 按钮 + check 图标 + "已添加"文案，防止重复添加。
- **拍照识别失败手动兜底**：catch 分支从 toast 改为 `_showScanFailureDialog()` 对话框，提供"重新拍照"和"手动搜索"（跳转 `/medicine/search`）两个操作。
- **死键清理**：`scanSearchFailedToast`（零引用）删除；`scanManualSearchToast` / `scanManualSearchAction` 从零引用改为在失败对话框中使用。
- **扫码遮罩安全弹窗**：新增 `_dismissOverlay()` 函数，通过 `canPop()` 检查后再 `pop()`，替代脆弱的 `Navigator.of(rootNavigator: true).pop()` 直弹。
- **扫码结果对话框关闭按钮**：新增 `onClose` 可选回调和 `scanCloseAction` 按钮（ghost 变体），无结果时可直接关闭不必重拍。

## 2026-07-20 P2 用药模块打磨

- **图标魔数统一**：`mobile_safety.dart`、`mobile_drugbox.dart`、`risk_red_flag.dart`、`rows.dart`、`log_panels.dart`、`form_fields.dart` 的 `size: 16` / `size: 18` 统一替换为 `size: Spacing.level5`（18），消除魔数。
- **提示音下拉固定宽 140 → Flexible**：`rows.dart` 的 `SizedBox(width: 140, child: FSelect(...))` 改为 `Flexible(child: FSelect(...))`，宽度自适应。
- **搜索超时文案中性化**：`medicine_search.dart` 的 `TimeoutException` 消息从硬编码中文改为英文（实际不上屏，由 `LucentErrorMapper` 覆盖）。

## 2026-07-20 P2 用药模块打磨续

- **跳过按钮区分**：`mobile_records.dart` 和 `mobile_drugbox.dart` 的跳过按钮从默认 `SemanticColor.primary` 改为 `SemanticColor.neutral`，与已服按钮（primary 填充）视觉区分。
- **红旗 action 去假链接**：`risk_red_flag.dart` 的 action 文案去掉 `FontWeight.w700`，避免被误认为可点击链接。
- **coverage 图标改 warning 色**：`risk_coverage_issue_tile.dart` 的 `circleAlert` 图标从 `colors.primary` 改为 `SemanticColor.warning.solid`，正确表达数据覆盖缺失的警告语义。
- **日志面板展开收起**：`ReminderDeliveryLogPanel` 从 `StatelessWidget` 改为 `StatefulWidget`，新增 `_showAll` 状态。日志超过 5 条时底部显示 ghost 按钮"查看全部"/"收起"，点击切换全部/前 5 条。新增 `medicineReminderLogCollapse` l10n 键。
- **告警行装饰 chevron 移除**：`mobile_safety.dart` 的 `_SafetyAlertRow` 移除尾部装饰性 `chevronRight`，整行已是 `FTappable`，chevron 与上方"查看"按钮目标重复。
- **短信不可用行降权**：`rows.dart` 的 `UnavailableMethodRow` 整体包裹 `Opacity(0.5)`，标题从 `FontWeight.w700` 改为 `mutedForeground` 色，视觉上明确表达"不可用"语义。
- **频率切换清空星期提示**：`reminder_edit.dart` 切换为每日频率时若有已选星期，显示 `medicineReminderFrequencyDailyClearedWeekdays` toast 提示。
- **扫码置信度解释**：`recognize_dialog.dart` 的置信度文本包裹 `FTooltip`，长按显示 `scanResultConfidenceExplanation` 解释文案。
- **扫码结果头图占位**：`recognize_dialog.dart` 的 `Image.file` 新增 `errorBuilder`，图片加载失败时显示 `imageOff` 图标占位。
- **扫码线框尺寸常量化**：`barcode_scanner.dart` 的 280×120 硬编码提取为 `_scanFrameWidth` / `_scanFrameHeight` 文件级常量。
- **指标 chip 联动**：`MedicineRiskMetricChip` 新增 `onTap` 参数，有对应列表段时点击用 `Scrollable.ensureVisible` 滚动到 findings/coverage 段。`_RiskCheckSectionCard` 构造函数加 `super.key` 接受 `GlobalKey`。
- **桌面预览空态改结构化**：搜索 `PreviewPanel` 的 `preview == null` 空态从一行小字改为带图标+居中文案的结构化空态。

## 2026-07-21 Medicine 主页空态与搜索栏微调

- **搜索栏图标偏移**：`_MedicineMobileSearchBar` 的放大镜左侧增加 `SizedBox(width: Spacing.level2)`，让图标与左边框保持 6px 呼吸间距。
- **未登录 preview 空态完整化**：`MedicinePage` 的 `isInsufficient` 判断增加 `session.isAuthenticated` 前缀；未登录时空计划不再进入"添加你的第一个药品"全屏空态，而是走 `readyBuilder` 并在顶部显示 `SignInHintBanner`，下方完整渲染当前用药盒、今日服用计划、用药安全摘要、用药操作四个 section 的空态。
- **已登录空计划保持不变**：仍显示 `AppStateMessageView`（"添加你的第一个药品"）。
- **今日服用计划空态文案**：`mobile_records.dart` 使用独立 `_TodayPlanEmpty`，文案键 `medicineTodayPlanEmpty`（"No doses scheduled today" / "今日暂无服药计划"）。
- **用药安全空态卡片**：`mobile_safety.dart` 在 `result == null` 时渲染 `_SafetyEngineEmpty` 显式空态卡片，文案键 `medicineSafetyPanelEmptyTitle` / `medicineSafetyPanelEmptyBody`。
- **测试**：新增/更新 `test/medicine/page_test.dart` 红测试先行，覆盖搜索栏偏移、未登录空 dashboard、已登录空计划三个场景；`flutter test test/medicine` 全部通过。

## 2026-07-26 搜索页布局修复

- **搜索框与标题间距**：`lib/features/search/presentation/widgets/views/view.dart` 移动端内容顶部内边距从 `Spacing.level4` 降至 `Spacing.level3`，桌面端保持 `Spacing.level5`。
- **来源切换改为 Forui Tabs**：`lib/features/search/presentation/widgets/sections/source_switch.dart` 从 `Wrap` + `FButton.raw` 按钮改为 `FTabs` + `FTabControl.lifted` + `FTabEntry`（子内容使用 `SizedBox.shrink()`），与登录页模式切换风格一致。
- **快捷操作防溢出**：`lib/features/search/presentation/widgets/sections/quick_actions.dart` 的 `_QuickActionButton` 内行文字包裹 `FittedBox(BoxFit.scaleDown)`，窄屏下"Scan barcode" / "Photo recognition" 双按钮不再溢出 14px。

## 2026-07-22 搜索页 SourceSwitch 防溢出

- `SourceSwitch` 从 `Row` + `Expanded` 改为 `Wrap` + `ConstrainedBox(minWidth: 120)`，消除窄屏下"国内药品"/"DrugBank" 双按钮文字溢出。
- 按钮间距由 `Wrap.spacing` / `runSpacing` 统一控制，移除原先最后一个元素特殊判空的 `Padding` 逻辑。


## 2026-07-26 P0 药品数据与风险检查修复

### 药品详情 `drugInteractions` 类型对齐

- 后端新增 `DrugbankDrugInteractionDto`（`drugbankId` + `description`），`DrugbankMedicineDetailDto.drugInteractions` 改为数组；CN 详情不再携带该字段。
- 重新生成 `generated/lucent_api/` 后，`MedicineDetailDataDtoDetail.drugInteractions` 为 `List<DrugbankDrugInteractionDto>?`，消除 `List<dynamic> is not a subtype of String?` 运行时异常。
- 风险检查链路（`risk_checker.dart`、`risk_medicine_detail.dart`）通过 `toJson()` 读取列表，无需改动。

### 风险检查 coverage 文案去中文硬编码

- 移除 `risk_checker.dart` 中的硬编码中文覆盖摘要。
- 新增 l10n 键 `medicineRiskCheckCoverageSummaryManual` / `medicineRiskCheckCoverageSummaryUnavailable`。
- 英文环境下显示英文摘要，不再混入中文。

### 用药搜索页布局

- 搜索框与顶部标题间距：移动端顶部内边距从 `Spacing.level4` 降至 `Spacing.level3`。
- 来源切换：改为 `FTabs` + `FTabControl.lifted`。
- 快捷操作：`_QuickActionButton` 内部包裹 `FittedBox(BoxFit.scaleDown)`，修复 14px 溢出。

### 数据导出枚举默认值修复（关联生成器 bug）

- 后端 `CreateDataExportRequestDto` 移除枚举字段 `default`，默认值由 service 层兜底。
- 避免 `openapi-generator` 生成非法 `const Enum._('value')` 构造函数与 `.g.dart` 中 `?? 'value'` 类型错误，确保 `flutter test` 编译通过。
