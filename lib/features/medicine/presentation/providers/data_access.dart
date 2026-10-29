/// medicine feature 展示层的数据接缝。
///
/// 展示层不应直接 import `medicine/data/`。这里把它再导出一次，作为
/// 展示层唯一入口（编译器只告警未用导入，未用符号不会报错）。
library;

export 'package:luminous/app/composition/medicine/workspace.dart';
export 'package:luminous/features/medicine/data/datasources/dose_log_cached.dart';
export 'package:luminous/features/medicine/data/datasources/dose_log_remote.dart';
export 'package:luminous/features/medicine/data/datasources/medicine_detail_remote.dart';
export 'package:luminous/features/medicine/data/datasources/reminder_local_preferences.dart';
export 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
export 'package:luminous/features/medicine/data/datasources/safety_tips_remote.dart';
export 'package:luminous/features/medicine/data/repositories/risk_check.dart';
