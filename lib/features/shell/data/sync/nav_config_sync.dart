// 字段私有、构造参数公开，不能写成 initializing formal（那样会把 `_remote`
// 暴露成公开的命名参数）。同 `core/network/client/` 与 `generation_remote.dart` 的处置。
// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:convert';

import 'package:luminous/core/network/app_log.dart';
import 'package:luminous/features/shell/domain/entities/nav_config.dart';
import 'package:luminous/features/shell/domain/repositories/nav_config.dart';
import 'package:luminous/features/shell/domain/repositories/nav_config_remote.dart';
import 'package:luminous/shared/domain/composition/surface.dart';

/// tab 配置的远端同步。
///
/// ## 为什么不复用 `CachedLayoutRepository`
///
/// 那条链路的载荷是 `SurfaceLayout`（`{schemaVersion, placements:[{id,size,...}]}`），
/// 而 `ComponentPlacement.id` 必须是 `domain.view` 两段格式；tab 的身份是
/// `today` / `record` 这样的单段值，塞不进去。
///
/// 但**传输层完全一样**：同一个 `/layouts/tab` 端点、同一个 `ui_layout`
/// 离线队列、同一套 409 语义。所以这里只依赖两个窄端口
/// （[NavConfigRemote] / [NavConfigSyncQueue]），由组合根把 customizer 的
/// 实现注进来——跨 feature 的接缝停在 `domain/`，不越到 `data/`。
///
/// ## 为什么本地读仍是同步的
///
/// 首帧就要知道底栏长什么样，异步读会让冷启动先闪一帧默认底栏。远端同步是
/// **旁路**：本地 KV 永远是权威读源，远端只在登录后补一次、以及每次写入后推一次。
class NavConfigSync {
  const NavConfigSync({
    required NavConfigRemote remote,
    required NavConfigSyncQueue syncQueue,
    required NavConfigRepository local,
  }) : _remote = remote,
       _syncQueue = syncQueue,
       _local = local;

  final NavConfigRemote _remote;
  final NavConfigSyncQueue _syncQueue;
  final NavConfigRepository _local;

  /// 同步用的 surface 名——就是 `tab`，没有额外前缀或后缀。
  static const surface = SurfaceId.tab;

  /// 把本地配置推到远端。
  ///
  /// 失败时入离线队列，由 `SyncWorker` 在联网后重放；这与页面布局的写入路径
  /// 同一条语义。返回 `true` 表示远端已接受。
  Future<bool> push(NavConfig config) async {
    final accepted = await _remote.put(
      surface: surface,
      schemaVersion: config.schemaVersion,
      payload: encodeNavConfigPayload(config),
    );
    if (accepted) return true;

    // 其余失败（含 409）：本地已生效。入队让联网后重放，只保留最后一次编辑
    // （队列按 entityId 去重）。
    _enqueue(config);
    appLog.warning('NavConfigSync.push: queued for retry');
    return false;
  }

  /// 从远端拉一次并写入本地。返回是否采纳了远端配置。
  ///
  /// 远端没有这份配置或拉取失败时保持本地不变——本地是权威读源，
  /// 这里只做「有更新就采纳」。
  Future<bool> pull() async {
    final (:payload, :failure) = await _remote.fetch(surface);
    if (failure != null) {
      appLog.warning('NavConfigSync.pull: remote failed: ${failure.message}');
      return false;
    }
    if (payload == null) return false;

    final remote = decodeNavConfigPayload(payload);
    if (remote == null) {
      // 远端文档解不开（更新的客户端写的、或坏数据）：保持本地，
      // 不覆盖用户当前能用的配置。
      appLog.warning('NavConfigSync.pull: unreadable remote document');
      return false;
    }
    if (remote == _local.read()) return false;

    // 采纳远端：本地是同步读源，必须先落盘再更新内存态，
    // 否则冷启动会退回旧值。
    await _local.write(remote);
    return true;
  }

  void _enqueue(NavConfig config) {
    // fire-and-forget：入队失败不该阻断本地已经生效的写入。
    unawaited(
      _syncQueue
          .enqueue(
            surface: surface,
            schemaVersion: config.schemaVersion,
            payload: encodeNavConfigPayload(config),
          )
          .catchError((Object error) {
            appLog.warning('NavConfigSync: failed to enqueue retry: $error');
          }),
    );
  }
}

/// 编码成服务端存的 payload。
///
/// 与本地 KV 存的是同一个 `NavConfig.toJson()`：两处格式一致是刻意的——
/// 少一层转换就少一处会漂的地方，而 `schemaVersion` 已经把演进收在同一个
/// 版本号下。
String encodeNavConfigPayload(NavConfig config) {
  return jsonEncode(config.toJson());
}

/// 解出远端 payload；形状不认识返回 `null`。
NavConfig? decodeNavConfigPayload(String raw) {
  try {
    return NavConfig.fromJson(jsonDecode(raw));
  } on FormatException {
    return null;
  }
}
