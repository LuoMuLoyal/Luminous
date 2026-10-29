import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/features/record/application/usecases/change_record_date.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/quick_entry/quick_entry_providers.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Moves a record to another day: updates the repository, refreshes the
/// dashboard, switches the selected day and toasts the result.
///
/// The write itself is [ChangeRecordDateUseCase] (application layer); the
/// selection + toasts are UI effects and stay here.
Future<void> changeRecordDate({
  required WidgetRef ref,
  required BuildContext context,
  required String recordId,
  required DateTime newDate,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final outcome = await ChangeRecordDateUseCase(
    repository: ref.read(quickEntryDailyRecordWriterProvider),
    emitDataChange: ref.read(emitQuickEntryDataChangeProvider),
  )(recordId: recordId, newDate: newDate);

  switch (outcome) {
    case ChangeRecordDateFailed():
      if (!context.mounted) return;
      await Toast.show(context, l10n.recordDragDateError);
    case ChangeRecordDateSucceeded(:final newDate):
      ref.read(selectedRecordDateProvider.notifier).setDate(newDate);
      if (!context.mounted) return;
      await Toast.show(context, l10n.recordDragDateChanged);
  }
}
