import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/providers/surface.dart';
import 'package:luminous/features/record/presentation/widgets/sections/dashboard/date_bar.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 记录页顶部的日期条区块。
///
/// 自己从 [recordSurfaceStateProvider] 取数，不再由页面向下传 `dashboard:` 切片；
/// 没有可显示的数据（首帧加载或加载失败）时不出内容，交给页面级的骨架/错误视图。
class RecordDateSection extends ConsumerWidget {
  const RecordDateSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(recordSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return const SizedBox.shrink();
    return RecordDateBar(
      dashboard: dashboard,
      l10n: AppLocalizations.of(context)!,
      onDateSelected: (date) =>
          ref.read(selectedRecordDateProvider.notifier).setDate(date),
    );
  }
}
