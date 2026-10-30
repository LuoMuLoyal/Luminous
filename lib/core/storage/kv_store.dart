import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Key-value store for small, non-relational preferences.
///
/// Structured health data stays in drift; this is only for switches, choices
/// and small scalars.
///
/// **No encryption here.** Nothing sensitive is stored through this API —
/// session credentials live in the platform secure store. Keeping the box
/// unencrypted avoids a second key to manage.
///
/// **No migration from SharedPreferences.** This is an intentional breaking
/// change: existing installs start from defaults.
abstract interface class KvStore {
  /// The process-wide store.
  ///
  /// Set by [HiveKvStore.open] during bootstrap. Reading it before that is a
  /// programming error, so it throws instead of silently returning an empty
  /// store (preferences would appear to vanish and then reappear on restart).
  static KvStore get instance {
    final store = _instance;
    if (store == null) {
      throw StateError('KvStore must be opened before any preference access.');
    }
    return store;
  }

  static KvStore? _instance;

  /// The current instance, or null before it is opened. Test-only.
  static KvStore? get tryInstance => _instance;

  /// Installs [store] as [instance]. Test-only.
  static KvStore installForTesting(KvStore store) {
    _instance = store;
    return store;
  }

  /// Forgets the current instance. Test-only.
  static void clearForTesting() => _instance = null;

  /// Reads [key] as [T], returning [fallback] when absent or of another type.
  T get<T>(String key, {required T fallback});

  /// Reads a nullable value; null when absent.
  T? getOrNull<T>(String key);

  /// Writes [value] under [key].
  Future<void> set(String key, Object? value);

  /// Removes [key].
  Future<void> remove(String key);

  /// Whether [key] has a value.
  bool containsKey(String key);

  /// Clears every entry. Used by the "clear local data" path.
  Future<void> clear();

  /// A snapshot of every stored entry. Used by tests to assert writes.
  Map<String, Object?> snapshot();
}

/// [KvStore] backed by a Hive box.
class HiveKvStore implements KvStore {
  HiveKvStore(this._box);

  /// Box name on disk.
  static const String boxName = 'preferences';

  final Box<dynamic> _box;

  /// Opens the box and installs it as [KvStore.instance]. Call once at bootstrap.
  ///
  /// `Hive.openBox` needs either an explicit path or an initialized Hive.
  /// Nothing else in the app initializes Hive, and the drift database already
  /// lives in the application documents directory, so the box is pointed at a
  /// path derived from the same root instead of adding a second storage root.
  static Future<KvStore> open() async {
    final box = await Hive.openBox<dynamic>(boxName, path: await _storagePath());
    return KvStore.installForTesting(HiveKvStore(box));
  }

  static Future<String> _storagePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final boxDir = Directory(p.join(dir.path, 'kv'));
    await boxDir.create(recursive: true);
    return boxDir.path;
  }

  @override
  T get<T>(String key, {required T fallback}) {
    final raw = _box.get(key);
    if (raw is T) return raw;
    if (raw != null) {
      appTalker.warning(
        'KvStore: $key expected $T but found ${raw.runtimeType}; '
        'falling back to default',
      );
    }
    return fallback;
  }

  @override
  T? getOrNull<T>(String key) {
    final raw = _box.get(key);
    return raw is T ? raw : null;
  }

  @override
  Future<void> set(String key, Object? value) => _box.put(key, value);

  @override
  Future<void> remove(String key) => _box.delete(key);

  @override
  bool containsKey(String key) => _box.containsKey(key);

  @override
  Future<void> clear() => _box.clear();

  @override
  Map<String, Object?> snapshot() => {
    for (final key in _box.keys) key as String: _box.get(key),
  };
}

/// In-memory [KvStore] for tests.
///
/// Synchronous to construct and seed, so test helpers do not need `async`.
class MemoryKvStore implements KvStore {
  MemoryKvStore([Map<String, Object?>? seed]) {
    if (seed != null) _data.addAll(seed);
  }

  final Map<String, Object?> _data = {};

  @override
  T get<T>(String key, {required T fallback}) {
    final raw = _data[key];
    return raw is T ? raw : fallback;
  }

  @override
  T? getOrNull<T>(String key) {
    final raw = _data[key];
    return raw is T ? raw : null;
  }

  @override
  Future<void> set(String key, Object? value) async {
    _data[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }

  @override
  bool containsKey(String key) => _data.containsKey(key);

  @override
  Future<void> clear() async {
    _data.clear();
  }

  @override
  Map<String, Object?> snapshot() => Map<String, Object?>.of(_data);
}
