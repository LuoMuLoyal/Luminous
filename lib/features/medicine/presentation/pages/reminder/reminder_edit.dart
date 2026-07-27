import 'dart:async';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/toast.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/utils/date_format_utils.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';
import 'package:luminous/features/medicine/presentation/providers/reminders.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/delete_dialog.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/form_body.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/loading.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineReminderEditPage extends HookConsumerWidget {
  const MedicineReminderEditPage({
    super.key,
    this.currentMedicineId,
    this.initialMedicineId,
  });

  final String? currentMedicineId;
  final String? initialMedicineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final formState = ref.watch(medicineReminderFormProvider);
    final soundPreference =
        ref.watch(medicineReminderSoundProvider).asData?.value ??
        MedicineReminderSoundPreference.defaultTone;

    final isEdit = currentMedicineId != null;

    final noteController = useTextEditingController();
    final selectedWeekdays = useState(<int>{});
    final times = useState(<MedicineReminderTimeInput>[]);
    final frequency = useState(ReminderFrequency.daily);
    final selectedMedicineId = useState<String?>(null);
    final startDate = useState<DateTime?>(null);
    final endDate = useState<DateTime?>(null);
    final isActive = useState(true);
    final prefilled = useState(false);

    ref.listen<MedicineReminderFormState>(medicineReminderFormProvider, (
      previous,
      next,
    ) {
      if (next.deleted && previous?.deleted != true) {
        Toast.show(context, l10n.medicineReminderDeletedToast);
        if (context.mounted) context.pop();
      } else if (next.saved && previous?.saved != true) {
        Toast.show(context, l10n.medicineReminderSavedToast);
        if (context.mounted) context.pop();
      }
      final error = next.errorMessage;
      if (error != null && error != previous?.errorMessage) {
        Toast.show(context, l10n.medicineReminderSaveFailedToast);
      }
    });

    void applyReminderState(List<MedicineReminderItem> existing) {
      if (existing.isNotEmpty) {
        isActive.value = existing.any((item) => item.isActive);
        startDate.value = parseDateOnly(existing.first.startDate);
        endDate.value = parseDateOnly(existing.first.endDate);
        noteController.text = existing.first.note ?? '';
        times.value = existing
            .map(
              (item) => MedicineReminderTimeInput(
                hour: item.scheduledHour,
                minute: item.scheduledMinute,
              ),
            )
            .toList();
        final days = existing.first.daysOfWeek;
        if (days == null) {
          frequency.value = ReminderFrequency.daily;
          selectedWeekdays.value = <int>{};
        } else {
          frequency.value = days.length == 1
              ? ReminderFrequency.weekly
              : ReminderFrequency.custom;
          selectedWeekdays.value = days.toSet();
        }
      } else {
        isActive.value = true;
        startDate.value = dateOnly(clock.now());
        endDate.value = null;
        frequency.value = ReminderFrequency.daily;
        selectedWeekdays.value = <int>{};
        times.value = const [
          MedicineReminderTimeInput(hour: 8, minute: 0),
          MedicineReminderTimeInput(hour: 20, minute: 0),
        ];
      }
    }

    void tryPrefill(
      HealthContextSnapshot snapshot,
      List<MedicineReminderItem> reminders,
    ) {
      if (prefilled.value) return;

      final activeMedicines = snapshot.currentMedicines
          .where((item) => item.isCurrent)
          .toList(growable: false);
      if (activeMedicines.isEmpty) {
        prefilled.value = true;
        return;
      }

      // Auto-select first medicine when none specified so the form (with
      // FSelect) renders directly instead of a dead-end "go search" prompt.
      final theId =
          currentMedicineId ?? initialMedicineId ?? activeMedicines.first.id;
      final medicine = activeMedicines
          .where((item) => item.id == theId)
          .firstOrNull;
      selectedMedicineId.value = medicine?.id ?? activeMedicines.first.id;

      final existing = remindersFor(reminders, selectedMedicineId.value!);
      applyReminderState(existing);
      prefilled.value = true;
    }

    Future<DateTime?> showForuiDatePicker(
      BuildContext context, {
      required DateTime initial,
      required DateTime first,
      required DateTime last,
    }) => showFDialog<DateTime?>(
      context: context,
      builder: (dialogContext, style, animation) => DialogShell(
        maxWidth: LayoutScaleResolver.dialogMaxWidthFor(
          MediaQuery.sizeOf(context).width,
        ),
        padding: const EdgeInsets.all(Spacing.level4),
        builder: (_) => SizedBox(
          height: 360,
          child: FCalendar.grid(
            control: FGridCalendarControl(start: first, end: last),
            selectionControl: FDateSelectionControl.liftedSingle(
              value: dateOnly(initial),
              onChange: (date) => Navigator.of(dialogContext).pop(date),
              toggleable: false,
            ),
          ),
        ),
      ),
    );

    Future<void> pickStartDate() async {
      final now = dateOnly(clock.now());
      final picked = await showForuiDatePicker(
        context,
        initial: startDate.value ?? now,
        first: DateTime(now.year - 5),
        last: DateTime(now.year + 10, 12, 31),
      );
      if (picked == null) return;
      final next = dateOnly(picked);
      startDate.value = next;
      final end = endDate.value;
      if (end != null && end.isBefore(next)) {
        endDate.value = null;
      }
    }

    Future<void> pickEndDate() async {
      final now = dateOnly(clock.now());
      final first = startDate.value ?? DateTime(now.year - 5);
      final picked = await showForuiDatePicker(
        context,
        initial: endDate.value ?? startDate.value ?? now,
        first: first,
        last: DateTime(now.year + 10, 12, 31),
      );
      if (picked == null) return;
      endDate.value = dateOnly(picked);
    }

    Future<void> addTime() async {
      final latest = times.value.isEmpty ? null : times.value.last;
      final initial = FTime(latest?.hour ?? 8, latest?.minute ?? 0);
      final picked = await showAppDialog<FTime?>(
        context: context,
        scrollable: false,
        builder: (_) => _ReminderTimePickerDialog(initial: initial),
      );
      if (picked == null) return;
      final isDuplicate = times.value.any(
        (t) => t.hour == picked.hour && t.minute == picked.minute,
      );
      if (isDuplicate) {
        if (!context.mounted) return;
        unawaited(Toast.show(context, l10n.medicineReminderDuplicateTimeToast));
        return;
      }
      final updated = [
        ...times.value,
        MedicineReminderTimeInput(hour: picked.hour, minute: picked.minute),
      ];
      updated.sort((left, right) {
        final hour = left.hour.compareTo(right.hour);
        if (hour != 0) return hour;
        return left.minute.compareTo(right.minute);
      });
      times.value = updated;
    }

    void onSave(
      HealthContextSnapshot? snapshot,
      List<MedicineReminderItem>? reminders,
    ) {
      if (snapshot == null || reminders == null) return;

      final medId = selectedMedicineId.value;
      final medIdError = RequiredInput.validate(
        medId,
        l10n.medicineReminderMedicineRequiredToast,
      );
      if (medIdError != null) {
        Toast.show(context, medIdError);
        return;
      }
      final effectiveMedId = medId!;

      if (times.value.isEmpty) {
        Toast.show(context, l10n.medicineReminderTimeRequiredToast);
        return;
      }

      final medicine = snapshot.currentMedicines
          .where((item) => item.id == effectiveMedId)
          .firstOrNull;
      if (medicine == null) {
        Toast.show(context, l10n.medicineReminderMedicineRequiredToast);
        return;
      }

      final daysOfWeek = frequency.value == ReminderFrequency.daily
          ? null
          : (selectedWeekdays.value.toList()..sort());
      if (frequency.value != ReminderFrequency.daily &&
          (daysOfWeek?.isEmpty ?? true)) {
        Toast.show(context, l10n.medicineReminderWeekdayRequiredToast);
        return;
      }

      final start = startDate.value;
      final end2 = endDate.value;
      if (start != null && end2 != null && end2.isBefore(start)) {
        Toast.show(context, l10n.medicineReminderDateRangeInvalidToast);
        return;
      }

      ref
          .read(medicineReminderFormProvider.notifier)
          .saveGroup(
            existingReminders: remindersFor(reminders, effectiveMedId),
            input: MedicineReminderGroupWriteInput(
              currentMedicineId: effectiveMedId,
              label: medicine.displayName,
              times: times.value,
              daysOfWeek: daysOfWeek,
              startDate: formatDateInput(startDate.value),
              endDate: formatDateInput(endDate.value),
              isActive: isActive.value,
              note: trimmedOrNull(noteController.text),
            ),
          );
    }

    Future<void> confirmDelete(List<MedicineReminderItem> reminders) async {
      final medId = selectedMedicineId.value;
      if (medId == null) return;
      final existing = remindersFor(reminders, medId);
      if (existing.isEmpty) {
        if (context.mounted) context.pop();
        return;
      }
      final confirmed = await showMedicineReminderDeleteDialog(context);
      if (confirmed != true) return;
      unawaited(
        ref.read(medicineReminderFormProvider.notifier).deleteGroup(existing),
      );
    }

    final Widget content;
    final List<Widget> actions;

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
      actions = const [];
    } else {
      final snapshot = ref.watch(healthContextSnapshotProvider);
      final reminders = ref.watch(medicineReminderListProvider);

      snapshot.whenOrNull(
        data: (data) =>
            reminders.whenOrNull(data: (items) => tryPrefill(data, items)),
      );

      final isLoading =
          snapshot.isLoading || reminders.isLoading || !prefilled.value;
      final hasError = snapshot.hasError || reminders.hasError;

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
              if (hasError)
                StateErrorView(
                  title: l10n.medicineReminderNotFoundTitle,
                  description: l10n.medicineReminderNotFoundDescription,
                  icon: FLucideIcons.circleAlert,
                  actionLabel: l10n.todayRetryAction,
                  onAction: () {
                    ref.invalidate(healthContextSnapshotProvider);
                    ref.invalidate(medicineReminderListProvider);
                  },
                )
              else if (isLoading)
                const ReminderLoading()
              else if (!isEdit && selectedMedicineId.value == null)
                _MedicineSelectorPrompt(
                  onSelect: () => context.push(Routes.medicineSearch),
                )
              else
                Builder(
                  builder: (ctx) {
                    final snapshotData = snapshot.requireValue;
                    final reminderItems = reminders.requireValue;

                    return ReminderFormBody(
                      snapshot: snapshotData,
                      reminders: reminderItems,
                      selectedMedicineId: selectedMedicineId.value,
                      frequency: frequency.value,
                      selectedWeekdays: selectedWeekdays.value,
                      times: times.value,
                      startDate: startDate.value,
                      endDate: endDate.value,
                      isActive: isActive.value,
                      soundPreference: soundPreference,
                      noteController: noteController,
                      isSaving: formState.isSaving,
                      isEdit: isEdit,
                      onMedicineChanged: isEdit
                          ? null
                          : (value) {
                              if (value == null) return;
                              selectedMedicineId.value = value;
                              applyReminderState(
                                remindersFor(reminderItems, value),
                              );
                            },
                      onFrequencyChanged: (value) {
                        final hadWeekdays = selectedWeekdays.value.isNotEmpty;
                        frequency.value = value;
                        if (value == ReminderFrequency.daily) {
                          selectedWeekdays.value = <int>{};
                          if (hadWeekdays) {
                            Toast.show(
                              context,
                              l10n.medicineReminderFrequencyDailyClearedWeekdays,
                            );
                          }
                        } else if (selectedWeekdays.value.isEmpty) {
                          selectedWeekdays.value = {clock.now().weekday % 7};
                        }
                      },
                      onWeekdayToggled: (day) {
                        final updated = selectedWeekdays.value.toSet();
                        if (updated.contains(day)) {
                          updated.remove(day);
                        } else {
                          updated.add(day);
                        }
                        selectedWeekdays.value = updated;
                        if (updated.isEmpty) {
                          frequency.value = ReminderFrequency.daily;
                        }
                      },
                      onAddTime: addTime,
                      onRemoveTime: (index) {
                        if (times.value.length > 1) {
                          final updated = [...times.value];
                          updated.removeAt(index);
                          times.value = updated;
                        }
                      },
                      onStartDateTap: pickStartDate,
                      onEndDateTap: pickEndDate,
                      onClearEndDate: endDate.value == null
                          ? null
                          : () => endDate.value = null,
                      onActiveChanged: (value) => isActive.value = value,
                      onSoundChanged: (value) => ref
                          .read(medicineReminderSoundProvider.notifier)
                          .setSound(value),
                      onSave: () => onSave(snapshotData, reminderItems),
                      onDelete: isEdit
                          ? () => confirmDelete(reminderItems)
                          : null,
                    );
                  },
                ),
            ],
          ),
        ),
      );

      // Save button lives at the bottom of the form body (with saving state).
      // No duplicate in the top bar.
      actions = const [];
    }

    final title = isEdit
        ? l10n.medicineReminderEditTitle
        : l10n.medicineReminderNewTitle;

    return PageScaffold(
      title: title,
      actions: actions,
      child: SingleChildScrollView(child: content),
    );
  }
}

