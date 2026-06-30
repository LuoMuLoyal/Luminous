import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/common/app_ink_well.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_copy.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_dashboard_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordDateBar extends StatelessWidget {
  const RecordDateBar({
    super.key,
    required this.dashboard,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onDateSelected,
    this.onPickDate,
  });

  final RecordDashboard dashboard;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<DateTime>? onDateSelected;
  final VoidCallback? onPickDate;

  @override
  Widget build(BuildContext context) {
    final dateLabel = l10n.recordDatePillLabel(
      dashboard.selectedDate.month,
      dashboard.selectedDate.day,
      recordCopy(l10n, weekdayKeyFromDate(dashboard.selectedDate)),
    );

    return Row(
      children: [
        _DateStepButton(
          key: const Key('record-date-previous-action'),
          icon: Icons.chevron_left_rounded,
          surface: surface,
          onTap: onDateSelected == null
              ? null
              : () => onDateSelected!(
                  dashboard.selectedDate.subtract(const Duration(days: 1)),
                ),
        ),
        const SizedBox(width: AppSpacingTokens.xs),
        Expanded(
          child: AppInkWell(
            onTap: onPickDate,
            borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: surface.canvas,
                borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
                border: Border.all(color: surface.hairline),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacingTokens.md,
                  vertical: AppSpacingTokens.sm,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: surface.body,
                      size: AppSpacingTokens.lg,
                    ),
                    const SizedBox(width: AppSpacingTokens.xs),
                    Expanded(
                      child: Text(
                        dateLabel,
                        style: typography.bodyMdStrong.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacingTokens.xs),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: surface.mute,
                      size: AppSpacingTokens.lg,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacingTokens.xs),
        _DateStepButton(
          key: const Key('record-date-next-action'),
          icon: Icons.chevron_right_rounded,
          surface: surface,
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
  const _DateStepButton({
    super.key,
    required this.icon,
    required this.surface,
    required this.onTap,
  });

  final IconData icon;
  final AppThemeSurface surface;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface.canvas,
          borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
          border: Border.all(color: surface.hairline),
        ),
        child: SizedBox.square(
          dimension: 44,
          child: Icon(icon, color: surface.body, size: AppSpacingTokens.lg),
        ),
      ),
    );
  }
}
