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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.level4),
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
                      horizontal: AppSpacingTokens.level4,
                      vertical: AppSpacingTokens.level3,
                    ),
                    child: FSelect<String>.rich(
                      label: Text(l10n.medicineReminderMedicineLabel),
                      hint: l10n.medicineReminderMedicineLabel,
                      format: (value) => medicines
                          .firstWhere((m) => m.id == value)
                          .displayName,
                      control: FSelectControl.lifted(
                        value: selectedMedicineId,
                        onChange: (value) => onMedicineChanged?.call(value),
                      ),
                      children: medicines
                          .map(
                            (item) => FSelectItem.item(
                              title: Text(item.displayName),
                              value: item.id,
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.level4),
          _FormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(label: l10n.medicineReminderSettingsSectionTitle),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacingTokens.level4,
                    vertical: AppSpacingTokens.level3,
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
                      horizontal: AppSpacingTokens.level4,
                      vertical: AppSpacingTokens.level3,
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
                    horizontal: AppSpacingTokens.level4,
                    vertical: AppSpacingTokens.level3,
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
          const SizedBox(height: AppSpacingTokens.level4),
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
          const SizedBox(height: AppSpacingTokens.level4),
          _FormCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacingTokens.level4),
              child: FTextField(
                control: FTextFieldControl.managed(controller: noteController),
                label: Text(l10n.medicineReminderNoteOptionalLabel),
                hint: l10n.medicineReminderNoteHint,
                maxLength: 100,
                maxLines: 3,
              ),
            ),
          ),
          const SizedBox(height: AppSpacingTokens.level5),
          FButton(
            key: const Key('medicine-reminder-save-button'),
            onPress: isSaving ? null : onSave,
            child: Text(l10n.mineEditSaveAction),
          ),
          if (onDelete != null) ...[
            const SizedBox(height: AppSpacingTokens.level3),
            FButton(
              key: const Key('medicine-reminder-form-delete-button'),
              variant: FButtonVariant.destructive,
              onPress: isSaving ? null : onDelete,
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
        AppSpacingTokens.level4,
        AppSpacingTokens.level4,
        AppSpacingTokens.level4,
        AppSpacingTokens.level3,
      ),
      child: Text(
        label,
        style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
