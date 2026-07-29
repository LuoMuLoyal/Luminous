import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/entities/inputs.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Changes a record's date: updates the repository, emits a data change
/// notification, navigates to the new date, and shows a toast.
Future<void> changeRecordDate({
  required WidgetRef ref,
  required BuildContext context,
  required String recordId,
  required DateTime newDate,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final dateStr = formatRecordDate(newDate);

  try {
    await ref
        .read(dailyRecordRepositoryProvider)
        .update(recordId, DailyRecordUpdateInput(occurredAt: dateStr));

    ref.read(dataChangeBusProvider.notifier).emit(DataChangeTopic.dailyRecords);

    ref.read(selectedRecordDateProvider.notifier).setDate(newDate);

    if (!context.mounted) return;
    await Toast.show(context, l10n.recordDragDateChanged);
  } catch (e) {
    if (!context.mounted) return;
    await Toast.show(context, l10n.recordDragDateError);
  }
}
