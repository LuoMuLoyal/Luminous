import 'package:luminous/core/network/config/pref_keys.dart';
import 'package:luminous/core/providers/storage/preferences_store.dart';

/// A user-scoped wrapper around [KvStore].
///
/// Currently only used by the notification preferences module. When a second
/// feature needs user-isolated local storage, extract this into
/// `core/storage/` with a generic key-scoping strategy (e.g. a
/// `ScopedStorage` class that takes a key prefix function). Until then,
/// keeping it here avoids a premature abstraction that may not fit future
/// use cases.
class ScopedPreferences {
  ScopedPreferences(this._store, this._userId);

  final KvStore _store;
  final String? _userId;

  String _key(String key) {
    final userId = _userId;
    return userId == null
        ? key
        : PrefKeys.settingsNotificationsScoped(key, userId);
  }

  /// Nullable reads, mirroring the previous SharedPreferences accessors.
  bool? getBool(String key) => getOrNull<bool>(key);

  int? getInt(String key) => getOrNull<int>(key);

  String? getString(String key) => getOrNull<String>(key);

  /// Reads [key] as [T], falling back to [fallback] when absent or mistyped.
  T get<T>(String key, {required T fallback}) =>
      _store.get<T>(_key(key), fallback: fallback);

  /// Reads [key] as [T], or null when absent / of another type.
  T? getOrNull<T>(String key) => _store.getOrNull<T>(_key(key));

  /// Writes [value] under [key].
  Future<void> set(String key, Object? value) => _store.set(_key(key), value);

  /// Removes [key].
  Future<void> remove(String key) => _store.remove(_key(key));
}
