---
status: active
owner: frontend
quadrant: explanation
updated: 2026-08-15
---

# 扫码识别与搜索 功能盘点与审计

> 范围：`Luminous/lib/features/scan/`、`Luminous/lib/features/search/`；
> 后端对照 `Lucent/src/modules/medicines/`（controller/service/adapters）、`Lucent/src/modules/files/`；
> 参考文档：`Luminous/docs/01-product/Product_Vision.md`、`Luminous/docs/00-current/Runtime_Snapshot.md`、
> `Luminous/plans/2026-07-29-native-bridging-roadmap.md`（视为已执行）、`Lucent/src/i18n/zh-CN/medicine.json`。

## 功能点总览

| 功能点 | 一句话作用 | 真伪 | 结论 | 优先级 |
|---|---|---|---|---|
| F-1 条码扫码页 | 相机扫药品条码（mobile_scanner），含权限/手电筒/手动搜索兜底 | 真实现 | 改造 | P0 |
| F-2 扫码结果匹配 | 用条码值搜 cn 药品库（name/barcode/批准文号等字段），多结果给候选列表 | 真实现 | 保留 | P1 |
| F-3 扫码后"查看详情"跳转 | 单结果直接跳 `/medicine/reminders/:medicineId` | 假实现（断链） | 改造 | P0 |
| F-4 药盒 OCR 识别 | 端侧 PaddleOCR（PP-OCRv6/ONNX）识别文字块，布局评分提取药名/批准文号候选，逐候选搜库 | 真实现 | 改造 | P1 |
| F-5 药盒 AI 识别 | 拍照压缩→COS 预签名上传→后端 LLM 视觉识别（名称/批准文号）→搜库 | 真实现 | 改造 | P1 |
| F-6 识别结果确认弹窗 | 展示 top 结果/候选列表/置信度，"确认，查看详情"按钮 | 部分实现（含假置信度+断链按钮） | 改造 | P0 |
| F-7 OCR 不可用回退 | 进相机前预检 OCR 引擎初始化，失败给"改用 AI 识别"对话框 | 真实现 | 保留 | P2 |
| F-8 关键词搜索 | cn/drugbank 双源切换 + 400ms 防抖 + 5s 超时，后端 Prisma 模糊查询 | 真实现 | 保留 | P0 |
| F-9 加入药箱 | 登录门控 → 风险预检弹窗 → 建档 → Toast 带"去设置提醒"直达新建提醒页 | 真实现 | 保留（修预检范围话术） | P0 |
| F-10 搜索页扫码/拍照快捷入口 | QuickActions 两个入口（仅 Android/iOS 渲染） | 真实现 | 保留 | P1 |
| F-11 桌面端预览面板 | 选中结果拉详情，显示"临床提示/安全确认" | 部分实现（内容造假，桌面冻结） | 改造/归档 | P2 |
| F-12 最近搜索 / 分类快捷 | 空查询时的历史关键词与分类导航 | 假实现（永远空列表，无数据源） | 改造 | P2 |
| F-13 无结果工具 | 无结果时给"换关键词/换数据源"两个动作 | 真实现 | 保留 | P2 |

## 逐功能分析

### F-1 条码扫码页

- 现状：`BarcodeScannerPage`（`scan/presentation/pages/barcode_scanner.dart:24`）。相机权限申请/永久拒绝引导、扫到码后停相机、调仓库搜索、失败 Toast 后自动恢复扫描；路由 `/scan/barcode`（`scan/presentation/routes.dart:8`）。
- 实际作用：把"手里有药盒"转成一次数据库查询，省掉手输条码。交互质量在模块内属上乘（权限恢复监听、重复触发防抖 `_hasScanned`）。
- 实现真实性：真实现。`mobile_scanner` 真实相机扫码（`barcode_scanner.dart:283`），权限走 `permission_handler`。测试覆盖充分（`test/scan/barcode_scanner_page_test.dart` 8 个用例含权限/候选/恢复）。
- 结论：改造。
- 改造方案：页面本身保留，问题是它的出口（见 F-3）。另修一个小 bug：手电筒按钮开关两种状态用同一个图标（`barcode_scanner.dart:271-275`，`_torchOn` 三态表达式两个分支都是 `SemanticIcons.safetyAllergy`），用户无法感知闪光灯状态。
- 优先级：P0（链路的入口端，出口修复前整个功能等于不存在）。

