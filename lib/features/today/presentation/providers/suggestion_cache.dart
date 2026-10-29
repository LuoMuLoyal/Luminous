import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/providers/today_suggestion_store.dart';

/// Today suggestion 缓存的展示层接缝。
///
/// 展示层不认识 drift DAO：真正的访问器在
/// `core/providers/today_suggestion_store.dart`，这里只是把它投影成本
/// feature 的名字。
final todaySuggestionCacheProvider = Provider<TodaySuggestionStore>(
  (ref) => ref.watch(todaySuggestionStoreProvider),
);
