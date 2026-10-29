/// notification feature 展示层的数据接缝。
///
/// 展示层不应直接 import `notification/data/`。这里把它再导出一次，作为展示层唯一入口。
library;

export 'package:luminous/app/composition/notification/unread_count.dart';

export 'package:luminous/features/notification/data/repositories/lucent.dart';
