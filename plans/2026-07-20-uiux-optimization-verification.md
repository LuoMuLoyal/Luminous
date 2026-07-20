# UIUX 优化计划核查报告与剩余工作

> 创建日期：2026-07-20
> 性质：对 `2026-07-18-uiux-per-page-optimization.md` 执行结果的逐条核查（53 个提交，截至 964c1826）
> 核查方式：7 路并行逐条比对当前工作区代码（非提交信息），l10n 键双语抽查，外加 `flutter analyze` / `flutter test`
> 结论：**约八成条目已落地且质量不错，但不能认定"全部完成"** —— 存在 2 个修复引入的新 bug、30 个测试失败、约 25 项未做与 20 项部分完成。

---

## 一、总体验收状态

| 检查项 | 结果 |
|--------|------|
| `flutter analyze` | ✅ 零问题 |
| `flutter test` | ❌ **2727 通过 / 30 失败**，全部集中在本次改动模块 |
| 计划"高"级别条目 | 绝大多数 ✅，但修复引入 2 个新 bug（见第二节） |
| 计划"中"级别条目 | 大部分 ✅，记录模块与报告模块有实质缺口 |
| 计划"低"级别条目 | 约半数完成 |
| 第五节"不得回退"清单 | ✅ 基本守住（状态架构、骨架基建、预检对话框、AuthShell 等均未回退） |

已验证落地较好的部分（无需再动）：跨页面 C1-C7（死代码清理、五 tab 骨架重排、硬编码文案、危险确认链、触控语义、间距 token 化、错误文案 mapper）；mine 模块 24/26 项；助手/通知高级别 9 项；settings 18/25 项。

---

## 二、修复引入的新问题（最高优先，均已复核确认）

| # | 问题 | 证据 | 修法 |
|---|------|------|------|
| R1 | **死路由回归**：用药主页铃铛与今日"提醒设置"快捷操作均跳 `/medicine/reminders`，该路径未注册任何 GoRoute（只有 `/new`、`/:medicineId`、`/:medicineId/edit`），点击触发 go_router 错误页 | `medicine/presentation/pages/page.dart:337`、`today/presentation/widgets/shared/view_models.dart:350`、`app/router.dart:79`（常量存在但无路由） | 决策落点（如新建提醒页 `/medicine/reminders/new` 或用药主页锚点），两处统一 |
| R2 | **扫码页文案张冠李戴**：识别中显示 `scanRecognitionFailedToast`（"识别失败，请重试"） | `scan/presentation/pages/barcode_scanner.dart:326-328` | 新增/改用"识别中"文案键 |
| R3 | **提醒启停失败 toast 复用错键**：新增启停切换的失败提示又用了 `settingsSyncFailed` | `medicine/presentation/pages/reminder/reminder_detail.dart:431` | 复用 `medicineReminderDeleteFailedToast` 同款专用键 |
| R4 | **`flutter test` 30 红**：分布与性质见下表 | 详见第三节 | 逐个区分"测试随实现更新"与"真回归" |

---

## 三、测试失败清单（30 个）

| 文件 | 数量 | 初步定性 |
|------|------|----------|
| `test/medicine/page_test.dart` | 9 | 含 `RenderFlex overflowed by 99730px` 渲染异常，定位到顶栏 `_MedicineSafeGuardPill`（`medicine/presentation/pages/page.dart:256`）——**需先确认是真布局 bug 还是测试环境假象**；其余多为断言旧 UI |
| `test/search/presentation/providers/medicine_search_notifier_test.dart` | 7 | 疑似 400ms 防抖引入后测试未配 fake async / 超时文案变更 |
| `test/settings/`（page/subpages/more_subpages/help/flow） | 8 | 多为断言旧 UI（如"开源许可"行已按 P0 删除、帮助页状态组件已换），测试未跟进 |
| `test/medicine/`（reminder_pages、reminder_form_body） | 3 | 表单行为变更（isSaving 禁用、药品预填流程）后测试未跟进 |
| `test/record/`（page、ocr_entry_dialog） | 2 | OCR 空结果文案移除后测试未跟进等 |
| `test/notification/providers_test.dart` | 1 | `notificationUnreadCountProvider` 行为变更 |

验收标准（原计划第六节）要求 analyze + test 全绿，此项**目前不达标**。

---

## 四、计划内未做 / 部分完成清单

> 仅列未闭环项；已 ✅ 的约 100 项不再复述。级别沿用原计划。

### 4.1 跨页面共性

