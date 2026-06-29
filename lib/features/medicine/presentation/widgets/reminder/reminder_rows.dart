import 'package:flutter/material.dart';
import 'package:luminous/core/widgets/common/app_status_pill.dart';
import 'package:luminous/core/widgets/common/app_icon_badge.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/health_context/domain/entities/health_context_snapshot.dart';
import 'package:luminous/features/medicine/presentation/providers/medicine_reminder_providers.dart';
import 'package:luminous/features/medicine/presentation/utils/medicine_reminder_formatters.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ReminderInfoRow extends StatelessWidget {
  const ReminderInfoRow({
    super.key,
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

class ValueActionRow extends StatelessWidget {
  const ValueActionRow({
    super.key,
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

class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
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

class UnavailableMethodRow extends StatelessWidget {
  const UnavailableMethodRow({
    super.key,
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
          AppStatusPill(label: status, color: surface.mute),
        ],
      ),
    );
  }
}

class SoundPreferenceRow extends StatelessWidget {
  const SoundPreferenceRow({
    super.key,
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
                      child: Text(soundPreferenceLabel(l10n, item)),
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

class SelectedMedicineRow extends StatelessWidget {
  const SelectedMedicineRow({
    super.key,
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
          AppIconBadge(
            icon: Icons.medication_rounded,
            color: surface.teal,
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
                  medicineDoseText(l10n, medicine),
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
