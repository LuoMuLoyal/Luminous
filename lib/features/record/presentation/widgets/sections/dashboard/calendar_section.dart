import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/providers/surface.dart';
import 'package:luminous/features/record/presentation/widgets/sections/dashboard/calendar_panel.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 记录页的月历面板区块。
///
/// 桌面端原本由手写三栏布局直接渲染 [RecordMonthCalendarPanel]，改走组件网格后
/// 没有对应组件，日历（以及「把时间线卡片拖到某天改日期」）就整个消失了。这里把它
/// 补成一个正式组件，于是它既能出现在桌面默认布局里，也能被用户自己编排。
///
/// 与其它 record 区块一致：自己从 [recordSurfaceStateProvider] 取数，不接收切片。
class RecordCalendarSection extends ConsumerWidget {
  const RecordCalendarSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(recordSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return const SizedBox.shrink();

    return RecordMonthCalendarPanel(
      days: dashboard.monthDays,
      selectedDate: dashboard.selectedDate,
      l10n: AppLocalizations.of(context)!,
      onDateSelected: (date) =>
          ref.read(selectedRecordDateProvider.notifier).setDate(date),
    );
  }
}
