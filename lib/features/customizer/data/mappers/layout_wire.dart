import 'dart:convert';

import 'package:luminous/core/composition/composition.dart';

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
  SurfaceLayout? fromDoc(Object? doc) {
    if (doc is! Map) return null;
    final payload = doc['payload'];
    if (payload == null) return null;

    // payload 可能是 JSON 字符串（缓存里存的）也可能是已解析的 map。
    final decoded = payload is String ? jsonDecode(payload) : payload;
    return SurfaceLayout.fromJson(decoded);
  }

  /// 缓存里存 payload 的字符串形式，避免 drift 表结构随布局模型演进而迁移。
  String encodePayload(SurfaceLayout layout) => jsonEncode(layout.toJson());
}
