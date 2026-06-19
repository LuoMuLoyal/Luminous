import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_reminder_providers.dart';
import 'package:luminous/features/medicine/presentation/utils/medicine_reminder_formatters.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/medicine_reminder_delete_sheet.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/medicine_reminder_form_body.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/reminder_loading.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
import 'package:luminous/l10n/app_localizations.dart';

class MedicineReminderEditPage extends ConsumerStatefulWidget {
  const MedicineReminderEditPage({
    super.key,
    this.currentMedicineId,
    this.initialMedicineId,
  });

  final String? currentMedicineId;
  final String? initialMedicineId;

  @override
  ConsumerState<MedicineReminderEditPage> createState() =>
      _MedicineReminderEditPageState();
}

class _MedicineReminderEditPageState
    extends ConsumerState<MedicineReminderEditPage> {
  final _noteController = TextEditingController();
  final _selectedWeekdays = <int>{};
  final _times = <MedicineReminderTimeInput>[];

  ReminderFrequency _frequency = ReminderFrequency.daily;
  String? _selectedMedicineId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isActive = true;
  bool _prefilled = false;

  bool get _isEdit => widget.currentMedicineId != null;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);
    final formState = ref.watch(medicineReminderFormProvider);
    final soundPreference =
        ref.watch(medicineReminderSoundProvider).asData?.value ??
        MedicineReminderSoundPreference.defaultTone;

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

    if (!session.canAccessProtectedData) {
      return PageScaffoldShell(
        title: _isEdit
            ? l10n.medicineReminderEditTitle
            : l10n.medicineReminderNewTitle,
        centerTitle: true,
        leading: const SettingsBackButton(),
        children: [
          session.isLoading
              ? const ReminderLoading()
              : AuthRequiredDialogGate(
                  onLogin: () =>
                      context.push(loginRouteForCurrentLocation(context)),
                ),
        ],
      );
    }

    final snapshot = ref.watch(healthContextSnapshotProvider);
    final reminders = ref.watch(medicineReminderListProvider);

    snapshot.whenOrNull(
      data: (data) =>
          reminders.whenOrNull(data: (items) => _tryPrefill(data, items)),
    );

    final isLoading = snapshot.isLoading || reminders.isLoading || !_prefilled;
    final hasError = snapshot.hasError || reminders.hasError;
    final title = _isEdit
        ? l10n.medicineReminderEditTitle
        : l10n.medicineReminderNewTitle;

    return PageScaffoldShell(
      title: title,
      centerTitle: true,
      leading: const SettingsBackButton(),
      actions: [
        TextButton(
          onPressed: formState.isSaving || isLoading
              ? null
              : () => _onSave(snapshot.asData?.value, reminders.asData?.value),
          child: Text(l10n.mineEditSaveAction),
        ),
      ],
      children: [
        if (hasError)
          AppStateErrorView(
            title: l10n.medicineReminderNotFoundTitle,
            description: '',
            icon: Icons.error_outline_rounded,
            actionLabel: l10n.todayRetryAction,
            onAction: () {
              ref.invalidate(healthContextSnapshotProvider);
              ref.invalidate(medicineReminderListProvider);
            },
          )
        else if (isLoading)
          const ReminderLoading()
        else
          Builder(
            builder: (context) {
              final snapshotData = snapshot.requireValue;
              final reminderItems = reminders.requireValue;

              return ReminderFormBody(
                snapshot: snapshotData,
                reminders: reminderItems,
                selectedMedicineId: _selectedMedicineId,
                frequency: _frequency,
                selectedWeekdays: _selectedWeekdays,
                times: _times,
                startDate: _startDate,
                endDate: _endDate,
                isActive: _isActive,
                soundPreference: soundPreference,
                noteController: _noteController,
                isSaving: formState.isSaving,
                isEdit: _isEdit,
                onMedicineChanged: _isEdit
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _selectedMedicineId = value;
                          _applyReminderState(
                            remindersFor(reminderItems, value),
                          );
                        });
                      },
                onFrequencyChanged: (value) => setState(() {
                  _frequency = value;
                  if (value == ReminderFrequency.daily) {
                    _selectedWeekdays.clear();
                  } else if (_selectedWeekdays.isEmpty) {
                    _selectedWeekdays.add(DateTime.now().weekday % 7);
                  }
                }),
                onWeekdayToggled: (day) => setState(() {
                  if (_selectedWeekdays.contains(day)) {
                    _selectedWeekdays.remove(day);
                  } else {
                    _selectedWeekdays.add(day);
                  }
                  if (_selectedWeekdays.isEmpty) {
                    _frequency = ReminderFrequency.daily;
                  }
                }),
                onAddTime: _addTime,
                onRemoveTime: (index) => setState(() {
                  if (_times.length > 1) {
                    _times.removeAt(index);
                  }
                }),
                onStartDateTap: _pickStartDate,
                onEndDateTap: _pickEndDate,
                onClearEndDate: _endDate == null
                    ? null
                    : () => setState(() => _endDate = null),
                onActiveChanged: (value) => setState(() => _isActive = value),
                onSoundChanged: (value) => ref
                    .read(medicineReminderSoundProvider.notifier)
                    .setSound(value),
                onSave: () => _onSave(snapshotData, reminderItems),
                onDelete:
                    _isEdit ? () => _confirmDelete(reminderItems) : null,
              );
            },
          ),
      ],
    );
  }

  void _tryPrefill(
    HealthContextSnapshot snapshot,
    List<MedicineReminderItem> reminders,
  ) {
    if (_prefilled) return;

    final activeMedicines = snapshot.currentMedicines
        .where((item) => item.isCurrent)
        .toList(growable: false);
    if (activeMedicines.isEmpty) {
      _prefilled = true;
      return;
    }

    final selectedId =
        widget.currentMedicineId ??
        widget.initialMedicineId ??
        activeMedicines.first.id;
    final medicine = activeMedicines
        .where((item) => item.id == selectedId)
        .firstOrNull;
    _selectedMedicineId = medicine?.id ?? activeMedicines.first.id;

    final existing = remindersFor(reminders, _selectedMedicineId!);
    _applyReminderState(existing);
    _prefilled = true;
  }

  void _applyReminderState(List<MedicineReminderItem> existing) {
    if (existing.isNotEmpty) {
      _isActive = existing.any((item) => item.isActive);
      _startDate = parseDateOnly(existing.first.startDate);
      _endDate = parseDateOnly(existing.first.endDate);
      _noteController.text = existing.first.note ?? '';
      _times
        ..clear()
        ..addAll(
          existing.map(
            (item) => MedicineReminderTimeInput(
              hour: item.scheduledHour,
              minute: item.scheduledMinute,
            ),
          ),
        );
      final days = existing.first.daysOfWeek;
      if (days == null) {
        _frequency = ReminderFrequency.daily;
        _selectedWeekdays.clear();
      } else {
        _frequency = days.length == 1
            ? ReminderFrequency.weekly
            : ReminderFrequency.custom;
        _selectedWeekdays
          ..clear()
          ..addAll(days);
      }
    } else {
      _isActive = true;
      _startDate = dateOnly(DateTime.now());
      _endDate = null;
      _frequency = ReminderFrequency.daily;
      _selectedWeekdays.clear();
      _times
        ..clear()
        ..addAll(const [
          MedicineReminderTimeInput(hour: 8, minute: 0),
          MedicineReminderTimeInput(hour: 20, minute: 0),
        ]);
    }
  }

  Future<void> _pickStartDate() async {
    final now = dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (picked == null) return;
    final next = dateOnly(picked);
    setState(() {
      _startDate = next;
      if (_endDate != null && _endDate!.isBefore(next)) {
        _endDate = null;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final now = dateOnly(DateTime.now());
    final firstDate = _startDate ?? DateTime(now.year - 5);
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? now,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (picked == null) return;
    setState(() => _endDate = dateOnly(picked));
  }

  Future<void> _addTime() async {
    final latest = _times.isEmpty ? null : _times.last;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: latest?.hour ?? 8,
        minute: latest?.minute ?? 0,
      ),
    );
    if (picked == null) return;
    setState(() {
      _times.add(MedicineReminderTimeInput.fromTimeOfDay(picked));
      _times.sort((left, right) {
        final hour = left.hour.compareTo(right.hour);
        if (hour != 0) return hour;
        return left.minute.compareTo(right.minute);
      });
    });
  }

  void _onSave(
    HealthContextSnapshot? snapshot,
    List<MedicineReminderItem>? reminders,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final medicineId = _selectedMedicineId;
    if (snapshot == null || reminders == null || medicineId == null) {
      AppToast.show(context, l10n.medicineReminderMedicineRequiredToast);
      return;
    }
    if (_times.isEmpty) {
      AppToast.show(context, l10n.medicineReminderTimeRequiredToast);
      return;
    }

    final medicine = snapshot.currentMedicines
        .where((item) => item.id == medicineId)
        .firstOrNull;
    if (medicine == null) {
      AppToast.show(context, l10n.medicineReminderMedicineRequiredToast);
      return;
    }

    final daysOfWeek = _frequency == ReminderFrequency.daily
        ? null
        : (_selectedWeekdays.toList()..sort());
    if (_frequency != ReminderFrequency.daily && daysOfWeek!.isEmpty) {
      AppToast.show(context, l10n.medicineReminderWeekdayRequiredToast);
      return;
    }
    if (_startDate != null &&
        _endDate != null &&
        _endDate!.isBefore(_startDate!)) {
      AppToast.show(context, l10n.medicineReminderDateRangeInvalidToast);
      return;
    }

    ref
        .read(medicineReminderFormProvider.notifier)
        .saveGroup(
          existingReminders: remindersFor(reminders, medicineId),
          input: MedicineReminderGroupWriteInput(
            currentMedicineId: medicineId,
            label: medicine.displayName,
            times: _times,
            daysOfWeek: daysOfWeek,
            startDate: formatDateInput(_startDate),
            endDate: formatDateInput(_endDate),
            isActive: _isActive,
            note: trimmedOrNull(_noteController.text),
          ),
        );
  }

  Future<void> _confirmDelete(List<MedicineReminderItem> reminders) async {
    final medicineId = _selectedMedicineId;
    if (medicineId == null) return;
    final existing = remindersFor(reminders, medicineId);
    if (existing.isEmpty) {
      if (mounted) context.pop();
      return;
    }
    final confirmed = await showMedicineReminderDeleteSheet(context);
    if (confirmed != true) return;
    ref.read(medicineReminderFormProvider.notifier).deleteGroup(existing);
  }
}
