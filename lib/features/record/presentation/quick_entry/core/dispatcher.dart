import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/record/domain/constants/symptom_catalog.dart';
import 'package:luminous/features/record/domain/entities/dashboard.dart';
import 'package:luminous/features/record/domain/services/quick_entry.dart';
import 'package:luminous/features/record/presentation/providers/data_access.dart';
import 'package:luminous/features/record/presentation/quick_entry/core/execution_context.dart';
import 'package:luminous/features/record/presentation/quick_entry/core/executor.dart';
import 'package:luminous/features/record/presentation/quick_entry/core/quick_entry_providers.dart';
import 'package:luminous/features/record/presentation/quick_entry/core/tap_decision.dart';
import 'package:luminous/features/record/presentation/quick_entry/meal.dart';
import 'package:luminous/features/record/presentation/quick_entry/medication.dart';
import 'package:luminous/features/record/presentation/quick_entry/sleep.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/quick_type_settings_dialog.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Dispatches a quick entry action to the appropriate handler based on type.
///
/// For meal, sleep, and medication types, delegates to their presentation
/// flows. For all other types, uses the generic [QuickEntryExecutor].
Future<void> handleQuickAction(
  BuildContext context,
  WidgetRef ref,
  RecordQuickAction action,
) async {
  assert(!action.locked, 'Locked quick actions should be disabled by UI');

  final decision = RecordQuickEntryDecision.read(ref);

  if (action.type == RecordEntryType.medication) {
    await handleMedicationQuickAction(
      context,
      ref,
      now: decision.now,
      occurredAt: decision.selectedDate,
      canAccessProtectedData: decision.canAccessProtectedData,
      isAuthLoading: decision.isAuthLoading,
    );
    return;
  }

  if (action.type == RecordEntryType.sleep) {
    await handleSleepQuickEntry(
      context,
      ref,
      selectedDate: decision.selectedDate,
      canAccessProtectedData: decision.canAccessProtectedData,
      isAuthLoading: decision.isAuthLoading,
    );
    return;
  }

  if (action.type == RecordEntryType.meal) {
    await handleMealQuickAction(
      context,
      ref,
      source: MealQuickEntrySource.camera,
      now: decision.now,
      occurredAt: decision.selectedDate,
      occurredTime: decision.now,
      canAccessProtectedData: decision.canAccessProtectedData,
      isAuthLoading: decision.isAuthLoading,
    );
    return;
  }

  final prefs =
      ref.read(quickEntryPreferencesProvider).asData?.value ??
      const QuickEntryPreferences();

  await QuickEntryExecutor(
    createRecord: ref.read(createDailyRecordProvider),
    deleteDailyRecord: ref.read(deleteDailyRecordProvider),
    emitDataChange: ref.read(emitQuickEntryDataChangeProvider),
    preferences: prefs,
    loadSymptomCatalog: () =>
        ref.read(symptomCatalogProvider).asData?.value ??
        const <SymptomCatalogEntry>[],
    onUndoFailed: (error, stackTrace) => ref
        .read(talkerProvider)
        .error('quick entry failed: $error', stackTrace),
  ).execute(
    QuickEntryExecutionContext(
      buildContext: context,
      action: action,
      selectedDate: decision.selectedDate,
      now: decision.now,
      canAccessProtectedData: decision.canAccessProtectedData,
      isAuthLoading: decision.isAuthLoading,
    ),
  );
}

/// Dispatches a quick-entry **long press** to the type-specific
/// "more/settings" surface (per the quick-entry UX spec).
///
/// - meal: manual no-photo meal entry dialog;
/// - water: water default amount / badge settings dialog;
/// - medication / symptom / mood / sleep: the type's current rule dialog.
Future<void> handleQuickActionLongPress(
  BuildContext context,
  WidgetRef ref,
  RecordQuickAction action,
) async {
  assert(!action.locked, 'Locked quick actions should be disabled by UI');

  final decision = RecordQuickEntryDecision.read(ref);

  if (action.type == RecordEntryType.meal) {
    await handleMealQuickAction(
      context,
      ref,
      source: MealQuickEntrySource.manual,
      now: decision.now,
      occurredAt: decision.selectedDate,
      occurredTime: decision.now,
      canAccessProtectedData: decision.canAccessProtectedData,
      isAuthLoading: decision.isAuthLoading,
    );
    return;
  }

  final l10n = AppLocalizations.of(context)!;
  await showAppDialog<void>(
    context: context,
    maxWidth: LayoutScaleResolver.dialogStandardMaxWidth,
    // 设置项高度随字号增长:走 DialogShell 默认滚动,不再显式关掉。
    builder: (dialogContext) =>
        QuickEntryTypeSettingsDialog(action: action, l10n: l10n),
  );
}
