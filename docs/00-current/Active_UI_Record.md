# Active UI — Record

## 支持的记录类型

- 症状
- 饮水（可选单位）
- 饮食/餐食
- 笔记（独立类型：有自己的快捷操作、筛选、时间线项）
- 睡眠（结构化录入：就寝/起床/质量/阶段）
- 用药（非创建型快捷操作）

## 自然语言录入

- 移动端底部弹层自然语言输入。
- 接入 Lucent candidate 解析。
- 确认后保存流程。

## 日期与时间

- 选中日期时间线 / 详情 / 创建 / 编辑。
- 顶部日期栏、筛选器。
- panel-backed 快速记录与时间线 section。
- 内部行使用 divider 而非嵌套卡片。

## 创建与快捷操作

- 活跃创建类型：water、meal、symptom、note、sleep。
- 这些类型的快捷操作先打开快速选择 bottom sheet：
  - 点击快速选项立即保存，使用选中日期与真实当前 `HH:mm`。
  - `more` 打开完整创建表单，可编辑日期与时间。
- 创建/编辑表单暴露显式日期 + 时间选择器。
- Lucent daily-record 持久化保留 `occurredAt` 作为日期键，单独持久化 `occurredTime`。
- 时间线/详情显示保存的具体时/分，而不是从时间戳回退推断。

## 候选记录

- 自然语言候选类型当前限于 water、meal、symptom、note、sleep。
- 候选审核可编辑、可选择性保存：
  - 调整 title / value / unit / note
  - 编辑睡眠 duration / quality payload
  - 取消选中项
  - 保留失败项
  - 仅重试失败候选，而非重新提交整批
- 候选编辑器按类型做轻量 MVP 打磨：
  - water：数字量 + `ml / cup / times` 单位选择器
  - meal / symptom：更具体的字段标签
  - note：强调正文而非通用 remark 字段
- 睡眠时间线行的紧凑时长标签从 payload 派生。
