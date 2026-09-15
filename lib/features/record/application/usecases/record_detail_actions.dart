import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/presentation/routes.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/features/record/presentation/utils/detail_labels.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Navigates to the record edit page for [recordId], showing an
/// auth-required dialog if the user is not signed in.
void editRecord(BuildContext context, String recordId) {
  unawaited(
    pushAuthRequiredRoute(context, RecordEditRoute(id: recordId).location),
  );
}

/// Deletes a daily record after user confirmation.
///
/// Shows a confirmation dialog, calls the repository, invalidates
/// the detail provider, emits a [DataChangeTopic.dailyRecords] event,
/// shows a toast, and pops [popCount] times.
Future<void> deleteRecord({
  required WidgetRef ref,
  required BuildContext context,
  required String recordId,
  required int popCount,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await _showDeleteConfirmDialog(context, l10n);
  if (confirmed != true) return;

  try {
    final result = await ref
        .read(dailyRecordRepositoryProvider)
        .delete(recordId)
        .run();
    result.fold((failure) => throw failure, (_) {});
    ref.invalidate(dailyRecordDetailProvider(recordId));
    ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.dailyRecords);
    if (!context.mounted) return;
    await Toast.show(context, l10n.recordDeletedToast);
    if (context.mounted) {
      for (var i = 0; i < popCount; i++) {
        context.pop();
      }
    }
  } catch (e) {
    ref.read(talkerProvider).error('deleteRecord: failed: $e');
    if (context.mounted) {
      await Toast.show(context, l10n.recordDeleteFailedToast);
    }
  }
}

Future<bool?> _showDeleteConfirmDialog(
  BuildContext context,
  AppLocalizations l10n,
) {
  return showAppDialog<bool>(
    context: context,
    scrollable: false,
    builder: (dialogContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recordDeleteConfirmTitle,
          style: dialogContext.theme.dialogStyle.titleTextStyle,
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.recordDeleteConfirmMessage,
          style: dialogContext.theme.dialogStyle.bodyTextStyle,
        ),
        const SizedBox(height: Spacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FButton(
              variant: FButtonVariant.ghost,
              onPress: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.authCancelAction),
            ),
            const SizedBox(width: Spacing.md),
            FButton(
              key: const Key('record-delete-confirm-action'),
              variant: FButtonVariant.destructive,
              onPress: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.recordDeleteAction),
            ),
          ],
        ),
      ],
    ),
  );
}

/// 重新分析一条失败/想重跑的餐食记录。
///
/// 服务端把「patch 里恰好带一张图片」当作一次新的分析请求(sourceRevision 递增后
/// 重新入队),所以重试不需要专门的端点:把记录已有的那张图原样提交即可。
/// 成功后就地刷新详情并广播 [DataChangeTopic.dailyRecords];失败只提示,不改状态。
Future<void> retryMealAnalysis({
  required WidgetRef ref,
  required BuildContext context,
  required DailyRecordItem record,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final attachments = record.attachments
      .where((item) => item.kind == DailyRecordAttachmentKind.image)
      .map(
        (item) => DailyRecordAttachmentInput(
          objectKey: item.objectKey,
          bucket: item.bucket,
          provider: item.provider,
          fileName: item.fileName,
          contentType: item.contentType,
          sizeBytes: item.sizeBytes,
          width: item.width,
          height: item.height,
          publicUrl: item.publicUrl,
        ),
      )
      .toList(growable: false);

  // 没有可重跑的图片时服务端不会入队,直接给失败提示而不是假装成功。
  if (attachments.length != 1) {
    await Toast.show(context, l10n.recordMealAnalysisRetryFailedToast);
    return;
  }

  try {
    final result = await ref
        .read(dailyRecordRepositoryProvider)
        .update(record.id, DailyRecordUpdateInput(attachments: attachments))
        .run();
    result.fold((failure) => throw failure, (_) {});
    ref.invalidate(dailyRecordDetailProvider(record.id));
    ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.dailyRecords);
    if (!context.mounted) return;
    await Toast.show(context, l10n.recordMealAnalysisRetryingToast);
  } catch (e, st) {
    ref.read(talkerProvider).error('retryMealAnalysis: failed: $e', st);
    if (!context.mounted) return;
    await Toast.show(context, l10n.recordMealAnalysisRetryFailedToast);
  }
}

/// Copies a compact text summary of [record] to the clipboard and shows a
/// confirmation toast.
Future<void> copyRecordSummary(
  BuildContext context,
  AppLocalizations l10n,
  DailyRecordItem record,
) async {
  final lines = <String>[
    '${l10n.recordCreateFieldKind}：${kindLabel(l10n, record.kind)}',
    if (nonEmpty(record.value) != null)
      '${l10n.recordDetailValueLabel}：${valueWithUnit(record.value!, record.unit)}',
    if (moodLabel(l10n, record) != null)
      '${l10n.recordDetailMoodLabel}：${moodLabel(l10n, record)}',
    if (nonEmpty(record.note) != null)
      '${l10n.recordCreateFieldNote}：${record.note}',
    if (nonEmpty(record.source) != null)
      '${l10n.recordDetailSourceLabel}：${sourceLabel(l10n, record.source!)}',
    '${l10n.recordDetailUpdatedAtLabel}：${formatRecordDateTimeLabel(record.updatedAt)}',
  ];
  await Clipboard.setData(ClipboardData(text: lines.join('\n')));
  if (context.mounted) {
    await Toast.show(context, l10n.recordDetailCopiedToast);
  }
}
