import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/record/domain/entities/record_dashboard.dart';
import 'package:luminous/features/record/presentation/widgets/record_components.dart';
import 'package:luminous/features/record/presentation/widgets/record_copy.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RecordMonthCalendarPanel extends StatelessWidget {
  const RecordMonthCalendarPanel({
    super.key,
    required this.days,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<RecordCalendarDay> days;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final weekdayKeys = const <RecordCopyKey>[
      RecordCopyKey.weekdaySun,
      RecordCopyKey.weekdayMon,
      RecordCopyKey.weekdayTue,
      RecordCopyKey.weekdayWed,
      RecordCopyKey.weekdayThu,
      RecordCopyKey.weekdayFri,
      RecordCopyKey.weekdaySat,
    ];

    return RecordSectionSurface(
      key: const Key('record-calendar-panel'),
      typography: typography,
      surface: surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.recordMonthLabel,
                  style: typography.bodyMdStrong,
                ),
              ),
              _CalendarIconButton(
                icon: Icons.chevron_left_rounded,
                label: l10n.recordPreviousDayAction,
              ),
              _CalendarIconButton(
                icon: Icons.chevron_right_rounded,
                label: l10n.recordNextDayAction,
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.md),
          Row(
            children: weekdayKeys
                .map(
                  (key) => Expanded(
                    child: Text(
                      recordCopy(l10n, key),
                      textAlign: TextAlign.center,
                      style: typography.caption.copyWith(color: surface.body),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.86,
              mainAxisSpacing: AppSpacingTokens.xs,
              crossAxisSpacing: AppSpacingTokens.xs,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) => _MonthDayCell(
              day: days[index],
              typography: typography,
              surface: surface,
              l10n: l10n,
            ),
          ),
        ],
      ),
    );
  }
}

class RecordFilterPanel extends StatelessWidget {
  const RecordFilterPanel({
    super.key,
    required this.filters,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final List<RecordFilter> filters;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    return RecordSectionSurface(
      key: const Key('record-filter-panel'),
      title: l10n.recordFilterSectionTitle,
      trailing: RecordTextAction(
        label: l10n.recordFilterSelectAll,
        typography: typography,
        surface: surface,
        onTap: () => showRecordToast(context, l10n.recordFilterSelectAll),
      ),
      typography: typography,
      surface: surface,
      child: Column(
        children: filters
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacingTokens.sm),
                child: _FilterRow(
                  filter: filter,
                  l10n: l10n,
                  typography: typography,
                  surface: surface,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MonthDayCell extends StatelessWidget {
  const _MonthDayCell({
    required this.day,
    required this.typography,
    required this.surface,
    required this.l10n,
  });

  final RecordCalendarDay day;
  final AppTypographyScale typography;
  final AppThemeSurface surface;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF159B55);
    final color = day.inMonth
        ? Theme.of(context).colorScheme.onSurface
        : surface.mute;
    final markerColors = day.hasAlert
        ? [...day.markers, const Color(0xFFFF4D57)]
        : day.markers;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            showRecordToast(context, '${l10n.recordOpenDateAction} ${day.day}'),
        borderRadius: BorderRadius.circular(AppRadiusTokens.pill),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.square(
              dimension: 24,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: day.selected ? accent : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: typography.caption.copyWith(
                      color: day.selected ? Colors.white : color,
                      fontWeight: day.selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: markerColors
                      .take(3)
                      .map(
                        (marker) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: marker,
                              shape: BoxShape.circle,
                            ),
                            child: const SizedBox.square(dimension: 3),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filter,
    required this.l10n,
    required this.typography,
    required this.surface,
  });

  final RecordFilter filter;
  final AppLocalizations l10n;
  final AppTypographyScale typography;
  final AppThemeSurface surface;

  @override
  Widget build(BuildContext context) {
    final label = recordCopy(l10n, filter.titleKey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showRecordToast(context, label),
        borderRadius: BorderRadius.circular(AppRadiusTokens.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacingTokens.xs),
          child: Row(
            children: [
              Icon(
                filter.selected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                color: filter.selected ? const Color(0xFF159B55) : surface.mute,
                size: 18,
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Icon(filter.icon, color: filter.accent, size: 18),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Text(
                  label,
                  style: typography.bodySmStrong,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (filter.locked)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: surface.canvasSoft2,
                    borderRadius: BorderRadius.circular(AppRadiusTokens.sm),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacingTokens.sm,
                      vertical: AppSpacingTokens.xs,
                    ),
                    child: Text(
                      l10n.recordNotEnabledLabel,
                      style: typography.caption.copyWith(color: surface.body),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarIconButton extends StatelessWidget {
  const _CalendarIconButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: label,
      visualDensity: VisualDensity.compact,
      onPressed: () => showRecordToast(context, label),
      icon: Icon(icon, size: 18),
    );
  }
}
