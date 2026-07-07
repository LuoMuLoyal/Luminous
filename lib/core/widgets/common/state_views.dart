/// 状态视图与骨架屏组件的 barrel export。
///
/// 历史原因：这些组件曾全部实现在本文件中。现已拆分为：
/// - [state_message.dart] — 空状态/错误提示视图
/// - [skeleton.dart] — shimmer 骨架屏相关组件
///
/// 建议新代码直接导入具体文件，避免依赖本 barrel。
library;

export 'state_message.dart';
export 'skeleton.dart';