### F-2 扫码结果匹配与候选选择

- 现状：`LucentScanRepository.search`（`scan/data/repositories/scan.dart:24-40`）硬编码 `source: 'cn'`、pageSize 20，把条码原始值当 query 搜药品库；多结果弹底部候选 sheet（`barcode_scanner.dart:147-234`）。
- 实际作用：条码命中药品库记录。后端 `CnMedicinesService.buildWhere` 确实查 `barcode` 字段（`Lucent/src/modules/medicines/adapters/cn.service.ts:107`），不是拿条码当关键词撞药名，匹配语义正确。
- 实现真实性：真实现。命中逻辑真实，未找到时弹 Toast 恢复扫描（`barcode_scanner.dart:108-117`），空结果处理诚实。
- 结论：保留。
- 改造方案（小问题）：条码是精确标识，`contains` 模糊匹配可能把子串相同的其他条码带出来（如 69 码前缀截断），可对纯数字 query 优先等值匹配 barcode 字段；后端 DTO 已有 `matchedBy`，前端候选列表可据此标注"条码精确命中"。
- 优先级：P1。

### F-3 扫码后"查看详情"跳转（断链，本模块最严重问题）

- 现状：单结果直接 `MedicineReminderDetailRoute(medicineId: item.id).push(context)`（`barcode_scanner.dart:119-126`）；候选 sheet 选择后同样跳转（`barcode_scanner.dart:197-205`）。
- 实际作用：**没有实际作用，跳转必然失败**。`item.id` 是公共药品库 `cnMedicineProduct` 的记录 id（`Lucent/.../cn.service.ts:118`），而 `MedicineReminderDetailPage` 用它在**用户药箱记录**里按 `CurrentMedicineItem.id` 查找（`medicine/presentation/providers/reminders.dart:140-145`：`snapshot.currentMedicines.where((item) => item.id == currentMedicineId)`，找不到就 `throw StateError('Medicine not found.')`）。药箱记录 id 是 `POST /user/health-context/current-medicines` 建档时服务端生成的（`health_context/data/datasources/snapshot.dart:96-105`），与药品库产品 id 是两个 id 空间（实体上分别是 `id` 和 `sourceRefId`，`health_context/domain/entities/snapshot.dart:77-92`）。即使用户已把该药加入药箱，id 也对不上。用户扫码后看到的必然是"药品不存在"错误页（`medicine/presentation/pages/reminder/detail.dart:83-98`）。
- 实现真实性：假实现。属于审计清单第 6 条的变体：按钮存在、跳转发生（"请求成功"），但业务成果（看到药品信息）永远不发生。widget 测试用桩路由断言了"跳转到 detail-page"（`test/scan/barcode_scanner_page_test.dart:178-190`），测的是路由 push 本身，恰好掩盖了断链。
- 结论：改造。
- 改造方案：扫码命中的不是"提醒详情"，而是"一个还没进药箱的药品"。正确出口是复用 F-9 已验证的闭环：识别结果页提供主按钮"加入药箱"（调 `createCurrentMedicine(source: cn, sourceRefId: item.id, displayName)`，走同一风险预检弹窗），成功 Toast 带"去设置提醒"动作；次按钮"查看说明书"（见模块级缺口的药品详情页）。已加入药箱的（按 `source:sourceRefId` 判重，搜索页已有此逻辑 `search/presentation/pages/page.dart:35-41`）才允许跳提醒详情，且要用药箱记录 id 而非产品 id。
- 优先级：P0。

### F-4 药盒 OCR 识别（PaddleOCR 端侧）

