import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/providers/surface.dart';
import 'package:luminous/features/record/presentation/widgets/sections/detail/mobile_timeline.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 移动端当日时间线区块。
///
/// 「回到今天」与「清除过滤」都只改本 feature 的选中状态，区块自己就能完成，
/// 不需要页面注入回调；移动端时间线本身不支持拖拽改日期（那是桌面
/// `RecordTimelinePanel` 的能力）。
class RecordTimelineSection extends ConsumerWidget {
  const RecordTimelineSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(recordSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return const SizedBox.shrink();

    return RecordMobileTimeline(
      entries: dashboard.timeline,
      totalCount: dashboard.timeline.length,
      l10n: AppLocalizations.of(context)!,
      selectedDate: dashboard.selectedDate,
      hasActiveFilter: !dashboard.filters.every((f) => f.selected),
      onClearFilter: () =>
          ref.read(selectedRecordFilterProvider.notifier).setFilter(null),
      onBackToToday: () =>
          ref.read(selectedRecordDateProvider.notifier).setDate(clock.now()),
    );
  }
}
