# Mock or Deferred

## 助手

- 助手 Phase 1 移动表面已作为独立 `/assistant` 工作区存在。
- 可从 Today 顶部栏和 Settings 进入。
- 已登录用户可：
  - 查看真实后端 capabilities
  - 选择是否启用助手
  - 选择是否跨新对话启用持久记忆
  - 选择健康档案 / 近期记录 / 睡眠数据 / 当前用药是否作为助手上下文
  - 恢复最新持久化对话
  - 打开近期对话列表
  - 切换到某个持久化对话
  - 从右上角 add 开始新对话
  - 发送真实 SSE 流式助手请求，Markdown 渲染
- Lucent 后端工具清单已超越最初的 4 工具基础，包括：
  - 今天/日期/范围记录读取
  - 精确日期 Today summary 查找
  - 精确范围 Report summary 查找
  - 近期 Today/Report 历史 AI 摘要
  - 用户资料/设置
  - 当前用药
  - 按范围睡眠读取
  - 结构化中文产品搜索/详情
  - 确定性 CN -> DrugBank 候选匹配
  - 结构化 DrugBank 详情读取
- 但仍是受控的服务器端预生成工具层，而非自由形式函数调用。

## 导出生命周期

- 导出生命周期 polish 仍刻意轻量：
  - 无页内请求历史列表
  - 无显式重试队列
  - clinic share link 无应用内链接管理，只能重新生成

## 延后但保留的代码

- Worker 填充的提醒投递历史；UI 可读 audit 行，但本地/push/SMS worker 尚未写入。
- 轻量心情记录连线。
- Today 或 Mine 的环境上下文连线。
- 用药侧扫描/OCR/拍照/条码/处方识别。
  - 底层 `MedicineWorkspace.quickActions` 与相关枚举/实体保留，但不在 UI 中暴露。
- Mock repositories（`mock_*_repository.dart`）保留用于开发与测试预览。
- Release 构建通过 `kDebugMode` 门控使用 domain `signedOut()` 工厂。
- `MockMedicineSearchRepository` 仅用于测试。

## 2026-06-30 更新

- 从 `app_en.arb` / `app_zh.arb` 中移除 11 个含 `[DEMO]` 硬编码药名的 `medicineMock*` ARB key。
- 替换为 3 个通用回退 key：`medicineGenericName` / `medicineGenericDosage` / `medicineGenericSchedule`。
- 对应更新 `MedicineCopyKey` 枚举值。
- mock repository `MedicinePlanItem` 数据切换为 `rawName` / `rawDosage` / `rawSchedule` 模式。
- `MemorySessionStore` 与 `StaticTodayRepository` 支持可配置 `delay` 参数（默认 `Duration.zero`），用于模拟网络延迟测试加载态。
- 移除 `test/today/today_test_helpers.dart` 中重复的 `SignedInAuthSessionNotifier` /
  `SignedOutAuthSessionNotifier`。
- 所有测试文件现在从共享 `test/helpers/test_helpers.dart` 导入。

## 延后代码标记

仍有用的延后代码应使用以下注释标记：

```dart
// Deferred by Product_Vision MVP: keep this code because the capability is useful,
// but do not surface it until the matching contract/product job is ready.
```
