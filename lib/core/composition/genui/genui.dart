/// 生成式 UI 的渲染引擎接缝。
///
/// 这是 `lib/` 里**唯一**允许 import `genui` / `a2ui_core` 的地方（除组合根
/// 装配 catalog item 外）。`genui` 是 0.x，API 可能破坏性变更；把它关在这一个
/// 目录里，升级只改这里。
///
/// 职责边界：
/// - 管：A2UI 消息怎么进（transport）、怎么校验注册面（catalog）、怎么渲染
///   （surface）；
/// - 不管：生成什么内容（那是 agent 的事）、业务数据从哪来（各 feature 的
///   provider，经组合根注入的 catalog item 读取）、结果怎么落盘（那是
///   `features/generative/data/` 的事——持久化要碰 `KvStore`，不适合留在
///   `core/`）。
///
/// 纯值类型（`DataScope`）也不在这里：它在 `lib/shared/domain/generative/`，
/// 因为规则层要用它而 `domain/` 不能依赖 `core/`。
library;

export 'catalog.dart';
export 'surface.dart';
export 'transport.dart';
