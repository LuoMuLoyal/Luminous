# lib/core/feedback — 轻量 Toast 反馈

单文件目录(`toast.dart`):`Toast` 全静态工具,封装 Forui `showFToast` 的单实例轻量提示。

## 职责与边界

- 管:瞬态轻量反馈 — `Toast.show`(纯文本)与 `Toast.showWithAction`(动作按钮替代默认关闭按钮)。
- 不管:页面级加载/错误/空态(走 `../widgets/common/feedback/page_state.dart` 的 `PageStateSwitch`)、
  对话框、本地与推送通知(`../notifications/`、`../push/`)。

## 对外契约

- 导出:`toast.dart` 的 `Toast.show` / `Toast.showWithAction`,返回 `Future<bool?>`
  (`false` = FToaster 不可用已降级)。
- 被依赖:各 feature 的 presentation(today/record/review/mine/auth/scan/assistant 等)、
  `../auth/sensitive_action_password_resolver.dart`、`../../app/bootstrap.dart`。

## 不变量

- 全局同时最多一条 toast;同消息重复触发只重置计时并换用最新 action 回调,不排队
  (类内 static 单槽状态;`test/core/feedback/app_toast_test.dart` 覆盖无 FToaster 的降级路径)。
- widget 树必须有 `FToaster` 祖先(bootstrap 注入);缺失时 `show` 捕获异常、记日志并返回
  `false`,不崩溃。
- 自动消失由内部计时器驱动(`showFToast(duration: null)`),展示期间重复触发只是重新计时。

## 依赖禁区

- API 依赖 `BuildContext`,禁止被 `data/`、`domain/` 层或 provider 的同步业务逻辑 import;
  错误文案先用 `userMessageFromError`(`../errors/user_message.dart`)归一再传入。
- 不反向依赖 features;仅依赖 core(design 的 `SemanticIcons`、logger)。

## 陷阱与决策

- "单槽替换而非排队"是刻意决策:连续触发同消息(如快捷入口撤销)以最后一次为准,避免 toast 洪泛。
- action 的 label 在展示时捕获、回调在按下时读取最新值 —— 同消息重放后按钮文案不变但指向最新
  闭包;需要文案热更新须重建 toast(源码内 TODO 标记)。
- 传入的 message 需已本地化;本目录不做 l10n。
