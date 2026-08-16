# 扫码识别与搜索改造计划

Created: 2026-08-16
> 来源: `Luminous/research/02-功能盘点/scan-search-扫码与搜索.md`(已审阅;内容以逐功能分析为准改写,速览表/结尾汇总仅作参考)。
> 执行顺序: 本批共 10 份改造计划,全局顺序见 [`README.md`](README.md);本计划为第 3 位。

## 一、目标与范围

范围:`Luminous/lib/features/scan/`、`Luminous/lib/features/search/`;后端对照 `Lucent/src/modules/medicines/`、`Lucent/src/modules/files/`。

核心问题:三种识别方式(条码/端侧 OCR/云端 AI)的识别层全部真实,但出口整体断链——都把药品库产品 id 当药箱记录 id 跳「提醒详情」,必然落「药品不存在」错误页。本计划的主线是把识别出口接到 F-9 已验证的建档闭环上,并修掉假置信度、预检话术失真等配套问题。识别层本身(相机、OCR 引擎、LLM 链路、双源搜索)不重做。

## 二、保留不动(清单)

- F-8 关键词搜索(cn/drugbank 双源 + 400ms 防抖 + 5s 超时,模块立足之本;遗留小瑕疵:未知 source 被静默映射为 drugbank、UI 无分页加载,作为后续打磨,不列入本期改造项)。
- F-13 无结果工具(「清空关键词/切换数据源」真实恢复路径,无需改动)。
- 后端 `recognize/async` + `recognize/status/:jobId` 队列端点:无消费方但保留为未来能力,不删除、不留双轨(接入与否见「六、不确定点」)。

## 三、改造项(按优先级分组)

### P0

#### F-3 扫码后「查看详情」跳转(断链修复,本模块最严重问题)

- 现状:单结果直接 `MedicineReminderDetailRoute(medicineId: item.id).push(context)`(`scan/presentation/pages/barcode_scanner.dart:119-126`),候选 sheet 选择后同样跳转(`barcode_scanner.dart:197-205`);跳转必然失败,用户必见「药品不存在」错误页。
- 断链机理(两个 id 空间):`item.id` 是公共药品库 `cnMedicineProduct` 的记录 id(`Lucent/src/modules/medicines/adapters/cn.service.ts:118`);而 `MedicineReminderDetailPage` 用它在**用户药箱记录**里按 `CurrentMedicineItem.id` 查找(`medicine/presentation/providers/reminders.dart:140-145`,找不到即 `throw StateError('Medicine not found.')`)。药箱记录 id 是 `POST /user/health-context/current-medicines` 建档时服务端生成的(`health_context/data/datasources/snapshot.dart:96-105`),实体上分别是 `id` 与 `sourceRefId`(`health_context/domain/entities/snapshot.dart:77-92`)——即使用户已把该药加入药箱,id 也对不上。现有 widget 测试用桩路由断言「跳转到 detail-page」(`test/scan/barcode_scanner_page_test.dart:178-190`),测的是路由 push 本身,恰好掩盖了断链,需一并改写。
- 改造方案:扫码命中的不是「提醒详情」,而是「一个还没进药箱的药品」。识别结果出口改为:
  - 主按钮「加入药箱」:调 `createCurrentMedicine(source: cn, sourceRefId: item.id, displayName)`,走 F-9 同一风险预检弹窗,成功 Toast 带「去设置提醒」动作;
  - 次按钮「查看说明书」:落点为移动端药品详情页,见 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) 的 F-14 一节,本文不展开;
  - 已加入药箱的(按 `source:sourceRefId` 判重,复用搜索页 `search/presentation/pages/page.dart:35-41` 的逻辑)才允许跳提醒详情,且必须传**药箱记录 id** 而非产品 id。
- 前后端分工:纯前端改动,后端无改动。
- 依赖:F-9 闭环(本计划内)、移动端药品详情页(medicine 计划 F-14)。

#### F-6 识别结果确认弹窗(假置信度 + 断链按钮)

