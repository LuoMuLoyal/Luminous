/// record feature 展示层的数据接缝。
///
/// 展示层不应直接 import `record/data/`。数据装配集中在 data 层的
/// `data/providers/record_access.dart`，这里把它再导出一次，作为展示层唯一入口。
///
/// 注意：这是中转再导出，不新增任何逻辑；等 data 层把 repository 装配下沉到
/// application 层后，本文件可以收窄成只导出读模型 provider。
library;

export 'package:luminous/features/record/data/datasources/quick_entry_preferences.dart';
export 'package:luminous/features/record/data/providers/record_access.dart';
export 'package:luminous/features/record/data/providers/water_target.dart';
