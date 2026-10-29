/// today feature 展示层的数据接缝。
///
/// 展示层不应直接 import `today/data/`。这里把它再导出一次，作为展示层唯一入口。
library;

export 'package:luminous/features/today/data/providers/suggestion.dart';

export 'package:luminous/features/today/data/providers/today_suggestion.dart';

export 'package:luminous/features/today/data/repositories/lucent_ai.dart';

export 'package:luminous/features/today/data/utils/suggestion_json_codec.dart';
