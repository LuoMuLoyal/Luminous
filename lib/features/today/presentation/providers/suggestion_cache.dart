import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/database/connection_providers.dart';

/// Today suggestion 本地缓存的展示层接缝。
///
/// 展示层不应该直接认识 drift DAO。这个文件是 today feature 的组合根，
/// 只有它 import `core/database`；`suggestion.dart` 通过
/// [TodaySuggestionCache] 读写缓存（JSON 文本，编解码在展示层完成）。
class TodaySuggestionCache {
  const TodaySuggestionCache(this._ref);

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
final todaySuggestionCacheProvider = Provider<TodaySuggestionCache>(
  TodaySuggestionCache.new,
);
