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
  /// The in-flight initial `build()` load future, captured in [build].
  ///
  /// A mutation that runs before the initial read settles must wait for it
  /// first — otherwise the load's completion (riverpod `handleFuture`) would
  /// overwrite the just-persisted write with the stale pre-write read value
  /// (F-12 P2-2). The write path only runs after the search page has built,
  /// so awaiting our own build future here cannot deadlock.
  Future<List<String>>? _pendingLoad;

  @override
  Future<List<String>> build() {
    final load = const RecentSearchesLocalPreferences().load();
    _pendingLoad = load;
    return load;
  }

  /// Waits for the initial [build] load to settle when it is still in
  /// flight. An initial load failure leaves the provider in error state with
  /// no pending value that could overwrite a write, so the failure is
  /// ignored and the mutation proceeds.
  Future<void> _settleInitialLoad() async {
    final pending = _pendingLoad;
    if (pending == null) return;
    try {
      await pending;
    } catch (_) {
      // Initial read failed: nothing in flight to overwrite the write with.
    }
  }

  /// Adds [keyword] (dedup + move-to-front + cap) and persists it.
  Future<void> addKeyword(String keyword) async {
    await _settleInitialLoad();
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
    await _settleInitialLoad();
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
