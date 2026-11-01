import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/providers/surface.dart';
import 'package:luminous/features/record/presentation/widgets/sections/dashboard/filter_panel.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 记录页的桌面筛选面板区块。
///
/// 桌面端原本由手写三栏布局直接渲染 [RecordFilterPanel]（带 `record-filter-panel`
/// key 的竖排筛选卡），改走组件网格后没有对应组件就消失了。与移动端的
/// `filter.types`（横向 chip 条）是两个形态，各自一个组件。
class RecordFilterPanelSection extends ConsumerWidget {
  const RecordFilterPanelSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(recordSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return const SizedBox.shrink();

    return RecordFilterPanel(
      filters: dashboard.filters,
      l10n: AppLocalizations.of(context)!,
      onFilterSelected: (type) =>
          ref.read(selectedRecordFilterProvider.notifier).setFilter(type),
    );
  }
}
