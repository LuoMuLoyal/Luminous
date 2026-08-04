import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/logger/logger.dart';
import 'package:luminous/core/providers/data_change_bus.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
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

Future<void> handleMealQuickAction(
  BuildContext context,
  WidgetRef ref, {
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

  late final MealQuickEntryOutcome outcome;
  try {
    outcome = await flow.startWithCamera(
      MealQuickEntryContext(
        occurredAt: occurredAt,
        occurredTime: occurredTime,
        defaultTitle: defaultMealTitle(l10n, now),
      ),
    );
  } on MealQuickImageUnsupportedException {
    if (!context.mounted) return;
    await Toast.show(context, l10n.recordImageUnsupportedToast);
    return;
  } catch (e, st) {
    ref
        .read(talkerProvider)
        .error('handleMealQuickAction startWithCamera failed: $e', st);
    if (!context.mounted) return;
    await Toast.show(context, l10n.recordImagePickFailedToast);
    return;
  }

  if (!context.mounted || outcome.type == MealQuickEntryOutcomeType.cancelled) {
    return;
  }
  final draft = outcome.draft;
  if (draft == null) return;
  await showMealConfirmationDialog(context, flow: flow, draft: draft);
}

/// Long-press meal entry: manual no-photo meal recording (per the quick-entry
/// UX spec, long press is the manual fallback for the camera-first path).
Future<void> handleMealQuickActionManual(
  BuildContext context,
  WidgetRef ref, {
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
  final draft = flow.buildManualDraft(
    MealQuickEntryContext(
      occurredAt: occurredAt,
      occurredTime: occurredTime,
      defaultTitle: defaultMealTitle(l10n, now),
    ),
  );
  await showMealConfirmationDialog(context, flow: flow, draft: draft);
}

MealQuickEntryFlow _buildFlow(WidgetRef ref, DailyRecordRepository repository) {
  return MealQuickEntryFlow(
    pickImage: ref.read(mealQuickImagePickerProvider),
    uploadImage: repository.uploadImage,
    createRecord: repository.create,
    emitDataChange: (topic) =>
        ref.read(dataChangeBusProvider.notifier).emit(topic),
  );
}
