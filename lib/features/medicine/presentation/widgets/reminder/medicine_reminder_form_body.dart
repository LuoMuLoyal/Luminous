import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_state_views.dart';
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
          AppSectionSurface(
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
                  SelectedMedicineRow(
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
          AppSectionSurface(
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
                  child: FrequencySegments(
                    frequency: frequency,
                    onChanged: onFrequencyChanged,
                  ),
                ),
                if (frequency != ReminderFrequency.daily) ...[
                  Divider(height: 1, thickness: 1, color: surface.hairline),
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
                Divider(height: 1, thickness: 1, color: surface.hairline),
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
                Divider(height: 1, thickness: 1, color: surface.hairline),
                ValueActionRow(
                  icon: Icons.calendar_today_rounded,
                  title: l10n.medicineReminderStartDateLabel,
                  value: dateLabel(l10n, startDate),
                  onTap: onStartDateTap,
                  typography: typography,
                  surface: surface,
                ),
                Divider(height: 1, thickness: 1, color: surface.hairline),
                ValueActionRow(
                  icon: Icons.event_busy_rounded,
                  title: l10n.medicineReminderEndDateLabel,
                  value: dateLabel(l10n, endDate),
                  onTap: onEndDateTap,
                  onClear: onClearEndDate,
                  typography: typography,
                  surface: surface,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AppSectionSurface(
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
                SwitchRow(
                  title: l10n.medicineReminderNotificationOn,
                  subtitle: l10n.medicineReminderDeviceLocalHint,
                  value: isActive,
                  onChanged: onActiveChanged,
                  typography: typography,
                  surface: surface,
                ),
                Divider(height: 1, thickness: 1, color: surface.hairline),
                UnavailableMethodRow(
                  icon: Icons.sms_outlined,
                  title: l10n.medicineReminderSmsLabel,
                  subtitle: l10n.medicineReminderSmsUnavailableHint,
                  status: l10n.medicineReminderUnavailableStatus,
                  typography: typography,
                  surface: surface,
                ),
                Divider(height: 1, thickness: 1, color: surface.hairline),
                SoundPreferenceRow(
                  value: soundPreference,
                  onChanged: onSoundChanged,
                  typography: typography,
                  surface: surface,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AppSectionSurface(
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
                backgroundColor: surface.error,
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
