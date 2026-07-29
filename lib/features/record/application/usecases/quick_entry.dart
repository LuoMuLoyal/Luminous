import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/auth/session_provider.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_meal.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_medication.dart';
import 'package:luminous/features/record/application/usecases/quick_entry_sleep.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/data/quick_entry_preferences.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/presentation/providers/dashboard.dart';
import 'package:luminous/features/record/presentation/providers/time.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_context.dart';
import 'package:luminous/features/record/presentation/services/quick_entry_executor.dart';
import 'package:luminous/features/record/presentation/utils/date_time_formatters.dart';

/// Dispatches a quick entry action to the appropriate handler based on type.
///
/// For meal, sleep, and medication types, delegates to specialized use cases.
/// For all other types, uses the generic [QuickEntryExecutor].
Future<void> handleQuickAction(
  BuildContext context,
  WidgetRef ref,
  RecordQuickAction action,
) async {
  assert(!action.locked, 'Locked quick actions should be disabled by UI');

  final selectedDate = ref.read(selectedRecordDateProvider);
  final now = ref.read(currentRecordDateTimeProvider);
  final date = formatRecordDate(selectedDate);
  final currentTime = formatRecordTimeValue(now);
  final session = ref.read(authSessionProvider);
  final canAccessProtectedData = session.canAccessProtectedData;
  final isAuthLoading = session.isLoading;

  if (action.type == RecordEntryType.medication) {
    await handleMedicationQuickAction(
      context,
      ref,
      now: now,
      occurredAt: date,
      canAccessProtectedData: canAccessProtectedData,
      isAuthLoading: isAuthLoading,
    );
    return;
  }

  if (action.type == RecordEntryType.sleep) {
    await handleSleepQuickAction(
      context,
      ref,
      selectedDate: selectedDate,
      now: now,
      occurredAt: date,
      occurredTime: currentTime,
      canAccessProtectedData: canAccessProtectedData,
      isAuthLoading: isAuthLoading,
    );
    return;
  }

  if (action.type == RecordEntryType.meal) {
    await handleMealQuickAction(
      context,
      ref,
      now: now,
      occurredAt: date,
      occurredTime: currentTime,
      canAccessProtectedData: canAccessProtectedData,
      isAuthLoading: isAuthLoading,
    );
    return;
  }

  final prefs =
      ref.read(quickEntryPreferencesProvider).asData?.value ??
      const QuickEntryPreferences();

  await QuickEntryExecutor(
    createRecord: ref.read(dailyRecordRepositoryProvider).create,
    deleteDailyRecord: ref.read(dailyRecordRepositoryProvider).delete,
    emitDataChange: (topic) =>
        ref.read(dataChangeBusProvider.notifier).emit(topic),
    preferences: prefs,
  ).execute(
    QuickEntryExecutionContext(
      buildContext: context,
      action: action,
      selectedDate: selectedDate,
      now: now,
      occurredAt: date,
      occurredTime: currentTime,
      canAccessProtectedData: canAccessProtectedData,
      isAuthLoading: isAuthLoading,
    ),
  );
}
