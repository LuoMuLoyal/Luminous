import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/log_level.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/auth/required_dialog.dart';
import 'package:luminous/core/widgets/common/dialog/dialog_shell.dart';
import 'package:luminous/features/record/data/providers/record_access.dart';
import 'package:luminous/features/record/domain/repositories/daily.dart';
import 'package:luminous/features/record/presentation/quick_entry/meal_flow.dart';
import 'package:luminous/features/record/presentation/widgets/dialogs/meal_confirmation.dart';
import 'package:luminous/l10n/app_localizations.dart';

String defaultMealTitle(AppLocalizations l10n, DateTime now) {
  final hour = now.hour;
  if (hour < 10) return l10n.recordFastChoiceMealBreakfast;
  if (hour < 15) return l10n.recordFastChoiceMealLunch;
  if (hour < 21) return l10n.recordFastChoiceMealDinner;
  return l10n.recordFastChoiceMealSnack;
}

Future<void> showMealConfirmationDialog(
  BuildContext context, {
  required MealQuickEntryFlow flow,
  required MealQuickEntryDraft draft,
}) async {
  await showAppDialog<void>(
    context: context,
    maxWidth: 460,
    scrollable: false,
    builder: (dialogContext) =>
        MealQuickConfirmationDialog(flow: flow, draft: draft),
  );
}

/// Which quick-entry gesture asked for the meal confirmation dialog.
enum MealQuickEntrySource {
  /// Single tap: open the camera first; a cancelled camera writes nothing.
  camera,

  /// Long press: manual no-photo meal entry (per the quick-entry UX spec, long
  /// press is the manual fallback for the camera-first path).
  manual,
}

Future<void> handleMealQuickAction(
  BuildContext context,
  WidgetRef ref, {
  required MealQuickEntrySource source,
  required DateTime now,
  required String occurredAt,
  required String occurredTime,
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
  final repository = ref.read(dailyRecordRepositoryProvider);
  final flow = _buildFlow(ref, repository);
  final entryContext = MealQuickEntryContext(
    occurredAt: occurredAt,
    occurredTime: occurredTime,
    defaultTitle: defaultMealTitle(l10n, now),
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

MealQuickEntryFlow _buildFlow(WidgetRef ref, DailyRecordRepository repository) {
  return MealQuickEntryFlow(
    pickImage: ref.read(mealQuickImagePickerProvider),
    uploadImage: (input) async => (await repository.uploadImage(input).run())
        .fold((failure) => throw failure, (attachment) => attachment),
    createRecord: (input) async => (await repository.create(input).run()).fold(
      (failure) => throw failure,
      (item) => item,
    ),
    emitDataChange: (topic) =>
        ref.read(dataChangeBusProvider.notifier).emit(topic),
  );
}
