/// today feature 展示层的数据接缝。
///
/// 展示层不应直接 import `today/data/`。这里把它再导出一次，作为展示层唯一入口。
library;

export 'package:luminous/app/composition/snapshot/health_context.dart'
    show healthContextSnapshotProvider;
export 'package:luminous/app/composition/today/suggestion.dart';
export 'package:luminous/app/composition/today/today_suggestion.dart';
export 'package:luminous/features/today/data/repositories/lucent_ai.dart';
export 'package:luminous/features/today/data/utils/suggestion_json_codec.dart';
