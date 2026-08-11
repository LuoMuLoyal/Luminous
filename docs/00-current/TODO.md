---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-07
---

# Luminous TODO

Last updated: 2026-08-07

本文件记录仍缺失或被故意门控的工作。当前事实见 [[00-current/Current_State]]；实现顺序见 [[00-current/Next_Plan]]。

## 大型产品闭环重构（已决策，可启动）

总计划见 [`../../plans/2026-08-07-product-loop-program.md`](../../plans/2026-08-07-product-loop-program.md)，决策依据见 [[02-reference/adr/0011-event-led-sparse-record-product-loop]]。

### 健康事件与关键确认

- 服药 UI 统一按计划槽位展示 `待确认 / 用户自报已服 / 跳过 / 超时未确认`，不得把未确认显示为漏服或把同一药品一天多次服用合并为一次完成
- 饮水统一以 ml 展示和分析；缺失记录显示未知，覆盖不足时不生成个性化饮水不足结论
- 睡眠快速弹窗支持夜间睡眠与午睡的近似时长/质量；Apple Health / Health Connect 只作为已验证设备范围内的可选增强，不作为国内 Android 用户的核心数据前提
- 饮食、心情和普通笔记保留录入与回看，退出首阶段主动建议闭环；数据足够时也只能先作为观察项

### `Report` 转为 `Review/回顾`

- 保留一级 Tab 和现有路由/代码，用户可见名称改为“回顾”；以健康事件为主单位，时间范围为次级筛选
- 首屏重构为“发生了什么 / 关键变化 / 完成了什么 / 接下来怎么办”，事件结束时只要求一次“好转 / 差不多 / 加重”结果确认
- 移除跨维度综合健康评分；单维趋势仅在来源和覆盖率足够时进入折叠区
- 数据不足不能锁住整页：仍展示进行中事件、最近事件和历史记录，并明确哪些维度未知
- `给校医院 / 月度报告 / 打印预览 / 分享给医生` 移入右上角“更多”；现有实现保留，但不再作为默认主内容或核心成功指标
- 没有健康事件时展示最近事件回顾和可选轻量周回顾；禁止为填充页面强行生成泛化 AI 总结

### 平台与验证

- 桌面端和完整认证 Web 应用冻结：保留代码，不继续功能对等、发行或产品化；手机端是唯一核心产品，`Luminous-website` 继续承担官网和竞赛展示
- 增加最小、隐私克制的闭环测量：记录成功、建议卡曝光与处理、事件开始/结束、结果确认、回顾打开，以及“更多”中导出/分享动作；快捷入口点击不能代替保存成功

### 当前已知但尚未实现/修复的运行时缺口

- Today/Report 对饮水分别按记录条数与容量计算；客户端 domain mapper 和展示必须收敛到后端标准 ml + coverage 合同
- 服药分析仍可能按 medicine/day 合并；客户端必须按 reminder slot 展示并保持 taken、skipped、unconfirmed 可区分
- Report 当前 readiness 会因任一指标不足锁住完整内容；Review 必须允许单一维度成立，其他维度明确 unknown
- Report 当前仍保留 score summary、通用 7/30 天切换、默认导出区和 AI 泛化摘要；迁移时分别删除、降级或移入“更多”
- Clinic Summary 当前没有字段级隐藏 UI，医生分享分支的安全提升边界与普通 PDF 不一致；迁移“更多”时统一预览、隐私选择和安全确认
- 当前没有可靠的 Report 打开、分享链接访问或事件结果测量；不能用导出请求成功推断医生查看或用户获益

## 延后（有明确原因）

- AI 会话重命名与删除
  - 当前客户端只支持新建、加载和切换会话；等待后端提供会话标题更新与删除 API 后再实现

- AI 消息 Markdown 模板升级
  - 当前只使用基础 `MarkdownBody` 样式；后续统一设计标题、列表、代码块、引用、表格和链接的视觉模板

- AI 消息操作按钮完善
  - 复制、重新生成、重新发送需要从上下文菜单占位行为调整为明确可用的消息操作，并补齐对应 controller 链路

- forui 0.25.0 toast dismiss 的 dispose-during-notifyListeners 风险
  - 现象：`FToasterEntry.dismiss()` 在 toast 入场动画完成前触发时，forui 非无障碍分支直接 `reverse()`，
    同步走到 dismissed 状态后在通知期间 `dispose()`（无障碍分支用 microtask 规避了同样问题）
  - 影响：连续 `Toast.show` 时旧 toast 可能在入场完成前被 dismiss，调试构建可能触发断言
  - 现状：toast 测试通过先完成入场动画规避；生产未复现，暂不处理，后续升级 forui 时留意
- `formz` 表单校验
  - 已尝试，发现该校验并不合适后回退
- `intl.DateFormat` 替代 ISO 字符串
  - `padLeft` 是线协议格式，DateFormat 不适用

## 审查暂缓项

- 超大文件拆分暂缓（Phase Guide 明确"现在不要做"）：`record/detail.dart`（853 行）、`quick_entry_panel.dart`（565 行）、`record/edit.dart`（511 行）、`report/page.dart`（470 行）、`settings/page.dart`（184 行）
- 剩余约 15 处 `!` 强制解引用：均为安全模式（有前置 null check），留待逐步清理

## 实验性功能（稳定版后启动）

- GenUI（Generative UI）渲染引擎
  - 现状：`proposedActions` 已是 GenUI 雏形（4 种固定类型 + 1 个固定卡片 `AssistantProposalCard`）
  - 目标：扩展为开放式 UI 组件 JSON schema，LLM 返回结构化组件树，客户端 `GenUIRenderer` 递归渲染原生 Widget
  - 路径：Phase 2 在 `proposedActions` 里新增 `type: "gen_ui"`，渐进式替代固定卡片
  - 前置条件：稳定版发布后启动，Feature Flags `genUiEnabled` 已就绪
  - 不需要 Firebase，纯客户端渲染 + Lucent 后端 LLM
  - 预估工作量：15-23 个工作日

## Not in P0-P3 Scope

- Women-health / period management
- Sports recovery
- Specialist health packs
- Smart devices
- Family profiles
- Skin recognition
- Desktop-first workflows

## P2/P3 Gated But Not Blocking Right Now

- 当前边界之外的额外已审核药品规则扩展
- 跨来源药品归一化与未审核相互作用扩展
- 固定 red-flag 规则、审核过的 offline-care 升级文案、help-resource 完整性
- Agent-assisted support discovery 或 map-backed nearby-care lookup
- 当前边界之外更深的药品安全规则覆盖与更清晰的 unsupported / low-confidence wording
- Worker-written reminder delivery history（本地/push/SMS 渠道）
- Environment-driven Today 或 Mine 建议
- 真实药品条码/OCR/拍照/处方识别流程
