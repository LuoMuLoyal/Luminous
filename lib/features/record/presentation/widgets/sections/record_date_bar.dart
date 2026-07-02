import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_copy.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_dashboard_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordDateBar extends StatelessWidget {
  const RecordDateBar({
    super.key,
    required this.dashboard,
    required this.l10n,
    this.onDateSelected,
    this.onPickDate,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final ValueChanged<DateTime>? onDateSelected;
  final VoidCallback? onPickDate;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final dateLabel = l10n.recordDatePillLabel(
      dashboard.selectedDate.month,
      dashboard.selectedDate.day,
      recordCopy(l10n, weekdayKeyFromDate(dashboard.selectedDate)),
    );

    return Row(
      children: [
        _DateStepButton(
          key: const Key('record-date-previous-action'),
          icon: FLucideIcons.chevronLeft,
          onTap: onDateSelected == null
              ? null
              : () => onDateSelected!(
                  dashboard.selectedDate.subtract(const Duration(days: 1)),
                ),
        ),
        const SizedBox(width: AppSpacingTokens.level2),
        Expanded(
          child: FTappable(
            onPress: onPickDate,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(AppRadiusTokens.levelFull),
                border: Border.all(color: colors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.level4,
                  vertical: AppSpacingTokens.level3,
                ),
                child: Row(
                  children: [
                    Icon(
                      FLucideIcons.calendarDays,
                      color: colors.foreground,
                      size: AppSpacingTokens.level5,
                    ),
                    const SizedBox(width: AppSpacingTokens.level2),
                    Expanded(
                      child: Text(
                        dateLabel,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacingTokens.level2),
                    Icon(
                      FLucideIcons.chevronDown,
                      color: colors.mutedForeground,
                      size: AppSpacingTokens.level5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.level2),
        _DateStepButton(
          key: const Key('record-date-next-action'),
          icon: FLucideIcons.chevronRight,
          onTap: onDateSelected == null
              ? null
              : () => onDateSelected!(
                  dashboard.selectedDate.add(const Duration(days: 1)),
                ),
        ),
      ],
    );
  }
}

class _DateStepButton extends StatelessWidget {
  const _DateStepButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return FTappable(
      onPress: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(AppRadiusTokens.levelFull),
          border: Border.all(color: colors.border),
        ),
        child: SizedBox.square(
          dimension: 44,
          child: Icon(
            icon,
            color: colors.foreground,
            size: AppSpacingTokens.level5,
          ),
        ),
      ),
    );
  }
}