- 现状:`MedicineRecognizeDialog`(`scan/presentation/widgets/dialogs/recognize_dialog.dart:11`)UI 完整,但 AI 路径硬编码 `confidence: 0.9`(`scan/presentation/pages/box_scan.dart:301`),向用户展示「置信度: 90%」并配解释文案(`lib/l10n/src/medicine_zh.arb:558-566`);「确认,查看详情」按钮同 F-3 断链(`recognize_dialog.dart:256-271`);top 结果取 `widget.results.first`(`recognize_dialog.dart:36-37`)而非排序后首位。
- 改造方案:
  - 删除硬编码「置信度 90%」;置信度字段改为后端识别接口返回的真实分数,接口不返回则改为可解释的来源标签(本地 OCR / 云端 AI / 条码),同步改 `medicine_zh.arb`/`medicine_en.arb` 文案(走 l10n fragment → `dart scripts/arb_tools.dart merge` → `flutter gen-l10n` 流程);
  - 「确认」主按钮改为「加入药箱」,复用 F-3 改造后的出口(含判重与「查看说明书」次按钮);
  - top 结果改为按排序口径取首位,与候选列表一致。
- 前后端分工:前端为主;后端仅需确认 `recognizeMedicine` 返回 JSON 是否含分数字段(见「六、不确定点」)。
- 依赖:同 F-3。

#### F-9 加入药箱闭环(本计划拥有并写全;预检即时化)

- 现状(已验证的闭环,F-3/F-4/F-6 的统一落点):搜索结果卡「加入药箱」(`search/presentation/widgets/shared/results.dart:106-109`)→ 未登录弹登录引导(`search/presentation/pages/page.dart:68-80`)→ 拉最近一次风险检查记录,有 findings/coverageIssues 时弹「添加前风险检查」确认框(`page.dart:96-110`,弹窗 `search/presentation/widgets/shared/medicine_add_precheck_dialog.dart`)→ `createCurrentMedicine`(`page.dart:112`)→ 发 DataChangeBus → Toast 带「去设置提醒」动作直达 `/medicine/reminders/new?medicineId=<药箱记录id>`(`page.dart:117-131`);已加入的按 `source:sourceRefId` 判重显示「已加入」禁用态(`page.dart:35-41`)。
- 失真点:弹窗标题「添加前风险检查」(`lib/l10n/src/medicine_zh.arb:466`),但内容来自添加**之前**对现有药箱跑的最新一次检查,新加的药不在检查范围内——数据是真的,范围声明是假的。
- 改造方案(以逐功能分析为准,话术修改只是保底):**首选**——预检不消费历史检查记录,改为就「现有药箱 + 待加药品」即时调后端 `POST /medicines/risk-check`(端点已存在)跑一次静态检查再展示;**保底**(即时检查入参形态不支持时)——弹窗标题/描述改为「当前药箱已知的检查提示」并明确新药品未纳入本次检查(unknown 不冒充已检查)。
- 前后端分工:前端改预检触发逻辑与弹窗文案;后端确认/扩展 `risk-check` 支持含未建档药品的入参形态。
- 依赖:后端 `POST /medicines/risk-check` 的入参能力(见「六、不确定点」)。

#### F-1 条码扫码页(页面保留,修出口与手电筒图标)

- 现状:`BarcodeScannerPage`(`scan/presentation/pages/barcode_scanner.dart:24`)交互质量上乘(权限恢复监听、`_hasScanned` 防抖、8 个测试用例),页面本身保留;问题在出口(F-3)与一个小 bug。
- 改造方案:出口随 F-3 改造;另修手电筒按钮开关两态用同一图标(`barcode_scanner.dart:271-275`,`_torchOn` 三态表达式两分支都是 `SemanticIcons.safetyAllergy`),换用区分开/关的图标(优先 `FLucideIcons`)。
- 前后端分工:纯前端。
- 依赖:F-3。

### P1

#### F-4 药盒 OCR 识别(出口修复 + 候选搜索优化)

