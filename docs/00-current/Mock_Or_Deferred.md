---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-16
---

# Mock or Deferred

Last updated: 2026-08-16

## 扫码（barcode / box scan）测试与平台桥接

- `barcode_scanner_page_test` / `box_scan_test` 通过注入平台接口 fake 隔离真实设备能力：`PermissionHandlerPlatform.instance`（相机权限）、`MobileScannerPlatform.instance`（相机预览/条码流）、`ImagePickerPlatform.instance`（拍照），`paddleOcrProvider` 以 mocktail `MockPaddleOcrEngine` 覆盖，`PaddleOcrNativePlatform.instance` 注入 `FakePaddleOcrNativePlatform`。测试从不启动真实相机/相册/OCR 引擎。
- `box_scan.dart` 的 AI 识别分支（`File.readAsBytes` → `ImageCompressor` 压缩 → 上传）依赖真实 dart:io 文件 I/O，在 `testWidgets` 的 FakeAsync 测试区内无法完成（Flutter 测试基础设施限制），按测试计划排除项处理，仅覆盖方法选择、OCR 分支、AI 取消路径。
- `recognize_dialog_test`（F-6）：`MedicineRecognizeDialog` 为 Consumer 组件，harness 用 `ProviderScope` + `TestForuiRouterApp`，`/dialog` 定义为 `/` 的子路由（保证 pop-then-push 出口有落点）、路由内包 `FToaster`（共享加药闭环的成功 toast 可渲染）；默认不 override `healthContextSnapshotProvider`（未恢复的 auth 会话使快照保持 pending → 空药箱 map），已加入态与「加入药箱」用例分别 override 快照 / auth / healthContext 仓库 / 风险预检仓库。
- P2 收尾批次（2026-08-16）新增测试模式：扫码结果 sheet / 识别弹窗的「加入后实时翻已加入」用例把 `healthContextSnapshotProvider` override 为「watch DataChangeBus 版本 + 仓储重取」的镜像实现（生产 provider 同款语义，非真实网络）；「在途防重」用例用 `FakeHealthContextRepository.createGate`（Completer）挂起 `createCurrentMedicine` 断言按钮禁用态；`pumpPage`/`pumpDialog` 的 overrides 参数类型化为 `List<Override>`（`package:flutter_riverpod/misc.dart` 导出）。


## 助手骨架死段清理

- `loading_view.dart` 移除第三段骨架（3 个 height=56 的块），该段对应已删除的常驻开关面板。
- 助手加载骨架现在只保留两段：标题行 + 对话区。

## 助手用户消息可复制

- `message_bubble.dart` 的用户消息从 `Text` 改为 `SelectableText`，允许选择复制。

## Mock 状态

Mock repositories 已从生产代码中完全移除，仅存在于 `test/helpers/mocks/` 目录下（`MockTodayRepository`、`MockReportRepository`、`MockRecordRepository`、`MockMineRepository`、`MockMedicineWorkspaceRepository`），用于单元/Widget 测试。

未登录态使用 repository 实现类的 `signedOut()` 工厂方法返回静态预览数据，不再通过 `kDebugMode` 门控 mock。

## 助手

- 助手 Phase 1 移动表面已作为独立 `/assistant` 工作区存在。
- 可从 Today 顶部栏和 Settings 进入。
- 已登录用户可查看真实后端 capabilities、选择启用助手、选择持久记忆、选择健康档案/近期记录/睡眠/当前用药作为上下文、恢复持久化对话、发送真实 SSE 流式请求。
- Lucent 后端工具清单已超越 4 工具基础：今天/日期/范围记录读取、精确日期 Today summary 查找、精确范围 Report summary 查找、近期 Today/Report 历史 AI 摘要、用户资料/设置、当前用药、按范围睡眠读取、结构化中文产品搜索/详情、确定性 CN→DrugBank 候选匹配、结构化 DrugBank 详情读取。
- 但仍是受控的服务器端预生成工具层，而非自由形式函数调用。
- `lib/core/ai/` 已新增 app-side AI runtime 实验 seam，但默认关闭；不接入 shipping 流程。

## 网络层与生成客户端

- API 客户端已从旧的 `packages/lucent_openapi/`（`dart-dio` 生成器）迁移到 `generated/lucent_api/`（`openapi_retrofit_generator`）。
- 旧的 700+ 行后处理脚本已删除；新生成器原生处理 enum/nullable/API 导出。
- `tool/verify_lucent_openapi_sync.dart` 验证 `generated/lucent_api/` 与 `Lucent/docs/openapi.json` 同步。
- OpenAPI 合同修复后，所有 `nullable: true` 的 DTO 字段已补充显式 `type`，`dynamic` 字段从 129 个降至 7 个。

## 导出生命周期

导出生命周期 polish 仍刻意轻量：

- 无页内请求历史列表
- 无显式重试队列
- clinic share link 无应用内链接管理，只能重新生成

## 延后但保留的代码

- 提醒投递历史已三通道落库：调度器每分钟写 `in_app` 行；本地通知展示后客户端按 `reminderId|date|time` 幂等回写 `local/delivered` 行；本地不可达/未确认时后端按 JPush 结果写 `push` 行（失败含 errorMessage）。SMS 通道仍无。
- 轻量心情记录连线。
- Today 或 Mine 的环境上下文连线。
- 处方 OCR 识别保留为未来能力、不排期；「手动添加药物」意图由快捷操作区「添加药品」入口 + 搜索/扫码「加入药箱」覆盖，不再显示处方导入占位入口（原占位 dead data 已删除）。

## 延后代码标记

仍有用的延后代码应使用以下注释标记：

```dart
// Deferred by Product Brainstorm P0/P1: keep this code because the capability is useful,
// but do not surface it until the matching contract/product job is ready.
```
