import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/utils/record_time_format.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/providers/surface.dart';
import 'package:luminous/features/record/presentation/quick_entry/core/dispatcher.dart';
import 'package:luminous/features/record/presentation/widgets/sections/quick_entry/new_entry_panel.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 记录页的「新建记录 / 快捷录入」面板区块。
///
/// 桌面端原本由手写三栏布局直接渲染 [RecordNewEntryPanel]，改走组件网格后没有
/// 对应组件，新建入口就整块消失了。这里把它补成正式组件，与其它 record 区块一致：
/// 自己从 [recordSurfaceStateProvider] 取数，自己处理点击。
class RecordNewEntrySection extends ConsumerWidget {
  const RecordNewEntrySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(recordSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return const SizedBox.shrink();

    return RecordNewEntryPanel(
      actions: dashboard.quickActions,
      l10n: AppLocalizations.of(context)!,
      onNewEntry: () => _openRecordCreate(context, ref),
      onQuickAction: (action) {
        unawaited(handleQuickAction(context, ref, action));
      },
    );
  }

  void _openRecordCreate(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.read(selectedRecordDateProvider);
    unawaited(
      pushAuthRequiredRoute(
        context,
        Uri(
          path: '/record/create',
          queryParameters: {'date': formatRecordDate(selectedDate)},
        ).toString(),
      ),
    );
  }
}
