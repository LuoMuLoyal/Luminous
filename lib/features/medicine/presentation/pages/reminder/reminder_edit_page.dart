import 'dart:async';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/app/router.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/forms/validators.dart';
import 'package:luminous/core/widgets/common/dialog_shell.dart';
import 'package:luminous/core/widgets/common/state_views.dart';
import 'package:luminous/core/widgets/layout/responsive_content_frame.dart';
import 'package:luminous/features/auth/presentation/providers/session/session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/shared/required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/presentation/providers/reminders.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/reminder_delete_dialog.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/reminder_form_body.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/reminder_loading.dart';
import 'package:luminous/core/widgets/layout/page_scaffold.dart';
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
        AppToast.show(context, l10n.medicineReminderDeletedToast);
        if (context.mounted) context.pop();
      } else if (next.saved && previous?.saved != true) {
        AppToast.show(context, l10n.medicineReminderSavedToast);
        if (context.mounted) context.pop();
      }
      final error = next.errorMessage;
      if (error != null && error != previous?.errorMessage) {
        AppToast.show(context, '${l10n.settingsSyncFailed}: $error');
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

      if (currentMedicineId == null && initialMedicineId == null) {
        prefilled.value = true;
        return;
      }

      final activeMedicines = snapshot.currentMedicines
          .where((item) => item.isCurrent)
          .toList(growable: false);
      if (activeMedicines.isEmpty) {
        prefilled.value = true;
        return;
      }

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
      builder: (dialogContext, style, animation) => AppDialogShell(
        maxWidth: LayoutScaleResolver.dialogMaxWidth,
        padding: const EdgeInsets.all(Spacing.level4),
        builder: (_) => SizedBox(
          height: 360,
          child: FCalendar.grid(
            control: FGridCalendarControl(start: first, end: last),
            selectionControl: FDateSelectionControl.lifted(
              selected: (date) => dateOnly(date) == dateOnly(initial),
              select: (date) => Navigator.of(dialogContext).pop(dateOnly(date)),
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
      final timeController = FTimePickerController(
        time: FTime(latest?.hour ?? 8, latest?.minute ?? 0),
      );
      final picked = await showFSheet<FTime?>(
        context: context,
        side: FLayout.btt,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.level4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 240,
                  child: FTimePicker(
                    control: FTimePickerControl.managed(
                      controller: timeController,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.level4),
                FButton(
                  onPress: () =>
                      Navigator.of(sheetContext).pop(timeController.value),
                  child: Text(MaterialLocalizations.of(context).okButtonLabel),
                ),
              ],
            ),
          ),
        ),
      );
      timeController.dispose();
      if (picked == null) return;
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
        AppToast.show(context, medIdError);
        return;
      }
      final effectiveMedId = medId!;

      if (times.value.isEmpty) {
        AppToast.show(context, l10n.medicineReminderTimeRequiredToast);
        return;
      }

      final medicine = snapshot.currentMedicines
          .where((item) => item.id == effectiveMedId)
          .firstOrNull;
      if (medicine == null) {
        AppToast.show(context, l10n.medicineReminderMedicineRequiredToast);
        return;
      }

      final daysOfWeek = frequency.value == ReminderFrequency.daily
          ? null
          : (selectedWeekdays.value.toList()..sort());
      if (frequency.value != ReminderFrequency.daily &&
          (daysOfWeek?.isEmpty ?? true)) {
        AppToast.show(context, l10n.medicineReminderWeekdayRequiredToast);
        return;
      }

      final start = startDate.value;
      final end2 = endDate.value;
      if (start != null && end2 != null && end2.isBefore(start)) {
        AppToast.show(context, l10n.medicineReminderDateRangeInvalidToast);
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
            vertical: width < Breakpoints.mobile ? 24 : 32,
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
            vertical: width < Breakpoints.mobile ? 24 : 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasError)
                AppStateErrorView(
                  title: l10n.medicineReminderNotFoundTitle,
                  description: '',
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
                  onSelect: () => context.push(AppRoutes.medicineSearch),
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
                        frequency.value = value;
                        if (value == ReminderFrequency.daily) {
                          selectedWeekdays.value = <int>{};
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

      actions = [
        FButton(
          variant: FButtonVariant.ghost,
          onPress: formState.isSaving || isLoading
              ? null
              : () => onSave(snapshot.asData?.value, reminders.asData?.value),
          child: Text(l10n.mineEditSaveAction),
        ),
      ];
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

    return FCard.raw(
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
