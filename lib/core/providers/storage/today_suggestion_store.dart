/// Today suggestion 本地缓存的访问接缝。
///
/// `lib/core/providers/` 是 presentation 层唯一允许依赖的 core 子树，
/// 所以 drift DAO 的访问集中在这里；presentation 只见到本文件暴露的
/// store provider。
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/database/connection_providers.dart';

/// Today suggestion 缓存的读写访问器。
class TodaySuggestionStore {
  const TodaySuggestionStore(this._ref);

  final Ref _ref;

  Future<String?> fetch() {
    return _ref.read(todaySuggestionDaoProvider).fetch();
  }

  Future<void> replace(String jsonData) {
    return _ref.read(todaySuggestionDaoProvider).replace(jsonData);
  }

  Future<void> clear() {
    return _ref.read(todaySuggestionDaoProvider).clear();
  }
}

/// 缓存访问器的 provider。
final todaySuggestionStoreProvider = Provider<TodaySuggestionStore>(
  TodaySuggestionStore.new,
);
