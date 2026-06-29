import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/app_section_surface.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/record_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordWeekStrip extends StatelessWidget {
  const RecordWeekStrip({
    super.key,
    required this.days,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onDateSelected,
  });

  final List<RecordWeekDay> days;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  Widget build(BuildContext context) {
    return AppSectionSurface(
      typography: typography,
      surface: surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.sm,
        vertical: AppSpacingTokens.md,
      ),
      child: Row(
        children: days
            .map(
              (day) => Expanded(
                child: _WeekDayCell(
                  day: day,
                  l10n: l10n,
                  typography: typography,
                  surface: surface,
                  onTap: onDateSelected,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _WeekDayCell extends StatelessWidget {
  const _WeekDayCell({
    required this.day,
    required this.l10n,
    required this.typography,
    required this.surface,
    this.onTap,
  });

  final RecordWeekDay day;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final ValueChanged<DateTime>? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = surface.accent;
    final foreground = day.selected
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(day.date),
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.xs),
          child: Column(
            children: [
              Text(
                recordCopy(l10n, day.weekdayKey),
                style: typography.caption.copyWith(color: surface.body),
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: day.selected ? accent : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: 30,
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: typography.bodySmStrong.copyWith(
                        color: foreground,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              _MarkerDots(colors: day.markers, hasAlert: day.hasAlert),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarkerDots extends StatelessWidget {
  const _MarkerDots({required this.colors, required this.hasAlert});

  final List<Color> colors;
  final bool hasAlert;

  @override
  Widget build(BuildContext context) {
    final markerColors = hasAlert
        ? [...colors, const Color(0xFFFF4D57)]
        : colors;

    return SizedBox(
      height: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: markerColors
            .take(3)
            .map(
              (color) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox.square(dimension: 4),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
