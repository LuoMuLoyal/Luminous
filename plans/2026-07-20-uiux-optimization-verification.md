# UIUX 优化计划核查报告与剩余工作

> 创建日期：2026-07-20
> 性质：对 `2026-07-18-uiux-per-page-optimization.md` 执行结果的逐条核查（53 个提交，截至 964c1826）
> 核查方式：7 路并行逐条比对当前工作区代码（非提交信息），l10n 键双语抽查，外加 `flutter analyze` / `flutter test`
> 结论：**P0 已全部闭环**。**P1 跨页面共性 + 今日模块已完成**。剩余约 20 项未做与 15 项部分完成，属 P1/P2 范畴。

---

## 一、总体验收状态

| 检查项 | 结果 |
|--------|------|
| `flutter analyze` | ✅ 零问题 |
| `flutter test` | ✅ **2756 通过 / 0 失败** |
| 计划"高"级别条目 | 绝大多数 ✅，P0 修复引入的新 bug 已全部闭环 |
| 计划"中"级别条目 | 大部分 ✅，记录模块与报告模块有实质缺口 |
| 计划"低"级别条目 | 约半数完成 |
| 第五节"不得回退"清单 | ✅ 基本守住（状态架构、骨架基建、预检对话框、AuthShell 等均未回退） |

已验证落地较好的部分（无需再动）：跨页面 C1-C7（死代码清理、五 tab 骨架重排、硬编码文案、危险确认链、触控语义、间距 token 化、错误文案 mapper）；mine 模块 24/26 项；助手/通知高级别 9 项；settings 18/25 项。

---

## 二、计划内未做 / 部分完成清单

> 仅列未闭环项；已 ✅ 的约 100 项不再复述。级别沿用原计划。

### 4.1 记录（record）

- ⚠️（低）移动端筛选空态无内联"清除筛选"（仅桌面有）；OCR 空结果牵强文案已删但无替代反馈。
- ❌（低）移动端"回到今天"入口；`date_bar` fontSize 11/14 硬编码；两端 locked 筛选策略不一致；图片附件无拍照入口；创建页字段无分区/标题过泛/切类型静默保留；脏状态返回无确认（全模块无 `PopScope`）；详情页编辑入口头尾重复、标签固定宽 88；菜品删除按钮无 tooltip/语义；NLP 候选睡眠仍分钟输入。

### 4.4 用药 / 搜索 / 扫码

- ⚠️（低）搜索超时文案中文硬编码仍在 `medicine_search.dart:78`（当前不上屏）。
- ❌（低）跳过按钮仍主色仅填充区分；“查看”按钮与告警行 chevron 目标重复；图标 size 16/18/20 魔数多处；coverage 图标仍 secondary 色；指标 chip 不可联动；红旗 action 假链接样式；日志无“查看全部”；短信不可用行未降权；提示音下拉固定宽 140；频率切换静默清空星期；桌面预览空态一行小字；置信度无解释；线框 280×120 硬编码；结果头图无占位。

### 4.5 报告（report）

- ⚠️（中）clinicShare 全程无进行中态；非进行中卡片禁用态仍显示 chevron（`export.dart:108-119`）。
- ⚠️（中）移动端“弹窗套弹窗”未改（`range_picker_dialog.dart:15,60`）。
- ⚠️（低）`emptyInsufficientBuilder` 死代码仍在（`page.dart:291-314`）；分数字号 token 外覆盖；装饰图标无 `ExcludeSemantics`；就绪卡“生成总结”入口无 loading；suggestion_history 仍传 `onSuggestionTap: null`（原计划注明可不阻塞）。

### 4.6 我的（mine）——完成度最高

- ❌（低）角色文案仍固定"大学生"（`data/repositories/lucent.dart:50`、`domain/entities/dashboard.dart:26`）。
- 备注：桌面骨架 SyncBanner 位置注释与实现不符；`medicineSourceLabel`、`archiveRecordListTitle` 成无引用残留。

### 4.7 设置（settings）

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

### P1 —— 一个迭代内（中级别实质缺口）

全部已闭环。

### P2 —— 打磨批（低级别合一次提交）

- 4.x 节全部 ❌/⚠️ 低级别项 + provider 层硬编码错误文案 + 无引用残留清理。

---

## 六、验收方式（沿用原计划）

- 每批完成后 `flutter analyze` + `flutter test` 全绿；改动页面过 zh/en 双语与 1.2 倍文字缩放。
- 完成条目按 plans 规范整节删除；本文件与原计划文件在全部闭环后一并删除。
