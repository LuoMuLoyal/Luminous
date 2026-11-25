/// 生成式 UI 的渲染引擎接缝（A2UI v1.0）。
///
/// 这是 `lib/` 里**唯一**允许 import `a2ui_flutter` / `a2ui_core` 的地方（组合根
/// 装配 catalog 时除外）。两个包都是 0.x，API 可能破坏性变更；把它们关在这一个
/// 目录里，升级只改这里。
///
/// 职责边界：
/// - 管：A2UI 消息怎么进（transport）、能落哪些组件（catalog）、怎么渲染
///   （surface）、渲染端有哪些能力（capabilities）；
/// - 不管：生成什么内容（agent 的事）、业务数据从哪来（各 feature 的 provider，
///   经组合根注入的领域组件读取）、结果怎么落盘（`features/generative/data/`）。
///
/// 与 A2UI 1.0 对齐后，这里**不再**有组件白名单：`basicCatalog()` 全量注册
/// （Button / TextField / CheckBox / Slider / ChoicePicker / DateTimeInput /
/// Tabs / Modal / Video / AudioPlayer 都在），交互与写入由 agent 决定。
library;

export 'catalog.dart';
export 'surface.dart';
export 'transport.dart';