- 现状：`showMedicineBoxScanSheet` 选"本地 OCR 识别"→ 预检引擎 → 拍照 → `PaddleOcrEngine.recognize`（`scan/domain/services/paddle_ocr_provider.dart:48-65`，包装 `paddle_ocr_native` 插件）→ `MedicineOcrExtractor.extractCandidates` 双策略提取（批准文号正则含 OCR 混淆字修正，药名按面积 0.5/位置 0.3/OCR 置信度 0.2 布局评分，带停用词表，`scan/domain/services/medicine_ocr_extractor.dart:41-65、89-113`）→ 每个候选调一次 `repo.search`（`scan/presentation/pages/box_scan.dart:257-279`）。
- 实际作用：不联网、不上传图片，从药盒照片提取检索词并搜库。算法是真实的启发式，不是摆设；`Runtime_Snapshot.md:130` 记载了从 ML Kit 迁到 PaddleOCR 的工程史，提取器有独立单测（`test/scan/medicine_ocr_extractor_test.dart`）。
- 实现真实性：真实现。候选为空时返回空列表，弹窗显示"未识别到药品"，无编造内容。
- 结论：改造。
- 改造方案：引擎和提取器保留，改两点：① 出口同 F-3（加入药箱而非跳断链详情页）；② 候选循环串行发 5×20 条搜索（`box_scan.dart:265-277`）既慢又产生大量重复候选，应先在本地对候选去重/合并，或后端支持批量 query。
- 优先级：P1（端侧识别是弱网/隐私场景的差异化能力，值得留）。

### F-5 药盒 AI 识别（压缩上传 + 后端 LLM 视觉）

- 现状：`box_scan.dart:281-305`：`ImageCompressor.compressForAiRecognition`（最长边 1920、JPEG 90%，`core/utils/image_compressor.dart:38-50`）→ `repo.uploadImage` 走 `/api/v1/user/files/upload` 预签名 + PUT 直传 COS（`scan/data/repositories/scan.dart:43-82`；后端 `Lucent/src/modules/files/services/files.service.ts:21-57` 真实签发，挂 `user` 路由前缀，`Lucent/src/app.module.ts:118-137`）→ `repo.recognizeMedicine` POST `/api/v1/medicines/recognize`（`scan/data/repositories/scan.dart:85-99`；后端 `MedicinesService.recognizeMedicine` 用 LLM 视觉模型读图返回 JSON，`Lucent/src/modules/medicines/services/medicines.service.ts:44-90`，prompt 在 `Lucent/src/i18n/zh-CN/medicine.json:4`）→ 优先按批准文号搜库。
- 实际作用：OCR 引擎不支持（非 arm64）或识别失败时的云端兜底，且能输出结构化字段（名称/批准文号/规格/厂商）。
- 实现真实性：真实现，链路每一环都真实：压缩失败回退原图（`image_compressor.dart:73-77`）、LLM JSON 解析失败返回全 null 而非编造（`medicines.service.ts:82-89`）、前端 name/批准文号都空时返回空结果（`box_scan.dart:292`）。两个小问题：① 该端点要求登录而扫码搜索是 `@Public()`，未登录用户走 AI 路径会在上传处 401，落进通用"识别失败"对话框而不是登录引导（`box_scan.dart:111-119`）；② 后端另有 `recognize/async` + `recognize/status/:jobId` 队列端点（`Lucent/.../medicines.controller.ts:215-272`），客户端从未调用，是无消费方的闲置表面。
- 结论：改造。
- 改造方案：链路保留；进 AI 路径前加登录门控（复用 `pushAuthRequiredRoute`，未登录走登录引导而非落入通用"识别失败"对话框）；后端 async 端点（`recognize/async` + `recognize/status/:jobId`）保留为未来能力——大图识别确实更适合异步+轮询，客户端接入排期或标注延后，不删除，不留双轨。
- 优先级：P1。

### F-6 识别结果确认弹窗

- 现状：`MedicineRecognizeDialog`（`scan/presentation/widgets/dialogs/recognize_dialog.dart:11`）：照片缩略图、top 结果卡片（药名/批准文号/置信度）、可展开候选列表、重拍/关闭/"确认，查看详情"。
- 实际作用：识别流程的确认环节。UI 完整，但包含两处失真：
- 实现真实性：部分实现。
  - **假置信度**（审计清单第 1 条）：AI 路径把 `confidence: 0.9` 硬编码（`box_scan.dart:301`），弹窗向用户展示"置信度: 90%"并配解释文案"置信度表示识别结果与数据库匹配的相关程度"（`lib/l10n/src/medicine_zh.arb:558-566`）。这不是任何模型或匹配过程的输出，是编造数字。OCR 路径的"置信度"实为布局启发式评分（`medicine_ocr_extractor.dart:109`，上限压到 0.95），也不是统计意义的置信度。
  - **断链按钮**（同 F-3）：`recognize_dialog.dart:256-271` 把搜索结果 id 当 `currentMedicineId` 推给提醒详情路由，必然 not found。
  - 次要：top 结果取 `widget.results.first`（`recognize_dialog.dart:36-37`）而非按置信度排序后的首位，与候选列表排序口径不一致。