class _MedicineSelectorPrompt extends StatelessWidget {
  const _MedicineSelectorPrompt({required this.onSelect});

  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.level4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.medicineReminderSelectMedicineHint,
              style: TypographyToken.level4.body(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.level4),
            FButton(
              onPress: onSelect,
              child: Text(l10n.medicineReminderSelectMedicineAction),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centered dialog for picking a reminder time.
///
/// Shows a title, live preview of the selected time, the
/// [FTimePicker] wheel, and explicit cancel/confirm action buttons.
class _ReminderTimePickerDialog extends HookWidget {
  const _ReminderTimePickerDialog({required this.initial});

  /// The time pre-selected when the dialog opens.
  final FTime initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;
    final locale = Localizations.localeOf(context);

    final timeController = useMemoized(
      () => FTimePickerController(time: initial),
    );
    useEffect(() => timeController.dispose, [timeController]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title row with close button
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.medicineReminderTimePickerTitle,
                style: typography.body.xl2.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FButton.icon(
              onPress: () => Navigator.of(context).pop(),
              variant: FButtonVariant.ghost,
              child: const Icon(FLucideIcons.x),
            ),
          ],
        ),
        const SizedBox(height: Spacing.level2),

        // Live preview of the currently selected time
        ValueListenableBuilder<FTime>(
          valueListenable: timeController,
          builder: (context, time, _) {
            return Text(
              formatTimeOfDay(
                TimeOfDay(hour: time.hour, minute: time.minute),
                locale,
              ),
              style: typography.body.xl3.copyWith(
                fontWeight: FontWeight.w800,
                color: context.theme.colors.primary,
              ),
            );
          },
        ),
        const SizedBox(height: Spacing.level4),

        // Time picker wheel
        SizedBox(
          height: 200,
          child: FTimePicker(
            control: FTimePickerControl.managed(controller: timeController),
          ),
        ),
        const SizedBox(height: Spacing.level4),

        // Cancel + Confirm action buttons
        Row(
          children: [
            Expanded(
              child: FButton(
                onPress: () => Navigator.of(context).pop(),
                variant: FButtonVariant.outline,
                child: Text(l10n.commonCancel),
              ),
            ),
            const SizedBox(width: Spacing.level3),
            Expanded(
              child: FButton(
                onPress: () => Navigator.of(context).pop(timeController.value),
                child: Text(l10n.commonConfirm),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
