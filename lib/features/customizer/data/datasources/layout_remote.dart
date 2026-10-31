import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:lucent_api/lucent_api.dart';
import 'package:luminous/core/network/client/dio_client.dart';
import 'package:luminous/core/network/contract/error_mapper.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 布局的远端数据源，对应 Lucent 的 `LayoutsApi`。
///
/// 契约（`Lucent/src/modules/layouts/`）：
/// - `GET  /layouts`            → `{ surfaces: { <surface>: LayoutResponse } }`
/// - `GET  /layouts/:surface`   → `LayoutResponse`（未存过是 404）
/// - `PUT  /layouts/:surface`   → `LayoutResponse`，带 `ifVersion` 做乐观并发；
///   版本冲突是 409 `LAYOUT_VERSION_CONFLICT`，`errors.current` 带回服务端当前文档
///
/// 服务端**不解释** `payload`（那是客户端自己的布局 JSON），这里只搬运字符串，
/// 解码统一交给 `LayoutWire`。
/// 远端契约：接口与实现分离，测试注入一个不触网的替身即可。
abstract interface class LayoutRemote {
  TaskEither<LucentFailure, Map<SurfaceId, String>> fetchAll();

  TaskEither<LucentFailure, int> put(
    SurfaceId surface,
    String payload, {
    required int schemaVersion,
    int? ifVersion,
  });
}

/// 走生成客户端（LayoutsApi）的实现。
final class LucentLayoutRemote implements LayoutRemote {
  const LucentLayoutRemote(this._client);

  final LucentClient _client;

  /// 拉全部 surface 的布局，返回 `surface → payload JSON 字符串`，与本地缓存同形。
  ///
  /// 没存过的 surface 不会出现在 `surfaces` 里，语义是「这个用户没自定义过」。
  @override
  TaskEither<LucentFailure, Map<SurfaceId, String>> fetchAll() {
    return TaskEither(() async {
      try {
        final response = await _client.layouts.listLayouts();
        final surfaces = response.data?.surfaces ?? const {};
        final result = <SurfaceId, String>{};
        for (final entry in surfaces.entries) {
          final surface = SurfaceId.fromWire(entry.key);
          // 后端未来可能新增 surface；本版本不认识的就跳过，这不是错误。
          if (surface == null) continue;
          final payload = _payloadOf(entry.value.payload);
          if (payload == null) continue;
          result[surface] = payload;
        }
        return Right<LucentFailure, Map<SurfaceId, String>>(result);
      } catch (error) {
        return Left<LucentFailure, Map<SurfaceId, String>>(
          LucentErrorMapper.fromObject(error),
        );
      }
    });
  }

  /// 保存一个 surface 的布局，返回服务端确认后的 `version`。
  ///
  /// 409 冲突由调用方决定怎么处理：`LucentErrorMapper` 会保留 `statusCode` 与
  /// `errors`（含 `current`），`CachedLayoutRepository` 据此采纳服务端版本。
  @override
  TaskEither<LucentFailure, int> put(
    SurfaceId surface,
    String payload, {
    required int schemaVersion,
    int? ifVersion,
  }) {
    return TaskEither(() async {
      try {
        final response = await _client.layouts.saveLayout(
          surface: surface.wireValue,
          saveLayoutRequest: SaveLayoutRequest(
            ifVersion: ifVersion,
            schemaVersion: schemaVersion,
            payload: jsonDecode(payload),
          ),
        );
        return Right<LucentFailure, int>(response.data?.version ?? 0);
      } catch (error) {
        return Left<LucentFailure, int>(
          LucentErrorMapper.fromObject(error),
        );
      }
    });
  }

  /// 服务端把 payload 当客户端自定义 JSON 存，可能回来已经是字符串。
  String? _payloadOf(Object? payload) {
    if (payload == null) return null;
    if (payload is String) return payload.isEmpty ? null : payload;
    return jsonEncode(payload);
  }
}
