/// health_data feature 数据层 provider 的组合根入口。
///
/// 这里只做再导出，不装配——装配在
/// `lib/app/composition/health_sync/health_sync.dart`（那组 provider 需要
/// `core/native` 桥与 record feature 的 daily-record repository，`health_data/data/`
/// 不允许 import 两者）。曾经的反向再导出（装配文件 export 本文件以借它的
/// `healthPlatformDataSourceProvider`）会与这里形成一个 import 环，所以本文件
/// 不再 import 装配文件，而是把它的出口一并再导出给老的消费方。
library;

export 'package:luminous/app/composition/health_sync/health_sync.dart';
