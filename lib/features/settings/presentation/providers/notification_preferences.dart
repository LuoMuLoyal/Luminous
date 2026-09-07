import 'package:luminous/core/config/pref_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A user-scoped wrapper around [SharedPreferences].
///
/// Currently only used by the notification preferences module. When a second
/// feature needs user-isolated local storage, extract this into
/// `core/storage/` with a generic key-scoping strategy (e.g. a
/// `ScopedStorage` class that takes a key prefix function). Until then,
/// keeping it here avoids a premature abstraction that may not fit future
/// use cases.
class ScopedPreferences {
  ScopedPreferences(this._preferences, this._userId);

  final SharedPreferences _preferences;
  final String? _userId;

  String _key(String key) {
    final userId = _userId;
    return userId == null
        ? key
        : PrefKeys.settingsNotificationsScoped(key, userId);
  }

  bool? getBool(String key) => _preferences.getBool(_key(key));

  int? getInt(String key) => _preferences.getInt(_key(key));

  String? getString(String key) => _preferences.getString(_key(key));

  Future<bool> setBool(String key, bool value) =>
      _preferences.setBool(_key(key), value);

  Future<bool> setInt(String key, int value) =>
      _preferences.setInt(_key(key), value);

  Future<bool> setString(String key, String value) =>
      _preferences.setString(_key(key), value);

  Future<bool> remove(String key) => _preferences.remove(_key(key));
}
