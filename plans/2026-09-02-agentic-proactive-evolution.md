# Agentic → Proactive → 伴身演进:Luminous 客户端任务清单

> 2026-09-02 起。定位:配合 Lucent 侧演进计划(`Lucent/plans/2026-09-02-agentic-proactive-evolution.md`),把 assistant 的 SSE 对话 + proposal 确认流从单页能力组件化,贯穿 today / review / medicine 主流程(Agentic 化),再承接 Proactive 推送与跨端会话一致。用户始终主驾,每个写动作过确认门。

## 现状锚点(代码事实)

- `lib/features/assistant/`:SSE 流式多轮对话 + `proposal_card` 门控写确认(shared/proposal_card 经 `flowui_adapter` 呈现),但 assistant 只能在一个页面里用。
- 扫药是端侧 PaddleOCR(ONNX 本地推理)+条码;搜索是关键词检索;review/today 的 AI 能力与 assistant 各自独立调后端。
- 提醒是 flutter_local_notifications 本地调度,纯规则。
- l10n 源在 `lib/l10n/src/` 片段文件,`app_*.arb` 是生成物——**严禁直改**。

## Phase 0 夯实期:接入后端语义能力

- [ ] **P0-1 语义搜索接入**
  - 搜索切到 Lucent 混合检索端点(关键词 + 向量),处理加载/空态/降级(后端不可用回退纯关键词);l10n 走 `medicine_zh/en.arb` 片段(现有 `medicineSearch*` 文案所在处)+ `dart scripts/l10n/arb_tools.dart merge` + `flutter gen-l10n`。
- [ ] **P0-2 扫药视觉增强**
  - OCR 仍在端侧(PaddleOCR + 条码);字段提取在线时以云端视觉模型为主路径**替代纯规则解析**,离线/云端失败降级回端侧规则解析;明确置信度展示与降级路径,扫码主流程不因云端失败而阻塞。
- [ ] **P0-3 AI 上下文统一(客户端侧)**
  - review / today 的 AI 数据源改为复用 assistant 的 data 层(`features/assistant/data`),消除重复请求模型与拼装逻辑。

## Phase 1 Agentic 化:assistant 贯穿主流程

- [ ] **P1-1 assistant 能力组件化**
  - 从 `features/assistant/presentation` 抽出可复用的会话控制器 + SSE 流 + proposal 卡片组件,使其他表面能嵌入"带上下文的 agent 会话",而不是复制聊天页。
- [ ] **P1-2 today 页:起草补录方案**
  - today 页新增入口 → 携带当日缺口上下文启动 assistant 会话 → 生成补录方案提案 → proposal 卡片内联确认。
- [ ] **P1-3 review 页:主动复盘 + 调整计划**
  - review 页新增"生成复盘/起草调整计划"入口,提案经同一门控确认后落库。
- [ ] **P1-4 medicine 页:对话式调整提醒**
  - reminders 调整(时间/剂量/暂停)提供对话式入口,写操作一律走 proposal 确认,不提供绕过门控的直达写。
- [ ] **P1-5 客户端合同与测试**
  - 后端每次 `export:openapi` 后执行 `dart run scripts/contract/bootstrap.dart` 重生成客户端;新增表面入口补 widget/集成测试;`flutter analyze` + `flutter test` 收尾。

## Phase 2 Proactive / Ambient:承接后台智能体

- [ ] **P2-1 Proactive 推送管道**
  - 承接后端 proactive 通知 payload:点开深链进入预置上下文的 assistant 会话(复用 P1-1 组件);与现有本地通知通道并存,优先级与去重由后端治理。
- [ ] **P2-2 Proactive 消息卡片**
  - 聊天窗外呈现主动提议(依从性建议、复查关怀、review 摘要推送)的统一卡片样式与确认/忽略交互;写动作仍走 proposal。
- [ ] **P2-3 通知偏好扩展**
  - mine/settings 增加 proactive 类型粒度开关(依从性/复查/复盘推送),对齐后端 notification-preferences 合同;l10n 走 mine 片段。

## Phase 3 伴身愿景:跨端一致(远期)

- [ ] 会话历史跨设备同步展示与续传,配合后端 SSE 恢复机制。
- [ ] 手机浏览器 Flutter Web(移动端形态之一,ADR-0008;PC Flutter Web 已停止扩展)接入 Next.js BFF/cookie 双写路径,agent 会话与记忆跨端一致;移动端 App 合同不动。
- [ ] UI 从"操作"向"委托与复核"演进的交互模式探索(设计稿先行,不预设落地时间)。

## 执行注意

- l10n 铁律:改 `lib/l10n/src/` 片段 → `dart scripts/l10n/arb_tools.dart merge` → `flutter gen-l10n`,不碰 `app_*.arb`。
- 桌面/PC Web 停止产品扩展(ADR-0008),本计划的跨端工作只面向移动端 + 未来 Next.js Web 客户端。
- 每次代码变更追加 `docs/logs/migration-log/YYYY-MM-DD.md`;完成项直接从清单删除。
- 迭代期窄命令,收尾跑 `flutter analyze`、`flutter test`、`dart run scripts/docs/verify.dart --warning-only`。
- 依赖关系:P1 依赖 P0 与 Lucent Phase 1 合同导出;P2 依赖 Lucent Phase 2 事件/推送就绪;Phase 3 与 BFF 启动同步。
