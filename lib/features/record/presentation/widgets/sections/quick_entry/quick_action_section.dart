import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/record/presentation/providers/data_access.dart';
import 'package:luminous/features/record/presentation/providers/surface.dart';
import 'package:luminous/features/record/presentation/quick_entry/core/dispatcher.dart';
import 'package:luminous/features/record/presentation/widgets/sections/quick_entry/quick_entry_panel.dart';
import 'package:luminous/features/record/presentation/widgets/shared/dashboard_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 快速录入面板区块（含 AI 输入行、快捷按钮网格与快捷备注）。
///
/// 数据自取；点击/长按分别走 [handleQuickAction] 与 [handleQuickActionLongPress]，
/// 组件构造函数因此不需要任何 `onXxx` 回调。
class RecordQuickActionSection extends ConsumerWidget {
  const RecordQuickActionSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(recordSurfaceStateProvider).dataOrNull;
    if (dashboard == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return RecordQuickEntryPanel(
      actions: buildMobileQuickActions(dashboard.quickActions),
      summary: dashboard.summary,
      timeline: dashboard.timeline,
      l10n: l10n,
      onQuickAction: (action) {
        unawaited(
          Future(
            () => ref
                .read(quickEntryPreferencesProvider.notifier)
                .recordTap(action.type),
          ),
        );
        unawaited(handleQuickAction(context, ref, action));
      },
      onQuickActionLongPress: (action) {
        unawaited(handleQuickActionLongPress(context, ref, action));
      },
    );
  }
}
