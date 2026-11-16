/// 自定义 genui 区块**声明**的仓储接口。
///
/// 与 [GenerationRepository] 分开：声明的生命周期（用户写下「这块放什么」）
/// 与生成结果（agent 现拼的内容）互不相干——清掉结果不该连带清掉声明，反之
/// 亦然。两者共用 KV 前缀是存储细节，不是接口约束。
library;

import 'package:fpdart/fpdart.dart';
import 'package:luminous/features/generative/domain/entities/slot_spec.dart';
import 'package:luminous/shared/domain/composition/surface.dart';
import 'package:luminous/shared/domain/failure.dart';

abstract interface class SlotSpecRepository {
  /// 读出该 surface 的声明；没写过（或已损坏）返回 `null`。
  ///
  /// 坏数据落在 `data/` 的边界上被吞成 `null`：一份读不出的声明等价于「没
  /// 配过」，编排页照常打开，不让它变成整页打不开的失败。
  Future<Either<LucentFailure, GenerativeSlotSpec?>> read(SurfaceId surface);

  /// 保存（或覆盖）该 surface 的声明。
  Future<Either<LucentFailure, Unit>> write(
    SurfaceId surface,
    GenerativeSlotSpec spec,
  );

  /// 清掉该 surface 的声明。
  Future<Either<LucentFailure, Unit>> clear(SurfaceId surface);
}
