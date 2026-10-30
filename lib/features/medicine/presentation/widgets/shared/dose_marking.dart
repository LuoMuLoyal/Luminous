import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/instrumentation/data_change_bus.dart';
import 'package:luminous/core/providers/session/session_snapshot.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/features/medicine/presentation/providers/data_access.dart';
import 'package:luminous/features/medicine/presentation/widgets/shared/workspace_parts.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 打卡 / 撤销打卡的展示层动作。
///
/// 原先是 `pages/page.dart` 注入给区块的回调；组件改成数据自取后不再收
/// `onXxx`，动作落在组件可自行调用的函数上。鉴权、写库、DataChangeBus 通知与
/// toast 的口径与改造前完全一致。
Future<void> markMedicineDose(
  BuildContext context,
  WidgetRef ref,
  MedicineDoseMarkRequest request,
) async {
  final session = ref.read(authSessionProvider);
  if (!session.canAccessProtectedData) {
    if (session.isLoading) {
      return;
    }
    if (context.mounted) {
      await showAuthRequiredDialog(
        context,
        onLogin: () => requestSignIn(context),
      );
    }
    return;
  }

  final l10n = AppLocalizations.of(context)!;
  final today = clock.now();
  final dateStr =
      '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

  try {
    final result = await ref
        .read(cachedDoseLogDataSourceProvider)
        .mark(
          currentMedicineId: request.currentMedicineId,
          reminderId: request.reminderId,
          scheduledTime: request.scheduledTime,
          status: request.action.name,
          date: dateStr,
        )
        .run();
    result.fold((failure) => throw failure, (_) {});
    ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.doseLogs);
    if (context.mounted) {
      unawaited(
        Toast.showWithAction(
          context,
          l10n.medicineDoseActionSavedToast,
          l10n.medicineDoseUndoAction,
          // The undo action fires on a later user tap; the page may have
          // been popped in between, so guard before using the context
          // (deactivated context trips the `_dependents.isEmpty` assertion).
          () {
            if (!context.mounted) return;
            unawaited(undoMedicineDose(context, ref, request, dateStr));
          },
        ),
      );
    }
  } catch (error) {
    ref.read(talkerProvider).error('markMedicineDose: failed: $error');
    if (context.mounted) {
      unawaited(Toast.show(context, l10n.medicineDoseActionFailedToast));
    }
  }
}

/// 撤销一次打卡：把该日该槽位写回 planned。
Future<void> undoMedicineDose(
  BuildContext context,
  WidgetRef ref,
  MedicineDoseMarkRequest request,
  String dateStr,
) async {
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context)!;
  try {
    final result = await ref
        .read(cachedDoseLogDataSourceProvider)
        .mark(
          currentMedicineId: request.currentMedicineId,
          reminderId: request.reminderId,
          scheduledTime: request.scheduledTime,
          status: DoseLogStatus.planned.name,
          date: dateStr,
        )
        .run();
    result.fold((failure) => throw failure, (_) {});
    ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.doseLogs);
    if (context.mounted) {
      unawaited(Toast.show(context, l10n.medicineDoseUndoneToast));
    }
  } catch (error) {
    ref.read(talkerProvider).error('undoMedicineDose: failed: $error');
    if (context.mounted) {
      unawaited(Toast.show(context, l10n.medicineDoseActionFailedToast));
    }
  }
}
