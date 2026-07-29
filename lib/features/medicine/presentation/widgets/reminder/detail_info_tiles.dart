import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/features/medicine/data/datasources/reminder_remote.dart';
import 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';
import 'package:luminous/features/medicine/presentation/providers/reminders.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';
import 'package:luminous/features/settings/presentation/widgets/shared/subpage_tile_group_style.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// Detail info tile group for a reminder — shows frequency, times, dose,
/// dates, notification method, SMS, sound, and note.
class ReminderDetailInfoTiles extends StatelessWidget {
  const ReminderDetailInfoTiles({
    super.key,
    required this.l10n,
    required this.data,
    required this.reminders,
    required this.soundPreference,
    required this.hasNote,
  });

  final AppLocalizations l10n;
  final MedicineReminderDetailData data;
  final List<MedicineReminderItem> reminders;
  final MedicineReminderSoundPreference soundPreference;
  final bool hasNote;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final firstReminder = reminders.firstOrNull;

    return FTileGroup(
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
            reminders.any((item) => item.isActive)
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
    );
  }
}
