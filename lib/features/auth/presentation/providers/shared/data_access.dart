/// auth feature 展示层的数据接缝。
///
/// 展示层不应直接 import `auth/data/`。这里把它再导出一次，作为展示层唯一入口。
library;

export 'package:luminous/app/composition/auth/auth.dart';

export 'package:luminous/app/composition/auth/sessions.dart';

export 'package:luminous/features/auth/data/services/avatar_uploader.dart';
