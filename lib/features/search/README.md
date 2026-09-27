# lib/features/search — 药品搜索

一句话:药品库搜索(cn/drugbank 双源)+ "加入药箱"预检闭环;页面路由注册在 medicine 下,加箱闭环被 scan 复用。

## 职责与边界
- 管:关键词搜索(400ms debounce 自动搜 + 键盘提交立即搜、5s 超时)、来源切换、最近搜索持久化(SharedPreferences,cap 10)、桌面结果预览面板、`addMedicineToBoxWithPrecheck` 闭环。
- 不管:药品详情页与提醒创建(medicine)、扫码/拍照 UI(scan)、药箱数据本身(health_context)。

## 对外契约
- 路由:本 feature 无 routes.dart;`/medicine/search` 由 medicine/presentation/routes.dart 声明 `MedicineSearchRoute` → SearchPage,常量 `Routes.medicineSearch`。
- 导出:presentation/widgets/shared/add_to_box.dart(`addMedicineToBoxWithPrecheck`)。
- 被依赖:medicine/presentation/routes.dart(页面注册)、scan 的 recognize_dialog.dart 与 barcode_scanner.dart(复用加箱闭环)。

## 不变量
- 加箱闭环顺序固定:auth 门 → `runPrecheck`(失败降级提示、不阻断)→ 有 findings/coverageIssues 时确认弹窗 → `createCurrentMedicine` → emit `DataChangeTopic.currentMedicines` → 以 box id 跳 `MedicineRemindersNewRoute`。
- 搜索失败与详情预览失败都不外抛;最近搜索写入失败只记日志,不得使搜索失败(F-12)。
- 搜索请求带 generation 守卫:每次 `_doSearch` 递增 `_searchGeneration`,响应(含失败与 detail preview 后的二次 await)提交前必须复核 generation,过期响应整体丢弃,不得覆盖新查询的 results / selectedResultId / detailPreview,也不得写最近搜索。清空查询同样递增 generation 并就地清 `isSearching`(被丢弃的搜索会提前 return,不会自己复位该标志)。
- `MedicineSearchCategory` / `MedicineSearchSafetyPreview` 保留但未接主路径(F-12/F-11);移动端不得用 SafetyPreview 展示临床信息,真实内容走药品详情页。

## 依赖禁区
- repository 装配 provider 在 data/repositories/lucent.dart,状态 provider 在 presentation/providers/(无 data/providers 层);跨 feature 引用仅限 add_to_box 现有面(health_context repository + write_inputs、medicine risk_check + typed route),不得扩大。

## 陷阱与决策
- 输入 400ms debounce 自动搜(`_searchDebounceDuration`),不是提交式;键盘 search 键走独立的 `submitQuery`,会先取消挂起的 debounce 再立即发起,不和 `updateQuery` 共用回调。
- 搜索词在 await 前捕获(searchedQuery),飞行中继续打字不会错记最近搜索(F-12 P2-1)。
- RecentSearchesNotifier 写路径先 settle 初始 load,否则 load 完成会用旧值覆盖刚写入的值(F-12 P2-2)。
- TaskEither 边界见 ../../../docs/reference/adr/0005-result-type-and-error-handling.md。
