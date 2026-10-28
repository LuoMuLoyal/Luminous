import 'package:luminous/core/config/pref_keys.dart';
import 'package:luminous/core/storage/kv_store.dart';

/// Data-layer service for recent search keyword persistence.
///
/// Mirrors the `MedicineReminderLocalPreferences` pattern: moves
/// [SharedPreferences] access out of presentation providers. Keywords are
/// stored latest-first, deduplicated and capped at [maxKeywords].
class RecentSearchesLocalPreferences {
  const RecentSearchesLocalPreferences();

  /// Maximum number of recent search keywords kept; the oldest ones are
  /// dropped beyond this cap.
  static const int maxKeywords = 10;

  /// Loads recent search keywords, latest first. Returns an empty list when
  /// nothing has been persisted yet.
  Future<List<String>> load() async {
    final prefs = KvStore.instance;
    return prefs.getOrNull<List<String>>(
          PrefKeys.medicineSearchRecentKeywords,
        ) ??
        const <String>[];
  }

  /// Adds [keyword] to the front of the list, moves it to the front when it
  /// already exists (dedup), caps the list at [maxKeywords], then persists.
  /// Returns the updated list (latest first) so callers can keep in-memory
  /// state in sync with storage.
  Future<List<String>> add(String keyword) async {
    final prefs = KvStore.instance;
    final current =
        prefs.getOrNull<List<String>>(PrefKeys.medicineSearchRecentKeywords) ??
        const <String>[];
    final updated = <String>[keyword, ...current.where((k) => k != keyword)];
    final capped = updated.take(maxKeywords).toList();
    await prefs.set(PrefKeys.medicineSearchRecentKeywords, capped);
    return capped;
  }

  /// Removes all recent search keywords.
  Future<void> clear() async {
    final prefs = KvStore.instance;
    await prefs.remove(PrefKeys.medicineSearchRecentKeywords);
  }
}
