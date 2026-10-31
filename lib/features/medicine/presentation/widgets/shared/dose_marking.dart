import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/channel.dart';
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
    // toast 的 action 在**之后**的某次点击才执行。那时 `mark` 拿到的这个
    // context 所属的 widget 很可能已经重建（行状态从 planned 变成 taken，
    // 整行被替换），`context.mounted` 就是 false——撤销按钮会静默失效。
    // 所以闭包只捕获 provider 容器（与 widget 生命周期无关），context 仅在
    // 此刻用来弹 toast。
    if (context.mounted) {
      final container = ProviderScope.containerOf(context, listen: false);
      unawaited(
        Toast.showWithAction(
          context,
          l10n.medicineDoseActionSavedToast,
          l10n.medicineDoseUndoAction,
          () => unawaited(_undoMarkedDose(container, request, dateStr)),
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
///
/// 由 toast 的 action 在稍后的点击里调用，那时 UI 上下文可能已经失效，所以
/// 只依赖 [ProviderContainer]，不碰 `BuildContext` 与 `WidgetRef`。
Future<void> _undoMarkedDose(
  ProviderContainer container,
  MedicineDoseMarkRequest request,
  String dateStr,
) async {
  try {
    final result = container
        .read(cachedDoseLogDataSourceProvider)
        .mark(
          currentMedicineId: request.currentMedicineId,
          reminderId: request.reminderId,
          scheduledTime: request.scheduledTime,
          status: DoseLogStatus.planned.name,
          date: dateStr,
        )
        .run();
    await unwrapFailure(result);
    container
        .read(dataChangeBusProvider.notifier)
        .emit(DataChangeTopic.doseLogs);
  } catch (error) {
    container.read(talkerProvider).error('undoMedicineDose: failed: $error');
  }
}
