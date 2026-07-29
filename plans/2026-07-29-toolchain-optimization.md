# Luminous 工具链优化计划

> 创建日期：2026-07-29
> 最后修订：2026-07-29
> 状态：主体已完成，剩余 discarded_futures 待修复
> 涉及仓库：Luminous

---

## 剩余项

### P2-1 第二批: 启用 discarded_futures

`discarded_futures` 规则启用后报 107 个 info 级别警告，均为 UI 回调中的 fire-and-forget Future 调用。需要逐一用 `unawaited()` 包裹或将外层函数改为 async。

当前状态：已在 `analysis_options.yaml` 中注释，附带 `# 107 issues — needs a dedicated unawaited() pass` 说明。

**修复完成后：** 取消 `analysis_options.yaml` 中 `discarded_futures` 的注释。

### P2-1 第二批: 启用 avoid_void_async / parameter_assignments / use_decorated_box

第二批 lint 规则尚未启用，需要小范围重构后取消注释。
