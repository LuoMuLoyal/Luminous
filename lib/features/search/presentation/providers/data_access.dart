/// search feature 展示层的数据接缝。
library;

///
/// 展示层不应直接 import `search/data/`。这里把它再导出一次，作为展示层唯一入口。

export 'package:luminous/features/search/data/datasources/recent_searches.dart';

export 'package:luminous/features/search/data/repositories/lucent.dart'
    show medicineSearchRepositoryProvider;