- 结论：改造。
- 改造方案：删除硬编码"置信度 90%"（`box_scan.dart:301`），置信度字段改造为后端识别服务的真实分数（识别接口若返回）；不返回则改为可解释的来源标签（本地 OCR / 云端 AI / 条码），符合"证据可追溯、不笼统"；"确认"主按钮改为"加入药箱"（复用 F-9 链路），top 结果改为排序后首位。
- 优先级：P0。

### F-7 OCR 不可用回退

- 现状：选 OCR 后先 `ensureInitialized()` 预检，失败弹"此设备架构不支持 OCR 离线识别引擎，请使用 AI 识别"对话框，可一键转 AI（`box_scan.dart:62-74、123-165`）。
- 实际作用：把 ABI 不兼容（Android 限定 arm64-v8a）从"拍照后才失败"提前为"进相机前告知"，并给了出路。
- 实现真实性：真实现。预检失败会重置引擎标志允许重试（`paddle_ocr_provider.dart:37-41`）。
- 结论：保留。
- 改造方案（小问题）：转 AI 按钮直接重开识别方式选择 sheet（`box_scan.dart:153-159`），多一步操作；可直接携带 `method=ai` 进拍照。
- 优先级：P2。

### F-8 关键词搜索（双源）

- 现状：`SearchPage` + `MedicineSearchNotifier`（`search/presentation/providers/medicine_search.dart:28-105`）：400ms 防抖、5s 超时、错误时保留旧结果仅首次整页 shimmer（`search/presentation/widgets/views/view.dart:177-183`）、cn/drugbank Tab 切换（`sections/source_switch.dart`）。后端 `MedicinesController.search/getDetail` 公开接口 + 缓存（`Lucent/.../medicines.controller.ts:107-158`），cn 查 `CnMedicineProduct`（名称/品牌名/批准文号/条码/本位码/searchText，`adapters/cn.service.ts:97-112`），drugbank 查 `DrugbankDrug`（名称/CAS/UNII/searchText/同义词，`adapters/drugbank.service.ts:113-126`），`matchedBy` 真实标注命中字段。
- 实际作用：产品"用药安全可信入口"的最短路径——查药、看摘要（适应症）、加入药箱。中文库是结构化本地数据，不是爬来的网页结果。
- 实现真实性：真实现。空结果显示 `NoResultTools`（F-13），无编造兜底内容；搜索失败展示真实错误消息（`medicine_search.dart:94-103`）。小瑕疵：mapper 把 `unknownDefaultOpenApi` 静默映射为 drugbank（`search/data/mappers/medicine_search.dart:23-24`）——契约外的未知 source 被当成确定性结论，属审计清单第 2 条的轻微形态；接口要求 `page/pageSize` 必填但 UI 无分页加载，永远只看前 20 条。
- 结论：保留。
- 改造方案（小问题）：未知 source 显式抛错或记日志；结果数达 pageSize 时提供"加载更多"。
- 优先级：P0（模块的立足之本）。

### F-9 加入药箱（含风险预检）

