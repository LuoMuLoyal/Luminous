# Luminous TODO

Last updated: 2026-07-07

本文件记录仍缺失或被故意门控的工作。当前事实见 [[00-current/Current_State]]；实现顺序见 [[00-current/Next_Plan]]。

## 延后（有明确原因）

- Forui 0.23.0 `FToaster` 的 `_entranceDismissController` LateInitializationError
  - 已通过移除测试树中的 `FToaster`、`AppToast.show` 加 try-catch 降级规避
  - 升级至 Forui 0.24+ 后恢复 toast 测试
- `formz` 表单校验
  - 新增依赖，当前 AppToast 校验模式工作正常
- `intl.DateFormat` 替代 ISO 字符串
  - `padLeft` 是线协议格式，DateFormat 不适用

## 审查暂缓项（2026-07-07 三审）

以下项经三份审查报告确认后暂缓，有明确原因：

- 超大页面拆分：`login_page.dart`（620+ 行）、`medicine_reminder_edit_page.dart`（400+ 行）— Phase Guide 明确"现在不要做"
- Provider 一致性：`FutureProvider`（7 个）和 `AsyncNotifierProvider`（5 个）未统一 — 非 Phase 2 目标
- Release 模式错误上报：`debugPrint` 仅 debug 生效，release 下静默 — 需上线前评估持久化日志/上报策略
- 剩余约 15 处 `!` 强制解引用：均为安全模式（有前置 null check），留待逐步清理

一、后端已就绪，前端缺失（优先级最高）

二、合理的新增扩展（需后端配合或纯前端实现）

1. 📊 数据与存储
   离线数据保留期 — 30天/90天/永久（影响本地缓存清理策略）
   图片质量 — 标准/省流（影响药品图片等加载质量）
   同步设置 — 仅 Wi-Fi 同步 / 移动网络也同步
2. 🏥 健康档案快捷入口
   当前状态：健康档案（过敏、疾病、当前用药）编辑入口分散在 mine 功能区
   建议：在设置页隐私或通用分组下增加「健康档案」入口，直达 health_context 编辑页
3. 🌐 开发者选项（Advanced 扩展）
   API 端点切换 — 开发/生产环境切换（仅 debug 模式可见）
   日志级别 — verbose/info/warning/error
   功能开关（Feature Flags） — 实验性功能灰度控制

## Not MVP

- Women-health / period management
- Sports recovery
- Specialist health packs
- Smart devices
- Family profiles
- Skin recognition
- Desktop-first workflows

## MVP Gaps To Close

- 当前 frozen mobile MVP 承诺无剩余 blocker
- 移动 MVP 路径现定义为：`record -> summarize -> bounded medicine safety check -> export`
- 对未审核药品有明确不确定性；不声称 broad cross-source normalization 或 unreviewed interaction expansion
- 下列工作属于 post-MVP 产品化或加固，不阻塞 MVP 完成

## MVP Gated But Not Blocking Right Now

- 当前边界之外的额外已审核药品规则扩展
- 跨来源药品归一化与未审核相互作用扩展
- 固定 red-flag 规则、审核过的 offline-care 升级文案、help-resource 完整性
- Agent-assisted support discovery 或 map-backed nearby-care lookup
- 当前边界之外更深的药品安全规则覆盖与更清晰的 unsupported / low-confidence wording
- Report/export finish-pass 客户端清理：
  - 最终状态文案一致性
  - 过期链接处理
  - 一次真实环境验收运行
  - 除非发现真实 bug，否则不重新打开后端/export 范围
- Worker-written reminder delivery history（本地/push/SMS 渠道）
- Environment-driven Today 或 Mine 建议
- 真实药品条码/OCR/拍照/处方识别流程
- 超越竞赛/营销首页的真实认证 Web 报告预览
- 环境驱动的 Today/Mine 建议
- Agent 辅助就医发现
