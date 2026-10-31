import 'dart:convert';

import 'package:luminous/shared/domain/composition/layout.dart';

/// 布局在本地缓存/网络上的编解码。
///
/// 服务端不解释 payload（只校验 schemaVersion 区间与 version 单调），
/// 所以映射只在客户端一处完成，加组件/加尺寸不需要动后端。
final class LayoutWire {
  const LayoutWire();

  /// 服务端 `LayoutDoc`：`{ version, schemaVersion, payload }`。
  Map<String, Object?> toDoc(SurfaceLayout layout, {int? version}) => {
    'version': version ?? 0,
    'schemaVersion': layout.schemaVersion,
    'payload': layout.toJson(),
  };

  /// 解出布局；文档形状不认识时返回 `null`，由调用方回退默认布局。
  ///
  /// 接受两种输入：
  /// - 服务端的 `LayoutDoc`（`{version, schemaVersion, payload}`）——409 冲突时
  ///   `errors.current` 就是这种形状；
  /// - 裸 payload JSON（本地缓存、`LayoutRemote.fetchAll` 传回来的字符串）。
  SurfaceLayout? fromDoc(Object? doc) {
    if (doc == null) return null;
    if (doc is String) {
      final decoded = _tryDecode(doc);
      return decoded == null ? null : SurfaceLayout.fromJson(decoded);
    }
    if (doc is! Map) return null;
    // 有 payload 键就是 LayoutDoc，取它的 payload；否则当作裸 payload。
    final payload = doc.containsKey('payload') ? doc['payload'] : doc;
    if (payload == null) return null;
    final decoded = payload is String ? _tryDecode(payload) : payload;
    if (decoded is! Map) return null;
    return SurfaceLayout.fromJson(decoded);
  }

  Map<String, Object?>? _tryDecode(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map
          ? {for (final e in decoded.entries) e.key.toString(): e.value}
          : null;
    } on FormatException {
      return null;
    }
  }

  /// 缓存里存 payload 的字符串形式，避免 drift 表结构随布局模型演进而迁移。
  String encodePayload(SurfaceLayout layout) => jsonEncode(layout.toJson());
}
