import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/composition/composition.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/sections/dashboard/sidebar.dart';
import 'package:luminous/features/record/presentation/widgets/sections/dashboard/summary_grid.dart';
import 'package:luminous/features/record/presentation/widgets/sections/detail/timeline.dart';
import 'package:luminous/features/record/presentation/widgets/sections/quick_entry/new_entry_panel.dart';
import 'package:luminous/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;

    final content = isDesktop
        ? _DesktopRecordDashboard(
            dashboard: dashboard,
            l10n: l10n,
            onDateSelected: onDateSelected,
            onFilterSelected: onFilterSelected,
            onQuickAction: onQuickAction,
            onNewEntry: onNewEntry,
            onRecordDateChange: onRecordDateChange,
          )
        : const _MobileRecordDashboard();

    // 不再叠加入场动画：外围过渡已经负责把内容带进来（页面状态切换 fade-through /
    // Tab 分支交叉淡化），再叠一层淡入 + 上浮会让显示被推迟，并有"内容往上飘"的观感。
    return SkeletonScope(isLoading: isLoading, child: content);
  }
}

/// 移动端 record 表面：只负责渲染 record 表面的布局。
///
/// 页面不再知道有哪些区块——区块的清单、顺序与间距都在
/// `presentation/components/catalog.dart` 与宿主里；增删改一个区块不会碰到这个文件。
class _MobileRecordDashboard extends ConsumerWidget {
  const _MobileRecordDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(surfaceLayoutProvider(SurfaceId.record));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 区块由宿主逐个渲染并按「相邻之间」给间距：末项之后不留空，
        // 条件隐藏的区块也不留洞（不再需要手写 SizedBox.shrink 占位）。
        ComponentHost(
          surface: SurfaceId.record,
          layout: layout,
          spacing: Spacing.lg,
        ),
        // 与改动前一致：页面底部统一留一个间距。
        const SizedBox(height: Spacing.lg),
      ],
    );
  }
}

class _DesktopRecordDashboard extends StatelessWidget {
  const _DesktopRecordDashboard({
    required this.dashboard,
    required this.l10n,
    this.onDateSelected,
    this.onFilterSelected,
    this.onQuickAction,
    this.onNewEntry,
    this.onRecordDateChange,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<RecordEntryType?>? onFilterSelected;
  final ValueChanged<RecordQuickAction>? onQuickAction;
  final VoidCallback? onNewEntry;
  final void Function(String recordId, DateTime newDate)? onRecordDateChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 260,
          child: Column(
            children: [
              RecordMonthCalendarPanel(
                days: dashboard.monthDays,
                selectedDate: dashboard.selectedDate,
                l10n: l10n,
                onDateSelected: onDateSelected,
                onRecordDropped: onRecordDateChange,
                // Month navigation is handled internally by the panel's
                // _viewedMonth state — no parent callback needed.
              ),
              const SizedBox(height: Spacing.lg),
              RecordFilterPanel(
                filters: dashboard.filters,
                l10n: l10n,
                onFilterSelected: onFilterSelected,
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.xl),
        Expanded(
          child: Column(
            children: [
              RecordSummaryGrid(
                summary: dashboard.summary,
                l10n: l10n,
                onTypeSelected: onFilterSelected,
              ),
              const SizedBox(height: Spacing.lg),
              RecordTimelinePanel(
                entries: dashboard.timeline,
                l10n: l10n,
                onClearFilter: () => onFilterSelected?.call(null),
                selectedDate: dashboard.selectedDate,
                onRecordDateChange: onRecordDateChange,
              ),
            ],
          ),
        ),
        const SizedBox(width: Spacing.xl),
        SizedBox(
          width: 220,
          child: Column(
            children: [
              RecordNewEntryPanel(
                actions: dashboard.quickActions,
                l10n: l10n,
                onNewEntry: onNewEntry,
                onQuickAction: onQuickAction,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
