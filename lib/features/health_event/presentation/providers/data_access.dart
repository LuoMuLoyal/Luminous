/// health_event feature 展示层的数据接缝。
///
/// 展示层不应直接 import `health_event/data/`。这里把它再导出一次，作为展示层唯一入口。
library;

export 'package:luminous/features/health_event/data/providers/health_event.dart';
