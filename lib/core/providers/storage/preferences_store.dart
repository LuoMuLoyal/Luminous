/// 本地键值偏好存储的接缝。
///
/// presentation 层不应直接依赖 `lib/core/storage/kv_store.dart`（Hive 打开、
/// 实例生命周期等 I/O 细节）。展示层的 provider 只通过这里拿 [KvStore] 抽象。
library;

export 'package:luminous/core/storage/kv_store.dart' show KvStore;
