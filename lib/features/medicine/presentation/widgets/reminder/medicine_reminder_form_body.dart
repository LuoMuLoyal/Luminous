import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_state_views.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/data/datasources/medicine_reminder_remote_data_source.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_reminder_providers.dart';
import 'package:luminous/features/medicine/presentation/utils/medicine_reminder_formatters.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/reminder_form_fields.dart';
import 'package:luminous/features/medicine/presentation/widgets/reminder/reminder_rows.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReminderFormBody extends StatelessWidget {
  const ReminderFormBody({
    super.key,
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
  final ReminderFrequency frequency;
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
  final ValueChanged<ReminderFrequency> onFrequencyChanged;
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
    final colors = context.theme.colors;
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
        icon: FLucideIcons.pill,
        actionLabel: l10n.medicineQuickAddTitle,
        onAction: () => context.push('/medicine/search'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(label: l10n.medicineReminderMedicineSectionTitle),
                Divider(height: 1, thickness: 1, color: colors.border),
                if (isEdit && selectedMedicine != null)
                  SelectedMedicineRow(medicine: selectedMedicine)
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
          _FormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(label: l10n.medicineReminderSettingsSectionTitle),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.md,
                    vertical: AppSpacingTokens.sm,
                  ),
                  child: FrequencySegments(
                    frequency: frequency,
                    onChanged: onFrequencyChanged,
                  ),
                ),
                if (frequency != ReminderFrequency.daily) ...[
                  Divider(height: 1, thickness: 1, color: colors.border),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacingTokens.md,
                      vertical: AppSpacingTokens.sm,
                    ),
                    child: WeekdayPicker(
                      selectedWeekdays: selectedWeekdays,
                      onToggled: onWeekdayToggled,
                    ),
                  ),
                ],
                Divider(height: 1, thickness: 1, color: colors.border),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.md,
                    vertical: AppSpacingTokens.sm,
                  ),
                  child: TimePickerRow(
                    times: times,
                    onAddTime: onAddTime,
                    onRemoveTime: onRemoveTime,
                  ),
                ),
                Divider(height: 1, thickness: 1, color: colors.border),
                ValueActionRow(
                  icon: FLucideIcons.calendar,
                  title: l10n.medicineReminderStartDateLabel,
                  value: dateLabel(l10n, startDate),
                  onTap: onStartDateTap,
                ),
                Divider(height: 1, thickness: 1, color: colors.border),
                ValueActionRow(
                  icon: FLucideIcons.calendarX2,
                  title: l10n.medicineReminderEndDateLabel,
                  value: dateLabel(l10n, endDate),
                  onTap: onEndDateTap,
                  onClear: onClearEndDate,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          _FormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(label: l10n.medicineReminderMethodLabel),
                SwitchRow(
                  title: l10n.medicineReminderNotificationOn,
                  subtitle: l10n.medicineReminderDeviceLocalHint,
                  value: isActive,
                  onChanged: onActiveChanged,
                ),
                Divider(height: 1, thickness: 1, color: colors.border),
                UnavailableMethodRow(
                  icon: FLucideIcons.messageSquare,
                  title: l10n.medicineReminderSmsLabel,
                  subtitle: l10n.medicineReminderSmsUnavailableHint,
                  status: l10n.medicineReminderUnavailableStatus,
                ),
                Divider(height: 1, thickness: 1, color: colors.border),
                SoundPreferenceRow(
                  value: soundPreference,
                  onChanged: onSoundChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          _FormCard(
            child: Padding(
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
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          FButton(
            key: const Key('medicine-reminder-save-button'),
            onPress: isSaving ? null : onSave,
            child: Text(l10n.mineEditSaveAction),
          ),
          if (onDelete != null) ...[
            const SizedBox(height: AppSpacingTokens.sm),
            OutlinedButton(
              key: const Key('medicine-reminder-form-delete-button'),
              onPressed: isSaving ? null : onDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.destructive,
                side: BorderSide(color: colors.destructive),
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacingTokens.md,
                ),
              ),
              child: Text(l10n.medicineReminderDeleteAction),
            ),
          ],
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FCard.raw(child: child);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacingTokens.md,
        AppSpacingTokens.md,
        AppSpacingTokens.md,
        AppSpacingTokens.sm,
      ),
      child: Text(
        label,
        style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