- 现状:`PaddleOcrEngine.recognize` + `MedicineOcrExtractor.extractCandidates` 双策略提取(批准文号正则含混淆字修正、布局评分带停用词表),引擎与提取器真实且有单测,保留;问题是出口断链,且候选循环串行发 5×20 条搜索(`scan/presentation/pages/box_scan.dart:257-279`),慢且产生大量重复候选。
- 改造方案:① 出口改接 F-3 的「加入药箱」闭环;② 候选先在本地去重/合并再搜库,或由后端支持批量 query(二选一,见「六、不确定点」)。
- 前后端分工:前端改出口与候选合并;若选批量 query 方案则后端 `MedicinesController.search` 需支持批量入参。
- 依赖:F-3。

#### F-5 药盒 AI 识别(登录门控)

- 现状:压缩→COS 预签名直传→`POST /api/v1/medicines/recognize` LLM 视觉识别,链路每一环真实;但 `recognize` 端点要求登录而扫码搜索是 `@Public()`,未登录用户走 AI 路径会在上传处 401,落进通用「识别失败」对话框而非登录引导(`box_scan.dart:111-119`)。
- 改造方案:进 AI 路径前加登录门控,复用 `pushAuthRequiredRoute`(F-9 已有未登录引导模式可参照),未登录走登录引导;后端 `recognize/async` 队列端点保留,客户端接入排期或标注延后(见「六、不确定点」),不删除。
- 前后端分工:纯前端门控;后端无改动。
- 依赖:无。

#### F-2 扫码结果匹配(条码精确命中)

- 现状:`LucentScanRepository.search`(`scan/data/repositories/scan.dart:24-40`)把条码原始值当 query 搜库,后端 `CnMedicinesService.buildWhere` 确实查 `barcode` 字段(`Lucent/src/modules/medicines/adapters/cn.service.ts:107`),匹配语义正确;但 `contains` 模糊匹配可能带出子串相同的其他条码(如 69 码前缀截断)。
- 改造方案:对纯数字 query 优先等值匹配 barcode 字段;前端候选列表利用后端 DTO 已有的 `matchedBy` 标注「条码精确命中」。
- 前后端分工:等值匹配改在前端(判断 query 形态)还是后端(`buildWhere` 分支)未定,见「六、不确定点」。
- 依赖:无。

#### F-10 识别入口上浮

- 现状:扫码/拍照入口只在搜索页空状态的 QuickActions(`search/presentation/widgets/views/view.dart:21-34`),层级太深(Medicine Tab → 搜索 → 快捷操作);medicine Tab 快捷操作区无扫码项(`medicine/presentation/widgets/sections/mobile_quick_operations.dart:14-44`)。
- 改造方案:扫码/拍照入口上浮到 Medicine 页快捷操作区,与「搜索药品」并列;搜索页 QuickActions 保留。
- 前后端分工:纯前端。
- 依赖:无。

### P2

#### F-7 OCR 不可用回退(转 AI 直达)

- 现状:进相机前 `ensureInitialized()` 预检,失败弹「改用 AI 识别」对话框,机制真实;但转 AI 按钮直接重开识别方式选择 sheet(`box_scan.dart:153-159`),多一步操作。
- 改造方案:转 AI 直接携带 `method=ai` 进拍照,跳过重选。
- 前后端分工:纯前端。
- 依赖:无。

#### F-11 桌面端预览面板(去造假,保留待调研)

- 现状:桌面 `PreviewPanel`(`search/presentation/widgets/shared/results.dart:167-293`)把后端单行「规格 / 厂商」subtitle 按 `\n` split 后展示在「临床提示」标题下,`checklist: const []` 使「安全确认」区块从不渲染,异常被吞返回 null——包装信息伪装成临床提示。
- 改造方案(以逐功能正文为准:改造并保留待调研,**非归档**):去掉「规格 / 厂商」当「临床提示」的映射与恒空安全清单的暗示;`MedicineSearchSafetyPreview`/`fetchDetail` 代码与注释保留,标注「不接入主路径」,避免造假模式被复制到移动端;数据源真实化(接 `getDetail` 真实字段)与桌面形态随桌面/Web 独立调研后决定——桌面形态挂起项统一见 [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md)(ADR-0012 待决策),本文不展开。
- 前后端分工:前端去造假映射;后端 `getDetail` 字段已齐全,无需改动。
- 依赖:桌面/Web 形态决策(ADR-0012)。

