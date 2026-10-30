import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 布局的远端数据源。
///
/// **当前为占位实现**：Lucent 还没有 `/ui/layouts` 端点，生成客户端里也就没有
/// 可调的 API。契约（`GET /ui/layouts`、`PUT /ui/layouts/:surface`）已在
/// `plans/2026-10-28-composable-tabs.md` §2.7 定义，后端落地后替换本类即可——
/// domain / application / 编排 UI 都不依赖这一层。
///
/// 在此之前 [fetchAll] 返回空、[put] 返回成功，语义是「这台设备还没有云端
/// 布局」：用户改的东西写入本地缓存并立即生效，只是暂时不同步到别的设备。
final class LayoutRemote {
  const LayoutRemote();

  TaskEither<LucentFailure, Map<SurfaceId, Object?>> fetchAll() {
    return TaskEither(
      () async => const Right<LucentFailure, Map<SurfaceId, Object?>>({}),
    );
  }

  TaskEither<LucentFailure, void> put(
    SurfaceId surface,
    String payload, {
    int? ifVersion,
  }) {
    return TaskEither(() async => const Right<LucentFailure, void>(null));
  }
}
