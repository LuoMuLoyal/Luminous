import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/features/search/data/datasources/recent_searches.dart';

/// Notifier that exposes the persisted recent search keywords.
///
/// State is `List<String>` (latest first). Mutations write through to
/// [SharedPreferences] via [RecentSearchesLocalPreferences] and update the
/// state from the persisted result, keeping in-memory state and storage in
/// sync. Persistence failures are logged and leave the previous state
/// untouched — they must never fail the search flow that triggered the write.
class RecentSearchesNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() {
    return const RecentSearchesLocalPreferences().load();
  }

  /// Adds [keyword] (dedup + move-to-front + cap) and persists it.
  Future<void> addKeyword(String keyword) async {
    try {
      final updated = await const RecentSearchesLocalPreferences().add(keyword);
      state = AsyncData(updated);
    } catch (e, st) {
      ref
          .read(talkerProvider)
          .error('RecentSearchesNotifier.addKeyword: persist failed: $e\n$st');
    }
  }

  /// Clears all recent search keywords.
  Future<void> clearAll() async {
    try {
      await const RecentSearchesLocalPreferences().clear();
      state = const AsyncData(<String>[]);
    } catch (e, st) {
      ref
          .read(talkerProvider)
          .error('RecentSearchesNotifier.clearAll: persist failed: $e\n$st');
    }
  }
}

final recentSearchesProvider =
    AsyncNotifierProvider<RecentSearchesNotifier, List<String>>(
      RecentSearchesNotifier.new,
    );