- ⚠️ C8 收尾漏 2 处：PIN"上次修改时间"仍手拼 `yyyy-MM-dd HH:mm`（`settings/presentation/pages/security_pin.dart:326-328`）；legal 列表 `updatedAt` 仍显示后端原始串（`legal/presentation/pages/list.dart:59`）。
- ⚠️（计划外残留）`core/network/error_mapper.dart:20,105-112` 通用错误兜底仍硬编码中文，英文界面极端错误路径会露中文。

### 4.2 今日（today）

- ⚠️（中）用药指标分母仍是"全部当前药品数"而非今日应服（`repositories/lucent.dart:23-25,98`），值已 l10n 化但误导语义未消除。
- ⚠️（中）置信度标签未按计划用 `FBadge` 呈现（只升了字号+加 chevron，`observation.dart:157-169`）；zh 的 medium/low 文案仍高度相近。

### 4.3 记录（record）——未闭环最多

- ❌（中）桌面筛选复选框图标暗示多选、单选不可取消（`sidebar.dart:428-436`、`providers/dashboard.dart:30-33`）。
- ❌（中）创建表单仍选不到 mood，两端类型集合未对齐（`form_fields.dart:225-231`）。
- ❌（中）语音 sheet 三件套：`errorMessage` 只存不显（`voice_entry_dialog.dart:48`）；初始化失败三类场景仍统一报"麦克风权限未授权"（:109-113、:125-129）；识别结果仍只读（:198-209）。
- ⚠️（高）必填校验只有 toast 无内联 error/聚焦，且"标题（可选）"标签与必填校验自相矛盾（`create.dart:244-278`、`form_fields.dart:127`）。
- ⚠️（中）保存中仅按钮有进度，表单字段未整体禁用（`create.dart:381-417`）。
- ⚠️（中）桌面骨架仍 2 列对真实 3 列版面（`skeleton_view.dart:47-84`）。
- ⚠️（中）语音/OCR 预生成阶段失败仍无提示（`page.dart:404-407` + `nlp_dialog.dart:26-32`）。
- ⚠️（低）移动端筛选空态无内联"清除筛选"（仅桌面有）；OCR 空结果牵强文案已删但无替代反馈。
- ❌（低）移动端"回到今天"入口；`date_bar` fontSize 11/14 硬编码；两端 locked 筛选策略不一致；图片附件无拍照入口；创建页字段无分区/标题过泛/切类型静默保留；脏状态返回无确认（全模块无 `PopScope`）；详情页编辑入口头尾重复、标签固定宽 88；菜品删除按钮无 tooltip/语义；NLP 候选睡眠仍分钟输入。

### 4.4 用药 / 搜索 / 扫码

- ⚠️（中）桌面搜索栏仍未固定进 `DesktopTabShell`，loading/error/empty 分支无搜索栏（`medicine/pages/page.dart:142`）。
- ❌（中）搜索结果卡无"已添加"态，可重复添加（`result_widgets.dart:87-90`）。
- ⚠️（中）拍照识别失败仍仅 toast 无手动兜底；新增 `scanManualSearchToast`/`scanSearchFailedToast` 两键零引用（死键）。
- ❌（中）扫码处理遮罩仍 `Navigator.of(rootNavigator: true).pop()` 脆弱写法（`box_scan.dart:68,91`）；结果对话框仍无关闭按钮，无结果时只能重拍（`recognize_dialog.dart:208-229`）。
- ⚠️（低）搜索超时文案中文硬编码仍在 `medicine_search.dart:78`（当前不上屏）。
- ❌（低）跳过按钮仍主色仅填充区分；"查看"按钮与告警行 chevron 目标重复；图标 size 16/18/20 魔数多处；coverage 图标仍 secondary 色；指标 chip 不可联动；红旗 action 假链接样式；日志无"查看全部"；短信不可用行未降权；提示音下拉固定宽 140；频率切换静默清空星期；桌面预览空态一行小字；置信度无解释；线框 280×120 硬编码；结果头图无占位。

### 4.5 报告（report）

- ❌（中）切时间范围首次加载仍整页骨架，无旧值兜底（family 新实例无缓存，`providers/dashboard.dart:15-19`）。
- ❌（中）AI 总结"自定义"范围仍无日期选择入口，可空日期请求（`sections/ai_summary.dart:117-120`、`providers/ai_summary.dart:49-55`）。
- ❌（中）桌面 loading 外壳 `ReportActionBar` 仍空回调假按钮（`page.dart:353`）。
- ⚠️（中）图表 tooltip 恒显示 `currentValue` 而非触点值且无日期（`trend.dart:237`）；图表 Semantics 只有标题无数值摘要。
- ⚠️（中）clinicShare 全程无进行中态；非进行中卡片禁用态仍显示 chevron（`export.dart:108-119`）。
- ⚠️（中）移动端"弹窗套弹窗"未改（`range_picker_dialog.dart:15,60`）。
- ⚠️（低）`emptyInsufficientBuilder` 死代码仍在（`page.dart:291-314`）；分数字号 token 外覆盖；装饰图标无 `ExcludeSemantics`；就绪卡"生成总结"入口无 loading；suggestion_history 仍传 `onSuggestionTap: null`（原计划注明可不阻塞）。

