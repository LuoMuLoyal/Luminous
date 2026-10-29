import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/composition/record/record_access.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/instrumentation/data_change_bus.dart';
import 'package:luminous/core/utils/record_time_format.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/domain/entities/record.dart';
import 'package:luminous/features/record/domain/services/quick_entry.dart';
import 'package:luminous/features/record/domain/undo/quick_entry_undo.dart';
import 'package:luminous/features/record/presentation/routes.dart';
import 'package:luminous/features/record/presentation/utils/detail_labels.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Outcome of [DeleteRecordUseCase.call].
sealed class DeleteRecordOutcome {
  const DeleteRecordOutcome();
}

/// The record was deleted.
final class DeleteRecordSucceeded extends DeleteRecordOutcome {
  const DeleteRecordSucceeded();
}

/// The delete failed; the caller surfaces a "delete failed" toast.
final class DeleteRecordFailed extends DeleteRecordOutcome {
  const DeleteRecordFailed(this.error);

  final Object error;
}

/// Deletes one daily record and broadcasts the change.
///
/// Confirmation dialogs, toasts and popping the page are presentation concerns;
/// this use case only removes the record.
class DeleteRecordUseCase {
  const DeleteRecordUseCase({
    required this.repository,
    required this.emitDataChange,
  });

  final DailyRecordWriter repository;
  final EmitDataChangeTopic emitDataChange;

  Future<DeleteRecordOutcome> call(String recordId) async {
    try {
      await repository.delete(recordId);
    } catch (error) {
      return DeleteRecordFailed(error);
    }
    emitDataChange(QuickEntryDataChange.dailyRecords);
    return const DeleteRecordSucceeded();
  }
}

/// Outcome of [RetryMealAnalysisUseCase.call].
sealed class RetryMealAnalysisOutcome {
  const RetryMealAnalysisOutcome();
}

/// The retry request was accepted (the server re-queued the analysis).
final class RetryMealAnalysisQueued extends RetryMealAnalysisOutcome {
  const RetryMealAnalysisQueued();
}

/// The record has no single image to re-analyze, so the server would not
/// re-queue anything — reported instead of pretending it worked.
final class RetryMealAnalysisNoImage extends RetryMealAnalysisOutcome {
  const RetryMealAnalysisNoImage();
}

/// The update failed; the caller surfaces a retry-failed toast.
final class RetryMealAnalysisFailed extends RetryMealAnalysisOutcome {
  const RetryMealAnalysisFailed(this.error);

  final Object error;
}

/// Re-runs AI analysis for a failed / stale meal record.
///
/// The server treats "a patch carrying exactly one image" as a new analysis
/// request (sourceRevision bumps and the job is re-queued), so re-submitting the
/// record's existing image is the whole retry — no dedicated endpoint.
class RetryMealAnalysisUseCase {
  const RetryMealAnalysisUseCase({
    required this.repository,
    required this.emitDataChange,
  });

  final DailyRecordWriter repository;
  final EmitDataChangeTopic emitDataChange;

  Future<RetryMealAnalysisOutcome> call(DailyRecordItem record) async {
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

    // Without exactly one image the server does not re-queue; report that
    // instead of faking success.
    if (attachments.length != 1) {
      return const RetryMealAnalysisNoImage();
    }

    try {
      await repository.update(
        record.id,
        DailyRecordUpdateInput(attachments: attachments),
      );
    } catch (error) {
      return RetryMealAnalysisFailed(error);
    }
    emitDataChange(QuickEntryDataChange.dailyRecords);
    return const RetryMealAnalysisQueued();
  }
}