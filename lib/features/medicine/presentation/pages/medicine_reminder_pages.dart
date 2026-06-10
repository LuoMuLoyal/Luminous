import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_required_dialog.dart';
import 'package:luminous/features/health_context/data/providers/health_context_data_providers.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/dose_log_remote_data_source.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_reminder_providers.dart';
import 'package:luminous/features/medicine/presentation/widgets/medicine_workspace_parts.dart';
import 'package:luminous/features/settings/presentation/widgets/settings_components.dart';
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

    if (!session.canAccessProtectedData) {
      return PageScaffoldShell(
        title: l10n.medicineReminderDetailTitle,
        centerTitle: true,
        leading: const SettingsBackButton(),
        children: [
          session.isLoading
              ? const _ReminderLoading()
              : AuthRequiredDialogGate(
                  onLogin: () =>
                      context.push(loginRouteForCurrentLocation(context)),
                ),
        ],
      );
    }

    final detail = ref.watch(medicineReminderDetailProvider(currentMedicineId));

    return PageScaffoldShell(
      title: l10n.medicineReminderDetailTitle,
      centerTitle: true,
      leading: const SettingsBackButton(),
      actions: [
        TextButton(
          onPressed: () => context.push(
            '/medicine/reminders/${Uri.encodeComponent(currentMedicineId)}/edit',
          ),
          child: Text(l10n.recordEditAction),
        ),
      ],
      children: [
        detail.when(
          data: (data) => _ReminderDetailBody(data: data),
          loading: () => const _ReminderLoading(),
          error: (_, __) => AppStateErrorView(
            title: l10n.medicineReminderNotFoundTitle,
            description: '',
            icon: Icons.error_outline_rounded,
            actionLabel: l10n.todayRetryAction,
            onAction: () => ref.invalidate(
              medicineReminderDetailProvider(currentMedicineId),
            ),
          ),
        ),
      ],
    );
  }
}

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

  _ReminderFrequency _frequency = _ReminderFrequency.daily;
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
              ? const _ReminderLoading()
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
          const _ReminderLoading()
        else
          Builder(
            builder: (context) {
              final snapshotData = snapshot.requireValue;
              final reminderItems = reminders.requireValue;

              return _ReminderFormBody(
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
                            _remindersFor(reminderItems, value),
                          );
                        });
                      },
                onFrequencyChanged: (value) => setState(() {
                  _frequency = value;
                  if (value == _ReminderFrequency.daily) {
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
                    _frequency = _ReminderFrequency.daily;
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
                onDelete: _isEdit ? () => _confirmDelete(reminderItems) : null,
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

    final existing = _remindersFor(reminders, _selectedMedicineId!);
    _applyReminderState(existing);
    _prefilled = true;
  }

  void _applyReminderState(List<MedicineReminderItem> existing) {
    if (existing.isNotEmpty) {
      _isActive = existing.any((item) => item.isActive);
      _startDate = _parseDateOnly(existing.first.startDate);
      _endDate = _parseDateOnly(existing.first.endDate);
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
        _frequency = _ReminderFrequency.daily;
        _selectedWeekdays.clear();
      } else {
        _frequency = days.length == 1
            ? _ReminderFrequency.weekly
            : _ReminderFrequency.custom;
        _selectedWeekdays
          ..clear()
          ..addAll(days);
      }
    } else {
      _isActive = true;
      _startDate = _dateOnly(DateTime.now());
      _endDate = null;
      _frequency = _ReminderFrequency.daily;
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
    final now = _dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (picked == null) return;
    final next = _dateOnly(picked);
    setState(() {
      _startDate = next;
      if (_endDate != null && _endDate!.isBefore(next)) {
        _endDate = null;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final now = _dateOnly(DateTime.now());
    final firstDate = _startDate ?? DateTime(now.year - 5);
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? now,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (picked == null) return;
    setState(() => _endDate = _dateOnly(picked));
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

    final daysOfWeek = _frequency == _ReminderFrequency.daily
        ? null
        : (_selectedWeekdays.toList()..sort());
    if (_frequency != _ReminderFrequency.daily && daysOfWeek!.isEmpty) {
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
          existingReminders: _remindersFor(reminders, medicineId),
          input: MedicineReminderGroupWriteInput(
            currentMedicineId: medicineId,
            label: medicine.displayName,
            times: _times,
            daysOfWeek: daysOfWeek,
            startDate: _formatDateInput(_startDate),
            endDate: _formatDateInput(_endDate),
            isActive: _isActive,
            note: _trimmedOrNull(_noteController.text),
          ),
        );
  }

  Future<void> _confirmDelete(List<MedicineReminderItem> reminders) async {
    final medicineId = _selectedMedicineId;
    if (medicineId == null) return;
    final existing = _remindersFor(reminders, medicineId);
    if (existing.isEmpty) {
      if (mounted) context.pop();
      return;
    }
    final confirmed = await showMedicineReminderDeleteSheet(context);
    if (confirmed != true) return;
    ref.read(medicineReminderFormProvider.notifier).deleteGroup(existing);
  }
}

class _ReminderDetailBody extends ConsumerWidget {
  const _ReminderDetailBody({required this.data});

  final MedicineReminderDetailData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final reminders = [...data.reminders]..sort(_compareReminderTime);
    final isActive = reminders.any((item) => item.isActive);
    final firstReminder = reminders.firstOrNull;
    final soundPreference =
        ref.watch(medicineReminderSoundProvider).asData?.value ??
        MedicineReminderSoundPreference.defaultTone;
    final methodValue =
        '${isActive ? l10n.medicineReminderNotificationOn : l10n.medicineReminderNotificationOff} · ${l10n.medicineReminderSmsOff} · ${_soundPreferenceLabel(l10n, soundPreference)}';
    final hasNote = data.reminders.any(
      (item) => (item.note ?? '').trim().isNotEmpty,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MedicinePanel(
            color: Color.alphaBlend(
              MedicinePalette.tealSoft.withValues(alpha: 0.38),
              surface.canvas,
            ),
            borderColor: MedicinePalette.teal.withValues(alpha: 0.14),
            shadow: const <BoxShadow>[],
            child: Row(
              children: [
                const MedicineIconBadge(
                  icon: Icons.medication_rounded,
                  color: MedicinePalette.orangeDeep,
                  backgroundColor: AppColorTokens.warningSoft,
                  shape: BoxShape.circle,
                  size: AppSpacingTokens.x4l,
                  iconSize: AppSpacingTokens.xl,
                ),
                const SizedBox(width: AppSpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.medicine.displayName,
                        style: typography.bodyLg.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacingTokens.xxs),
                      Text(
                        _medicineDoseText(l10n, data.medicine),
                        style: typography.bodySm.copyWith(
                          color: surface.body,
                          letterSpacing: 0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                MedicineStatusPill(
                  label: isActive
                      ? l10n.medicineReminderEnabledStatus
                      : l10n.medicineReminderDisabledStatus,
                  color: isActive ? MedicinePalette.teal : surface.mute,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          MedicinePanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ReminderInfoRow(
                  icon: Icons.repeat_rounded,
                  label: l10n.medicineReminderFrequencyLabel,
                  value: _frequencyLabel(l10n, reminders),
                  typography: typography,
                  surface: surface,
                  showDivider: true,
                ),
                _ReminderInfoRow(
                  icon: Icons.schedule_rounded,
                  label: l10n.medicineReminderTimesLabel,
                  value: reminders.isEmpty
                      ? l10n.medicineScheduleNotSet
                      : reminders.map((item) => item.timeLabel).join(' · '),
                  typography: typography,
                  surface: surface,
                  showDivider: true,
                ),
                _ReminderInfoRow(
                  icon: Icons.medication_liquid_outlined,
                  label: l10n.medicineReminderDoseLabel,
                  value: _medicineDoseText(l10n, data.medicine),
                  typography: typography,
                  surface: surface,
                  showDivider: true,
                ),
                _ReminderInfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: l10n.medicineReminderStartDateLabel,
                  value:
                      firstReminder?.startDate ??
                      l10n.medicineReminderDateNotSet,
                  typography: typography,
                  surface: surface,
                  showDivider: true,
                ),
                _ReminderInfoRow(
                  icon: Icons.event_busy_rounded,
                  label: l10n.medicineReminderEndDateLabel,
                  value:
                      firstReminder?.endDate ?? l10n.medicineReminderDateNotSet,
                  typography: typography,
                  surface: surface,
                  showDivider: true,
                ),
                _ReminderInfoRow(
                  icon: Icons.notifications_none_rounded,
                  label: l10n.medicineReminderMethodLabel,
                  value: methodValue,
                  typography: typography,
                  surface: surface,
                  showDivider: hasNote,
                ),
                if (hasNote)
                  _ReminderInfoRow(
                    icon: Icons.notes_rounded,
                    label: l10n.medicineReminderNoteLabel,
                    value: data.reminders
                        .map((item) => item.note?.trim())
                        .whereType<String>()
                        .where((item) => item.isNotEmpty)
                        .first,
                    typography: typography,
                    surface: surface,
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          _ReminderTodayLogPanel(
            logs: data.todayLogs,
            typography: typography,
            surface: surface,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          _ReminderDeliveryLogPanel(
            logs: data.deliveryLogs,
            typography: typography,
            surface: surface,
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          FilledButton.icon(
            key: const Key('medicine-reminder-delete-button'),
            style: FilledButton.styleFrom(
              backgroundColor: MedicinePalette.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadiusTokens.md),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacingTokens.md,
              ),
            ),
            onPressed: reminders.isEmpty
                ? null
                : () async {
                    final confirmed = await showMedicineReminderDeleteSheet(
                      context,
                    );
                    if (confirmed != true) return;
                    final deleted = await ref
                        .read(medicineReminderFormProvider.notifier)
                        .deleteGroup(reminders);
                    if (deleted && context.mounted) {
                      AppToast.show(context, l10n.medicineReminderDeletedToast);
                      context.pop();
                    } else if (context.mounted) {
                      AppToast.show(context, l10n.settingsSyncFailed);
                    }
                  },
            icon: const Icon(Icons.delete_outline_rounded),
            label: Text(l10n.medicineReminderDeleteAction),
          ),
        ],
      ),
    );
  }
}

class _ReminderFormBody extends StatelessWidget {
  const _ReminderFormBody({
    required this.snapshot,
    required this.reminders,
    required this.selectedMedicineId,
    required this.frequency,
    required this.selectedWeekdays,
    required this.times,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.soundPreference,
    required this.noteController,
    required this.isSaving,
    required this.isEdit,
    required this.onMedicineChanged,
    required this.onFrequencyChanged,
    required this.onWeekdayToggled,
    required this.onAddTime,
    required this.onRemoveTime,
    required this.onStartDateTap,
    required this.onEndDateTap,
    required this.onClearEndDate,
    required this.onActiveChanged,
    required this.onSoundChanged,
    required this.onSave,
    required this.onDelete,
  });

  final HealthContextSnapshot snapshot;
  final List<MedicineReminderItem> reminders;
  final String? selectedMedicineId;
  final _ReminderFrequency frequency;
  final Set<int> selectedWeekdays;
  final List<MedicineReminderTimeInput> times;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final MedicineReminderSoundPreference soundPreference;
  final TextEditingController noteController;
  final bool isSaving;
  final bool isEdit;
  final ValueChanged<String?>? onMedicineChanged;
  final ValueChanged<_ReminderFrequency> onFrequencyChanged;
  final ValueChanged<int> onWeekdayToggled;
  final VoidCallback onAddTime;
  final ValueChanged<int> onRemoveTime;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final VoidCallback? onClearEndDate;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<MedicineReminderSoundPreference> onSoundChanged;
  final VoidCallback onSave;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);
    final medicines = snapshot.currentMedicines
        .where((item) => item.isCurrent)
        .toList(growable: false);
    final selectedMedicine = medicines
        .where((item) => item.id == selectedMedicineId)
        .firstOrNull;

    if (medicines.isEmpty) {
      return AppStateErrorView(
        title: l10n.medicineNoMedicineTitle,
        description: l10n.medicineNoMedicineBody,
        icon: Icons.medication_outlined,
        actionLabel: l10n.medicineQuickAddTitle,
        onAction: () => context.push('/medicine/search'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MedicinePanel(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacingTokens.md,
                    AppSpacingTokens.md,
                    AppSpacingTokens.md,
                    AppSpacingTokens.sm,
                  ),
                  child: Text(
                    l10n.medicineReminderMedicineSectionTitle,
                    style: typography.bodyMdStrong.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Divider(height: 1, thickness: 1, color: surface.hairline),
                if (isEdit && selectedMedicine != null)
                  _SelectedMedicineRow(
                    medicine: selectedMedicine,
                    typography: typography,
                    surface: surface,
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacingTokens.md,
                      vertical: AppSpacingTokens.sm,
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedMedicineId,
                      decoration: InputDecoration(
                        labelText: l10n.medicineReminderMedicineLabel,
                      ),
                      items: medicines
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.displayName),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: onMedicineChanged,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          MedicinePanel(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacingTokens.md,
                    AppSpacingTokens.md,
                    AppSpacingTokens.md,
                    AppSpacingTokens.xs,
                  ),
                  child: Text(
                    l10n.medicineReminderSettingsSectionTitle,
                    style: typography.bodyMdStrong.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.md,
                    vertical: AppSpacingTokens.sm,
                  ),
                  child: _FrequencySegments(
                    frequency: frequency,
                    onChanged: onFrequencyChanged,
                  ),
                ),
                if (frequency != _ReminderFrequency.daily) ...[
                  Divider(height: 1, thickness: 1, color: surface.hairline),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacingTokens.md,
                      vertical: AppSpacingTokens.sm,
                    ),
                    child: _WeekdayPicker(
                      selectedWeekdays: selectedWeekdays,
                      onToggled: onWeekdayToggled,
                    ),
                  ),
                ],
                Divider(height: 1, thickness: 1, color: surface.hairline),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.md,
                    vertical: AppSpacingTokens.sm,
                  ),
                  child: _TimePickerRow(
                    times: times,
                    onAddTime: onAddTime,
                    onRemoveTime: onRemoveTime,
                  ),
                ),
                Divider(height: 1, thickness: 1, color: surface.hairline),
                _ValueActionRow(
                  icon: Icons.calendar_today_rounded,
                  title: l10n.medicineReminderStartDateLabel,
                  value: _dateLabel(l10n, startDate),
                  onTap: onStartDateTap,
                  typography: typography,
                  surface: surface,
                ),
                Divider(height: 1, thickness: 1, color: surface.hairline),
                _ValueActionRow(
                  icon: Icons.event_busy_rounded,
                  title: l10n.medicineReminderEndDateLabel,
                  value: _dateLabel(l10n, endDate),
                  onTap: onEndDateTap,
                  onClear: onClearEndDate,
                  typography: typography,
                  surface: surface,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          MedicinePanel(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacingTokens.md,
                    AppSpacingTokens.md,
                    AppSpacingTokens.md,
                    AppSpacingTokens.xs,
                  ),
                  child: Text(
                    l10n.medicineReminderMethodLabel,
                    style: typography.bodyMdStrong.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
                _SwitchRow(
                  title: l10n.medicineReminderNotificationOn,
                  subtitle: l10n.medicineReminderDeviceLocalHint,
                  value: isActive,
                  onChanged: onActiveChanged,
                  typography: typography,
                  surface: surface,
                ),
                Divider(height: 1, thickness: 1, color: surface.hairline),
                _UnavailableMethodRow(
                  icon: Icons.sms_outlined,
                  title: l10n.medicineReminderSmsLabel,
                  subtitle: l10n.medicineReminderSmsUnavailableHint,
                  status: l10n.medicineReminderUnavailableStatus,
                  typography: typography,
                  surface: surface,
                ),
                Divider(height: 1, thickness: 1, color: surface.hairline),
                _SoundPreferenceRow(
                  value: soundPreference,
                  onChanged: onSoundChanged,
                  typography: typography,
                  surface: surface,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          MedicinePanel(
            padding: const EdgeInsets.all(AppSpacingTokens.md),
            child: TextField(
              controller: noteController,
              maxLength: 100,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.medicineReminderNoteOptionalLabel,
                hintText: l10n.medicineReminderNoteHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          FilledButton(
            key: const Key('medicine-reminder-save-button'),
            onPressed: isSaving ? null : onSave,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadiusTokens.md),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacingTokens.md,
              ),
            ),
            child: Text(l10n.mineEditSaveAction),
          ),
          if (onDelete != null) ...[
            const SizedBox(height: AppSpacingTokens.sm),
            FilledButton.icon(
              key: const Key('medicine-reminder-form-delete-button'),
              onPressed: isSaving ? null : onDelete,
              style: FilledButton.styleFrom(
                backgroundColor: MedicinePalette.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadiusTokens.md),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacingTokens.md,
                ),
              ),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(l10n.medicineReminderDeleteAction),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReminderInfoRow extends StatelessWidget {
  const _ReminderInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.typography,
    required this.surface,
    this.showDivider = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: surface.body, size: AppSpacingTokens.lg),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Text(
              label,
              style: typography.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: typography.bodySm.copyWith(
                color: surface.body,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );

    if (!showDivider) return row;
    return Column(
      children: [
        row,
        Divider(
          height: 1,
          thickness: 1,
          indent:
              AppSpacingTokens.md + AppSpacingTokens.lg + AppSpacingTokens.md,
          color: surface.hairline,
        ),
      ],
    );
  }
}

class _ValueActionRow extends StatelessWidget {
  const _ValueActionRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    required this.typography,
    required this.surface,
    this.onClear,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacingTokens.md,
            vertical: AppSpacingTokens.sm,
          ),
          child: Row(
            children: [
              Icon(icon, color: surface.body, size: AppSpacingTokens.lg),
              const SizedBox(width: AppSpacingTokens.md),
              Expanded(
                child: Text(
                  title,
                  style: typography.bodyMdStrong.copyWith(letterSpacing: 0),
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: typography.bodySm.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(width: AppSpacingTokens.xs),
                IconButton(
                  tooltip: AppLocalizations.of(
                    context,
                  )!.medicineReminderClearDateAction,
                  visualDensity: VisualDensity.compact,
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ] else ...[
                const SizedBox(width: AppSpacingTokens.xs),
                Icon(
                  Icons.chevron_right_rounded,
                  color: surface.mute,
                  size: AppSpacingTokens.lg,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UnavailableMethodRow extends StatelessWidget {
  const _UnavailableMethodRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.typography,
    required this.surface,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          Icon(icon, color: surface.body, size: AppSpacingTokens.lg),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.bodyMdStrong.copyWith(letterSpacing: 0),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  subtitle,
                  style: typography.bodySm.copyWith(
                    color: surface.mute,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          MedicineStatusPill(label: status, color: surface.mute),
        ],
      ),
    );
  }
}

class _SoundPreferenceRow extends StatelessWidget {
  const _SoundPreferenceRow({
    required this.value,
    required this.onChanged,
    required this.typography,
    required this.surface,
  });

  final MedicineReminderSoundPreference value;
  final ValueChanged<MedicineReminderSoundPreference> onChanged;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.volume_up_outlined,
            color: surface.body,
            size: AppSpacingTokens.lg,
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicineReminderSoundLabel,
                  style: typography.bodyMdStrong.copyWith(letterSpacing: 0),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  l10n.medicineReminderSoundLocalHint,
                  style: typography.bodySm.copyWith(
                    color: surface.mute,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          DropdownButtonHideUnderline(
            child: DropdownButton<MedicineReminderSoundPreference>(
              value: value,
              onChanged: (next) {
                if (next != null) onChanged(next);
              },
              items: MedicineReminderSoundPreference.values
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(_soundPreferenceLabel(l10n, item)),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderTodayLogPanel extends StatelessWidget {
  const _ReminderTodayLogPanel({
    required this.logs,
    required this.typography,
    required this.surface,
  });

  final List<DoseLogItem> logs;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visibleLogs = logs.isEmpty
        ? <DoseLogItem>[]
        : logs.take(3).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacingTokens.xs),
          child: Text(
            l10n.medicineReminderTodayLogsTitle,
            style: typography.bodyMdStrong.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        MedicinePanel(
          padding: EdgeInsets.zero,
          child: visibleLogs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.pending_actions_rounded,
                        color: surface.mute,
                        size: AppSpacingTokens.lg,
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      Expanded(
                        child: Text(
                          l10n.medicineReminderNoTodayLogs,
                          style: typography.bodySm.copyWith(
                            color: surface.body,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (var index = 0; index < visibleLogs.length; index += 1)
                      _TodayLogRow(
                        log: visibleLogs[index],
                        isLast: index == visibleLogs.length - 1,
                        typography: typography,
                        surface: surface,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ReminderDeliveryLogPanel extends StatelessWidget {
  const _ReminderDeliveryLogPanel({
    required this.logs,
    required this.typography,
    required this.surface,
  });

  final List<ReminderDeliveryItem> logs;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final visibleLogs = logs.take(5).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacingTokens.xs),
          child: Text(
            l10n.medicineReminderDeliveryLogsTitle,
            style: typography.bodyMdStrong.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        MedicinePanel(
          padding: EdgeInsets.zero,
          child: visibleLogs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacingTokens.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: surface.mute,
                        size: AppSpacingTokens.lg,
                      ),
                      const SizedBox(width: AppSpacingTokens.sm),
                      Expanded(
                        child: Text(
                          l10n.medicineReminderNoDeliveryLogs,
                          style: typography.bodySm.copyWith(
                            color: surface.body,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    for (var index = 0; index < visibleLogs.length; index += 1)
                      _DeliveryLogRow(
                        log: visibleLogs[index],
                        isLast: index == visibleLogs.length - 1,
                        typography: typography,
                        surface: surface,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _DeliveryLogRow extends StatelessWidget {
  const _DeliveryLogRow({
    required this.log,
    required this.isLast,
    required this.typography,
    required this.surface,
  });

  final ReminderDeliveryItem log;
  final bool isLast;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _deliveryStatusColor(log.status, surface);
    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          Icon(_deliveryStatusIcon(log.status), color: color, size: 18),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateTimeShortLabel(l10n, log.scheduledFor),
                  style: typography.bodySmStrong.copyWith(letterSpacing: 0),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  _deliveryChannelLabel(l10n, log.channel),
                  style: typography.caption.copyWith(
                    color: surface.mute,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          MedicineStatusPill(
            label: _deliveryStatusLabel(l10n, log.status),
            color: color,
          ),
        ],
      ),
    );
    if (isLast) return row;
    return Column(
      children: [
        row,
        Divider(
          height: 1,
          thickness: 1,
          indent: AppSpacingTokens.md + AppSpacingTokens.lg,
          color: surface.hairline,
        ),
      ],
    );
  }
}

class _TodayLogRow extends StatelessWidget {
  const _TodayLogRow({
    required this.log,
    required this.isLast,
    required this.typography,
    required this.surface,
  });

  final DoseLogItem log;
  final bool isLast;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = switch (log.status) {
      DoseLogStatus.taken => MedicinePalette.teal,
      DoseLogStatus.skipped => MedicinePalette.orangeDeep,
      DoseLogStatus.missed => MedicinePalette.red,
      DoseLogStatus.planned => MedicinePalette.blue,
    };
    final label = switch (log.status) {
      DoseLogStatus.taken => l10n.medicineDoseStatusTaken,
      DoseLogStatus.skipped => l10n.medicineDoseStatusSkipped,
      DoseLogStatus.missed => l10n.medicineReminderMissedStatus,
      DoseLogStatus.planned => l10n.medicineRecordScheduledStatus,
    };

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, color: color, size: 18),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Text(
              _dateTimeTimeLabel(log.scheduledFor),
              style: typography.bodySm.copyWith(
                color: surface.body,
                letterSpacing: 0,
              ),
            ),
          ),
          MedicineStatusPill(label: label, color: color),
        ],
      ),
    );
    if (isLast) return row;
    return Column(
      children: [
        row,
        Divider(
          height: 1,
          thickness: 1,
          indent: AppSpacingTokens.md + AppSpacingTokens.lg,
          color: surface.hairline,
        ),
      ],
    );
  }
}

class _SelectedMedicineRow extends StatelessWidget {
  const _SelectedMedicineRow({
    required this.medicine,
    required this.typography,
    required this.surface,
  });

  final CurrentMedicineItem medicine;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Row(
        children: [
          const MedicineIconBadge(
            icon: Icons.medication_rounded,
            color: MedicinePalette.teal,
            shape: BoxShape.circle,
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.displayName,
                  style: typography.bodyMdStrong.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  _medicineDoseText(l10n, medicine),
                  style: typography.bodySm.copyWith(
                    color: surface.body,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FrequencySegments extends StatelessWidget {
  const _FrequencySegments({required this.frequency, required this.onChanged});

  final _ReminderFrequency frequency;
  final ValueChanged<_ReminderFrequency> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SegmentedButton<_ReminderFrequency>(
      segments: [
        ButtonSegment(
          value: _ReminderFrequency.daily,
          label: Text(l10n.medicineReminderFrequencyDaily),
        ),
        ButtonSegment(
          value: _ReminderFrequency.weekly,
          label: Text(l10n.medicineReminderFrequencyWeekly),
        ),
        ButtonSegment(
          value: _ReminderFrequency.custom,
          label: Text(l10n.medicineReminderFrequencyCustom),
        ),
      ],
      selected: {frequency},
      showSelectedIcon: false,
      onSelectionChanged: (value) => onChanged(value.single),
    );
  }
}

class _WeekdayPicker extends StatelessWidget {
  const _WeekdayPicker({
    required this.selectedWeekdays,
    required this.onToggled,
  });

  final Set<int> selectedWeekdays;
  final ValueChanged<int> onToggled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = <int, String>{
      1: l10n.recordWeekdayMon,
      2: l10n.recordWeekdayTue,
      3: l10n.recordWeekdayWed,
      4: l10n.recordWeekdayThu,
      5: l10n.recordWeekdayFri,
      6: l10n.recordWeekdaySat,
      0: l10n.recordWeekdaySun,
    };

    return Wrap(
      spacing: AppSpacingTokens.xs,
      runSpacing: AppSpacingTokens.xs,
      children: labels.entries
          .map(
            (entry) => FilterChip(
              label: Text(entry.value),
              selected: selectedWeekdays.contains(entry.key),
              onSelected: (_) => onToggled(entry.key),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _TimePickerRow extends StatelessWidget {
  const _TimePickerRow({
    required this.times,
    required this.onAddTime,
    required this.onRemoveTime,
  });

  final List<MedicineReminderTimeInput> times;
  final VoidCallback onAddTime;
  final ValueChanged<int> onRemoveTime;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.medicineReminderTimesLabel,
          style: AppTypographyTokens.mobile(
            Theme.of(context).colorScheme.onSurface,
          ).bodySmStrong.copyWith(letterSpacing: 0),
        ),
        const SizedBox(height: AppSpacingTokens.sm),
        Wrap(
          spacing: AppSpacingTokens.xs,
          runSpacing: AppSpacingTokens.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var index = 0; index < times.length; index += 1)
              InputChip(
                key: Key('medicine-reminder-time-$index'),
                label: Text(times[index].label),
                avatar: const Icon(Icons.schedule_rounded, size: 16),
                onDeleted: times.length > 1 ? () => onRemoveTime(index) : null,
              ),
            ActionChip(
              key: const Key('medicine-reminder-add-time'),
              avatar: const Icon(Icons.add_rounded, size: 16),
              label: Text(l10n.medicineReminderAddTimeAction),
              onPressed: onAddTime,
            ),
          ],
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.typography,
    required this.surface,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: surface.body,
            size: AppSpacingTokens.lg,
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.bodyMdStrong.copyWith(letterSpacing: 0),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  subtitle,
                  style: typography.bodySm.copyWith(
                    color: surface.mute,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ReminderLoading extends StatelessWidget {
  const _ReminderLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
      child: AppInlineSkeletonSection(
        children: [
          AppInlineSkeletonBlock(height: 86),
          AppInlineSkeletonBlock(height: 216),
          AppInlineSkeletonBlock(height: 116),
          AppInlineSkeletonBlock(height: 52),
        ],
      ),
    );
  }
}

Future<bool?> showMedicineReminderDeleteSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  final typography = AppTypographyTokens.mobile(theme.colorScheme.onSurface);

  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacingTokens.md,
            0,
            AppSpacingTokens.md,
            AppSpacingTokens.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: MedicinePalette.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(
                    dimension: AppSpacingTokens.x3l,
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: MedicinePalette.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacingTokens.md),
              Text(
                l10n.medicineReminderDeleteConfirmTitle,
                textAlign: TextAlign.center,
                style: typography.displaySm.copyWith(letterSpacing: 0),
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                l10n.medicineReminderDeleteConfirmBody,
                textAlign: TextAlign.center,
                style: typography.bodySm.copyWith(
                  color: Theme.of(context).extension<AppThemeSurface>()!.body,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              FilledButton(
                key: const Key('medicine-reminder-delete-confirm-button'),
                style: FilledButton.styleFrom(
                  backgroundColor: MedicinePalette.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadiusTokens.md),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacingTokens.md,
                  ),
                ),
                onPressed: () => Navigator.of(sheetContext).pop(true),
                child: Text(l10n.medicineReminderConfirmDeleteAction),
              ),
              const SizedBox(height: AppSpacingTokens.sm),
              OutlinedButton(
                onPressed: () => Navigator.of(sheetContext).pop(false),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadiusTokens.md),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacingTokens.md,
                  ),
                ),
                child: Text(l10n.medicineReminderCancelAction),
              ),
            ],
          ),
        ),
      );
    },
  );
}

enum _ReminderFrequency { daily, weekly, custom }

List<MedicineReminderItem> _remindersFor(
  List<MedicineReminderItem> reminders,
  String currentMedicineId,
) {
  return reminders
      .where((item) => item.currentMedicineId == currentMedicineId)
      .toList(growable: false)
    ..sort(_compareReminderTime);
}

int _compareReminderTime(
  MedicineReminderItem left,
  MedicineReminderItem right,
) {
  final hour = left.scheduledHour.compareTo(right.scheduledHour);
  if (hour != 0) return hour;
  return left.scheduledMinute.compareTo(right.scheduledMinute);
}

String _medicineDoseText(AppLocalizations l10n, CurrentMedicineItem medicine) {
  final text = [
    medicine.strengthText,
    medicine.doseText,
  ].whereType<String>().where((item) => item.trim().isNotEmpty).join(' · ');
  return text.isEmpty ? l10n.medicineDoseNotSet : text;
}

String _frequencyLabel(
  AppLocalizations l10n,
  List<MedicineReminderItem> reminders,
) {
  if (reminders.isEmpty) return l10n.medicineScheduleNotSet;
  final days = reminders.first.daysOfWeek;
  if (days == null) return l10n.medicineReminderFrequencyDaily;
  if (days.length == 1) {
    return '${l10n.medicineReminderFrequencyWeekly} · ${_weekdayLabel(l10n, days.single)}';
  }
  return '${l10n.medicineReminderFrequencyCustom} · ${days.map((day) => _weekdayLabel(l10n, day)).join(' ')}';
}

String _weekdayLabel(AppLocalizations l10n, int day) {
  return switch (day) {
    0 => l10n.recordWeekdaySun,
    1 => l10n.recordWeekdayMon,
    2 => l10n.recordWeekdayTue,
    3 => l10n.recordWeekdayWed,
    4 => l10n.recordWeekdayThu,
    5 => l10n.recordWeekdayFri,
    6 => l10n.recordWeekdaySat,
    _ => '$day',
  };
}

String _dateLabel(AppLocalizations l10n, DateTime? value) {
  if (value == null) return l10n.medicineReminderDateNotSet;
  return _formatDateInput(value);
}

String _soundPreferenceLabel(
  AppLocalizations l10n,
  MedicineReminderSoundPreference value,
) {
  return switch (value) {
    MedicineReminderSoundPreference.defaultTone =>
      l10n.medicineReminderSoundDefault,
    MedicineReminderSoundPreference.gentle => l10n.medicineReminderSoundGentle,
    MedicineReminderSoundPreference.silent => l10n.medicineReminderSoundSilent,
  };
}

String _deliveryChannelLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'local' => l10n.medicineReminderDeliveryChannelLocal,
    'push' => l10n.medicineReminderDeliveryChannelPush,
    'email' => l10n.medicineReminderDeliveryChannelEmail,
    'sms' => l10n.medicineReminderDeliveryChannelSms,
    _ => value,
  };
}

String _deliveryStatusLabel(AppLocalizations l10n, String value) {
  return switch (value) {
    'scheduled' => l10n.medicineReminderDeliveryStatusScheduled,
    'delivered' => l10n.medicineReminderDeliveryStatusDelivered,
    'failed' => l10n.medicineReminderDeliveryStatusFailed,
    _ => value,
  };
}

IconData _deliveryStatusIcon(String value) {
  return switch (value) {
    'delivered' => Icons.check_circle_outline_rounded,
    'failed' => Icons.error_outline_rounded,
    _ => Icons.schedule_rounded,
  };
}

Color _deliveryStatusColor(String value, AppThemeSurface surface) {
  return switch (value) {
    'delivered' => MedicinePalette.teal,
    'failed' => MedicinePalette.red,
    'scheduled' => MedicinePalette.orangeDeep,
    _ => surface.mute,
  };
}

String _dateTimeShortLabel(AppLocalizations l10n, String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  final now = DateTime.now();
  final date = _dateOnly(parsed);
  final today = _dateOnly(now);
  final datePrefix = date == today
      ? l10n.recordTodayAction
      : _formatDateInput(parsed);
  return '$datePrefix ${_dateTimeTimeLabel(value)}';
}

String _dateTimeTimeLabel(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime? _parseDateOnly(String? value) {
  if (value == null || value.isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return null;
  return _dateOnly(parsed);
}

String _formatDateInput(DateTime? value) {
  if (value == null) return '';
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String? _trimmedOrNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
