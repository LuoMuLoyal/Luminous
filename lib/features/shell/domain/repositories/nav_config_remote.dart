import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

/// tab 配置的远端端口。
///
/// `shell` 不能 import `customizer` 的 `data/`（`cross_feature_import` 门禁），
/// 但两者要共用同一个 `/layouts` 端点。所以这里只声明「要往某个 surface 写一份
/// 带版本号的文档」，由组合根把 `customizer` 的实现注进来。
///
/// 接口刻意窄到只够用：shell 不需要知道 409 的 `current` 怎么解析，也不需要
/// 知道 payload 是对象还是数组。
abstract interface class NavConfigRemote {
  /// 写入一层 surface 的配置，返回是否被服务端接受。
  ///
  /// 失败**不抛**：调用方（`NavConfigSync`）据返回值决定入队还是静默——
  /// 本地已经生效，远端失败不是用户可见的错误。
  Future<bool> put({
    required SurfaceId surface,
    required int schemaVersion,
    required String payload,
  });

  /// 读一层 surface 的配置；未存过返回 `null`。
  ///
  /// 失败以 `Left` 返回，让「没存过」与「拉不到」在调用方可以分开处理：
  /// 前者是正常的首次使用，后者要记日志。
  Future<({String? payload, LucentFailure? failure})> fetch(SurfaceId surface);
}

/// tab 配置的离线入队端口。
///
/// 重放本身由 `SyncWorker` 与 customizer 的队列实现负责；shell 只负责
/// 「把这一份配置排进去」。
abstract interface class NavConfigSyncQueue {
  Future<void> enqueue({
    required SurfaceId surface,
    required int schemaVersion,
    required String payload,
  });
}
