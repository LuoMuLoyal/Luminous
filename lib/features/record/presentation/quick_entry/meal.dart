import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/composition/record/record_access.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/instrumentation/data_change_bus.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/domain/services/hour_minute.dart';
import 'package:luminous/features/record/domain/services/meal_quick_entry.dart';
import 'package:luminous/features/record/domain/services/quick_entry.dart';
import 'package:luminous/features/record/presentation/quick_entry/meal_flow.dart';
import 'package:luminous/features/record/presentation/quick_entry/quick_entry_providers.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/meal_confirmation.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Opens the meal confirmation dialog for [draft].
Future<void> showMealConfirmationDialog(
  BuildContext context, {
  required MealQuickEntryFlow flow,
  required MealQuickEntryDraft draft,
}) async {
  await showAppDialog<void>(
    context: context,
    maxWidth: 460,
    // 确认卡片高度随内容增长:走 DialogShell 默认滚动,不再显式关掉。
    builder: (dialogContext) =>
        MealQuickConfirmationDialog(flow: flow, draft: draft),
  );
}

/// The default meal title for [now], resolved from its slot.
String mealTitleForSlot(AppLocalizations l10n, MealTitleSlot slot) {
  return switch (slot) {
    MealTitleSlot.breakfast => l10n.recordFastChoiceMealBreakfast,
    MealTitleSlot.lunch => l10n.recordFastChoiceMealLunch,
    MealTitleSlot.dinner => l10n.recordFastChoiceMealDinner,
    MealTitleSlot.snack => l10n.recordFastChoiceMealSnack,
  };
}

/// Camera-first (single tap) / manual (long press) meal quick entry.
///
/// Builds the draft through the application-layer [MealQuickEntryFlow] and owns
/// every UI effect: the auth dialog, the confirmation sheet and the toasts.
Future<void> handleMealQuickAction(
  BuildContext context,
  WidgetRef ref, {
  required MealQuickEntrySource source,
  required DateTime now,
  required DateTime occurredAt,
  required DateTime occurredTime,
  required bool canAccessProtectedData,
  required bool isAuthLoading,
}) async {
  if (!canAccessProtectedData) {
    if (isAuthLoading) return;
    await showAuthRequiredDialog(
      context,
      onLogin: () => context.push(loginRouteForCurrentLocation(context)),
    );
    return;
  }

  final l10n = AppLocalizations.of(context)!;
  final flow = _buildFlow(ref);
  final entryContext = MealQuickEntryContext(
    occurredAt: formatCalendarDateKey(occurredAt),
    occurredTime: formatClockHourMinute(occurredTime),
    defaultTitle: mealTitleForSlot(l10n, mealTitleSlotAt(now)),
  );

  // Null means "abort without confirming": the camera was cancelled or failed.
  final draft = switch (source) {
    MealQuickEntrySource.manual => flow.buildManualDraft(entryContext),
    MealQuickEntrySource.camera => await _pickCameraDraft(
      context,
      ref,
      flow,
      entryContext,
      l10n,
    ),
  };

  if (draft == null || !context.mounted) return;
  await showMealConfirmationDialog(context, flow: flow, draft: draft);
}

/// Runs the camera-first path and returns the draft to confirm, or null when
/// the user cancelled the picker / it failed (a toast is shown for the latter).
Future<MealQuickEntryDraft?> _pickCameraDraft(
  BuildContext context,
  WidgetRef ref,
  MealQuickEntryFlow flow,
  MealQuickEntryContext entryContext,
  AppLocalizations l10n,
) async {
  final MealQuickEntryOutcome outcome;
  try {
    outcome = await flow.startWithCamera(entryContext);
  } on MealQuickImageUnsupportedException {
    if (!context.mounted) return null;
    await Toast.show(context, l10n.recordImageUnsupportedToast);
    return null;
  } catch (e, st) {
    ref
        .read(talkerProvider)
        .error('handleMealQuickAction startWithCamera failed: $e', st);
    if (!context.mounted) return null;
    await Toast.show(context, l10n.recordImagePickFailedToast);
    return null;
  }

  if (outcome.type == MealQuickEntryOutcomeType.cancelled) return null;
  return outcome.draft;
}

MealQuickEntryFlow _buildFlow(WidgetRef ref) {
  final writer = ref.read(quickEntryDailyRecordWriterProvider);
  return MealQuickEntryFlow(
    pickImage: ref.read(mealQuickImagePickerProvider),
    uploadImage: writer.uploadImage,
    createRecord: writer.create,
    emitDataChange: ref.read(emitQuickEntryDataChangeProvider),
  );
}