- 现状：搜索结果卡"加入药箱"（`search/presentation/widgets/shared/results.dart:106-109`）→ 未登录弹登录引导（`search/presentation/pages/page.dart:68-80`）→ 拉最近一次风险检查记录，有 findings/coverageIssues 时弹"添加前风险检查"确认框（`page.dart:96-110`，弹窗 `widgets/shared/medicine_add_precheck_dialog.dart`）→ `createCurrentMedicine`（`page.dart:112`）→ 发 DataChangeBus → Toast 带"去设置提醒"动作直达 `/medicine/reminders/new?medicineId=<药箱记录id>`（`page.dart:117-131`）。已加入的按 `source:sourceRefId` 判重显示"已加入"禁用态（`page.dart:35-41`）。
- 实际作用：这是整个模块唯一真正闭环的链路：搜索→建档→设提醒，且带动了风险检查曝光。正是 F-3/F-6 应该复用的模式。
- 实现真实性：真实现。有一处话术失真：弹窗标题"添加前风险检查"（`medicine_zh.arb:466`），但内容来自**添加之前**对现有药箱跑的最新一次检查（`page.dart:96-99`），新加的药不在检查范围内——用户看到"发现风险提示"会以为与当前要加的药有关。数据是真的，范围声明是假的（审计清单第 5 条的轻度形态）。
- 结论：保留。
- 改造方案：预检不应消费历史检查记录，而应就"现有药箱 + 待加药品"即时跑一次静态检查（后端 `POST /medicines/risk-check` 已存在）再展示；至少把弹窗标题/描述改成"当前药箱已知的检查提示"并明确新药品未纳入本次检查（unknown 不冒充已检查）。
- 优先级：P0。

### F-10 搜索页扫码/拍照快捷入口

- 现状：空查询时渲染 QuickActions，仅 Android/iOS 包含扫码、拍照两项（`search/presentation/widgets/views/view.dart:21-34`）；点击分别进 `/scan/barcode` 与 `showMedicineBoxScanSheet`（`sections/quick_actions.dart:51-59`）。
- 实际作用：识别功能的唯一产品入口（medicine Tab 的快捷操作里没有扫码项，`medicine/presentation/widgets/sections/mobile_quick_operations.dart:14-44`）。
- 实现真实性：真实现，无死按钮（keyword/switchSource 分支的 Toast 兜底 `quick_actions.dart:57-58` 对应不出现在列表里的枚举值，不可达）。
- 结论：保留。
- 改造方案（小问题）：入口层级太深（Medicine Tab → 搜索 → 快捷操作）。扫码/拍照应上浮到 Medicine 页快捷操作区，与"搜索药品"并列——对"手里有药盒"的用户这是主路径。
- 优先级：P1。

### F-11 桌面端预览面板

- 现状：桌面布局右侧 `PreviewPanel`（`search/presentation/widgets/shared/results.dart:167-293`），选中结果后 `fetchDetail` 拉详情（`search/data/repositories/lucent.dart:40-62`）。
- 实际作用：几乎没有。`fetchDetail` 把详情 DTO 映射成 `MedicineSearchSafetyPreview`：`conditions` 是 `subtitle.split('\n')`——而 subtitle 是后端用 `' / '` 单行的"规格 / 厂商"（`Lucent/.../utils/data-format.ts:58-63`），拆出来的一条"规格 / 厂商"被展示在"临床提示"标题下（`results.dart:199-234`）；`checklist: const []`（`lucent.dart:54`）使"安全确认"区块从不渲染；异常被吞掉返回 null（`lucent.dart:56-61`），失败与"无数据"不可区分。
- 实现真实性：假实现（审计清单第 1、5 条）：把包装信息伪装成临床提示，安全清单字段恒空。虽然桌面端冻结，但造假模式本身要记录，避免被复制到移动端。
- 结论：改造/归档。内容不再伪装临床提示，作为桌面"大屏阅读"资产保留待调研，数据源真实化；`MedicineSearchSafetyPreview`/`fetchDetail` 代码与注释保留，标注不接入主路径。
- 改造方案：去掉把"规格 / 厂商"当"临床提示"的映射（`results.dart:199-234`）与恒空安全清单的"已检查"暗示，数据源接后端 `getDetail` 真实字段。移动端真正需要的是药品详情页（见模块级缺口），届时详情数据直接展示说明书原文（后端 `getDetail` 已返回完整字段：适应症/用法用量/禁忌/不良反应/相互作用等，`Lucent/.../adapters/cn.service.ts:64-86`、`drugbank.service.ts:66-90`），不需要"预览"这种二手摘要；桌面形态与数据源真实化随桌面/Web 独立调研后决定，不追求功能对等。
- 优先级：P2。

