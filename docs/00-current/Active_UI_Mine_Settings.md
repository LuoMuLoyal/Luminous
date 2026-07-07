# Active UI — Mine / Settings

- Mine 根页移动端现为 `单一档案状态主卡 → 健康档案分组 → 账户与隐私分组`，不再使用首屏三宫格状态总览。
- 未登录时不再显示独立顶部登录提示条；登录门槛、preview 说明和主 CTA 已并入 Mine 主卡。
- 健康档案入口使用 Forui `FTileGroup + FTile`，状态通过明确文字表达，不再只靠颜色。
- 账户
- 基础健康档案
- 过敏史
- 当前用药
- 服务器端隐私/AI 设置
- 数据导出请求状态
- 帮助/关于元数据
- 高级设置
- 助手控制

## 设置页结构

- 标准 app 模式，五个分组：
  - Account & Security
  - Notifications
  - Privacy
  - General
  - About
- 两态切换使用内联 switch。
- 多态项路由到子页。
- 睡眠提醒页使用主开关；关闭时子项禁用；时间选择使用 Forui `FTimeField.picker`。

## 主题与通知

- 主题设置现为双层选择：显示模式 `system / light / dark` + 颜色主题 `blue / green / neutral / orange / red / rose / slate / violet / yellow / zinc`。
- 旧调色板选择器和 `theme.palette` 持久化仍已移除；当前只保留 `theme.mode` 与 `theme.family` 两个本地偏好。
- 通知收件箱已真实化：
  - Today 与 Mine 铃铛图标上的未读红点由真实后端未读数驱动
  - 分组列表页（今天/昨天/更早）
  - 分页 load-more
  - 批量标为已读
  - 滑动删除
  - 详情页带动作路由（「去处理」根据通知类型导航到 Today / Report / Account）
  - 显式标为未读/删除动作
- 通知列表/详情/项表面现在直接通过 Forui 颜色/文本/按钮语义渲染，不再使用旧的手写通知 surface/body/hairline 主题层。
- 后端在 AI 摘要完成、报告导出完成、密码变更时生成通知。

## 设置文案

- 隐私文案范围限定为报告分享与 AI 摘要/建议，而非宽泛的 AI 记忆。
- 睡眠提醒行显示本地占位标签，而非 enabled/disabled 状态。
- Mine 使用中性错误文案，不出现 `mock` 字样。
- Mine 主卡文案现在区分 `preview / 缺失关键信息 / 基本就绪` 三种 readiness 语义。

## 助手入口

- 助手体验不再隐藏在 Settings 子页中。
- Today 顶部栏暴露一级助手入口，路由到独立 `/assistant` 工作区。
- Settings 保留相同的能力/权限控制作为二级入口。
- 助手工作区读取真实 Lucent capabilities。
- 恢复最新持久化对话。
- 右上角 add 动作可开始新对话。
- 发送真实 SSE 流式助手请求，Markdown 渲染。
