import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';

class RecordDashboardView extends StatelessWidget {
  const RecordDashboardView({
    super.key,
    required this.dashboard,
    this.isPreview = false,
    this.isLoading = false,
    this.onQuickAction,
    this.onNewEntry,
    this.onFilterSelected,
    this.onDateSelected,
    this.onRecordDateChange,
  });

  final RecordDashboard dashboard;
  final bool isPreview;
  final bool isLoading;

  /// 桌面端底部「新建记录」面板仍由页面装配，因此保留整块看板级别的回调。
  /// 移动端已改为区块自取数据/自处理交互，不再经过这里。
  final ValueChanged<RecordQuickAction>? onQuickAction;
  final VoidCallback? onNewEntry;
  final ValueChanged<RecordEntryType?>? onFilterSelected;
  final ValueChanged<DateTime>? onDateSelected;

  /// Called when a timeline card is dragged onto a calendar day.
  /// Receives the record ID and the new target date.
  final void Function(String recordId, DateTime newDate)? onRecordDateChange;

  @override
  Widget build(BuildContext context) {
    // 不再叠加入场动画：外围过渡已经负责把内容带进来（页面状态切换 fade-through /
    // Tab 分支交叉淡化），再叠一层淡入 + 上浮会让显示被推迟，并有"内容往上飘"的观感。
    return SkeletonScope(isLoading: isLoading, child: const _RecordSurface());
  }
}

/// record 表面：只负责渲染 record 表面的布局。
///
/// 页面不再知道有哪些区块——区块的清单、顺序、跨列与间距都在
/// `presentation/components/catalog.dart` 里；增删改一个区块不会碰到这个文件。
/// 桌面端与移动端共用同一个宿主：宿主按当前视口解析列数（手机 1 列、桌面 2 列），
/// 因此不再需要手写的桌面三栏。
class _RecordSurface extends ConsumerWidget {
  const _RecordSurface();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(surfaceLayoutProvider(SurfaceId.record));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 区块由宿主逐个渲染并按「相邻之间」给间距：末项之后不留空，
        // 条件隐藏的区块也不留洞（不再需要手写 SizedBox.shrink 占位）。
        ComponentHostGrid(
          surface: SurfaceId.record,
          layout: layout,
          rowSpacing: Spacing.lg,
          columnSpacing: Spacing.lg,
        ),
        // 与改动前一致：页面底部统一留一个间距。
        const SizedBox(height: Spacing.lg),
      ],
    );
  }
}
