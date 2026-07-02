import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/shared/record_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordWeekStrip extends StatelessWidget {
  const RecordWeekStrip({
    super.key,
    required this.days,
    required this.l10n,
    this.onDateSelected,
  });

  final List<RecordWeekDay> days;
  final AppLocalizations l10n;
  final ValueChanged<DateTime>? onDateSelected;

  @override
  Widget build(BuildContext context) {
    return FCard.raw(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.level3,
          vertical: AppSpacingTokens.level4,
        ),
        child: Row(
          children: days
              .map(
                (day) => Expanded(
                  child: _WeekDayCell(
                    day: day,
                    l10n: l10n,
                    onTap: onDateSelected,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _WeekDayCell extends StatelessWidget {
  const _WeekDayCell({required this.day, required this.l10n, this.onTap});

  final RecordWeekDay day;
  final AppLocalizations l10n;
  final ValueChanged<DateTime>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final textTheme = Theme.of(context).textTheme;
    final foreground = day.selected ? colors.background : colors.foreground;

    return FTappable(
      onPress: onTap == null ? null : () => onTap!(day.date),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.level2),
        child: Column(
          children: [
            Text(
              recordCopy(l10n, day.weekdayKey),
              style: textTheme.labelSmall?.copyWith(
                color: colors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacingTokens.level2),
            DecoratedBox(
              decoration: BoxDecoration(
                color: day.selected ? colors.foreground : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 30,
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacingTokens.level2),
            _MarkerDots(colors: day.markers, hasAlert: day.hasAlert),
          ],
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
