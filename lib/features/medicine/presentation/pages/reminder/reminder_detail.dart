import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/widgets/common/divider.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';
import 'package:luminous/features/medicine/presentation/providers/reminders.dart';
import 'package:luminous/features/medicine/presentation/routes.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/delete_dialog.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/loading.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/log_panels.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineReminderDetailPage extends ConsumerWidget {
  const MedicineReminderDetailPage({
    super.key,
    required this.currentMedicineId,
  });

  final String currentMedicineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    final Widget content;

    if (!session.canAccessProtectedData) {
      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              session.isLoading
                  ? const ReminderLoading()
                  : AuthRequiredDialogGate(
                      onLogin: () =>
                          context.push(loginRouteForCurrentLocation(context)),
                    ),
            ],
          ),
        ),
      );
    } else {
      final detail = ref.watch(
        medicineReminderDetailProvider(currentMedicineId),
      );

      final width = MediaQuery.sizeOf(context).width;
      content = ResponsiveContentFrame(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: width < Breakpoints.mobile
                ? Spacing.level6
                : Spacing.level7,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              detail.when(
                data: (data) => _ReminderDetailBody(data: data),
                loading: () => const ReminderLoading(),
                error: (error, _) {
                  final isNotFound =
                      error is StateError &&
                      error.message == 'Medicine not found.';
                  return StateErrorView(
                    title: isNotFound
                        ? l10n.medicineReminderNotFoundTitle
                        : l10n.medicineReminderGenericErrorTitle,
                    description: isNotFound
                        ? l10n.medicineReminderNotFoundDescription
                        : l10n.medicineReminderGenericErrorDescription,
                    icon: SemanticIcons.statusError,
                    actionLabel: l10n.todayRetryAction,
                    onAction: () => ref.invalidate(
                      medicineReminderDetailProvider(currentMedicineId),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    final actions = <Widget>[
      if (session.canAccessProtectedData)
        FButton(
          variant: FButtonVariant.ghost,
          onPress: () => MedicineReminderEditRoute(
            medicineId: currentMedicineId,
          ).push(context),
          child: Text(l10n.recordEditAction),
        ),
    ];

    return PageScaffold(
      title: l10n.medicineReminderDetailTitle,
      actions: actions,
      child: SingleChildScrollView(child: content),
    );
  }
}

class _ReminderDetailBody extends ConsumerWidget {
  const _ReminderDetailBody({required this.data});

  final MedicineReminderDetailData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;

    final reminders = [...data.reminders]..sort(compareReminderTime);
    final isActive = reminders.any((item) => item.isActive);
    final firstReminder = reminders.firstOrNull;
    final soundPreference =
        ref.watch(medicineReminderSoundProvider).asData?.value ??
        MedicineReminderSoundPreference.defaultTone;
    final hasNote = data.reminders.any(
      (item) => (item.note ?? '').trim().isNotEmpty,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.level4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Spacing.level4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.medicine.displayName,
                              style: TypographyToken.level5
                                  .body(context)
                                  .copyWith(fontWeight: FontWeight.w800),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: Spacing.level1),
                            Text(
                              medicineDoseText(l10n, data.medicine),
                              style: TypographyToken.level3
                                  .body(context)
                                  .copyWith(color: colors.mutedForeground),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Spacing.level3),
                      FBadge.raw(
                        builder: (context, style) {
                          final pillColor = isActive
                              ? SemanticColor.primary
                              : SemanticColor.neutral;
                          final foreground = pillColor.solid(context);
                          return DecoratedBox(
                            decoration: ShapeDecoration(
                              color: pillColor.muted(context),
                              shape: RoundedSuperellipseBorder(
                                borderRadius: BorderRadius.circular(
                                  RadiusTokens.level2,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.level2,
                                vertical: Spacing.level1,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isActive
                                        ? l10n.medicineReminderEnabledStatus
                                        : l10n.medicineReminderDisabledStatus,
                                    style: TypographyToken.level3
                                        .body(context)
                                        .copyWith(
                                          color: foreground,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const AppDivider(),
                // Active/inactive toggle — allows switching without entering edit page.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.level4,
                    vertical: Spacing.level3,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        SemanticIcons.dosePower,
                        color: isActive
                            ? SemanticColor.primary.solid(context)
                            : colors.mutedForeground,
                        size: Spacing.level5,
                      ),
                      const SizedBox(width: Spacing.level4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.medicineReminderToggleActiveLabel,
                              style: context.theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: Spacing.level1),
                            Text(
                              isActive
                                  ? l10n.medicineReminderEnabledStatus
                                  : l10n.medicineReminderDisabledStatus,
                              style: context.theme.typography.body.sm.copyWith(
                                color: colors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FSwitch(
                        value: isActive,
                        onChange: (value) => _toggleReminderActive(
                          ref,
                          context,
                          l10n,
                          reminders,
                          value,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.level4),
          FTileGroup(
            style: settingsSubpageTileGroupStyle(context.theme),
            physics: const NeverScrollableScrollPhysics(),
            divider: FItemDivider.full,
            children: [
              FTile(
                prefix: Icon(
                  SemanticIcons.doseRepeat,
                  color: colors.mutedForeground,
                  size: Spacing.level5,
                ),
                title: Text(l10n.medicineReminderFrequencyLabel),
                details: Text(
                  frequencyLabel(l10n, reminders),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.mutedForeground),
                ),
              ),
              FTile(
                prefix: Icon(
                  SemanticIcons.statusPending,
                  color: colors.mutedForeground,
                  size: Spacing.level5,
                ),
                title: Text(l10n.medicineReminderTimesLabel),
                details: Text(
                  reminders.isEmpty
                      ? l10n.medicineScheduleNotSet
                      : reminders.map((item) => item.timeLabel).join(' · '),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.mutedForeground),
                ),
              ),
              FTile(
                prefix: Icon(
                  SemanticIcons.medicineBottle,
                  color: colors.mutedForeground,
                  size: Spacing.level5,
                ),
                title: Text(l10n.medicineReminderDoseLabel),
                details: Text(
                  medicineDoseText(l10n, data.medicine),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.mutedForeground),
                ),
              ),
              FTile(
                prefix: Icon(
                  SemanticIcons.actionCalendar,
                  color: colors.mutedForeground,
                  size: Spacing.level5,
                ),
                title: Text(l10n.medicineReminderStartDateLabel),
                details: Text(
                  firstReminder?.startDate ?? l10n.medicineReminderDateNotSet,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.mutedForeground),
                ),
              ),
              FTile(
                prefix: Icon(
                  SemanticIcons.safetySchedulingConflict,
                  color: colors.mutedForeground,
                  size: Spacing.level5,
                ),
                title: Text(l10n.medicineReminderEndDateLabel),
                details: Text(
                  firstReminder?.endDate ?? l10n.medicineReminderDateNotSet,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.mutedForeground),
                ),
              ),
              FTile(
                prefix: Icon(
                  SemanticIcons.notificationBell,
                  color: colors.mutedForeground,
                  size: Spacing.level5,
                ),
                title: Text(l10n.medicineReminderMethodLabel),
                details: Text(
                  isActive
                      ? l10n.medicineReminderNotificationOn
                      : l10n.medicineReminderNotificationOff,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.mutedForeground),
                ),
              ),
              FTile(
                prefix: Icon(
                  SemanticIcons.actionMessage,
                  color: colors.mutedForeground,
                  size: Spacing.level5,
                ),
                title: Text(l10n.medicineReminderSmsLabel),
                details: Text(
                  l10n.medicineReminderSmsOff,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.mutedForeground),
                ),
              ),
              FTile(
                prefix: Icon(
                  SemanticIcons.doseVolume,
                  color: colors.mutedForeground,
                  size: Spacing.level5,
                ),
                title: Text(l10n.medicineReminderSoundLabel),
                details: Text(
                  soundPreferenceLabel(l10n, soundPreference),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.mutedForeground),
                ),
              ),
              if (hasNote)
                FTile(
                  prefix: Icon(
                    SemanticIcons.tabRecord,
                    color: colors.mutedForeground,
                    size: Spacing.level5,
                  ),
                  title: Text(l10n.medicineReminderNoteLabel),
                  details: Text(
                    data.reminders
                        .map((item) => item.note?.trim())
                        .whereType<String>()
                        .where((item) => item.isNotEmpty)
                        .first,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colors.mutedForeground),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Spacing.level4),
          ReminderTodayLogPanel(logs: data.todayLogs),
          const SizedBox(height: Spacing.level4),
          ReminderDeliveryLogPanel(logs: data.deliveryLogs),
          if (reminders.isNotEmpty) ...[
            const SizedBox(height: Spacing.level5),
            FButton(
              key: const Key('medicine-reminder-delete-button'),
              variant: FButtonVariant.destructive,
              onPress: () async {
                final confirmed = await showMedicineReminderDeleteDialog(
                  context,
                );
                if (confirmed != true) return;
                final deleted = await ref
                    .read(medicineReminderFormProvider.notifier)
                    .deleteGroup(reminders);
                if (deleted && context.mounted) {
                  unawaited(
                    Toast.show(context, l10n.medicineReminderDeletedToast),
                  );
                  context.pop();
                } else if (context.mounted) {
                  unawaited(
                    Toast.show(context, l10n.medicineReminderDeleteFailedToast),
                  );
                }
              },
              prefix: const Icon(SemanticIcons.actionDelete),
              child: Text(l10n.medicineReminderDeleteAction),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggleReminderActive(
    WidgetRef ref,
    BuildContext context,
    AppLocalizations l10n,
    List<MedicineReminderItem> reminders,
    bool newActive,
  ) async {
    if (reminders.isEmpty) return;
    final first = reminders.first;
    final input = MedicineReminderGroupWriteInput(
      currentMedicineId: first.currentMedicineId!,
      label: first.label,
      times: reminders
          .map(
            (r) => MedicineReminderTimeInput(
              hour: r.scheduledHour,
              minute: r.scheduledMinute,
            ),
          )
          .toList(),
      daysOfWeek: first.daysOfWeek,
      startDate: first.startDate,
      endDate: first.endDate,
      isActive: newActive,
      note: first.note,
    );
    final success = await ref
        .read(medicineReminderFormProvider.notifier)
        .saveGroup(existingReminders: reminders, input: input);
    if (context.mounted) {
      unawaited(
        Toast.show(
          context,
          success
              ? l10n.medicineReminderSavedToast
              : l10n.medicineReminderToggleFailedToast,
        ),
      );
    }
  }
}
