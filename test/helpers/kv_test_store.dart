import 'package:luminous/core/storage/kv_store.dart';

/// Test helpers for [KvStore].
///
/// Synchronous by design: tests seed preferences in `setUp` and in synchronous
/// helper functions, and an `await` there would force those helpers to become
/// async for no benefit. The in-memory store needs no I/O.
abstract final class KvTestStore {
  /// Installs a fresh in-memory store, optionally seeded.
  static KvStore install({Map<String, Object?> seed = const {}}) {
    return KvStore.installForTesting(MemoryKvStore(seed));
  }

  /// Forgets the installed store.
  static void reset() => KvStore.clearForTesting();
}