### F-12 最近搜索 / 分类快捷

- 现状：空查询时渲染 `RecentSearches(keywords: const <String>[])` 和 `Categories(categories: const <...>[])`（`views/view.dart:203-214、361-369`）。
- 实际作用：零。两个 section 对空列表直接 `SizedBox.shrink`（`sections/recent_searches.dart:22-24`、`categories.dart:20-22`），即永远不可见；没有任何持久化搜索历史的代码（`recentKeywords` 全库仅出现在定义与这两处空调用）；分类点击处理（`views/view.dart:212-213`）同样不可达。`MedicineSearchDashboard` 实体（`search/domain/entities/entities.dart:24-41`）已无人使用，是旧 dashboard 设计的遗骸。
- 实现真实性：假实现的残留形态——功能脚手架（含"清除"按钮文案、五种分类枚举与图标映射）齐全，但数据源从未接线，生产路径上表现为"恰好永远为空"。
- 结论：改造。最近搜索接本地搜索历史（真实记录持久化后渲染）；分类快捷接后端分类数据，或标注延后不排期；脚手架代码与实体保留，标注不接入主路径。
- 改造方案：本地持久化真实搜索关键词（`recentKeywords` 补写入与读取），空查询时渲染最近搜索；分类快捷接后端分类数据源（后端药品库可聚合分类字段），接不通则标注延后、保持隐藏；`MedicineSearchDashboard`/`MedicineSearchCategory` 实体与相关 l10n 键保留并注释"不接入主路径"，避免后续误用。
- 优先级：P2。

### F-13 无结果工具

- 现状：搜索无结果时给"清空关键词"和"切换数据源"两个动作（`results.dart:295-351`）。
- 实际作用：真实的恢复路径，尤其 cn 库查不到进口/成分名时提示切 DrugBank，符合双源设计。
- 实现真实性：真实现。
- 结论：保留。
- 改造方案（小问题）：无。
- 优先级：P2。

## 模块级结论

**对产品目标的贡献**：关键词搜索→加入药箱→设提醒（F-8/F-9）是用药领域唯一走通的可信链路，数据来自结构化中文药品库与 DrugBank，证据可追溯。它是健康伙伴在用户需要用药时的高价值能力，但与餐食拍照、饮水、睡眠等输入平级，不定义整个产品。三种识别方式（条码/端侧 OCR/云端 AI）的**识别层全部真实且在同类产品中属于高投入能力**，没有 mock、没有 kDebugMode 门控、测试覆盖在全部模块中算好的。

**核心问题**：识别链路在最后一公里整体断裂。三种识别方式的出口都是把药品库产品 id 当药箱记录 id 跳"提醒详情"，**必然落在"药品不存在"错误页**（`reminders.dart:140-145`）——用户扫完码、拍完照，既不能建档也不能加入用药，识别完就结束。配合 AI 路径硬编码的"置信度 90%"，识别模块目前是"演示级"状态：能力是真的，交付是假的。修复不需要新能力，只需把出口接到 F-9 已验证的建档闭环上，这是 P0。

**冗余**：桌面预览面板（F-11）内容造假应改造（不再伪装临床提示，作为桌面"大屏阅读"资产保留待调研，数据源真实化）；最近搜索/分类（F-12）应改造为接真实数据源（最近搜索接本地搜索历史、分类快捷接后端分类数据或标注延后）；后端 `recognize/async` 队列端点无消费方，保留为未来能力（大图识别异步化）或标注延后，不删除。

**缺口**：
1. **移动端没有药品详情页**。搜索结果卡在移动端不可点（`results.dart:117-120` 注释明言"点卡片无可见结果"），唯一动作是"加入药箱"。用户无法在读说明书（适应症/禁忌/相互作用，后端详情接口字段齐全）之后再决定加入——对"可信入口"这是关键缺失，也是 F-3/F-6 改造后"查看说明书"次按钮的落点。
2. 识别入口埋得太深（只在搜索页空状态），应上浮到 Medicine 页快捷操作区。
3. 加入药箱的风险预检消费的是历史检查记录，新药品不在检查范围内，应改为包含待加药品的即时检查或如实标注范围。
