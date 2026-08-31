import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/design.dart';
import 'package:luminous/core/widgets/common/control/divider.dart';
import 'package:luminous/features/health_context/domain/entities/snapshot.dart';
import 'package:luminous/features/medicine/domain/entities/reminder_sound_preference.dart';
import 'package:luminous/features/medicine/presentation/utils/reminder_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReminderInfoRow extends StatelessWidget {
  const ReminderInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final tile = FTile(
      prefix: Icon(
        icon,
        color: SemanticColor.neutral.solid(context),
        size: Spacing.level5,
      ),
      title: Text(label),
      details: Text(
        value,
        textAlign: TextAlign.right,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: SemanticColor.neutral.solid(context)),
      ),
    );

    if (!showDivider) return tile;

    return Column(children: [tile, const AppDivider()]);
  }
}

class ValueActionRow extends StatelessWidget {
  const ValueActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    return FTappable(
      onPress: onTap,
      builder: (context, data, _) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level4,
          vertical: Spacing.level3,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: SemanticColor.neutral.solid(context),
              size: Spacing.level5,
            ),
            const SizedBox(width: Spacing.level4),
            Expanded(
              child: Text(
                title,
                style: typography.body.sm.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: Spacing.level3),
            Text(
              value,
              textAlign: TextAlign.right,
              style: typography.body.sm.copyWith(
                color: SemanticColor.neutral.solid(context),
              ),
            ),
            const SizedBox(width: Spacing.level2),
            onClear != null
                ? FButton.icon(
                    variant: FButtonVariant.ghost,
                    size: .sm,
                    onPress: onClear,
                    child: const Icon(
                      SemanticIcons.actionClose,
                      size: Spacing.level5,
                    ),
                  )
                : Icon(
                    SemanticIcons.actionNext,
                    color: SemanticColor.neutral.solid(context),
                    size: Spacing.level5,
                  ),
          ],
        ),
      ),
    );
  }
}

class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.level4,
        vertical: Spacing.level3,
      ),
      child: Row(
        children: [
          Icon(
            SemanticIcons.notificationBellRing,
            color: SemanticColor.neutral.solid(context),
            size: Spacing.level5,
          ),
          const SizedBox(width: Spacing.level4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  subtitle,
                  style: typography.body.sm.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ],
            ),
          ),
          FSwitch(value: value, onChange: onChanged),
        ],
      ),
    );
  }
}

class UnavailableMethodRow extends StatelessWidget {
  const UnavailableMethodRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;

  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;

    return Opacity(
      opacity: 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.level4,
          vertical: Spacing.level3,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: SemanticColor.neutral.solid(context),
              size: Spacing.level5,
            ),
            const SizedBox(width: Spacing.level4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typography.body.sm.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: typography.body.sm.copyWith(
                      color: SemanticColor.neutral.solid(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.level3),
            FBadge(variant: FBadgeVariant.secondary, child: Text(status)),
          ],
        ),
      ),
    );
  }
}

class SoundPreferenceRow extends StatelessWidget {
  const SoundPreferenceRow({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final MedicineReminderSoundPreference value;
  final ValueChanged<MedicineReminderSoundPreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.level4,
        vertical: Spacing.level3,
      ),
      child: Row(
        children: [
          Icon(
            SemanticIcons.doseVolume,
            color: SemanticColor.neutral.solid(context),
            size: Spacing.level5,
          ),
          const SizedBox(width: Spacing.level4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicineReminderSoundLabel,
                  style: typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  l10n.medicineReminderSoundLocalHint,
                  style: typography.body.sm.copyWith(
                    color: SemanticColor.neutral.solid(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.level3),
          Flexible(
            child: FSelect<MedicineReminderSoundPreference>(
              items: {
                for (final item in MedicineReminderSoundPreference.values)
                  soundPreferenceLabel(l10n, item): item,
              },
              control: FSelectControl.lifted(
                value: value,
                onChange: (next) {
                  if (next != null) onChanged(next);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectedMedicineRow extends StatelessWidget {
  const SelectedMedicineRow({super.key, required this.medicine});

  final CurrentMedicineItem medicine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typography = context.theme.typography;

    return Padding(
      padding: const EdgeInsets.all(Spacing.level4),
      child: Row(
        children: [
          FAvatar.raw(
            child: Icon(
              SemanticIcons.recordMedicine,
              color: SemanticColor.primary.solid(context),
            ),
          ),
          const SizedBox(width: Spacing.level4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.displayName,
                  style: typography.body.sm.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.level1),
                Text(
                  medicineDoseText(l10n, medicine),
                  style: typography.body.sm.copyWith(
                    color: SemanticColor.neutral.solid(context),
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
