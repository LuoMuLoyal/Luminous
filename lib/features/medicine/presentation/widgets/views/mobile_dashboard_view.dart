import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/domain/entities/workspace.dart';

/// 用药页内容区。
///
/// 两种形态都交给组件宿主：页面不再知道该页有哪些区块，加组件 / 换顺序 /
/// 改跨列都不用改这个文件。桌面端用 [ComponentHostGrid]，按 `compact`
/// 尺寸把卡片排成两列，而不是手写 `Row` 分栏——手写分栏既无法被编排页
/// 重排，也让「桌面上每张卡都只是被放大」这件事躲过了组件模型。
class MedicineMobileDashboardView extends ConsumerWidget {
  const MedicineMobileDashboardView({super.key, required this.workspace});

  /// 保留该入参只为维持调用点签名：各区块自取数据，本视图不再向下传切片。
  final MedicineWorkspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(surfaceLayoutProvider(SurfaceId.medicine));
    return ComponentHostGrid(
      surface: SurfaceId.medicine,
      layout: layout,
      rowSpacing: Spacing.lg,
      columnSpacing: Spacing.lg,
    );
  }
}
