import 'package:fpdart/fpdart.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/shared/domain/failure.dart';

/// 布局的读写接口。
///
/// 权威在后端（多设备一致、换机不丢），本地只做缓存与离线队列。
/// 这层只声明"能做什么"，cache-first、乐观写、409 冲突处理都在 data 层实现。
abstract interface class LayoutRepository {
  /// 读取全 surface 布局。返回 `Right(空 map)` 表示账号还没有任何布局，
  /// 调用方据此回退到各 surface 的 defaultLayout。
  TaskEither<LucentFailure, Map<SurfaceId, SurfaceLayout>> readAll();

  /// 保存单 surface 布局。
  ///
  /// [ifVersion] 是乐观锁：`null` 表示"首次写入/允许覆盖"，非 null 时服务端版本
  /// 不匹配会返回冲突，调用方以服务端为准并提示——不静默覆盖另一台设备的修改。
  TaskEither<LucentFailure, SurfaceLayout> write(
    SurfaceId surface,
    SurfaceLayout layout, {
    int? ifVersion,
  });
}