### 4.6 我的（mine）——完成度最高

- ❌（低）角色文案仍固定"大学生"（`data/repositories/lucent.dart:50`、`domain/entities/dashboard.dart:26`）。
- ⚠️（中）用药表单"途径/剂量"只有示例 hint，无常用值选择器（`current_medicine_edit.dart:291,299`）。
- 备注：桌面骨架 SyncBanner 位置注释与实现不符；`medicineSourceLabel`、`archiveRecordListTitle` 成无引用残留。

### 4.7 设置（settings）

- ❌（中）PIN 校验失败仍只有 toast、无行内 error（`security_pin.dart:345,349,383,387,419`）。
- ⚠️（中）advanced 两个弹层 + feature_flags provider 弹层勾选图标仍 `selected ? : null` 无占位（`advanced.dart:341-343,426-428`、`feature_flags.dart:230-232`）。
- ⚠️（中）帮助页未接重试 action，且 title/description 传同一字符串重复显示（`help.dart:42-46,71-76`）。
- ⚠️（低）"通知"组仍单 tile；免打扰摘要仍用 subtitle 其余用 details；支持 URL 仍为文件内常量（仅作兜底）；垂直 padding helper 仅主页在用。
- 备注："健康档案"入口已移组但仍 push `/mine` tab 根，返回栈问题实质未解决。

### 4.8 助手 / 通知 / 法律 / 认证

- ❌（低）助手：用户消息不可选择复制、无时间戳无长按菜单（`message_bubble.dart:66-72`）；"正在打开…/生成中"仍纯静态文本。
- ⚠️（中）通知：桌面端无 hover 操作钮，仍只能 Slidable 鼠标拖（`list_item.dart:44-69`）。
- ❌（低）认证：头像仍仅 URL 输入无预览无校验（`account_settings.dart:567-572`）；各页辅助链接仍 sm 小字小触控目标。
- ⚠️（中）认证：改密/注销字段已加 validator 但无 `Form` 包裹，提交仍走 toast 双通道；验证码按钮残留 `top: 26` 魔数，`change_email.dart:74-90` 冷却期仍可点。
- 备注：助手加载骨架第三段仍对应已移除的常驻开关面板；provider 层个别硬编码错误文案（`conversation.dart:298,440`、`auth/providers/account.dart:104`）。

---

## 五、剩余工作分批建议

### P0 —— 立即修（新引入问题，预估 < 半天）

1. R1 死路由：决策 `/medicine/reminders` 落点并统一两处入口。
2. R2 扫码"识别中"文案。
3. R3 启停失败 toast 专用键。
4. R4 测试修复：先查 `_MedicineSafeGuardPill` 溢出是否为真 bug，再逐文件区分"更新测试 vs 修代码"至全绿。

### P1 —— 一个迭代内（中级别实质缺口）

1. 记录：语音 sheet 三件套（错误显示/分类文案/结果可编辑）；必填校验内联化并消除"标题（可选）"矛盾；桌面筛选单选语义+可取消；创建表单 mood 对齐；预生成阶段失败提示。
2. 报告：切范围保留旧值；AI"自定义"日期入口（或移除该项）；桌面 loading 假按钮禁用；图表 tooltip 触点值+日期。
3. 用药/搜索/扫码：结果卡"已添加"态；扫码结果框关闭按钮+遮罩改造；桌面搜索栏固定；拍照失败手动兜底（并清死键）。
4. 记录/报告骨架收尾（桌面 3 列）；PIN 行内 error；帮助页重试 action。

### P2 —— 打磨批（低级别合一次提交）

- 4.x 节全部 ❌/⚠️ 低级别项 + C8 两处漏改 + error_mapper 中文兜底 + provider 层硬编码错误文案 + 无引用残留清理。

---

## 六、验收方式（沿用原计划）

- 每批完成后 `flutter analyze` + `flutter test` 全绿；改动页面过 zh/en 双语与 1.2 倍文字缩放。
- 完成条目按 plans 规范整节删除；本文件与原计划文件在全部闭环后一并删除。
