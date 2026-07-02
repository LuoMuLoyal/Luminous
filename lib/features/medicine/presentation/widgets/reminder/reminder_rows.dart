import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/widgets/common/app_icon_badge.dart';
import 'package:luminous/core/widgets/common/app_ink_well.dart';
import 'package:luminous/core/widgets/common/app_status_pill.dart';
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
    this.showDivider = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    final row = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.mutedForeground, size: AppSpacingTokens.lg),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: textTheme.bodySmall?.copyWith(
                color: colors.mutedForeground,
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
          color: colors.border,
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
    this.onClear,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return AppInkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.md,
          vertical: AppSpacingTokens.sm,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: colors.mutedForeground,
              size: AppSpacingTokens.lg,
            ),
            const SizedBox(width: AppSpacingTokens.md),
            Expanded(
              child: Text(
                title,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacingTokens.sm),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.mutedForeground,
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
                icon: const Icon(FLucideIcons.x, size: 18),
              ),
            ] else ...[
              const SizedBox(width: AppSpacingTokens.xs),
              Icon(
                FLucideIcons.chevronRight,
                color: colors.mutedForeground,
                size: AppSpacingTokens.lg,
              ),
            ],
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
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          Icon(
            FLucideIcons.bellRing,
            color: colors.mutedForeground,
            size: AppSpacingTokens.lg,
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.mutedForeground,
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.mutedForeground, size: AppSpacingTokens.lg),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          AppStatusPill(label: status, color: colors.mutedForeground),
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
  });

  final MedicineReminderSoundPreference value;
  final ValueChanged<MedicineReminderSoundPreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.md,
        vertical: AppSpacingTokens.sm,
      ),
      child: Row(
        children: [
          Icon(
            FLucideIcons.volume2,
            color: colors.mutedForeground,
            size: AppSpacingTokens.lg,
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.medicineReminderSoundLabel,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  l10n.medicineReminderSoundLocalHint,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.mutedForeground,
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
  const SelectedMedicineRow({super.key, required this.medicine});

  final CurrentMedicineItem medicine;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(AppSpacingTokens.md),
      child: Row(
        children: [
          const AppIconBadge(
            icon: FLucideIcons.pill,
            color: AppColorTokens.cyanDeep,
            shape: BoxShape.circle,
          ),
          const SizedBox(width: AppSpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.displayName,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  medicineDoseText(l10n, medicine),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.mutedForeground,
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