#### F-12 最近搜索 / 分类快捷(接真实数据源)

- 现状:`RecentSearches(keywords: const [])` 与 `Categories(categories: const [])` 永远空列表、永远不可见(`views/view.dart:203-214、361-369`),无任何持久化搜索历史的代码;`MedicineSearchDashboard` 实体(`search/domain/entities/entities.dart:24-41`)是旧 dashboard 遗骸。
- 改造方案:最近搜索接本地持久化的真实搜索关键词(补 `recentKeywords` 写入与读取),空查询时渲染;分类快捷接后端分类数据源,**接不通则标注延后、保持隐藏**(保留此条件分支);`MedicineSearchDashboard`/`MedicineSearchCategory` 实体与相关 l10n 键保留并注释「不接入主路径」。
- 前后端分工:前端负责本地历史持久化;分类数据源需后端药品库支持聚合分类字段(未确认,见「六、不确定点」)。
- 依赖:后端分类字段能力(条件分支)。

## 四、跨计划引用与依赖

- **移动端药品详情页**(F-3/F-6「查看说明书」次按钮的落点,后端 `getDetail` 已返回适应症/用法用量/禁忌/不良反应/相互作用等完整字段):方案见 [`2026-08-16-medicine-remediation-plan.md`](2026-08-16-medicine-remediation-plan.md) 的 F-14 一节,本文不重复展开。
- **桌面/Web 形态挂起**(F-11 后续):统一见 [`2026-08-14-product-surface-route.md`](2026-08-14-product-surface-route.md)(ADR-0012 待决策)。
- **本计划拥有并写全**:F-9 建档闭环(`createCurrentMedicine(source, sourceRefId, displayName)` + 风险预检弹窗 + `source:sourceRefId` 判重 + Toast「去设置提醒」直达 `/medicine/reminders/new`)与 F-3/F-6 断链机理(`id` vs `sourceRefId` 两个 id 空间)——后续计划如需引用识别出口闭环,以本文为准。
- **后端依赖**(Lucent,本期只读确认、可能小改):`POST /medicines/risk-check` 入参形态、`recognizeMedicine` 返回字段、条码等值匹配与批量 query、分类聚合字段;如涉及 API 契约变更,走 `pnpm export:openapi` + `dart run scripts/bootstrap_generated_sources.dart` 流程。

## 五、本计划内执行顺序

1. F-9 预检即时化(含后端 `risk-check` 入参确认)——闭环本体先修,它是其余改造的地基。
2. F-3 断链修复(出口改接 F-9 闭环)→ F-1 出口与手电筒图标。
3. F-6 弹窗改造(置信度 + 按钮出口)。
4. F-4、F-5 识别路径出口与门控。
5. F-10 入口上浮、F-2 精确命中。
6. F-7、F-11、F-12 打磨项(F-11/F-12 含条件分支,可随时挂起)。

## 六、不确定点(待决策)

- **F-9 即时检查入参形态**:首选方案依赖后端 `POST /medicines/risk-check` 支持「现有药箱 + 待加药品」的入参;端点已存在但未确认是否支持未建档药品的即时检查,不支持则退保底话术方案。
- **F-6 置信度数据源**:`recognizeMedicine` 返回 JSON 是否含真实分数字段未经文档确认;无分数则改来源标签方案。
- **F-4 候选搜索优化二选一**:本地去重/合并 vs 后端批量 query,前后端分工未定。
- **F-2 纯数字等值匹配分工**:改在前端(判断 query 形态)还是后端(`buildWhere` 分支)未定。
- **F-5 async 端点**:客户端接入排期 or 标注延后,二选一未决(端点保留不删)。
- **F-11 桌面形态与数据源真实化**:随桌面/Web 独立调研后决定(ADR-0012),本期只做去造假。
- **F-12 分类快捷数据源**:「后端药品库可聚合分类字段」是推测性表述,现有字段是否支持未确认;接不通则标注延后、保持隐藏。
- 调研文档全篇无工作量(人日/故事点)数据,本计划不给出工作量估算,仅沿用 P0/P1/P2 优先级。
