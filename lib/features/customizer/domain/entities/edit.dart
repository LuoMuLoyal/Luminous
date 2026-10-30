import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/composition/composition.dart';

part 'edit.freezed.dart';

/// 一次编排动作。
///
/// 把"用户做了什么"建模成数据，而不是在 UI 里直接改列表：跨 surface 移动
/// 需要同时改两个 surface（源移出 + 目标移入），如果 UI 直接操作两个列表，
/// 撤销、校验、提交都没法在一处处理。
@freezed
sealed class LayoutEdit with _$LayoutEdit {
  const factory LayoutEdit.move({
    required SurfaceId from,
    required SurfaceId to,
    required ComponentId id,
    required int toIndex,
  }) = LayoutEditMove;

  const factory LayoutEdit.toggle({
    required SurfaceId surface,
    required ComponentId id,
    required bool visible,
  }) = LayoutEditToggle;

  /// 从 surface 移除，回到该 surface 的未挂载池。
  const factory LayoutEdit.remove({
    required SurfaceId surface,
    required ComponentId id,
  }) = LayoutEditRemove;

  /// 从未挂载池加回 surface。
  const factory LayoutEdit.add({
    required SurfaceId surface,
    required ComponentId id,
    required int toIndex,
  }) = LayoutEditAdd;

  const factory LayoutEdit.resize({
    required SurfaceId surface,
    required ComponentId id,
    required ComponentSize size,
  }) = LayoutEditResize;
}
